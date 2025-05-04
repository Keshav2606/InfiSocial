import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:infi_social/services/remote_config_service.dart';

Future uploadOnCloudinary(String imagePath) async {
  try {
    final url = Uri.parse('https://api.cloudinary.com/v1_1/${ConfigService.cloudinaryCloudName}/upload');

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = 'xxztgy'
      ..files.add(await http.MultipartFile.fromPath('file', imagePath));

    final response = await request.send();

    final responseData = await response.stream.toBytes();
    final responseString = String.fromCharCodes(responseData);
    final jsonMap = jsonDecode(responseString);

    return jsonMap['url'].toString();
  } catch (error) {
    return null;
  }
}
