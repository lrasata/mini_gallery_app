import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mini_gallery_app/services/api_service.dart';
import 'package:mini_gallery_app/widgets/image_grid.dart';

import '../models/image_item.dart';
import '../widgets/button.dart';

final String userId = "6";
final String resource = "users";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();

  List<ImageItem> _items = [];
  bool _isUploading = false;
  String _status = "";

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

  Future<void> _fetchImages() async {
    setState(() => _status = "Loading...");
    try {
      final images = await ApiService.fetchImages(userId: userId, resource: resource);
      setState(() => _items = images);
    } catch (e) {
      setState(() => _status = "Error fetching images: $e");
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    // Read the picked image bytes
    final bytes = await picked.readAsBytes();

    setState(() => _isUploading = true);

    try {
      await ApiService.uploadFile(userId: userId, filename: picked.name, resource: resource, bytes: bytes);
      await _fetchImages(); // Refresh after upload
      setState(() => _status = "Upload successful");
    } catch (e) {
      setState(() => _status = "Upload failed: $e");
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mini Gallery App',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Welcome User $userId! Upload your images below.",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Button(
              text: "Upload",
              onPressed: _isUploading ? null : _pickAndUploadImage,
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                Text("Number of uploaded images: ${_items.length}",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 16),
                Button(
                  text: "Refresh",
                  onPressed: _isUploading ? null : _fetchImages,
                ),
              ]
            ),

            const SizedBox(height: 12),
            Expanded(
              child: _isUploading
                  ? const Center(child: CircularProgressIndicator())
                  : _items.isEmpty
                      ? const Center(child: Text("No images uploaded yet"))
                      : ImageGrid(items: _items),
            ),
          ],
        ),
      ),
    );
  }
}
