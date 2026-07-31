import 'package:flutter/material.dart';
import 'package:victorcoin_app/theme/app_theme.dart';
import 'package:victorcoin_app/widgets/glass_card.dart';
import 'package:victorcoin_app/widgets/gold_button.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final List<Map<String, String>> _chatMessages = [
    {"sender": "ai", "text": "Hello Victor! I am your 24/7 VictorCoin AI Assistant. How can I help you today?"},
  ];
  final TextEditingController _chatController = TextEditingController();

  void _sendMessage() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _chatMessages.add({"sender": "user", "text": text});
      _chatController.clear();
    });

    // Simulate instant AI response
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _chatMessages.add({
            "sender": "ai",
            "text": "Thank you for reaching out! Regarding '$text', our support team and automated ledger engines are standing by."
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("24/7 AI Support & Live Chat", style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.primaryGold),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _chatMessages.length,
                itemBuilder: (context, index) {
                  final msg = _chatMessages[index];
                  final isUser = msg['sender'] == "user";
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      decoration: BoxDecoration(
                        color: isUser ? AppTheme.primaryGold : AppTheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: isUser ? null : Border.all(color: AppTheme.cardBorder),
                      ),
                      child: Text(
                        msg['text']!,
                        style: TextStyle(
                          color: isUser ? Colors.black : AppTheme.textPrimary,
                          fontWeight: isUser ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                border: Border(top: BorderSide(color: AppTheme.cardBorder)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _chatController,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: const InputDecoration(
                        hintText: "Type message to AI Assistant...",
                        hintStyle: TextStyle(color: AppTheme.textSecondary),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: AppTheme.primaryGold),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
