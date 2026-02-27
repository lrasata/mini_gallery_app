import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get uploadEndpoint => dotenv.env['UPLOAD_FILE_ENDPOINT']!;
  static String get fetchFilesEndpoint => dotenv.env['FETCH_FILES_ENDPOINT']!;
}