import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/book_model.dart';
import '../services/book_service.dart';

/// BookController - GetX State Management untuk LibraryKu
///
/// Mengelola semua state reaktif (.obs) dan memanggil BookService
/// untuk operasi CRUD ke REST API backend CI4.
class BookController extends GetxController {
  final BookService _bookService = BookService();

  // ----------------------------------------------------------------
  // State Reaktif
  // ----------------------------------------------------------------

  /// Semua buku dari API
  final RxList<BookModel> books = <BookModel>[].obs;

  /// Buku yang terfilter berdasarkan pencarian
  final RxList<BookModel> filteredBooks = <BookModel>[].obs;

  /// Detail buku yang sedang ditampilkan
  final Rxn<BookModel> selectedBook = Rxn<BookModel>();

  /// Loading untuk GET semua buku
  final RxBool isLoading = false.obs;

  /// Loading untuk operasi POST/PUT/DELETE (mencegah double submit)
  final RxBool isSubmitting = false.obs;

  /// Pesan error yang ditampilkan di UI
  final RxString errorMessage = ''.obs;

  /// Query pencarian aktif
  final RxString searchQuery = ''.obs;

  // ----------------------------------------------------------------
  // onInit: Dipanggil saat controller pertama kali dibuat
  // ----------------------------------------------------------------
  @override
  void onInit() {
    super.onInit();
    fetchBooks();
    ever(searchQuery, (_) => _filterBooks());
    ever(books, (_) => _filterBooks());
  }

  // ================================================================
  // fetchBooks: GET /api/books
  // ================================================================
  Future<void> fetchBooks() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final List<BookModel> result = await _bookService.getBooks();
      books.assignAll(result);
    } catch (e) {
      errorMessage.value = _cleanError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ================================================================
  // fetchBookDetail: GET /api/books/{id}
  // ================================================================
  Future<void> fetchBookDetail(int id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      selectedBook.value = null;

      final BookModel result = await _bookService.getBookById(id);
      selectedBook.value = result;
    } catch (e) {
      errorMessage.value = _cleanError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ================================================================
  // createBook: POST /api/books
  // Mengembalikan true jika berhasil, false jika gagal.
  // Snackbar sukses HANYA ditampilkan setelah server konfirmasi.
  // ================================================================
  Future<bool> createBook(BookModel book) async {
    // Cegah double submit
    if (isSubmitting.value) return false;

    try {
      isSubmitting.value = true;
      errorMessage.value = '';

      final BookModel newBook = await _bookService.createBook(book);

      // Tambahkan ke list (urutan terbaru di atas)
      books.insert(0, newBook);

      // Notifikasi sukses tepat sesuai spesifikasi
      _showSuccessSnackbar('Sukses', 'Buku berhasil ditambahkan!');

      return true;
    } catch (e) {
      errorMessage.value = _cleanError(e.toString());
      _showErrorSnackbar('Gagal', errorMessage.value.isNotEmpty ? errorMessage.value : 'Gagal menambahkan buku.');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ================================================================
  // updateBook: PUT /api/books/{id}
  // ================================================================
  Future<bool> updateBook(int id, BookModel book) async {
    if (isSubmitting.value) return false;

    try {
      isSubmitting.value = true;
      errorMessage.value = '';

      final BookModel updatedBook = await _bookService.updateBook(id, book);

      // Update item di list reaktif
      final int index = books.indexWhere((b) => b.id == id);
      if (index != -1) {
        books[index] = updatedBook;
      }

      // Update selectedBook jika sedang ditampilkan
      if (selectedBook.value?.id == id) {
        selectedBook.value = updatedBook;
      }

      _showSuccessSnackbar('Sukses', 'Buku berhasil diperbarui!');

      return true;
    } catch (e) {
      errorMessage.value = _cleanError(e.toString());
      _showErrorSnackbar('Gagal', errorMessage.value.isNotEmpty ? errorMessage.value : 'Gagal memperbarui buku.');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ================================================================
  // deleteBook: DELETE /api/books/{id}
  // ================================================================
  Future<bool> deleteBook(int id, String title) async {
    if (isSubmitting.value) return false;

    try {
      isSubmitting.value = true;
      errorMessage.value = '';

      await _bookService.deleteBook(id);

      // Hapus dari list reaktif
      books.removeWhere((b) => b.id == id);

      _showDeleteSnackbar('Sukses', 'Buku berhasil dihapus!');

      return true;
    } catch (e) {
      errorMessage.value = _cleanError(e.toString());
      _showErrorSnackbar('Gagal', errorMessage.value.isNotEmpty ? errorMessage.value : 'Gagal menghapus buku.');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ================================================================
  // Pencarian
  // ================================================================
  void updateSearchQuery(String query) {
    searchQuery.value = query.trim();
  }

  void clearSearch() {
    searchQuery.value = '';
  }

  void clearError() {
    errorMessage.value = '';
  }

  void _filterBooks() {
    final String query = searchQuery.value.toLowerCase();
    if (query.isEmpty) {
      filteredBooks.assignAll(books);
    } else {
      filteredBooks.assignAll(
        books.where((book) {
          return book.title.toLowerCase().contains(query) ||
              book.author.toLowerCase().contains(query);
        }).toList(),
      );
    }
  }

  // ================================================================
  // Statistik Dashboard
  // ================================================================
  int get totalBooks => books.length;
  int get totalStock => books.fold(0, (sum, book) => sum + book.stock);
  int get outOfStockCount => books.where((b) => b.stock == 0).length;
  List<String> get categories =>
      books.map((b) => b.category).toSet().toList()..sort();

  // ================================================================
  // Notifikasi - Menggunakan ScaffoldMessenger yang aman dan otomatis hilang
  // ================================================================

  void _showSuccessSnackbar(String title, String message) {
    final context = Get.context;
    if (context != null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1A2E4A),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(milliseconds: 2500),
        ),
      );
    }
  }

  void _showDeleteSnackbar(String title, String message) {
    final context = Get.context;
    if (context != null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(milliseconds: 2500),
        ),
      );
    }
  }

  void _showErrorSnackbar(String title, String message) {
    final context = Get.context;
    if (context != null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade800,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(milliseconds: 3000),
        ),
      );
    }
  }

  // ================================================================
  // Helper: Bersihkan prefix "Exception: " dari pesan error
  // ================================================================
  String _cleanError(String error) {
    return error.replaceFirst('Exception: ', '').trim();
  }
}
