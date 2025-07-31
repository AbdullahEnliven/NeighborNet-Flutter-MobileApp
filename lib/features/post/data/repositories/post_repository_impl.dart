// data/repositories/post_repository_impl.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neighbornet/features/post/data/datasources/post_remote_datasource.dart';

import '../../domain/entities/post_entities.dart';

import '../../domain/repositeries/post_repository.dart';

import '../models/post_model.dart';

class PostRepositoryImpl implements PostRepository {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final PostRemoteDataSource postRemoteDataSource;

  PostRepositoryImpl(this.firestore, this.storage, this.postRemoteDataSource);

  @override
  Future<void> submitPost(
    PostEntity post,
    Map<String, XFile?> rawImages,
    String fcmToken,
    String adress,
    String authorName,
    String content,
    String profileurl,
    String postId,
    String phoneNumber,
  ) async {
    final imageUrls = <String, String?>{};

    for (final entry in rawImages.entries) {
      final file = entry.value;
      if (file != null) {
        final ref = storage.ref().child(
          'posts/${DateTime.now().millisecondsSinceEpoch}_${entry.key}',
        );
        final uploadTask = await ref.putFile(File(file.path));
        final url = await uploadTask.ref.getDownloadURL();
        imageUrls[entry.key] = url;
      } else {
        imageUrls[entry.key] = null;
      }
    }

    final finalPost = PostEntity(
      postType: post.postType,
      textFields: post.textFields,
      imageUrls: imageUrls,
      profileurl: profileurl,
      authorName: authorName,
      address:adress,
      content: content,
      fcmToken: fcmToken,
      postId: post.postId,
      phoneNumber: post.phoneNumber,
    );

    await firestore.collection('posts').doc(postId).set(PostModel.toMap(finalPost));
    await postRemoteDataSource.sendNotificationToNeighbours(
      authorFcmToken: fcmToken,
      authorName: authorName,
      postAddress: adress,
      postContent: content,
    );
  }
}
