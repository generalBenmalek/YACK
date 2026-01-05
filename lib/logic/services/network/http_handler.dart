import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class HttpHandler {
  static final HttpHandler _instance = HttpHandler._internal();
  factory HttpHandler() => _instance;

  HttpHandler._internal();

  // server
  final String baseUrl = "https://yack.leapcell.app";

  // -----------------------
  // Get Firebase Token
  // -----------------------
  Future<String?> _getIdToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    return await user.getIdToken(true);
  }

  // -----------------------
  // Get FCM Token
  // -----------------------
  Future<String?> _getFcmToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  // -----------------------
  // Common headers
  // -----------------------
  Future<Map<String, String>> _headers() async {
    final token = await _getIdToken();
    return {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };
  }

  // -----------------------
  // POST request
  // -----------------------
  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    final url = Uri.parse("$baseUrl$endpoint");

    // always add FCM token to body
    final fcm = await _getFcmToken();
    body ??= {};
    if (fcm != null) body["fcmToken"] = fcm;

    final response = await http.post(
      url,
      headers: await _headers(),
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  // -----------------------
  // GET request
  // -----------------------
  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse("$baseUrl$endpoint");

    final response = await http.get(
      url,
      headers: await _headers(),
    );

    return _handleResponse(response);
  }

  // -----------------------
  // PUT request
  // -----------------------
  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
    final url = Uri.parse("$baseUrl$endpoint");

    body ??= {};
    final fcm = await _getFcmToken();
    if (fcm != null) body["fcmToken"] = fcm;

    final response = await http.put(
      url,
      headers: await _headers(),
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  // -----------------------
  // PATCH request
  // -----------------------
  Future<dynamic> patch(String endpoint, {Map<String, dynamic>? body}) async {
    final url = Uri.parse("$baseUrl$endpoint");

    body ??= {};
    final fcm = await _getFcmToken();
    if (fcm != null) body["fcmToken"] = fcm;

    final response = await http.patch(
      url,
      headers: await _headers(),
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  // -----------------------
  // DELETE request
  // -----------------------
  Future<dynamic> delete(String endpoint) async {
    final url = Uri.parse("$baseUrl$endpoint");

    final response = await http.delete(
      url,
      headers: await _headers(),
    );

    return _handleResponse(response);
  }

  // -----------------------
  // Handle server responses
  // -----------------------
  dynamic _handleResponse(http.Response res) {
    final status = res.statusCode;

    try {
      final json = jsonDecode(res.body);

      if (status >= 200 && status < 300) return json;

      throw Exception(json["error"] ?? "Unknown server error");
    } catch (_) {
      throw Exception("Invalid server response (${res.statusCode}): ${res.body}");
    }
  }
}
