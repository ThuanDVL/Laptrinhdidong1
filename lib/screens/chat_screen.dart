import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../storage/app_data.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  /// ✅ API 9a — Load tin nhắn từ MockAPI
  Future<void> _loadMessages() async {
    final userId = AppData.userId;
    final data = await ApiService.getMessages(userId);

    setState(() {
      if (data.isNotEmpty) {
        _messages = data;
      } else {
        // Fallback nếu chưa có tin nhắn trong API
        _messages = [
          {"text": "Xin chào! Bạn cần giúp gì hôm nay?", "isMe": false},
          {"text": "Tôi muốn tìm tour phù hợp", "isMe": true},
          {"text": "Chúng tôi có nhiều tour 1 ngày và tour 3 ngày. Bạn thích lịch trình nào?", "isMe": false},
        ];
      }
      _isLoading = false;
    });

    _scrollToBottom();
  }

  /// ✅ API 9b — Gửi tin nhắn lên MockAPI
  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Cập nhật UI ngay lập tức
    setState(() {
      _messages.add({"text": text, "isMe": true});
      _controller.clear();
    });
    _scrollToBottom();

    // Gọi API nền
    ApiService.sendMessage(
      userId: AppData.userId,
      text: text,
      isMe: true,
    );

    // Giả lập bot trả lời
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _messages.add({
        "text": "Cảm ơn bạn! Tôi sẽ có câu trả lời sớm.",
        "isMe": false,
      });
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (_isLoading)
            const LinearProgressIndicator(
              color: Color(0xFF00D1A3),
              backgroundColor: Color(0xFFE0F7F4),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final messageText =
                    (message['text'] as String?) ?? (message['message'] as String?) ?? '';
                final bool isMe = message['isMe'] as bool? ??
                    message['userId']?.toString() == AppData.userId;
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isMe
                            ? const Color(0xFF00D1A3)
                            : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isMe ? 16 : 0),
                          bottomRight: Radius.circular(isMe ? 0 : 16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Text(
                        messageText,
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black87,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.grey.shade100,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Gõ tin nhắn...',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 45,
                    width: 45,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00D1A3),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      splashRadius: 24,
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
