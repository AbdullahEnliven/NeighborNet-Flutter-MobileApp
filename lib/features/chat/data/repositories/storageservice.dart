import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as http;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  StorageService();

  Future<String?> uploadProfileImage({
    required File file,
    required String uid,
  }) async {
    try {
      Reference ref =
          _storage.ref('users/pimg').child("$uid${http.extension(file.path)}");
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;

      if (taskSnapshot.state == TaskState.success) {
        String downloadURL = await ref.getDownloadURL();
        return downloadURL;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<String?> uploadimg(
      // ignore: non_constant_identifier_names
      {required File file, required String Chatid}) async {
    Reference fileref = _storage
        .ref('chats/$Chatid')
        .child("${DateTime.now().toIso8601String()}${http.extension(file.path)}");
    UploadTask upload = fileref.putFile(file);
    TaskSnapshot taskSnapshot = await upload;

    if (taskSnapshot.state == TaskState.success) {
      String downloadURL = await fileref.getDownloadURL();
      return downloadURL;
    } else {
      return null;
    }
  }
  
}

