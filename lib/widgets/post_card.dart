import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../profile.dart';

class PostCard extends StatefulWidget {
  final String postId;
  final String userId;
  final String teamName;
  final String timeAgo;
  final String content;
  final String imageUrl;
  final int likes;
  final int comments;
  final bool isOwner;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final bool isLiked;
  final String currentUsername;

  const PostCard({
    super.key,
    required this.postId,
    required this.userId,
    required this.teamName,
    required this.timeAgo,
    required this.content,
    required this.imageUrl,
    required this.likes,
    required this.comments,
    required this.isOwner,
    required this.onLike,
    required this.onComment,
    required this.onDelete,
    required this.onEdit,
    required this.isLiked,
    required this.currentUsername,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool liked;
  late int likeCount;
  String? profilePictureUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    liked = widget.isLiked;
    likeCount = widget.likes;
    fetchProfilePicture();
  }

  void toggleLike() {
    widget.onLike();
    setState(() {
      liked = !liked;
      likeCount += liked ? 1 : -1;
    });
  }

  Future<void> fetchProfilePicture() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('tbl_Users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        setState(() {
          profilePictureUrl = data?['profilePicture'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with profile tap
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                        builder: (_) => ProfilePage(
                      userId: widget.userId,
                      currentUsername: widget.currentUsername,
                        )
                    ),
                    );
                  },
                  child: Row(
                    children: [
                      isLoading
                          ? const CircleAvatar(child: Icon(Icons.group))
                          : (profilePictureUrl != null && profilePictureUrl!.isNotEmpty)
                          ? CircleAvatar(
                        backgroundImage: NetworkImage(profilePictureUrl!),
                      )
                          : const CircleAvatar(child: Icon(Icons.group)),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.teamName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            widget.timeAgo,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (widget.isOwner)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') widget.onEdit();
                      if (value == 'delete') widget.onDelete();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Post content
            Text(widget.content),

            if (widget.imageUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Text(
                        '⚠️ Failed to load image',
                        style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
                      );
                    },
                  ),
                ),
              ),

            const SizedBox(height: 12),

            Row(
              children: [
                GestureDetector(
                  onTap: toggleLike,
                  child: Icon(
                    liked ? Icons.favorite : Icons.favorite_border,
                    color: liked ? Colors.red : null,
                  ),
                ),
                const SizedBox(width: 6),
                Text(likeCount.toString()),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: widget.onComment,
                  child: const Icon(Icons.comment_outlined),
                ),
                const SizedBox(width: 6),
                Text(widget.comments.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
