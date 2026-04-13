import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../state/auth_state.dart';

// ── Data Models ────────────────────────────────────────────────────────────

class _Story {
  final String username;
  final String avatar;
  final bool isYours;

  const _Story({
    required this.username,
    required this.avatar,
    this.isYours = false,
  });
}

class _FeedPost {
  final String username;
  final String userAvatar;
  final String timeAgo;
  final String content;
  final String imageEmoji;
  int likes;
  int shares;
  final List<_Comment> comments;

  _FeedPost({
    required this.username,
    required this.userAvatar,
    required this.timeAgo,
    required this.content,
    required this.imageEmoji,
    required this.likes,
    this.shares = 0,
    required this.comments,
  });
}

class _Comment {
  final String username;
  final String avatar;
  final String text;
  final String timeAgo;

  _Comment({
    required this.username,
    required this.avatar,
    required this.text,
    this.timeAgo = 'Just now',
  });
}

// ── Feed Page ──────────────────────────────────────────────────────────────

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final List<_Story> _stories = const [
    _Story(username: 'Your Story', avatar: '👤', isYours: true),
    _Story(username: 'Golden Scissors', avatar: '✂️'),
    _Story(username: 'Style Hub', avatar: '💆'),
    _Story(username: 'Barber Co.', avatar: '🧔'),
    _Story(username: 'Nail Studio', avatar: '💅'),
    _Story(username: 'Glow Spa', avatar: '🌸'),
  ];

  final List<_FeedPost> _posts = [
    _FeedPost(
      username: 'Golden Scissors',
      userAvatar: '✂️',
      timeAgo: '2 hours ago',
      content:
          'Fresh summer cuts are in! Come visit us for a new look 💇‍♂️ Book now and get 20% off your first visit!',
      imageEmoji: '✂️',
      likes: 42,
      shares: 5,
      comments: [
        _Comment(
          username: 'Ashan',
          avatar: 'A',
          text: 'Love the new styles!',
          timeAgo: '1 hr ago',
        ),
        _Comment(
          username: 'Nimal',
          avatar: 'N',
          text: 'Booked for tomorrow 🔥',
          timeAgo: '45 min ago',
        ),
      ],
    ),
    _FeedPost(
      username: 'Style Hub',
      userAvatar: '💆',
      timeAgo: '5 hours ago',
      content:
          'Bridal season is here! Book your bridal makeup package now 💄👰 Limited slots available!',
      imageEmoji: '💄',
      likes: 87,
      shares: 12,
      comments: [
        _Comment(
          username: 'Dilani',
          avatar: 'D',
          text: 'Amazing work as always!',
          timeAgo: '4 hr ago',
        ),
      ],
    ),
    _FeedPost(
      username: 'The Barber Co.',
      userAvatar: '🧔',
      timeAgo: '1 day ago',
      content:
          'Beard game strong 💪 Check out our new beard styling packages! Walk-ins welcome.',
      imageEmoji: '🧔',
      likes: 31,
      shares: 3,
      comments: [],
    ),
    _FeedPost(
      username: 'Nail Studio',
      userAvatar: '💅',
      timeAgo: '2 days ago',
      content:
          'New nail art designs available this week! DM to book 💅✨ Prices starting from \$15.',
      imageEmoji: '💅',
      likes: 65,
      shares: 8,
      comments: [
        _Comment(
          username: 'Kavya',
          avatar: 'K',
          text: 'These look gorgeous!',
          timeAgo: '1 day ago',
        ),
        _Comment(
          username: 'Priya',
          avatar: 'P',
          text: 'Can I book for Saturday?',
          timeAgo: '1 day ago',
        ),
        _Comment(
          username: 'Salon',
          avatar: 'S',
          text: 'Yes! Call us 📞',
          timeAgo: '23 hr ago',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF18191A) : const Color(0xFFF0F2F5);
    final cardColor = isDark ? const Color(0xFF242526) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF050505);
    final subColor = isDark ? const Color(0xFFB0B3B8) : const Color(0xFF65676B);
    final dividerColor = isDark
        ? const Color(0xFF3A3B3C)
        : const Color(0xFFE4E6EB);

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // ── FB-style Top Nav ──
          Container(
            color: cardColor,
            padding: EdgeInsets.fromLTRB(16, topPadding + 8, 12, 8),
            child: Row(
              children: [
                // App name / logo
                Text(
                  'StyleNow',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                // Icon buttons
                _NavIconBtn(
                  icon: Icons.search_rounded,
                  onTap: () => guardAction(context),
                  bgColor: isDark
                      ? const Color(0xFF3A3B3C)
                      : const Color(0xFFE4E6EB),
                  iconColor: textColor,
                ),
                const SizedBox(width: 8),
                _NavIconBtn(
                  icon: Icons.notifications_outlined,
                  onTap: () => guardAction(context),
                  bgColor: isDark
                      ? const Color(0xFF3A3B3C)
                      : const Color(0xFFE4E6EB),
                  iconColor: textColor,
                  badgeCount: 5,
                ),
              ],
            ),
          ),
          Divider(height: 1, color: dividerColor),
          // ── Feed ──
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Create Post Box
                _CreatePostBox(
                  cardColor: cardColor,
                  textColor: textColor,
                  subColor: subColor,
                  dividerColor: dividerColor,
                  onPost: () => _showCreatePostSheet(context),
                ),
                SizedBox(height: 8),
                // Stories Row
                _StoriesRow(
                  stories: _stories,
                  cardColor: cardColor,
                  textColor: textColor,
                  subColor: subColor,
                ),
                SizedBox(height: 8),
                // Posts
                ...List.generate(_posts.length, (i) {
                  return Column(
                    children: [
                      _PostCard(
                        post: _posts[i],
                        textColor: textColor,
                        subColor: subColor,
                        cardColor: cardColor,
                        dividerColor: dividerColor,
                        onLike: () {
                          if (!guardAction(context)) return;
                          setState(() {});
                        },
                      ),
                      SizedBox(height: 8),
                    ],
                  );
                }),
              ],
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const _CreatePostSheet(),
    );
  }
}

