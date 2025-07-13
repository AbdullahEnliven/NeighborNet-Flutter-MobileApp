
//import '../domain/models/user_profile_model.dart';

import '../domain/models/user_profile_model.dart';

abstract class UserState {}
class UserInitial extends UserState {}
class UserLoading extends UserState {}
class UserLoaded extends UserState {
  final UserProfile user;
 UserLoaded(this.user);
}
class SavedCompleted extends UserState {}
class UserError extends UserState {
  final String message;
  UserError(this.message);
}