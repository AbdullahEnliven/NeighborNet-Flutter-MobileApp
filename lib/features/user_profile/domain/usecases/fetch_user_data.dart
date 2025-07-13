import '../../data/user_profiel_repository.dart';
import '../models/user_profile_model.dart';

class FetchUserData {
  final UserProfileRepository repository;
  FetchUserData(this.repository);

  Future<UserProfile> call() async => await repository.fetchUserProfile();
}
