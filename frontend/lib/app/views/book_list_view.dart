import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/book_controller.dart';
import '../models/book_model.dart';
import 'book_detail_view.dart';
import 'book_form_view.dart';
import 'dashboard_view.dart' show AppColors;

/// BookListView - Halaman daftar semua buku
///
/// Fitur:
/// - Daftar buku dalam bentuk card
/// - Pencarian berdasarkan judul/pengarang
/// - Pull-to-refresh
/// - Loading, error, dan empty state
/// - Navigasi ke detail dan form edit
/// - Hapus buku dengan dialog konfirmasi
class BookListView extends StatefulWidget {
  const BookListView({super.key});

  @override
  State<BookListView> createState() => _BookListViewState();
}

class _BookListViewState extends State<BookListView> {
  final BookController controller = Get.find<BookController>();

  // Controller untuk TextField pencarian
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    // Bersihkan controller saat halaman ditutup
    _searchController.dispose();
    // Reset pencarian saat keluar dari halaman
    controller.clearSearch();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey,
      appBar: AppBar(
        title: const Text('Daftar Buku'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Get.back(),
        ),
        actions: [
          // Tombol refresh manual
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: controller.fetchBooks,
          ),
        ],
      ),
      // Tombol tambah buku floating
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Navigasi ke form tambah buku, tunggu hasilnya
          await Get.to(() => const BookFormView());
          controller.fetchBooks();
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Buku'),
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // ---- Search Bar ----
          _buildSearchBar(),

          // ---- Daftar Buku ----
          Expanded(
            child: Obx(() {
              // State: Loading pertama kali
              if (controller.isLoading.value && controller.books.isEmpty) {
                return const _LoadingContent();
              }

              // State: Error dan data kosong
              if (controller.errorMessage.isNotEmpty &&
                  controller.books.isEmpty) {
                return _ErrorContent(
                  message: controller.errorMessage.value,
                  onRetry: controller.fetchBooks,
                );
              }

              // State: Data ada tapi filter menghasilkan kosong
              if (controller.filteredBooks.isEmpty &&
                  controller.searchQuery.isNotEmpty) {
                return _SearchEmptyContent(
                  query: controller.searchQuery.value,
                );
              }

              // State: Tidak ada buku sama sekali
              if (controller.books.isEmpty) {
                return _EmptyContent(
                  onAdd: () => Get.to(() => const BookFormView()),
                );
              }

              // State: Tampilkan daftar buku
              return RefreshIndicator(
                onRefresh: () async {
                  _searchController.clear();
                  controller.clearSearch();
                  await controller.fetchBooks();
                },
                color: AppColors.navy,
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: controller.filteredBooks.length,
                  itemBuilder: (context, index) {
                    final BookModel book = controller.filteredBooks[index];
                    return _BookCard(
                      book: book,
                      onTap: () async {
                        await Get.to(
                          () => BookDetailView(bookId: book.id!),
                        );
                        controller.fetchBooks();
                      },
                      onEdit: () async {
                        await Get.to(
                          () => BookFormView(book: book),
                        );
                        controller.fetchBooks();
                      },
                      onDelete: () => _showDeleteDialog(book),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------
  // Search Bar Widget
  // ----------------------------------------------------------------
  Widget _buildSearchBar() {
    return Container(
      color: AppColors.navy,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: TextField(
        controller: _searchController,
        onChanged: controller.updateSearchQuery,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Cari judul atau pengarang...',
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.white70),
          suffixIcon: Obx(
            () => controller.searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () {
                      _searchController.clear();
                      controller.clearSearch();
                    },
                  )
                : const SizedBox.shrink(),
          ),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white54),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  // ----------------------------------------------------------------
  // Dialog Konfirmasi Hapus Buku
  // ----------------------------------------------------------------
  void _showDeleteDialog(BookModel book) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.warning),
            SizedBox(width: 8),
            Text(
              'Hapus Buku',
              style: TextStyle(
                color: AppColors.navy,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus buku ini?',
          style: TextStyle(
            color: AppColors.greyMedium,
            fontSize: 14,
          ),
        ),
        actions: [
          // Tombol batal
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.greyMedium),
            ),
          ),
          // Tombol hapus
          Obx(
            () => ElevatedButton(
              onPressed: controller.isSubmitting.value
                  ? null
                  : () async {
                      Get.back(); // Tutup dialog konfirmasi terlebih dahulu
                      await controller.deleteBook(
                        book.id!,
                        book.title,
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: controller.isSubmitting.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Ya, Hapus'),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}

// ================================================================
// Widget: Kartu Buku
// ================================================================
class _BookCard extends StatelessWidget {
  final BookModel book;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BookCard({
    required this.book,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Ikon Buku ----
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.blueLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.book_rounded,
                  color: AppColors.navy,
                  size: 26,
                ),
              ),

              const SizedBox(width: 14),

              // ---- Info Buku ----
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.navy,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Pengarang
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 14,
                          color: AppColors.greyMedium,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            book.author,
                            style: const TextStyle(
                              color: AppColors.greyMedium,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Penerbit & Tahun
                    Row(
                      children: [
                        const Icon(
                          Icons.business_outlined,
                          size: 14,
                          color: AppColors.greyMedium,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${book.publisher} · ${book.publishedYear}',
                            style: const TextStyle(
                              color: AppColors.greyMedium,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Baris bawah: kategori + stok + tombol aksi
                    Row(
                      children: [
                        // Badge kategori
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.blueLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            book.category,
                            style: const TextStyle(
                              color: AppColors.blue,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Badge stok
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: book.stock > 0
                                ? const Color(0xFFE6F4EE)
                                : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Stok: ${book.stock}',
                            style: TextStyle(
                              color: book.stock > 0
                                  ? AppColors.success
                                  : AppColors.error,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Tombol edit
                        IconButton(
                          onPressed: onEdit,
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: AppColors.blue,
                            size: 20,
                          ),
                          tooltip: 'Edit',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 12),
                        // Tombol hapus
                        IconButton(
                          onPressed: onDelete,
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.error,
                            size: 20,
                          ),
                          tooltip: 'Hapus',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// Widget: Loading
// ================================================================
class _LoadingContent extends StatelessWidget {
  const _LoadingContent();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.navy),
          SizedBox(height: 16),
          Text(
            'Memuat data buku...',
            style: TextStyle(color: AppColors.greyMedium),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// Widget: Error State
// ================================================================
class _ErrorContent extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorContent({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: AppColors.error,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Gagal Memuat Data',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.greyMedium,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// Widget: Empty State (tidak ada buku)
// ================================================================
class _EmptyContent extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyContent({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books_outlined,
              color: Colors.grey.shade400,
              size: 80,
            ),
            const SizedBox(height: 16),
            const Text(
              'Koleksi Masih Kosong',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada buku yang ditambahkan.\nMulai tambahkan koleksi buku Anda!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Tambah Buku Pertama'),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// Widget: Empty State (hasil pencarian kosong)
// ================================================================
class _SearchEmptyContent extends StatelessWidget {
  final String query;

  const _SearchEmptyContent({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              color: Colors.grey.shade400,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Buku Tidak Ditemukan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tidak ada buku dengan kata kunci\n"$query"',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
