import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/content_service.dart';

class JsonImporterView extends StatefulWidget {
  const JsonImporterView({super.key});

  @override
  State<JsonImporterView> createState() => _JsonImporterViewState();
}

class _JsonImporterViewState extends State<JsonImporterView> {
  final TextEditingController _jsonController = TextEditingController();
  final TextEditingController _targetReleaseIdController =
      TextEditingController();
  final TextEditingController _targetSubModuleIdController =
      TextEditingController();
  final ContentService _contentService = ContentService();

  bool _isLoading = false;
  String _importMode = 'full'; // 'full', 'submodule', 'context'

  // QC State
  bool _isValid = false;
  Map<String, dynamic>? _validatedData;
  String? _validationSummary; // Text summary for the preview card
  String? _errorMessage; // For Syntax/Schema errors

  // Reset all state when mode changes
  void _changeMode(String newMode) {
    setState(() {
      _importMode = newMode;
      _resetState();
    });
  }

  void _resetState() {
    _isValid = false;
    _validatedData = null;
    _validationSummary = null;
    _errorMessage = null;
    // We don't clear default text controllers to allow easy corrections
  }

  // --- PHASE 1: VALIDATION (The "Gatekeeper") ---
  void _validateInput() {
    setState(() {
      _isLoading = true;
      _resetState(); // Clear previous results
    });

    final inputContent = _jsonController.text.trim();
    if (inputContent.isEmpty) {
      _failValidation("Input content cannot be empty.");
      return;
    }

    try {
      // 1. SYNTAX GUARD
      if (_importMode == 'context') {
        // Context is raw string, so just check target IDs
        _validateContextMode(inputContent);
      } else {
        // Expecting JSON
        final decoded = jsonDecode(inputContent);

        // 2. SCHEMA GUARD
        if (_importMode == 'full') {
          _validateFullReleaseSchema(decoded);
        } else if (_importMode == 'submodule') {
          _validateSubModuleSchema(decoded);
        }
      }
    } on FormatException catch (e) {
      _failValidation("SYNTAX ERROR: Invalid JSON format.\n${e.message}");
    } catch (e) {
      _failValidation("VALIDATION ERROR: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _validateFullReleaseSchema(dynamic decoded) {
    if (decoded is! Map<String, dynamic>) {
      throw "JSON must be an Object {} for Full Release.";
    }

    // Check mandatory fields
    final requiredFields = ['id', 'title', 'version', 'modules'];
    for (var field in requiredFields) {
      if (!decoded.containsKey(field)) {
        throw "Missing required field: '$field'.";
      }
    }

    // Check sub_modules existence (implied by content structure)
    // We just check if 'modules' is list for preview summary
    final modules = decoded['modules'] as List?;
    final subModules = decoded['sub_modules'] as List?;

    _passValidation(
        decoded,
        "Title: ${decoded['title']}\n"
        "ID: ${decoded['id']}\n"
        "Version: ${decoded['version']}\n"
        "Modules: ${modules?.length ?? 0}\n"
        "SubModules: ${subModules?.length ?? 0}");
  }

  void _validateSubModuleSchema(dynamic decoded) {
    // Can be List or Map
    List items = [];
    if (decoded is Map<String, dynamic>) {
      items = [decoded];
    } else if (decoded is List) {
      items = decoded;
    } else {
      throw "JSON must be an Object {} or Array [] for SubModules.";
    }

    if (_targetReleaseIdController.text.isEmpty) {
      throw "Target Release ID is required for SubModule import.";
    }

    // Check items
    for (var item in items) {
      if (item is! Map<String, dynamic>) throw "Items must be Objects.";
      if (!item.containsKey('id')) throw "Item missing 'id'.";
      if (!item.containsKey('title')) {
        throw "Item '${item['id']}' missing 'title'.";
      }
    }

    _passValidation(
        decoded is List ? decoded : [decoded],
        "Action: Add/Update SubModules\n"
        "Target Release: ${_targetReleaseIdController.text}\n"
        "Item Count: ${items.length}\n"
        "IDs: ${items.map((e) => e['id']).take(3).join(', ')}${items.length > 3 ? '...' : ''}");
  }

  void _validateContextMode(String content) {
    if (_targetReleaseIdController.text.isEmpty ||
        _targetSubModuleIdController.text.isEmpty) {
      throw "Target Release ID and SubModule ID are required.";
    }

    // Payload construction for Service
    final payload = {
      'release_id': _targetReleaseIdController.text.trim(),
      'sub_module_id': _targetSubModuleIdController.text.trim(),
      'ai_context': content
    };

    _passValidation(
        payload,
        "Action: Update AI Context (RAG)\n"
        "Target Release: ${_targetReleaseIdController.text}\n"
        "Target SubModule: ${_targetSubModuleIdController.text}\n"
        "Context Length: ${content.length} characters");
  }

  void _failValidation(String message) {
    setState(() {
      _isValid = false;
      _errorMessage = message;
    });
  }

  void _passValidation(dynamic data, String summary) {
    setState(() {
      _isValid = true;
      _validatedData = data is Map<String, dynamic> ? data : {'data': data};
      // ^ Normalize list to map wrapper if needed, though for full/context it's already map
      // For submodule list, we might wrap it. Let's handle generic 'data' passing carefully
      if (_importMode == 'submodule' && data is List) {
        _validatedData = {'items': data};
      }

      _validationSummary = summary;
    });
  }

  // --- PHASE 2: UPLOAD (Execution) ---
  Future<void> _handleUpload() async {
    if (!_isValid || _validatedData == null) return;

    setState(() => _isLoading = true);

    try {
      if (_importMode == 'full') {
        await _contentService.importRelease(_validatedData!);
      } else if (_importMode == 'context') {
        await _contentService.updateSubModuleContext(_validatedData!);
      } else if (_importMode == 'submodule') {
        // Extract list back from wrapper
        final payload = _validatedData!['items'] ?? _validatedData!;
        await _contentService.addSubModules(
            _targetReleaseIdController.text.trim(), payload);
      }

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('SUCCESS: Data uploaded to Cloud! ☁️'),
            backgroundColor: Colors.green),
      );

      // Optional: Clear form after success?
      // _jsonController.clear();
      // _resetState();
    } catch (e) {
      setState(() => _errorMessage = "UPLOAD ERROR: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // MODE SELECTOR
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'full', label: Text('Release')),
              ButtonSegment(value: 'submodule', label: Text('Sub-Modules')),
              ButtonSegment(value: 'context', label: Text('Context (RAG)')),
            ],
            selected: {_importMode},
            onSelectionChanged: (Set<String> newSelection) =>
                _changeMode(newSelection.first),
          ),
          const SizedBox(height: 16),

