// data/models/post_model.dart


import 'package:neighbornet/core/constants/user_id.dart';
import 'package:neighbornet/features/post/domain/entities/post_entities.dart';

class PostModel {
  static Map<String, dynamic> toMap(PostEntity entity) {
    return {
      'postType': entity.postType,
      'textFields': entity.textFields,
      'imageUrls': entity.imageUrls,
      'timestamp': DateTime.now().toIso8601String(),
      'uid' : UserId.uid!,
      'profileurl' : entity.profileurl,
      'authorName': entity.authorName,
      'address': entity.address,
      'fcmToken': entity.fcmToken,
      'postId': entity.postId,
      'phoneNumber': entity.phoneNumber,
    };
  }
}
