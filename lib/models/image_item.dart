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
    return ImageItem(
      filename: json['filename'],
      timestamp: DateTime.parse(json['timestamp']),
      imageUrl: json['imageUrl'],
    );
  }
}
