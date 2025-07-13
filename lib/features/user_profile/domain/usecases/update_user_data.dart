import '../../data/user_profiel_repository.dart';
import 'dart:io';

class UpdateUserProfile {
  final UserProfileRepository repository;
  UpdateUserProfile(this.repository);

  Future<void> call({required String name, File? image}) async {
    await repository.saveUserProfile(name: name, imageFile: image);
  }
}