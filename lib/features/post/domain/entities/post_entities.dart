// domain/entities/post_entity.dart
class PostEntity {
  final String postType;
  final Map<String, String> textFields;
  final Map<String, String?> imageUrls;
  final String profileurl;
  final String authorName;
  final String address;
  final String content;
  final String fcmToken;
  final String postId;
  final String phoneNumber;
  PostEntity({
    required this.postType,
    required this.textFields,
    required this.imageUrls,
    required this.profileurl,
    required this.authorName,
    required this.address,
    required this.content,
    required this.fcmToken,
    required this.postId,
    required this.phoneNumber
  });
}
