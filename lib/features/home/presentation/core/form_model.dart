import 'dart:io';

class PostData {
  final String postType; 
  final Map<String, String> textFields;
  final Map<String, File?> images;

  PostData({
    required this.postType,
    required this.textFields,
    required this.images,
  });
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'postType': postType,
      'textFields': textFields,
      'images': images.map((key, file) => MapEntry(key, file?.path)),
    };
    return map;
  }
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