// ── Nav Icon Button ────────────────────────────────────────────────────────

class _NavIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color bgColor;
  final Color iconColor;
  final int badgeCount;

  const _NavIconBtn({
    required this.icon,
    required this.onTap,
    required this.bgColor,
    required this.iconColor,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 22),
          ),
        ),
        if (badgeCount > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$badgeCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Create Post Box ────────────────────────────────────────────────────────

class _CreatePostBox extends StatelessWidget {
  final Color cardColor;
  final Color textColor;
  final Color subColor;
  final Color dividerColor;
  final VoidCallback onPost;

  const _CreatePostBox({
    required this.cardColor,
    required this.textColor,
    required this.subColor,
    required this.dividerColor,
    required this.onPost,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: cardColor,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary,
                child: const Text('👤', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: onPost,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: subColor.withValues(alpha: 0.4),
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      "What's on your mind?",
                      style: TextStyle(color: subColor, fontSize: 15),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: dividerColor),
          // Bottom action row
          Row(
            children: [
              _PostActionChip(
                icon: Icons.videocam_rounded,
                label: 'Live video',
                color: Colors.red,
                onTap: onPost,
              ),
              _PostActionChip(
                icon: Icons.photo_library_rounded,
                label: 'Photo/Video',
                color: Colors.green,
                onTap: onPost,
              ),
              _PostActionChip(
                icon: Icons.emoji_emotions_outlined,
                label: 'Feeling',
                color: Colors.orange,
                onTap: onPost,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PostActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PostActionChip({
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
        icon: Icon(icon, color: color, size: 20),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 6),
        ),
      ),
    );
  }
}

// ── Stories Row ────────────────────────────────────────────────────────────

class _StoriesRow extends StatelessWidget {
  final List<_Story> stories;
  final Color cardColor;
  final Color textColor;
  final Color subColor;

  const _StoriesRow({
    required this.stories,
    required this.cardColor,
    required this.textColor,
    required this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: cardColor,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SizedBox(
        height: 180,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          itemCount: stories.length,
          itemBuilder: (context, i) {
            final story = stories[i];
            return _StoryCard(story: story, textColor: textColor);
          },
        ),
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  final _Story story;
  final Color textColor;

  const _StoryCard({required this.story, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 105,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: story.isYours
                ? [const Color(0xFFE4E6EB), const Color(0xFFE4E6EB)]
                : [
                    AppColors.primary.withValues(alpha: 0.85),
                    AppColors.primary,
                  ],
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background emoji
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 40,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Container(
                  color: story.isYours
                      ? const Color(0xFFE4E6EB)
                      : AppColors.secondary.withValues(alpha: 0.6),
                  child: Center(
                    child: Text(
                      story.avatar,
                      style: const TextStyle(fontSize: 44),
                    ),
                  ),
                ),
              ),
            ),
            // Avatar circle
            Positioned(
              top: story.isYours ? null : 10,
              bottom: story.isYours ? 44 : null,
              left: 0,
              right: 0,
              child: Center(
                child: story.isYours
                    ? Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                      )
                    : Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.accent, width: 3),
                        ),
                        child: CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Text(
                            story.avatar,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
              ),
            ),
            // Name label
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: story.isYours
                      ? const Color(0xFFE4E6EB)
                      : AppColors.primary,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  story.isYours ? 'Add to Story' : story.username,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: story.isYours ? AppColors.primary : Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Post Card ──────────────────────────────────────────────────────────────

class _PostCard extends StatefulWidget {
  final _FeedPost post;
  final Color textColor;
  final Color subColor;
  final Color cardColor;
  final Color dividerColor;
  final VoidCallback onLike;

  const _PostCard({
    required this.post,
    required this.textColor,
    required this.subColor,
    required this.cardColor,
    required this.dividerColor,
    required this.onLike,
  });

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
    final post = widget.post;
    final totalLikes = _liked ? post.likes + 1 : post.likes;

    return Container(
      color: widget.cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Author Row ──
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        post.userAvatar,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: widget.cardColor, width: 2),
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
                        post.username,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: widget.textColor,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            post.timeAgo,
                            style: TextStyle(
                              fontSize: 12,
                              color: widget.subColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.public, size: 12, color: widget.subColor),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_horiz, color: widget.subColor),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.close, color: widget.subColor, size: 18),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          // ── Post Content ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              post.content,
              style: TextStyle(fontSize: 15, color: widget.textColor),
            ),
          ),
          const SizedBox(height: 10),
          // ── Post Image ──
          Container(
            height: 220,
            width: double.infinity,
            color: AppColors.primary.withValues(alpha: 0.12),
            child: Center(
              child: Text(
                post.imageEmoji,
                style: const TextStyle(fontSize: 80),
              ),
            ),
          ),
          // ── Reactions Summary ──
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _ReactionBubble(
                      emoji: '👍',
                      color: const Color(0xFF1877F2),
                    ),
                    _ReactionBubble(emoji: '❤️', color: Colors.red),
                    const SizedBox(width: 4),
                    Text(
                      '$totalLikes',
                      style: TextStyle(fontSize: 13, color: widget.subColor),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '${post.comments.length} comments',
                      style: TextStyle(fontSize: 13, color: widget.subColor),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${post.shares} shares',
                      style: TextStyle(fontSize: 13, color: widget.subColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: widget.dividerColor,
            indent: 12,
            endIndent: 12,
          ),
          // ── Action Buttons ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              children: [
                _FbActionBtn(
                  icon: _liked ? Icons.thumb_up : Icons.thumb_up_outlined,
                  label: 'Like',
                  color: _liked ? const Color(0xFF1877F2) : widget.subColor,
                  onTap: () {
                    if (!guardAction(context)) return;
                    setState(() => _liked = !_liked);
                  },
                ),
                _FbActionBtn(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'Comment',
                  color: widget.subColor,
                  onTap: () {
                    if (!guardAction(context)) return;
                    setState(() => _showComments = !_showComments);
                  },
                ),
                _FbActionBtn(
                  icon: Icons.reply_rounded,
                  label: 'Share',
                  color: widget.subColor,
                  onTap: () => guardAction(context),
                ),
              ],
            ),
          ),
          // ── Comments Section ──
          if (_showComments) ...[
            Divider(height: 1, color: widget.dividerColor),
            if (post.comments.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                child: Column(
                  children: post.comments
                      .map(
                        (c) => _CommentTile(
                          comment: c,
                          textColor: widget.textColor,
                          subColor: widget.subColor,
                        ),
                      )
                      .toList(),
                ),
              ),
            // Comment input
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary,
                    child: Text('👤', style: TextStyle(fontSize: 14)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _commentCtrl,
                      style: TextStyle(fontSize: 14, color: widget.textColor),
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: widget.subColor,
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        filled: true,
                        fillColor: widget.dividerColor.withValues(alpha: 0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.emoji_emotions_outlined,
                              color: widget.subColor,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () {
                                if (_commentCtrl.text.trim().isEmpty) return;
                                setState(() {
                                  post.comments.add(
                                    _Comment(
                                      username: 'You',
                                      avatar: 'Y',
                                      text: _commentCtrl.text.trim(),
                                    ),
                                  );
                                  _commentCtrl.clear();
                                });
                              },
                              child: Icon(
                                Icons.send_rounded,
                                color: AppColors.accent,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
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

class _ReactionBubble extends StatelessWidget {
  final String emoji;
  final Color color;

  const _ReactionBubble({required this.emoji, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      margin: const EdgeInsets.only(right: 2),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 11))),
    );
  }
}

// ── FB Action Button ───────────────────────────────────────────────────────

class _FbActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _FbActionBtn({
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
        icon: Icon(icon, size: 20, color: color),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }
}

// ── Comment Tile ───────────────────────────────────────────────────────────

class _CommentTile extends StatelessWidget {
  final _Comment comment;
  final Color textColor;
  final Color subColor;

  const _CommentTile({
    required this.comment,
    required this.textColor,
    required this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary,
            child: Text(
              comment.avatar,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: subColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.username,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        comment.text,
                        style: TextStyle(fontSize: 13, color: textColor),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: Row(
                    children: [
                      Text(
                        comment.timeAgo,
                        style: TextStyle(fontSize: 11, color: subColor),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Like',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: subColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Reply',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: subColor,
                        ),
                      ),
                    ],
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

// ── Create Post Sheet ──────────────────────────────────────────────────────

class _CreatePostSheet extends StatefulWidget {
  const _CreatePostSheet();

  @override
  State<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<_CreatePostSheet> {
  final TextEditingController _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final subColor = textColor.withValues(alpha: 0.5);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  'Create Post',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: subColor.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, color: textColor, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: subColor.withValues(alpha: 0.2)),
          // Author row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary,
                  child: Text('👤', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'You',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: textColor,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: subColor.withValues(alpha: 0.4),
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.public, size: 12, color: subColor),
                          const SizedBox(width: 4),
                          Text(
                            'Public',
                            style: TextStyle(fontSize: 12, color: subColor),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            size: 14,
                            color: subColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Text input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _ctrl,
              maxLines: 5,
              autofocus: true,
              style: TextStyle(fontSize: 18, color: textColor),
              decoration: InputDecoration(
                hintText: "What's on your mind?",
                hintStyle: TextStyle(fontSize: 18, color: subColor),
                border: InputBorder.none,
              ),
            ),
          ),
          // Add to post row
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: subColor.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    'Add to your post',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: textColor,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.photo_library_rounded,
                    color: Colors.green,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.person_add_alt_1_rounded,
                    color: const Color(0xFF1877F2),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.emoji_emotions_outlined,
                    color: Colors.orange,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.location_on_outlined, color: Colors.red, size: 28),
                ],
              ),
            ),
          ),
          // Post button
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Post',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
