import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/user_profiel_repository.dart';
import 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final UserProfileRepository repository;
  UserCubit(this.repository) : super(UserInitial());

  void saveProfile(
    String name,
    File? imageFile,
    String address,
    String bio,
  ) async {
    emit(UserLoading());
    try {
      await repository.saveUserProfile(
        name: name,
        imageFile: imageFile,
        address: address,
        bio: bio,
      );
      //final user = await repository.fetchUserProfile();
      emit(SavedCompleted());
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  void loadUser() async {
    emit(UserLoading());
    try {
      final user = await repository.fetchUserProfile();
      emit(UserLoaded(user));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}
