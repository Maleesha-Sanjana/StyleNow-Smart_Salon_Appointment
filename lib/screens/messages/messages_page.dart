import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchCtrl = TextEditingController();
  String _query = '';
  bool _searchOpen = false;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Mock data ──────────────────────────────────────────────────────────

  static final List<_Conversation> _chats = [
    _Conversation(
      name: 'Golden Scissors',
      avatar: '✂️',
      lastMessage: 'Your appointment is confirmed for tomorrow at 10am!',
      time: '2m ago',
      unread: 2,
      isOnline: true,
    ),
    _Conversation(
      name: 'Style Hub',
      avatar: '💆',
      lastMessage: 'Thank you for your booking 😊',
      time: '1h ago',
      unread: 0,
      isOnline: true,
    ),
    _Conversation(
      name: 'The Barber Co.',
      avatar: '🧔',
      lastMessage: 'We have a slot open this Saturday, interested?',
      time: '3h ago',
      unread: 1,
      isOnline: false,
    ),
    _Conversation(
      name: 'Nail Studio',
      avatar: '💅',
      lastMessage: 'Your nail art is ready for pickup!',
      time: 'Yesterday',
      unread: 0,
      isOnline: false,
    ),
    _Conversation(
      name: 'Glow Spa',
      avatar: '🌸',
      lastMessage: 'Hi! How can we help you today?',
      time: 'Mon',
      unread: 0,
      isOnline: true,
    ),
    _Conversation(
      name: 'Ashan Fernando',
      avatar: 'A',
      lastMessage: 'Did you try the new salon on Main St?',
      time: 'Sun',
      unread: 0,
      isOnline: false,
    ),
  ];

  List<_Conversation> get _filtered => _query.isEmpty
      ? _chats
      : _chats
            .where(
              (c) =>
                  c.name.toLowerCase().contains(_query.toLowerCase()) ||
                  c.lastMessage.toLowerCase().contains(_query.toLowerCase()),
            )
            .toList();

  int get _totalUnread => _chats.fold(0, (sum, c) => sum + c.unread);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // ── App Bar ──────────────────────────────────────────────────
          Container(
            color: AppColors.primary,
            padding: EdgeInsets.fromLTRB(4, topPadding + 4, 8, 0),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    if (_searchOpen) ...[
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          autofocus: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Search messages...',
                            hintStyle: const TextStyle(color: Colors.white54),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8,
                            ),
                            suffixIcon: _query.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.white54,
                                      size: 18,
                                    ),
                                    onPressed: () => setState(() {
                                      _searchCtrl.clear();
                                      _query = '';
                                    }),
                                  )
                                : null,
                          ),
                          onChanged: (v) => setState(() => _query = v),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => setState(() {
                          _searchOpen = false;
                          _searchCtrl.clear();
                          _query = '';
                        }),
                      ),
                    ] else ...[
                      const Text(
                        'Messages',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_totalUnread > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$_totalUnread',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.search, color: Colors.white),
                        onPressed: () => setState(() => _searchOpen = true),
                        tooltip: 'Search',
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                        tooltip: 'New Message',
                      ),
                    ],
                  ],
                ),
                // Tabs
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.accent,
                  labelColor: AppColors.accent,
                  unselectedLabelColor: Colors.white54,
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Unread'),
                  ],
                ),
              ],
            ),
          ),

          // ── Tab Views ────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ConversationList(conversations: _filtered, isDark: isDark),
                _ConversationList(
                  conversations: _filtered.where((c) => c.unread > 0).toList(),
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Conversation List ──────────────────────────────────────────────────────

class _ConversationList extends StatelessWidget {
  final List<_Conversation> conversations;
  final bool isDark;

  const _ConversationList({required this.conversations, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 72,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'No messages yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Start a conversation with a salon',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: conversations.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        indent: 76,
        endIndent: 16,
        color: isDark ? const Color(0xFF3A3B3C) : const Color(0xFFE4E6EB),
      ),
      itemBuilder: (context, i) =>
          _ConversationTile(conv: conversations[i], isDark: isDark),
    );
  }
}

