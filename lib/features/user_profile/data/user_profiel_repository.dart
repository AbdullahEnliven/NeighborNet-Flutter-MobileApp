import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../domain/models/user_profile_model.dart';

class UserProfileRepository {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  Future<void> saveUserProfile({
    required String name,
    File? imageFile,
    String? address,
    String? bio,
  }) async {
    final uid = _auth.currentUser!.uid;
    final phone = _auth.currentUser!.phoneNumber ?? "";

    // Fetch existing user profile if exists
    DocumentSnapshot existingDoc = await _firestore
        .collection('users')
        .doc(uid)
        .get();
    UserProfile? existingProfile;
    if (existingDoc.exists) {
      existingProfile = UserProfile.fromMap(
        existingDoc.data() as Map<String, dynamic>,
      );
    }

    // Upload image if new image is picked
    String? imageUrl = existingProfile?.photoUrl;
    if (imageFile != null) {
      final ref = _storage.ref().child('profile_images/$uid.jpg');
      await ref.putFile(imageFile);
      imageUrl = await ref.getDownloadURL();
    }

    // Handle location permission and fetch only if location not yet stored
    String location = existingProfile?.location ?? '';
    String finalAddress = address ?? existingProfile?.address ?? '';

    if (location.isEmpty || finalAddress.isEmpty) {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied.');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied.');
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: AndroidSettings(accuracy: LocationAccuracy.best),
      );

      final lat = position.latitude;
      final lng = position.longitude;
      final locationCoords = "$lat, $lng";

      final placemarks = await placemarkFromCoordinates(lat, lng);
      final place = placemarks.first;
      finalAddress = "${place.subLocality ?? ''}, ${place.locality ?? ''}"
          .trim();
      location = "$locationCoords - $finalAddress";
    }

    final userProfile = UserProfile(
      uid: uid,
      phoneNumber: phone,
      name: name,
      photoUrl: imageUrl ?? '',
      location: location,
      address: finalAddress,
      bio: bio ?? existingProfile?.bio ?? '',
    );

    await _firestore.collection('users').doc(uid).set(userProfile.toMap());
  }

  Future<UserProfile> fetchUserProfile() async {
    final uid = _auth.currentUser!.uid;
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) throw Exception("User profile not found");
    return UserProfile.fromMap(doc.data()!);
  }
}
