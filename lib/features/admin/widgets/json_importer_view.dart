import 'dart:convert';
import 'package:flutter/material.dart';
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
  final ContentService _contentService = ContentService();

  bool _isLoading = false;
  String _importMode = 'full'; // 'full' or 'submodule'
  String? _statusMessage;
  Color _statusColor = Colors.black;

  Future<void> _handleImport() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    final jsonString = _jsonController.text.trim();
    if (jsonString.isEmpty) {
      _showError('Please enter JSON data.');
      return;
    }

    try {
      final decoded = jsonDecode(jsonString);

      if (_importMode == 'full') {
        // Full Release Import
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException(
              'For Full Release, JSON must be an object (Map).');
        }
        await _contentService.importRelease(decoded);
        _showSuccess('Success! Release imported.');
      } else {
        // Sub-Module Import
        final targetId = _targetReleaseIdController.text.trim();
        if (targetId.isEmpty) {
          _showError('Please enter Target Release ID.');
          return; // Stop here, isLoading will be reset in finally
        }

        await _contentService.addSubModules(targetId, decoded);
        _showSuccess('Success! Sub-modules added/updated.');
      }

      _jsonController.clear();
      // Keep target ID in case they want to add more to same release
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _statusMessage = message;
      _statusColor = Colors.red;
    });
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    setState(() {
      _statusMessage = message;
      _statusColor = Colors.green;
    });
  }

  @override
  void dispose() {
    _jsonController.dispose();
    _targetReleaseIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Import Release JSON',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // Mode Selection
          // Mode Selection
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Mode:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'full', label: Text('Full Release')),
                    ButtonSegment(
                        value: 'submodule',
                        label: Text('Append/Update Sub-Modules')),
                  ],
                  selected: {_importMode},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      _importMode = newSelection.first;
                      _statusMessage = null;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Target Release ID (Only for SubModule mode)
          if (_importMode == 'submodule') ...[
            const Text(
              'Target Release ID',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _targetReleaseIdController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'e.g., sejarah_01',
                isDense: true,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'JSON Payload (List of SubModules or Single SubModule Object)',
              style: TextStyle(color: Colors.grey),
            ),
          ] else
            const Text(
              'Paste the full Release object JSON from the Masterplan V5 schema here.',
              style: TextStyle(color: Colors.grey),
            ),

          const SizedBox(height: 8),
          Expanded(
            child: TextField(
              controller: _jsonController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: _importMode == 'full'
                    ? '{\n  "release_id": "...",\n  ...\n}'
                    : '[\n  {\n    "id": "sub_xx",\n    ...\n  }\n]',
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
              ),
              style: const TextStyle(fontFamily: 'Courier', fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),
          if (_statusMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              color: _statusColor.withValues(alpha: 0.1),
              child: Text(
                _statusMessage!,
                style:
                    TextStyle(color: _statusColor, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
          ],
          ElevatedButton(
            onPressed: _isLoading ? null : _handleImport,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text('IMPORT JSON'),
          ),
        ],
      ),
    );
  }
}
