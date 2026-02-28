class ImageItem {
  final String filename;
  final DateTime timestamp;
  final String imageUrl;

  ImageItem({
    required this.filename,
    required this.timestamp,
    required this.imageUrl,
  });

  factory ImageItem.fromJson(Map<String, dynamic> json) {
    final filename = json['filename'] as String;
    final timestamp = DateTime.parse(json['timestamp'] as String);
    final imageUrl = json['imageUrl'] as String;

    return ImageItem(
      filename: filename,
      timestamp: timestamp,
      imageUrl: imageUrl,
    );
  }
}
