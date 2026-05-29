import 'package:flutter/material.dart';
import 'package:smart_community_safety/models/chat_message.dart';
import 'package:smart_community_safety/services/chat_service.dart';
import 'package:smart_community_safety/services/firestore_service.dart';
import 'package:smart_community_safety/utils/helpers.dart';

class CommunityChatScreen extends StatefulWidget {
  const CommunityChatScreen({Key? key}) : super(key: key);

  @override
  State<CommunityChatScreen> createState() => _CommunityChatScreenState();
}

class _CommunityChatScreenState extends State<CommunityChatScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final ChatService _chatService = ChatService();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _showWelcome = true;
  bool _isEmojiPickerVisible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showWelcome = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    await _chatService.sendMessage(text: _messageController.text.trim());
    _messageController.clear();
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _toggleEmojiPicker() {
    setState(() {
      _isEmojiPickerVisible = !_isEmojiPickerVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Chat'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          Expanded(
            child: _showWelcome
                ? _buildWelcomeAnimation(context)
                : StreamBuilder<List<ChatMessage>>(
              stream: _firestoreService.listenToChat(),
              builder: (context, snapshot) {
                List<ChatMessage> messages = snapshot.hasData
                    ? snapshot.data!
                    : _chatService.getLocalMessages();

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return _buildMessageBubble(context, msg);
                  },
                );
              },
            ),
          ),
          if (!_showWelcome) ...[
            if (_isEmojiPickerVisible)
              SizedBox(
                height: 200,
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: 64,
                  itemBuilder: (context, index) {
                    final emoji = String.fromCharCode(0x1F600 + index);
                    return GestureDetector(
                      onTap: () {
                        _messageController.text += emoji;
                        setState(() {
                          _isEmojiPickerVisible = false;
                        });
                      },
                      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
                    );
                  },
                ),
              ),
            _buildMessageInput(context),
          ],
        ],
      ),
    );
  }

  Widget _buildWelcomeAnimation(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/chat_character.png',
            height: 150,
          ),
          const SizedBox(height: 24),
          Text(
            'Welcome to Smart Community Chat!',
            style: Theme.of(context).textTheme.titleLarge!.copyWith( // ✅ FIXED: headline6 → titleLarge
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessage msg) {
    final isCurrentUser = msg.senderId == 'temp_local'; // Simplified

    return Container(
      margin: EdgeInsets.only(
        top: 8,
        bottom: 8,
        left: isCurrentUser ? 60 : 12,
        right: isCurrentUser ? 12 : 60,
      ),
      child: Column(
        crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isCurrentUser)
            Padding(
              padding: const EdgeInsets.only(bottom: 4, left: 8, right: 8),
              child: Text(
                msg.senderName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 12,
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: isCurrentUser
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              msg.text,
              style: TextStyle(
                color: isCurrentUser ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 15,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
            child: Text(
              Helpers.formatTimestamp(msg.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.mood),
            onPressed: _toggleEmojiPicker,
            color: Theme.of(context).colorScheme.primary,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(color: Theme.of(context).hintColor),
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}