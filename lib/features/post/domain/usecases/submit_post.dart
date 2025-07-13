// domain/usecases/submit_post.dart
import 'package:image_picker/image_picker.dart';
import 'package:neighbornet/features/post/domain/entities/post_entities.dart';
import 'package:neighbornet/features/post/domain/repositeries/post_repository.dart';

class SubmitPostUseCase {
  final PostRepository repository;

  SubmitPostUseCase(this.repository);

  Future<void> call(
    PostEntity post,
    Map<String, XFile?> images,
    String fcmToken,
    String address,
    String authorName,
    String content,
    String profileurl,
    String postId,
    String phoneNumber,
  ) {
    return repository.submitPost(
      post,
      images,
      fcmToken,
      address,
      authorName,
      content,
      profileurl,
      postId,
      phoneNumber,
    );
  }
}
