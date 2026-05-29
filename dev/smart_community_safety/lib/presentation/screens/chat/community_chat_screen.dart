import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../../data/models/chat_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().start();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final auth = context.read<AuthProvider>();
    final profile = context.read<ProfileProvider>();
    final chat = context.read<ChatProvider>();

    // ✅ MUST use Profile name
    final userName = (profile.name?.trim().isNotEmpty == true)
        ? profile.name!.trim()
        : "Community Member";

    // If you have auth uid getter, use that. Otherwise fallback:
    final userId = auth.uid ?? "unknown_user";

    await chat.send(
      userId: userId,
      userName: userName,
      text: _controller.text,
    );

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final chat = context.watch<ChatProvider>();

    final messages = chat.realtime.isNotEmpty ? chat.realtime : chat.local;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Community Chat"),
        actions: [
          IconButton(
            onPressed: () => context.read<ChatProvider>().sync(),
            icon: const Icon(Icons.sync),
            tooltip: "Sync",
          )
        ],
      ),
      body: Column(
        children: [
          // Top info bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.08),
              border: Border(
                bottom: BorderSide(color: Colors.black.withOpacity(0.06)),
              ),
            ),
            child: const Text(
              "Be respectful. Avoid sharing personal details. Messages sync automatically.",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),

          // Messages
          Expanded(
            child: messages.isEmpty
                ? const Center(
              child: Text(
                "No messages yet.\nSay hello to your community 👋",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            )
                : ListView.builder(
              controller: _scroll,
              reverse: true,
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              itemCount: messages.length,
              itemBuilder: (_, i) => _bubble(context, messages[i]),
            ),
          ),

          // Input
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: "Write a message…",
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: _send,
                    style: FilledButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(14),
                    ),
                    child: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(BuildContext context, ChatMessage m) {
    final cs = Theme.of(context).colorScheme;
    final auth = context.read<AuthProvider>();
    final mine = (auth.uid != null && auth.uid == m.userId);

    final bg = mine ? cs.primary.withOpacity(0.14) : cs.secondary.withOpacity(0.12);

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 330),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withOpacity(0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                m.userName, // ✅ NAME only (never email)
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: cs.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                m.text,
                style: const TextStyle(fontWeight: FontWeight.w700, height: 1.25),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
