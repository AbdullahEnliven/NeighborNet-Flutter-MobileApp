// lib/features/post/domain/usecases/notify_neighbours_usecase.dart

import '../../data/datasources/post_remote_datasource.dart';

class NotifyNeighboursUseCase {
  final PostRemoteDataSource postRemoteDataSource;

  NotifyNeighboursUseCase(this.postRemoteDataSource);

  Future<void> call({
    required String postAddress,
    required String authorName,
    required String postContent,
    required String authorFcmToken,
  }) async {
    await postRemoteDataSource.sendNotificationToNeighbours(
      postAddress: postAddress,
      authorName: authorName,
      postContent: postContent,
      authorFcmToken: authorFcmToken,
    );
  }
}
