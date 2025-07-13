// presentation/cubit/post_form_state.dart
part of 'post_form_cubit.dart';

abstract class PostFormState {}

class PostFormInitial extends PostFormState {}

class PostFormSubmitting extends PostFormState {}

class PostFormSuccess extends PostFormState {}

class PostFormError extends PostFormState {
  final String message;
  PostFormError(this.message);
}
