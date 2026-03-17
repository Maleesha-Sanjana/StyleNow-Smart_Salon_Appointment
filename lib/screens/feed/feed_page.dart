import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../state/auth_state.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final List<_FeedPost> _posts = [
    _FeedPost(
      username: 'Golden Scissors',
      userAvatar: '✂️',
      timeAgo: '2 hours ago',
      content: 'Fresh summer cuts are in! Come visit us for a new look 💇‍♂️',
      imageEmoji: '✂️',
      likes: 42,
      comments: [
        _Comment(username: 'Ashan', text: 'Love the new styles!'),
        _Comment(username: 'Nimal', text: 'Booked for tomorrow 🔥'),
      ],
    ),
    _FeedPost(
      username: 'Style Hub',
      userAvatar: '💆',
      timeAgo: '5 hours ago',
      content:
          'Bridal season is here! Book your bridal makeup package now 💄👰',
      imageEmoji: '💄',
      likes: 87,
      comments: [_Comment(username: 'Dilani', text: 'Amazing work as always!')],
    ),
    _FeedPost(
      username: 'The Barber Co.',
      userAvatar: '🧔',
      timeAgo: '1 day ago',
      content: 'Beard game strong 💪 Check out our new beard styling packages!',
      imageEmoji: '🧔',
      likes: 31,
      comments: [],
    ),
    _FeedPost(
      username: 'Nail Studio',
      userAvatar: '💅',
      timeAgo: '2 days ago',
      content: 'New nail art designs available this week! DM to book 💅✨',
      imageEmoji: '💅',
      likes: 65,
      comments: [
        _Comment(username: 'Kavya', text: 'These look gorgeous!'),
        _Comment(username: 'Priya', text: 'Can I book for Saturday?'),
        _Comment(username: 'Salon', text: 'Yes! Call us 📞'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Header
          Container(
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            padding: EdgeInsets.fromLTRB(16, topPadding + 12, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Feed',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showCreatePostSheet(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Post'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Feed list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: _posts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) =>
                  _PostCard(post: _posts[index], textColor: textColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreatePostSheet(BuildContext context) {
    if (!guardAction(context)) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _CreatePostSheet(),
    );
  }
}

// ── Post Card ──────────────────────────────────────────────────────────────

class _PostCard extends StatefulWidget {
  final _FeedPost post;
  final Color textColor;

  const _PostCard({required this.post, required this.textColor});

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  bool _liked = false;
  bool _showComments = false;
  final TextEditingController _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final subColor = widget.textColor.withValues(alpha: 0.55);
    final post = widget.post;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(
                    post.userAvatar,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.username,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: widget.textColor,
                        ),
                      ),
                      Text(
                        post.timeAgo,
                        style: TextStyle(fontSize: 11, color: subColor),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.more_horiz, color: subColor),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              post.content,
              style: TextStyle(fontSize: 14, color: widget.textColor),
            ),
          ),
          // Image placeholder
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 160,
                color: AppColors.primary.withValues(alpha: 0.15),
                child: Center(
                  child: Text(
                    post.imageEmoji,
                    style: const TextStyle(fontSize: 64),
                  ),
                ),
              ),
            ),
          ),
          // Like count
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
            child: Text(
              '${_liked ? post.likes + 1 : post.likes} likes',
              style: TextStyle(fontSize: 12, color: subColor),
            ),
          ),
          const Divider(height: 16, indent: 14, endIndent: 14),
          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Row(
              children: [
                _ActionBtn(
                  icon: _liked ? Icons.favorite : Icons.favorite_border,
                  label: 'Like',
                  color: _liked ? Colors.red : subColor,
                  onTap: () {
                    if (!guardAction(context)) return;
                    setState(() => _liked = !_liked);
                  },
                ),
                _ActionBtn(
                  icon: Icons.chat_bubble_outline,
                  label: 'Comment',
                  color: subColor,
                  onTap: () {
                    if (!guardAction(context)) return;
                    setState(() => _showComments = !_showComments);
                  },
                ),
                _ActionBtn(
                  icon: Icons.reply,
                  label: 'Share',
                  color: subColor,
                  onTap: () => guardAction(context),
                ),
              ],
            ),
          ),
          // Comments section
          if (_showComments) ...[
            const Divider(height: 1, indent: 14, endIndent: 14),
            if (post.comments.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
                child: Column(
                  children: post.comments
                      .map(
                        (c) => _CommentTile(
                          comment: c,
                          textColor: widget.textColor,
                        ),
                      )
                      .toList(),
                ),
              ),
            // Comment input
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentCtrl,
                      style: TextStyle(fontSize: 13, color: widget.textColor),
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        hintStyle: TextStyle(fontSize: 13, color: subColor),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: subColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: subColor.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      if (_commentCtrl.text.trim().isEmpty) return;
                      setState(() {
                        post.comments.add(
                          _Comment(
                            username: 'You',
                            text: _commentCtrl.text.trim(),
                          ),
                        );
                        _commentCtrl.clear();
                      });
                    },
                    child: const CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.accent,
                      child: Icon(
                        Icons.send,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Action Button ──────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: color),
        label: Text(label, style: TextStyle(fontSize: 12, color: color)),
        style: TextButton.styleFrom(padding: EdgeInsets.zero),
      ),
    );
  }
}

// ── Comment Tile ───────────────────────────────────────────────────────────

class _CommentTile extends StatelessWidget {
  final _Comment comment;
  final Color textColor;

  const _CommentTile({required this.comment, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.primary.withValues(alpha: 0.3),
            child: Text(
              comment.username[0].toUpperCase(),
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment.username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: textColor,
                    ),
                  ),
                  Text(
                    comment.text,
                    style: TextStyle(fontSize: 12, color: textColor),
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

// ── Create Post Sheet ──────────────────────────────────────────────────────

class _CreatePostSheet extends StatefulWidget {
  const _CreatePostSheet();

  @override
  State<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<_CreatePostSheet> {
  final TextEditingController _ctrl = TextEditingController();
  String _selectedType = 'Photo';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 20, 16, 20 + bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Create Post',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: textColor),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ctrl,
            maxLines: 4,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: "What's on your mind?",
              hintStyle: TextStyle(color: textColor.withValues(alpha: 0.4)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: textColor.withValues(alpha: 0.2)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Media type selector
          Row(
            children: ['Photo', 'Video'].map((type) {
              final selected = _selectedType == type;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedType = type),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.accent : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? AppColors.accent
                            : textColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          type == 'Photo'
                              ? Icons.photo_outlined
                              : Icons.videocam_outlined,
                          size: 16,
                          color: selected ? AppColors.primary : textColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          type,
                          style: TextStyle(
                            fontSize: 13,
                            color: selected ? AppColors.primary : textColor,
                            fontWeight: selected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Post',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data Models ────────────────────────────────────────────────────────────

class _FeedPost {
  final String username;
  final String userAvatar;
  final String timeAgo;
  final String content;
  final String imageEmoji;
  int likes;
  final List<_Comment> comments;

  _FeedPost({
    required this.username,
    required this.userAvatar,
    required this.timeAgo,
    required this.content,
    required this.imageEmoji,
    required this.likes,
    required this.comments,
  });
}

class _Comment {
  final String username;
  final String text;

  _Comment({required this.username, required this.text});
}
