class UserProfile {
  final String uid;
  final String phoneNumber;
  final String name;
  final String photoUrl;
  final String location;
  final String address;
  final String bio;
  final String fcmToken;
  UserProfile({
    required this.uid,
    required this.phoneNumber,
    required this.name,
    required this.photoUrl,
    required this.location,
    this.bio = '',
    this.address = '',
    this.fcmToken='',
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'phoneNumber': phoneNumber,
        'name': name,
        'photoUrl': photoUrl,
        'location': location,
        'bio': bio,
        'address': address,
        'fcmToken': fcmToken
      };

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
        uid: map['uid'],
        phoneNumber: map['phoneNumber'],
        name: map['name'],
        photoUrl: map['photoUrl'],
        location: map['location'],
        bio: map['bio'] ?? '',
        address: map['address'] ?? '',
        fcmToken: map['fcmToken'] ?? ''
      );
}