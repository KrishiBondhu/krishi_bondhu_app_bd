import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StorageService {
  final String _imgbbApiKey =
      "14de6aa76a479b81224e18a9087f5bac"; // <-- Make sure your API key is here

  // This function now uploads a *list* of images
  Future<List<String>> uploadMultipleImages(List<File> images) async {
    List<String> imageUrls = [];
    try {
      for (File image in images) {
        String url = await _uploadSingleImage(image);
        imageUrls.add(url);
      }
      return imageUrls;
    } catch (e) {
      print("Error uploading multiple images: $e");
      throw Exception('Image upload failed');
    }
  }

  // This is your old function, renamed
  Future<String> _uploadSingleImage(File image) async {
    final uri = Uri.parse('https://api.imgbb.com/1/upload?key=$_imgbbApiKey');
    var request = http.MultipartRequest('POST', uri);
    var file = await http.MultipartFile.fromPath('image', image.path);
    request.files.add(file);

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(responseBody);
      return jsonResponse['data']['url'];
    } else {
      print('ImgBB Error: $responseBody');
      throw Exception('Image upload failed');
    }
  }
}
