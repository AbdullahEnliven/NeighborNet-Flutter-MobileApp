
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neighbornet/features/pushnotification/send_notfication.dart';

abstract class PostRemoteDataSource {
  Future<void> sendNotificationToNeighbours({
    required String postAddress,
    required String authorName,
    required String postContent,
    required String authorFcmToken,
  });
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {

  @override
  Future<void> sendNotificationToNeighbours({
    required String postAddress,
    required String authorName,
    required String postContent,
    required String authorFcmToken,
  }) async {
    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('address', isEqualTo: postAddress)
        .get();

    final tokens = usersSnapshot.docs
        .map((doc) => doc['fcmToken'] as String?)
        .where((token) => token != null && token != authorFcmToken)
        .toList();

    for (final token in tokens) {
      await SendNotification.sendPushNotification(
        fcmToken: token!,
        title: 'New post from $authorName',
        message: postContent,
      );
    }
  }
}
