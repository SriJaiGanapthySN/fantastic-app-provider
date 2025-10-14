import 'dart:typed_data';
import 'package:http/http.dart' as http;

Future<Uint8List> downloadFileBytes(String url) async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    return response.bodyBytes;
  } else {
    throw Exception("Failed to fetch file");
  }
}
