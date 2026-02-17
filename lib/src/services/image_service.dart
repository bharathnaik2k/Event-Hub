import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// const String imageKitPrivateKey = '';
// const String imageKitUploadUrl = '';

Future<String> uploadDirect(File file) async {
  final request = http.MultipartRequest(
    'POST',
    Uri.parse(dotenv.env['IMAGE_KIT_UPLOAD_URL']!),
  );
  request.files.add(await http.MultipartFile.fromPath('file', file.path));
  request.fields['fileName'] = file.path.split('/').last;
  final basicAuth =
      'Basic ${base64Encode(utf8.encode('${dotenv.env['IMAGE_KIT_PRIVATE_KEY']!}:'))}';
  request.headers['Authorization'] = basicAuth;

  final response = await request.send();
  final respStr = await response.stream.bytesToString();

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(respStr);
    final url = jsonResponse['url'];
    log('image URL: $url');
    return url;
  } else {
    log('(${response.statusCode}): $respStr');
    return "";
  }
}
