import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SaathiChatScreen extends StatefulWidget {
  const SaathiChatScreen({super.key});

  @override
  State<SaathiChatScreen> createState() => _SaathiChatScreenState();
}
class _SaathiChatScreenState extends State<SaathiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> messages = [];
  bool isTyping = false;

  Future<void> sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({"sender": "user", "text": text});
      _controller.clear();
      isTyping = true;
    });

    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse("https://web-production-34a40.up.railway.app/chat"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": text}),
      );

      final data = jsonDecode(response.body);

      setState(() {
        messages.add({
          "sender": "ai",
          "text": data["response"] ?? "Sorry, I couldn’t understand that.",
        });
      });
    } catch (e) {
      setState(() {
        messages.add({
          "sender": "ai",
          "text": "Connection error. Please try again later.",
        });
      });
    }

    setState(() => isTyping = false);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 180), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Widget buildBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(14),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent])
              : null,
          color: isUser ? null : Colors.grey.shade200,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(2, 3),
            )
          ],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(6),
            bottomRight: isUser ? const Radius.circular(6) : const Radius.circular(18),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 15,
            height: 1.35,
          ),
        ),
      ),
    );
  }

  Widget aiTypingIndicator() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              dot(),
              const SizedBox(width: 4),
              dot(),
              const SizedBox(width: 4),
              dot(),
            ],
          ),
        ),
      ],
    );
  }

  Widget dot() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.grey.shade600,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget chatIntroCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.deepPurple, Colors.purple],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        "👋 Hey! I’m Saathi — your personal health companion.\n\n"
            "I can help with:\n• Period & cycle questions\n• PCOS guidance\n• Symptom understanding\n• Daily wellness tips\n\n"
            "Ask me anything!",
        style: TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "My Saathi",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.pinkAccent],
            ),
          ),
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: messages.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return chatIntroCard();

                final msg = messages[index - 1];
                final isUser = msg["sender"] == "user";

                if (index == messages.length && isTyping) {
                  return aiTypingIndicator();
                }

                return buildBubble(msg["text"], isUser);
              },
            ),
          ),

          // ---------------- INPUT BAR ----------------
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Ask Saathi anything…",
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                GestureDetector(
                  onTap: sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Colors.deepPurple, Colors.purpleAccent],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.shade200,
                          blurRadius: 10,
                          spreadRadius: 1,
                        )
                      ],
                    ),
                    child: const Icon(Icons.send, color: Colors.white, size: 22),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
