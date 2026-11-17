import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/book_controller.dart';
import '../models/book_model.dart';
import 'book_form_view.dart';
import 'book_list_view.dart';
import 'dashboard_view.dart' show AppColors;

/// BookDetailView - Halaman detail informasi lengkap satu buku
///
/// Menerima [bookId] sebagai parameter, lalu memanggil API
/// GET /api/books/{id} untuk mengambil data terbaru dari server.
class BookDetailView extends StatefulWidget {
  final int bookId;

  const BookDetailView({super.key, required this.bookId});

  @override
  State<BookDetailView> createState() => _BookDetailViewState();
}

class _BookDetailViewState extends State<BookDetailView> {
  final BookController controller = Get.find<BookController>();

  @override
  void initState() {
    super.initState();
    // Ambil detail buku berdasarkan ID saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchBookDetail(widget.bookId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey,
      appBar: AppBar(
        title: const Text('Detail Buku'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Get.back(),
        ),
        actions: [
          // Tombol refresh detail
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => controller.fetchBookDetail(widget.bookId),
          ),
        ],
      ),
      body: Obx(() {
        // State: Loading
        if (controller.isLoading.value) {
          return const _DetailLoading();
        }

        // State: Error
        if (controller.errorMessage.isNotEmpty &&
            controller.selectedBook.value == null) {
          return _DetailError(
            message: controller.errorMessage.value,
            onRetry: () => controller.fetchBookDetail(widget.bookId),
          );
        }

        // State: Buku tidak ditemukan
        if (controller.selectedBook.value == null) {
          return const Center(
            child: Text(
              'Data buku tidak ditemukan.',
              style: TextStyle(color: AppColors.greyMedium),
            ),
          );
        }

        // State: Tampilkan detail buku
        final BookModel book = controller.selectedBook.value!;
        return _buildDetailContent(book);
      }),
    );
  }

  // ----------------------------------------------------------------
  // Konten utama detail buku
  // ----------------------------------------------------------------
  Widget _buildDetailContent(BookModel book) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- Header dengan info utama buku ----
          _buildHeader(book),

          const SizedBox(height: 16),

          // ---- Informasi Detail ----
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Informasi Buku',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 12),

                // Kartu informasi detail
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.person_outline,
                        label: 'Pengarang',
                        value: book.author,
                      ),
                      _Divider(),
                      _InfoRow(
                        icon: Icons.qr_code,
                        label: 'ISBN',
                        value: book.isbn,
                      ),
                      _Divider(),
                      _InfoRow(
                        icon: Icons.business_outlined,
                        label: 'Penerbit',
                        value: book.publisher,
                      ),
                      _Divider(),
                      _InfoRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Tahun Terbit',
                        value: book.publishedYear.toString(),
                      ),
                      _Divider(),
                      _InfoRow(
                        icon: Icons.category_outlined,
                        label: 'Kategori',
                        value: book.category,
                      ),
                      _Divider(),
                      _InfoRow(
                        icon: Icons.inventory_2_outlined,
                        label: 'Stok Tersedia',
                        value: '${book.stock} eksemplar',
                        valueColor: book.stock > 0
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ],
                  ),
                ),

                // ---- Deskripsi Buku ----
                if (book.description.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Deskripsi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      book.description,
                      style: const TextStyle(
                        color: AppColors.greyMedium,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // ---- Tombol Aksi: Edit & Hapus ----
                Row(
                  children: [
                    // Tombol Edit
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await Get.to(
                            () => BookFormView(book: book),
                          );
                          // Refresh detail setelah kembali dari form edit
                          controller.fetchBookDetail(widget.bookId);
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit Buku'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navy,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Tombol Hapus
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showDeleteDialog(book),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.error,
                        ),
                        label: const Text(
                          'Hapus',
                          style: TextStyle(color: AppColors.error),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------
  // Header: Judul + Badge Kategori & Stok
  // ----------------------------------------------------------------
  Widget _buildHeader(BookModel book) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navy, AppColors.navyLight],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon buku besar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.book_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 14),
          // Judul buku
          Text(
            book.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          // Pengarang
          Text(
            'oleh ${book.author}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 14),
          // Badge bawah
          Row(
            children: [
              _HeaderBadge(label: book.category, icon: Icons.label_outline),
              const SizedBox(width: 8),
              _HeaderBadge(
                label: book.stock > 0 ? 'Tersedia' : 'Stok Habis',
                icon: book.stock > 0
                    ? Icons.check_circle_outline
                    : Icons.cancel_outlined,
                color: book.stock > 0
                    ? const Color(0xFF48BB78)
                    : AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------
  // Dialog Konfirmasi Hapus
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
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.greyMedium),
            ),
          ),
          Obx(
            () => ElevatedButton(
              onPressed: controller.isSubmitting.value
                  ? null
                  : () async {
                      Get.back(); // Tutup dialog konfirmasi terlebih dahulu
                      final bool success = await controller.deleteBook(
                        book.id!,
                        book.title,
                      );
                      if (success) {
                        // Kembali ke halaman daftar buku
                        Get.offAll(() => const BookListView());
                      }
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
// Widget Pembantu
// ================================================================

/// Baris informasi detail (icon + label + value)
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.blue, size: 20),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.greyMedium,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? AppColors.navy,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Garis pembatas tipis antar baris
class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      indent: 48,
      endIndent: 16,
      color: Color(0xFFF0F0F0),
    );
  }
}

/// Badge di header buku
class _HeaderBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color;

  const _HeaderBadge({
    required this.label,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color ?? Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color ?? Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading state untuk detail buku
class _DetailLoading extends StatelessWidget {
  const _DetailLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.navy),
          SizedBox(height: 16),
          Text(
            'Memuat detail buku...',
            style: TextStyle(color: AppColors.greyMedium),
          ),
        ],
      ),
    );
  }
}

/// Error state untuk detail buku
class _DetailError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DetailError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Gagal Memuat Detail',
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
