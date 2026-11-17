import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

import '../models/book_model.dart';

/// BookService - Lapisan service untuk komunikasi dengan REST API
///
/// URL otomatis dipilih sesuai platform:
/// - Flutter Web (Chrome)   → http://localhost:8080/api
/// - Android Emulator       → http://10.0.2.2:8080/api
/// - Windows Desktop        → http://localhost:8080/api
class BookService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080/api';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080/api';
    }
    return 'http://localhost:8080/api';
  }

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ================================================================
  // Helper: Parse error message dari response body
  // Menangani berbagai format error dari server
  // ================================================================
  static String _parseErrorResponse(http.Response response) {
    try {
      final Map<String, dynamic> body = json.decode(response.body);

      // Jika ada field 'errors' (validasi), gabungkan semua pesan error
      if (body['errors'] != null && body['errors'] is Map) {
        final errors = body['errors'] as Map<String, dynamic>;
        final messages = errors.values
            .map((v) => v.toString())
            .where((v) => v.isNotEmpty)
            .join('\n');
        if (messages.isNotEmpty) return messages;
      }

      // Ambil pesan dari field 'message'
      return body['message']?.toString() ?? 'Terjadi kesalahan pada server.';
    } catch (_) {
      return 'Terjadi kesalahan pada server (status ${response.statusCode}).';
    }
  }

  // ================================================================
  // GET /api/books
  // ================================================================
  Future<List<BookModel>> getBooks() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/books'), headers: _headers)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception(
              'Koneksi timeout. Pastikan server backend sudah berjalan di http://localhost:8080',
            ),
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> booksJson = jsonData['data'] ?? [];
        return booksJson
            .map((item) => BookModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(_parseErrorResponse(response));
      }
    } on Exception {
      rethrow;
    }
  }

  // ================================================================
  // GET /api/books/{id}
  // ================================================================
  Future<BookModel> getBookById(int id) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/books/$id'), headers: _headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return BookModel.fromJson(jsonData['data'] as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        throw Exception('Buku dengan ID $id tidak ditemukan.');
      } else {
        throw Exception(_parseErrorResponse(response));
      }
    } on Exception {
      rethrow;
    }
  }

  // ================================================================
  // POST /api/books
  // ================================================================
  Future<BookModel> createBook(BookModel book) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/books'),
            headers: _headers,
            body: json.encode(book.toJson()),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 201) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return BookModel.fromJson(jsonData['data'] as Map<String, dynamic>);
      } else if (response.statusCode == 422 || response.statusCode == 400) {
        // Error validasi dari server
        throw Exception(_parseErrorResponse(response));
      } else {
        throw Exception(_parseErrorResponse(response));
      }
    } on Exception {
      rethrow;
    }
  }

  // ================================================================
  // PUT /api/books/{id}
  // ================================================================
  Future<BookModel> updateBook(int id, BookModel book) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/books/$id'),
            headers: _headers,
            body: json.encode(book.toJson()),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return BookModel.fromJson(jsonData['data'] as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        throw Exception('Buku dengan ID $id tidak ditemukan.');
      } else if (response.statusCode == 422 || response.statusCode == 400) {
        throw Exception(_parseErrorResponse(response));
      } else {
        throw Exception(_parseErrorResponse(response));
      }
    } on Exception {
      rethrow;
    }
  }

  // ================================================================
  // DELETE /api/books/{id}
  // ================================================================
  Future<String> deleteBook(int id) async {
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl/books/$id'), headers: _headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData['message']?.toString() ?? 'Buku berhasil dihapus!';
      } else if (response.statusCode == 404) {
        throw Exception('Buku dengan ID $id tidak ditemukan.');
      } else {
        throw Exception(_parseErrorResponse(response));
      }
    } on Exception {
      rethrow;
    }
  }
}
