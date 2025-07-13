import 'package:image_picker/image_picker.dart';

import '../entities/post_entities.dart';

abstract class PostRepository {
  Future<void> submitPost(
    PostEntity post,
    Map<String, XFile?> rawImages,
    String fcmToken,
    String address,
    String authorName,
    String content,
    String profileurl,
    String postId,
    String phoneNumber,
  );
}
