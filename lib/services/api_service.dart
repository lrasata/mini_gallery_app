import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mini_gallery_app/core/config/env_config.dart';
import '../features/gallery/models/image_item.dart';

class ApiService {
  static const Duration _timeout = Duration(seconds: 15);

  static Exception _httpError(String message, http.Response response) {
    final trimmed = response.body.trim();
    String errorMessage = '';
    if (trimmed.length <= 300) {
      errorMessage = trimmed;
    } else {
      errorMessage = '${trimmed.substring(0, 300)}…';
    }

    return Exception(
      '$message (status: ${response.statusCode}, body: $errorMessage)',
    );
  }

  static Future<List<ImageItem>> fetchImages({
    required String userId,
    required String resource,
    http.Client? client,
  }) async {
    final httpClient = client ?? http.Client();
    try {
      final uri = Uri.parse(
        Env.fetchFilesEndpoint,
      ).replace(queryParameters: {'id': userId, 'resource': resource});

      final response = await httpClient.get(uri).timeout(_timeout);
      ;

      if (response.statusCode != 200) {
        throw _httpError('Failed to fetch images', response);
      }

      final decoded = jsonDecode(response.body);

      final imagesJson = decoded['images'];
      if (imagesJson is! List) {
        throw Exception(
          'Failed to fetch images: "images" is missing or not a list',
        );
      }

      final List<ImageItem> images = imagesJson
          .map(
            (imgItem) => ImageItem(
              filename: imgItem['filename'],
              timestamp: DateTime.parse(imgItem['uploaded_timestamp']),
              imageUrl: imgItem['image_url'],
            ),
          )
          .toList();

      // Sort by timestamp descending
      images.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return images;
    } on TimeoutException {
      throw Exception(
        'Failed to fetch images: request timed out after ${_timeout.inSeconds}s',
      );
    } finally {
      if (client == null) httpClient.close();
    }
  }

  static Future<void> uploadFile({
    required String userId,
    required String filename,
    required String resource,
    required List<int> bytes,
    required String mimeType,
    http.Client? client,
  }) async {
    final httpClient = client ?? http.Client();

    try {
      // STEP 1 — Get presigned URL
      final uri = Uri.parse(Env.uploadEndpoint).replace(
        queryParameters: {
          'id': userId,
          'fileKey': filename,
          'resource': resource,
          'mimeType': mimeType,
        },
      );

      final presignResponse = await httpClient
          .get(uri, headers: {'Content-Type': mimeType})
          .timeout(_timeout);
      ;

      if (presignResponse.statusCode != 200) {
        throw _httpError('Failed to get presigned URL', presignResponse);
      }

      final decoded = jsonDecode(presignResponse.body);
      final uploadUrl = decoded['upload_url'] as String;

      // STEP 2 — Upload to S3
      final uploadResponse = await httpClient
          .put(
            Uri.parse(uploadUrl),
            body: bytes,
            headers: {
              'Content-Type': mimeType,
              'x-amz-meta-originalfilename': filename,
            },
          )
          .timeout(_timeout);

      if (uploadResponse.statusCode != 200 &&
          uploadResponse.statusCode != 204) {
        throw _httpError('Upload failed', uploadResponse);
      }
    } on TimeoutException {
      throw Exception(
        'Upload failed: request timed out after ${_timeout.inSeconds}s',
      );
    } finally {
      if (client == null) httpClient.close();
    }
  }
}
