import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mini_gallery_app/settings/env.dart';
import '../models/image_item.dart';

class ApiService {

  static Future<List<ImageItem>> fetchImages({
    required String userId,
    required String resource,
  }) async {
    final uri = Uri.parse(Env.fetchFilesEndpoint).replace(queryParameters: {
      'id': userId,
      'resource': resource,
    });

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch images: ${response.statusCode}');
    }

    final body = jsonDecode(response.body);

    final List<ImageItem> images = (body['images'] as List)
        .map((img) => ImageItem(
              filename: img['filename'],
              timestamp: DateTime.parse(img['uploaded_timestamp']),
              imageUrl: img['image_url'],
            ))
        .toList();

    // Sort by timestamp descending
    images.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return images;
  }

  static Future<void> uploadFile({
    required String userId,
    required String filename,
    required String resource,
    required List<int> bytes,
  }) async {
    const mimeType = 'image/png';

    // STEP 1 — Get presigned URL
    final uri = Uri.parse(Env.uploadEndpoint).replace(queryParameters: {
      'id': userId,
      'file_key': filename,
      'resource': resource,
      'mimeType': mimeType,
    });

    final presignResponse = await http.get(uri, headers: {
      'Content-Type': mimeType,
    });

    if (presignResponse.statusCode != 200) {
      throw Exception('Failed to get presigned URL');
    }

    final data = jsonDecode(presignResponse.body);
    final uploadUrl = data['upload_url'];

    // STEP 2 — Upload to S3
    final uploadResponse = await http.put(
      Uri.parse(uploadUrl),
      body: bytes,
      headers: {
        'Content-Type': mimeType,
        'x-amz-meta-originalfilename': filename,
      },
    );

    if (uploadResponse.statusCode != 200) {
      throw Exception('Upload failed: ${uploadResponse.statusCode}');
    }
  }
}