// ── Conversation Tile ──────────────────────────────────────────────────────

class _ConversationTile extends StatelessWidget {
  final _Conversation conv;
  final bool isDark;

  const _ConversationTile({required this.conv, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final subColor = textColor.withValues(alpha: conv.unread > 0 ? 0.9 : 0.55);

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => _ChatPage(conversation: conv)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: Text(
                    conv.avatar,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                if (conv.isOnline)
                  Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conv.name,
                          style: TextStyle(
                            fontWeight: conv.unread > 0
                                ? FontWeight.bold
                                : FontWeight.w600,
                            fontSize: 15,
                            color: textColor,
                          ),
                        ),
                      ),
                      Text(
                        conv.time,
                        style: TextStyle(
                          fontSize: 12,
                          color: conv.unread > 0 ? AppColors.accent : subColor,
                          fontWeight: conv.unread > 0
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conv.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: subColor,
                            fontWeight: conv.unread > 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (conv.unread > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${conv.unread}',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
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

// ── Chat Page ──────────────────────────────────────────────────────────────

class _ChatPage extends StatefulWidget {
  final _Conversation conversation;
  const _ChatPage({required this.conversation});

  @override
  State<_ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<_ChatPage> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  final List<_Message> _messages = [
    _Message(
      text: 'Hello! How can I help you today?',
      isMine: false,
      time: '10:00 AM',
    ),
    _Message(
      text: 'Hi! I wanted to ask about your availability this weekend.',
      isMine: true,
      time: '10:01 AM',
    ),
    _Message(
      text:
          'We have slots on Saturday at 2pm and 4pm. Would either work for you?',
      isMine: false,
      time: '10:02 AM',
    ),
    _Message(text: '2pm Saturday works great!', isMine: true, time: '10:03 AM'),
    _Message(
      text: 'Perfect! I\'ll book that for you. See you then 😊',
      isMine: false,
      time: '10:04 AM',
    ),
  ];

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _send() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Message(text: text, isMine: true, time: _nowTime()));
      _msgCtrl.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _nowTime() {
    final now = DateTime.now();
    final h = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final m = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF18191A) : const Color(0xFFF0F2F5);

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // App bar
          Container(
            color: AppColors.primary,
            padding: EdgeInsets.fromLTRB(4, topPadding + 4, 12, 10),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.accent.withValues(alpha: 0.2),
                      child: Text(
                        widget.conversation.avatar,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    if (widget.conversation.isOnline)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 11,
                          height: 11,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.conversation.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        widget.conversation.isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          color: widget.conversation.isOnline
                              ? Colors.greenAccent
                              : Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.call_outlined, color: Colors.white),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              itemCount: _messages.length,
              itemBuilder: (context, i) =>
                  _MessageBubble(message: _messages[i]),
            ),
          ),

          // Input bar
          Container(
            color: Theme.of(context).cardColor,
            padding: EdgeInsets.fromLTRB(8, 8, 8, 8 + bottomPadding),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: AppColors.accent,
                  ),
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Message...',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF3A3B3C)
                          : const Color(0xFFF0F2F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.emoji_emotions_outlined,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: () {},
                      ),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: _send,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Message Bubble ─────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final _Message message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine;
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMine ? AppColors.accent : Theme.of(context).cardColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMine ? 18 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 18),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                fontSize: 14,
                color: isMine
                    ? AppColors.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              message.time,
              style: TextStyle(
                fontSize: 10,
                color: isMine
                    ? AppColors.primary.withValues(alpha: 0.6)
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data Models ────────────────────────────────────────────────────────────

class _Conversation {
  final String name;
  final String avatar;
  final String lastMessage;
  final String time;
  final int unread;
  final bool isOnline;

  const _Conversation({
    required this.name,
    required this.avatar,
    required this.lastMessage,
    required this.time,
    required this.unread,
    required this.isOnline,
  });
}

class _Message {
  final String text;
  final bool isMine;
  final String time;

  const _Message({
    required this.text,
    required this.isMine,
    required this.time,
  });
}
