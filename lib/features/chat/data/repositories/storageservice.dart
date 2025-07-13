import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  StorageService() {}

  Future<String?> uploadProfileImage({
    required File file,
    required String uid,
  }) async {
    try {
      Reference ref =
          _storage.ref('users/pimg').child("$uid${p.extension(file.path)}");
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;

      if (taskSnapshot.state == TaskState.success) {
        String downloadURL = await ref.getDownloadURL();
        return downloadURL;
      } else {
        return null;
      }
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<String?> uploadimg(
      {required File file, required String Chatid}) async {
    Reference _fileref = _storage
        .ref('chats/$Chatid')
        .child("${DateTime.now().toIso8601String()}${p.extension(file.path)}");
    UploadTask _upload = _fileref.putFile(file);
    TaskSnapshot taskSnapshot = await _upload;

    if (taskSnapshot.state == TaskState.success) {
      String downloadURL = await _fileref.getDownloadURL();
      return downloadURL;
    } else {
      return null;
    }
  }
  
}