          // TARGET INPUTS
          if (_importMode != 'full') ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _targetReleaseIdController,
                    decoration: const InputDecoration(
                        labelText: 'Release ID (e.g. sejarah_01)',
                        border: OutlineInputBorder()),
                  ),
                ),
                if (_importMode == 'context') ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _targetSubModuleIdController,
                      decoration: const InputDecoration(
                          labelText: 'SubModule ID',
                          border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
          ],

          // MAIN INPUT AREA
          const Text("Paste Content Here:",
              style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: TextField(
              controller: _jsonController,
              maxLines: null,
              style: GoogleFonts.firaCode(fontSize: 12),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: _isValid
                    ? Colors.green.withAlpha(0x0D)
                    : (_errorMessage != null
                        ? Colors.red.withAlpha(0x0D)
                        : Colors.grey[50]),
                hintText: _importMode == 'context'
                    ? 'Paste Raw Text...'
                    : 'Paste JSON...',
              ),
              onChanged: (_) {
                if (_isValid || _errorMessage != null) {
                  _resetState(); // Auto-reset validation status on edit
                }
              },
            ),
          ),
          const SizedBox(height: 16),

          // STATUS AREA (ERROR OR PREVIEW)
          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.red[100],
              child: SelectableText(_errorMessage!,
                  style: const TextStyle(color: Colors.red)),
            ),

          if (_isValid && _validationSummary != null)
            Card(
              color: Colors.green[50], // Light green for "Good to Go"
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text("VALID DATA - READY TO UPLOAD",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green)),
                    ]),
                    const Divider(),
                    Text(_validationSummary!,
                        style: const TextStyle(
                            fontFamily: 'Courier', fontSize: 12)),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // ACTION BUTTONS
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isValid
                      ? null
                      : _validateInput, // Disable if already valid
                  icon: const Icon(Icons.rule),
                  label: const Text("1. VALIDATE SYNTAX"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    // Highlighting this button primarily
                    backgroundColor: !_isValid ? Colors.blue[50] : null,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: (_isValid && !_isLoading) ? _handleUpload : null,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.cloud_upload),
                  label: const Text("2. UPLOAD TO CLOUD"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
