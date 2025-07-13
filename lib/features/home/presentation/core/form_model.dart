import 'dart:io';

class PostData {
  final String postType; // e.g., 'Ask for Help', 'Giveaway Item', etc.

  // Text fields stored as a map: label -> value
  final Map<String, String> textFields;

  // Images stored as a map: label -> File (nullable if no image)
  final Map<String, File?> images;

  PostData({
    required this.postType,
    required this.textFields,
    required this.images,
  });

  // Convert to Map for serialization (e.g. saving to Firestore)
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'postType': postType,
      'textFields': textFields,
      // For images, you might upload separately and store URLs here,
      // so here just store null or placeholder string
      'images': images.map((key, file) => MapEntry(key, file?.path ?? null)),
    };
    return map;
  }

  // Create from map (e.g., from Firestore)
  factory PostData.fromMap(Map<String, dynamic> map) {
    return PostData(
      postType: map['postType'] ?? '',
      textFields: Map<String, String>.from(map['textFields'] ?? {}),
      images: (map['images'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value != null ? File(value) : null),
          ) ??
          {},
    );
  }
}
