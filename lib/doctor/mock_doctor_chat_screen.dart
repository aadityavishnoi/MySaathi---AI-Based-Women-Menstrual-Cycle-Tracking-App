import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MockDoctorChatScreen extends StatefulWidget {
  const MockDoctorChatScreen({super.key});

  @override
  State<MockDoctorChatScreen> createState() => _MockDoctorChatScreenState();
}

class _MockDoctorChatScreenState extends State<MockDoctorChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [];

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        "role": "user",
        "text": text,
        "time": DateTime.now(),
      });
    });

    _controller.clear();
    _scrollDown();

    Future.delayed(const Duration(milliseconds: 900), () {
      setState(() {
        _messages.add({
          "role": "doctor",
          "text":
          "This is a mock doctor response. No real doctors are available — only general guidance.",
          "time": DateTime.now(),
        });
      });
      _scrollDown();
    });
  }

  void _scrollDown() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _chatBubble(Map<String, dynamic> msg) {
    final bool isUser = msg["role"] == "user";
    final time = DateFormat("hh:mm a").format(msg["time"]);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment:
      isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        // Doctor Avatar
        if (!isUser)
          const CircleAvatar(
            radius: 16,
            backgroundColor: Colors.deepPurple,
            child: Icon(Icons.medical_services, color: Colors.white, size: 18),
          ),

        if (!isUser) const SizedBox(width: 8),

        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isUser
                    ? [Color(0xFF8A2BE2), Color(0xFFB279FF)]
                    : [Color(0xFFECE9FF), Color(0xFFD6CCFF)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(14),
                topRight: const Radius.circular(14),
                bottomLeft:
                isUser ? const Radius.circular(14) : Radius.zero,
                bottomRight:
                isUser ? Radius.zero : const Radius.circular(14),
              ),
            ),
            child: Column(
              crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  msg["text"],
                  style: TextStyle(
                    color: isUser ? Colors.white : Colors.black87,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11,
                    color: isUser ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),

        if (isUser) const SizedBox(width: 8),

        // User Avatar
        if (isUser)
          const CircleAvatar(
            radius: 16,
            backgroundColor: Colors.pink,
            child: Icon(Icons.person, color: Colors.white, size: 18),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FF),

      // BEAUTIFUL GRADIENT APP BAR
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(

          ),
        ),
        title: Row(
          children: const [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: Icon(Icons.local_hospital, color: Colors.deepPurple),
            ),
            SizedBox(width: 10),
            Text(
              "Doctor Chat (Mock)",
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 19, color: Colors.white),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _chatBubble(_messages[index]);
              },
            ),
          ),

          // INPUT FIELD WITH ROUNDED UI
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, -2),
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: "Type your message…",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Floating Circular Send Button
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF8A2BE2), Color(0xFFB279FF)],
                      ),
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
