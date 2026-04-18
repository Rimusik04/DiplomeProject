import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String?> uploadImageToCloudinary(File imageFile) async {

  final url = Uri.parse(
      "https://api.cloudinary.com/v1_1/dbyfybai7/image/upload");

  var request = http.MultipartRequest("POST", url);

  request.fields['upload_preset'] = 'socpet_upload';

  request.files.add(
    await http.MultipartFile.fromPath(
      'file',
      imageFile.path,
    ),
  );

  var response = await request.send();

  if (response.statusCode == 200) {
    final res = await response.stream.bytesToString();
    final data = jsonDecode(res);

    return data['secure_url'];
  }

  return null;
}