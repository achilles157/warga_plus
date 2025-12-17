import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/models/release_model.dart';
import '../widgets/reader_widgets.dart';
import '../../profile/services/profile_service.dart';

class ChatStreamScreen extends StatefulWidget {
  final SubModule subModule;

  const ChatStreamScreen({super.key, required this.subModule});

  @override
  State<ChatStreamScreen> createState() => _ChatStreamScreenState();
}

class _ChatStreamScreenState extends State<ChatStreamScreen> {
  // Store the list of visible messages.
  final List<dynamic> _visibleScript = [];
  int _currentIndex = 0;
  final ScrollController _scrollController = ScrollController();
  List<dynamic> get _fullScript => widget.subModule.chatScript ?? [];
  bool _isTyping = false;

  // Track the unique key of the current typing item to force rebuilds if needed
  Key _currentBubbleKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _advanceScript(); // Show first message immediately
  }

  void _advanceScript() {
    if (_currentIndex >= _fullScript.length) return;

    final nextItem = _fullScript[_currentIndex];

    // Check role of next item
    final role = nextItem['role'];

    // Calculate typing duration to auto-finish state
    int typingDurationMs = 0;
    if (role == 'ai') {
      final text = nextItem['text'] as String? ?? '';
      typingDurationMs =
          (text.length * 30).clamp(500, 3000) + 300; // Add buffer
    }

    setState(() {
      _visibleScript.add(nextItem);
      _currentIndex++;
      _isTyping = role == 'ai';
      _currentBubbleKey = UniqueKey();
    });

    // Auto-scroll to bottom immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    // If it's AI, we start a timer to automatically unset _isTyping if user doesn't tap
    if (role == 'ai') {
      Future.delayed(Duration(milliseconds: typingDurationMs), () {
        if (mounted && _isTyping) {
          setState(() {
            _isTyping = false;
          });
        }
      });

      if (_isTyping) {
        _startTypingScroll();
      }
    }
  }

  void _startTypingScroll() async {
    while (_isTyping && mounted) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (_isTyping && mounted) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent +
              50, // Gentle nudge to keep revealing
          duration: const Duration(milliseconds: 300),
          curve: Curves.linear,
        );
      }
    }
    // Final scroll to ensure bottom
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 200, // Overshoot slightly
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleTap() {
    if (_isTyping) {
      // User tapped while typing -> Skip animation
      setState(() {
        _isTyping = false;
        // This rebuilds widgets. The last ChatBubble will see skipAnimation = true (implied logic)
      });
    } else {
      // Check if we are waiting for user choice
      if (_currentIndex < _fullScript.length) {
        final nextItem = _fullScript[_currentIndex] as Map<String, dynamic>;
        if (nextItem['role'] == 'user_choice') {
          return; // Block tap if user needs to choose
        }
      }
      // User tapped while idle -> Advance script
      _advanceScript();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if the last visible item is a user choice that needs input
    // If yes, show buttons. If no (and not finished), show "Tap to continue" or just user response button area.

    // We assume the strict structure: AI Text -> User Choice (Optional) -> Response -> ...
    // For V5 Masterplan, interaction is: User Taps -> Next AI Message Appears.
    // If it's a "user_choice" item in the script, it renders AS buttons at the bottom.

    // Check if the *next* item (or current if just added) requires specific input type interaction?
    // Actually, let's look at the LAST visible item.
    if (_visibleScript.isNotEmpty) {
      // Logic for checking last item if needed
    }

    // Peek at the NEXT item to decide what the button does
    // If finished, show Finish button.
    final bool isFinished = _currentIndex >= _fullScript.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7), // Light grey
      appBar: AppBar(
        title: Text(widget.subModule.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: _fullScript.isEmpty ? 0 : _currentIndex / _fullScript.length,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: _handleTap, // Whole screen tap handling
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 20),
                itemCount: _visibleScript.length,
                itemBuilder: (context, index) {
                  final item = _visibleScript[index] as Map<String, dynamic>;
                  final role = item['role'];

                  // Check if this is the last item and we are typing
                  final isLast = index == _visibleScript.length - 1;
                  // Actually, ChatBubble property is 'skipAnimation'.
                  // If _isTyping is true, we ARE animating (skip=false).
                  // If _isTyping is false (after tap), we skip (skip=true).
                  // BUT only for the *latest* AI message. Old messages should just be static text (which skip=true effect effectively does by showing full text).
                  // So we can pass skipAnimation = true for all OLD messages.
                  // For the LAST message:
                  //    If _isTyping = true -> skip = false (Animate)
                  //    If _isTyping = false -> skip = true (Show full)

                  final bool forceFullText = !isLast || !_isTyping;

                  if (role == 'ai') {
                    return ChatBubble(
                      key: isLast
                          ? _currentBubbleKey
                          : null, // Key helps finding widget?
                      text: item['text'] ?? '',
                      isAi: true,
                      imageUrl: item['image_url'],
                      caption: item['caption'],
                      skipAnimation: forceFullText,
                    );
                  } else if (role == 'user_choice') {
                    // ... (same)
                    return const SizedBox.shrink();
                  } else if (role == 'user_selected') {
                    return ChatBubble(
                      text: item['text'],
                      isAi: false,
                      skipAnimation: true, // Always show user text immediately
                    );
                  } else if (role == 'summary_card') {
                    return SummaryCard(
                      title: item['title'] ?? 'Summary',
                      content: item['content'] ?? '',
                    );
                  } else if (role == 'bibliography_card') {
                    return BibliographyCard(
                      title: item['title'] ?? 'Reference',
                      content: item['content'] ?? '',
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            _buildInputArea(isFinished),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(bool isFinished) {
    if (isFinished) {
      return Container(
        padding: const EdgeInsets.all(24),
        // Removed white box decoration
        child: SafeArea(
          child: ElevatedButton.icon(
            onPressed: () async {
              await ProfileService().completeModule(widget.subModule);
              if (mounted) Navigator.pop(context);
            },
            icon: const Icon(Icons.verified_user_outlined),
            label: const Text(
              "SELESAI MEMBACA",
              style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ).animate().scale(curve: Curves.elasticOut, duration: 600.ms),
        ),
      );
    }

    // Check current item from FULL script (the one waiting to be revealed or interacted with)
    // Wait, _currentIndex points to the NEXT item to be added.
    // So if _currentIndex < length, we have a pending item.
    final nextItem = _fullScript[_currentIndex] as Map<String, dynamic>;
    final nextRole = nextItem['role'];

    if (nextRole == 'user_choice') {
      final options = (nextItem['options'] as List<dynamic>).cast<String>();
      return Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: options
              .map((opt) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          // 1. Add synthetic user bubble
                          setState(() {
                            _visibleScript
                                .add({'role': 'user_selected', 'text': opt});
                            _currentIndex++; // Skip the 'user_choice' item in index
                          });
                          // 2. Advance again to show AI response immediately?
                          // Usually yes.
                          Future.delayed(const Duration(milliseconds: 300),
                              () => _advanceScript());
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.indigo),
                        ),
                        child: Text(opt,
                            style: const TextStyle(color: Colors.indigo)),
                      ),
                    ),
                  ))
              .toList(),
        ),
      );
    }

    // Default "Tap to Continue" interaction
    // Default "Tap to Continue" interaction (Invisible now since whole screen taps)
    // We can show a small indicator or nothing.
    return const SizedBox.shrink();
  }
}
