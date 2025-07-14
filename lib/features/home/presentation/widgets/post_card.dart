// post_card_body.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:neighbornet/features/chat/data/repositories/firebasefirestore.dart';
import 'package:neighbornet/features/chat/presentation/messaging_page.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  final bool userpost;

  const PostCard({super.key, required this.post, this.userpost = false});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isshare = false;
  final user = FirebaseAuth.instance.currentUser;
  final databaseService = database();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textFields = Map<String, dynamic>.from(
      widget.post['textFields'] ?? {},
    );
    final imageUrls = Map<String, dynamic>.from(widget.post['imageUrls'] ?? {});
    final postType = widget.post['postType'] ?? 'Post';
    final author =
        (widget.post['authorName'] as String?)?.trim().isEmpty ?? true
        ? 'Anonymous'
        : widget.post['authorName'];
    final location = widget.post['address'] ?? 'Unknown';
    final title = _getTitle(postType, textFields);
    final subtitle = _getSubtitle(postType, textFields);
    final imageUrl = imageUrls.values.firstWhere(
      (e) => e != null,
      orElse: () => null,
    );
    final otherUserId = widget.post['uid'] ?? '';
    final publishedAt = formatPostTimestamp(widget.post['timestamp']);
    final phonenumber = widget.post['phoneNumber'] ?? '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme, postType, author),
            const SizedBox(height: 8),
            _buildLocation(theme, location),
            const SizedBox(height: 12),
            if (title != null) _buildTitle(theme, title),
            if (subtitle != null)
              Text(subtitle, style: theme.textTheme.bodyMedium),
            if (imageUrl != null) _buildImage(imageUrl),
            const SizedBox(height: 12),
            // 📅 Published Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '📅 $publishedAt',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                if (author == 'Anonymous')
                  _buildFooter(
                    context,
                    theme,
                    author,
                    otherUserId,
                    phonenumber,
                  ),
              ],
            ),

            /// Show Chat button *after time row* only if author is anonymous
            if (author != 'Anonymous') ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: _buildFooter(
                  context,
                  theme,
                  author,
                  otherUserId,
                  '+923045726681',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, String postType, String author) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left Chip
        Chip(
          label: Text(
            postType,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),

        // Right side row wrapped in Flexible to prevent overflow
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Author name with ellipsis if too long
              widget.userpost
                  ? SizedBox.shrink()
                  : Flexible(
                      child: Text(
                        author,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
              // Remove SizedBox(width: 8) here to eliminate space

              // Share IconButton with zero padding and constraints
              IconButton(
                onPressed: () => sharePostWithImage(widget.post),
                icon: const Icon(Icons.share, size: 17, color: Colors.grey),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                splashRadius: 20,
              ),

              // Popup menu for user posts, also use child IconButton for zero padding
              if (widget.userpost)
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    size: 20,
                    color: Colors.grey,
                  ),
                  padding: EdgeInsets
                      .zero, // remove padding if possible (may require custom)
                  onSelected: (value) async {
                    if (value == 'delete') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Post'),
                          content: const Text(
                            'Are you sure you want to delete this post?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        try {
                          await databaseService.deletePost(
                            widget.post['postId'],
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Post deleted successfully'),
                              ),
                            );
                            // TODO: Refresh or update UI after delete
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to delete post: $e'),
                              ),
                            );
                          }
                        }
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocation(ThemeData theme, String location) {
    return Row(
      children: [
        const Icon(Icons.location_on, size: 16, color: Colors.redAccent),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            location,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(ThemeData theme, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  Widget _buildImage(String imageUrl) {
    return Column(
      children: [
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrl,
            width: double.infinity,
            height: 180,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(
    BuildContext context,
    ThemeData theme,
    String author,
    String otherUserId,
    String phonenumber,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        if (!widget.userpost && user?.uid != otherUserId) ...[
          if (author != 'Anonymous') ...[
            _buildActionButton(
              context,
              'Call',
              'phone-call',
              Theme.of(context).colorScheme.onSecondary,
              () => _makePhoneCall(phonenumber ?? ''),
            ),
            _buildActionButton(
              context,
              'WhatsApp',
              'whatsapp',
              Theme.of(context).colorScheme.onSecondary,
              () => _sendWhatsAppMessage(
                phonenumber ?? '',
                'Hello, I found your post on NeighborNet and would like to discuss it further.',
              ),
            ),
          ],
          _buildActionButton(
            context,
            'Chat',
            'messages',
            Theme.of(context).colorScheme.onSecondary,
            () async {
              final exists = await databaseService.checkuserid(
                user!.uid,
                otherUserId,
              );
              if (!exists) {
                await databaseService.createnewchat(user!.uid, otherUserId);
              }
              final userProfile = await databaseService.getUserProfile(
                otherUserId,
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MessagingPage(
                    chatuserid: userProfile!.uid,
                    chatusername: userProfile.name,
                    chatuserphoto: userProfile.photoUrl,
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    String icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      splashColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/$icon.png', width: 30, height: 30),

            // const SizedBox(width: 8),
            // Text(
            //   label,
            //   style: TextStyle(
            //     color: buttonTextColor,
            //     fontWeight: FontWeight.w600,
            //     fontSize: 16,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendSms(String phoneNumber, String message) async {
    final Uri smsLaunchUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: <String, String>{'body': Uri.encodeComponent(message)},
    );
    await launchUrl(smsLaunchUri);
  }

  Future<void> _sendWhatsAppMessage(String phoneNumber, String message) async {
    // Remove all symbols and spaces from phone number
    String cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // Ensure it's in international format (e.g., 923001234567 for Pakistan)
    if (!cleanedNumber.startsWith('92')) {
      // Add logic if needed to convert to international format
      cleanedNumber = '92$cleanedNumber';
    }

    final encodedMessage = Uri.encodeComponent(message);
    final whatsappUrl = 'https://wa.me/$cleanedNumber?text=$encodedMessage';

    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(
        Uri.parse(whatsappUrl),
        mode: LaunchMode.externalApplication,
      );
    } else {
      debugPrint('Could not launch WhatsApp.');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open WhatsApp.')));
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    await launchUrl(launchUri);
  }

  Future<void> sharePostWithImage(Map<String, dynamic> post) async {
    try {
      setState(() => isshare = true);
      final textFields = Map<String, dynamic>.from(post['textFields'] ?? {});
      final imageUrls = Map<String, dynamic>.from(post['imageUrls'] ?? {});
      final postType = post['postType'] ?? 'Post';
      final author = (post['authorName'] as String?)?.trim().isEmpty ?? true
          ? 'Anonymous'
          : post['authorName'];
      final location = post['address'] ?? 'Unknown';
      final postId = post['postId'];
      final publishedAt = formatPostTimestamp(post['timestamp']);
      final String postDetails =
          '📢 *$postType* on NeighborNet\n\n👤 *Posted by*: $author\n📍 *Location*: $location\n📝 *Details*: ${_getShareableDetails(postType, textFields)}\n📅 *Published At*: $publishedAt\n\nView more details:\nhttps://neighbournet-bd503.web.app/';

      final firstImageUrl = imageUrls.values.firstWhere(
        (e) => e != null,
        orElse: () => null,
      );

      if (firstImageUrl != null) {
        final response = await http.get(Uri.parse(firstImageUrl));
        final documentDirectory = await getApplicationDocumentsDirectory();
        final file = File('${documentDirectory.path}/temp_post_image.jpg');
        file.writeAsBytesSync(response.bodyBytes);
        final xFile = XFile(file.path);
        setState(() => isshare = false);
        await Share.shareXFiles([xFile], text: postDetails);
        await file.delete();
      } else {
        setState(() => isshare = false);
        await Share.share(postDetails);
      }
    } catch (e) {
      setState(() => isshare = false);
    }
  }

  String formatPostTimestamp(dynamic timestamp) {
    DateTime? dateTime;
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else if (timestamp is String) {
      try {
        dateTime = DateTime.parse(timestamp);
      } catch (e) {
        dateTime = null;
      }
    }
    if (dateTime == null) return 'N/A';
    return '${dateTime.day} ${_monthName(dateTime.month)} ${dateTime.year}, ${_formatTime(dateTime)}';
  }

  String _monthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month];
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _getTitle(String postType, Map<String, dynamic> fields) {
    switch (postType) {
      case 'Ask for Help':
        return fields['Title'];
      case 'Giveaway Item':
        return fields['Item Name'];
      case 'Alert':
        return fields['Alert Title'];
      case 'Announcement':
        return fields['Announcement Title'];
      case 'Need Volunteers':
        return fields['Task'];
      default:
        return fields.values.first;
    }
  }

  String? _getSubtitle(String postType, Map<String, dynamic> fields) {
    switch (postType) {
      case 'Giveaway Item':
        return fields['Description'];
      case 'Alert':
      case 'Announcement':
      case 'Need Volunteers':
      case 'Ask for Help':
        return fields['Details'];
      default:
        return null;
    }
  }

  String _getShareableDetails(String postType, Map<String, dynamic> fields) {
    switch (postType) {
      case 'Ask for Help':
      case 'Alert':
      case 'Announcement':
      case 'Need Volunteers':
        return fields['Details'] ?? 'N/A';
      case 'Giveaway Item':
        return fields['Description'] ?? 'N/A';
      default:
        return fields.values.join(', ');
    }
  }
}
