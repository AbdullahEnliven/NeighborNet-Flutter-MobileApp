// presentation/cubit/post_form_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neighbornet/features/post/domain/entities/post_entities.dart';


import '../../domain/usecases/submit_post.dart';

part 'post_form_state.dart';

class PostFormCubit extends Cubit<PostFormState> {
  final SubmitPostUseCase submitPost;
  
  PostFormCubit(this.submitPost) : super(PostFormInitial());

  Future<void> submitForm({
    required String postType,
    required Map<String, String> textFields,
    required Map<String, XFile?> imageFiles,
    required String fcmToken,
    required String address,
    required String content,
    required String authorName,
    required String profileurl,
    required String postId,
    required String phoneNumber,
  }) async {
    emit(PostFormSubmitting());
    try {
      final post = PostEntity(
        postType: postType,
        textFields: textFields,
        imageUrls: {}, // imageUrls will be handled inside repository
        profileurl: profileurl,
        authorName: authorName,
        address: address,
        content: content,
        fcmToken: fcmToken,
        postId: postId,
        phoneNumber: phoneNumber,
      );
      await submitPost(post, imageFiles,fcmToken, address, authorName, content,profileurl, postId, phoneNumber);
      emit(PostFormSuccess());
    } catch (e) {
      emit(PostFormError(e.toString()));
    }
  }
}
