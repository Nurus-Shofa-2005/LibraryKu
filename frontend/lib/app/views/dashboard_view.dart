import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/book_controller.dart';
import '../models/book_model.dart';
import 'book_list_view.dart';
import 'book_form_view.dart';

// ----------------------------------------------------------------
// Konstanta warna tema LibraryKu
// ----------------------------------------------------------------
class AppColors {
  static const Color navy = Color(0xFF1A2E4A);
  static const Color navyLight = Color(0xFF2A4166);
  static const Color blue = Color(0xFF4A90D9);
  static const Color blueLight = Color(0xFFE8F2FC);
  static const Color grey = Color(0xFFF5F7FA);
  static const Color greyMedium = Color(0xFF6B7280);
  static const Color white = Colors.white;
  static const Color error = Color(0xFFE53E3E);
  static const Color success = Color(0xFF38A169);
  static const Color warning = Color(0xFFDD6B20);
}

/// DashboardView - Halaman utama LibraryKu
///
/// Menampilkan:
/// - Header berisi nama app dan tombol tambah buku
/// - Kartu statistik: total buku, total stok, buku habis stok
/// - Daftar buku terbaru (5 teratas)
/// - Tombol akses cepat ke halaman daftar buku
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil controller yang sudah di-register di main.dart
    final BookController controller = Get.find<BookController>();

    return Scaffold(
      backgroundColor: AppColors.grey,
      body: RefreshIndicator(
        // pull-to-refresh: panggil ulang fetchBooks saat ditarik ke bawah
        onRefresh: controller.fetchBooks,
        color: AppColors.navy,
        child: CustomScrollView(
          slivers: [
            // ------------------------------------------------
            // AppBar dengan gradient navy
            // ------------------------------------------------
            SliverAppBar(
              expandedHeight: 140,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.navy,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.navy, AppColors.navyLight],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Icon buku
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.local_library_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'LibraryKu',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const Spacer(),
                              // Tombol tambah buku
                              ElevatedButton.icon(
                                onPressed: () async {
                                  await Get.to(
                                    () => const BookFormView(),
                                  );
                                  controller.fetchBooks();
                                },
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Tambah'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Sistem Manajemen Perpustakaan',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ------------------------------------------------
            // Body konten dashboard
            // ------------------------------------------------
            SliverToBoxAdapter(
              child: Obx(() {
                // Tampilkan loading saat pertama kali fetch
                if (controller.isLoading.value && controller.books.isEmpty) {
                  return const _LoadingWidget();
                }

                // Tampilkan error jika gagal konek ke server
                if (controller.errorMessage.isNotEmpty &&
                    controller.books.isEmpty) {
                  return _ErrorWidget(
                    message: controller.errorMessage.value,
                    onRetry: controller.fetchBooks,
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // ---- Kartu Statistik ----
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ringkasan Koleksi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.navy,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              // Stat: Total Buku
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.book_rounded,
                                  label: 'Total Buku',
                                  value: controller.totalBooks.toString(),
                                  color: AppColors.navy,
                                  bgColor: AppColors.blueLight,
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Stat: Total Stok
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.inventory_2_rounded,
                                  label: 'Total Stok',
                                  value: controller.totalStock.toString(),
                                  color: AppColors.success,
                                  bgColor: const Color(0xFFE6F4EE),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Stat: Stok Habis
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.warning_amber_rounded,
                                  label: 'Stok Habis',
                                  value:
                                      controller.outOfStockCount.toString(),
                                  color: AppColors.warning,
                                  bgColor: const Color(0xFFFEF0E6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ---- Akses Cepat ----
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Menu',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.navy,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              // Tombol: Daftar Semua Buku
                              Expanded(
                                child: _QuickAccessButton(
                                  icon: Icons.list_alt_rounded,
                                  label: 'Daftar Buku',
                                  onTap: () => Get.to(
                                    () => const BookListView(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Tombol: Tambah Buku
                              Expanded(
                                child: _QuickAccessButton(
                                  icon: Icons.add_circle_outline_rounded,
                                  label: 'Tambah Buku',
                                  onTap: () => Get.to(
                                    () => const BookFormView(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ---- Daftar Buku Terbaru ----
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Buku Terbaru',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.navy,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Get.to(
                              () => const BookListView(),
                            ),
                            child: const Text(
                              'Lihat Semua',
                              style: TextStyle(
                                color: AppColors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Tampilkan buku (maks 5) atau pesan kosong
                    if (controller.books.isEmpty)
                      const _EmptyStateWidget(
                        message: 'Belum ada buku.\nTambahkan buku pertama Anda!',
                      )
                    else
                      ListView.builder(
                        // Nonaktifkan scroll ListView karena sudah ada
                        // CustomScrollView di luar
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        // Ambil maksimal 5 buku terbaru
                        itemCount: controller.books.length > 5
                            ? 5
                            : controller.books.length,
                        itemBuilder: (context, index) {
                          final BookModel book = controller.books[index];
                          return _DashboardBookCard(book: book);
                        },
                      ),

                    const SizedBox(height: 24),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// Widget: Kartu Statistik
// ================================================================
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color bgColor;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.greyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// Widget: Tombol Akses Cepat
// ================================================================
class _QuickAccessButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAccessButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.navy, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.navy,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// Widget: Kartu Buku di Dashboard (ringkas)
// ================================================================
class _DashboardBookCard extends StatelessWidget {
  final BookModel book;

  const _DashboardBookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.blueLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.book_rounded,
            color: AppColors.navy,
            size: 22,
          ),
        ),
        title: Text(
          book.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.navy,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${book.author} · ${book.category}',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.greyMedium,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: book.stock > 0
                ? const Color(0xFFE6F4EE)
                : const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Stok: ${book.stock}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: book.stock > 0 ? AppColors.success : AppColors.error,
            ),
          ),
        ),
        onTap: () {
          // Navigasi ke halaman daftar buku saat tap
          Get.to(() => const BookListView());
        },
      ),
    );
  }
}

// ================================================================
// Widget: Loading Indicator
// ================================================================
class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.navy),
            SizedBox(height: 16),
            Text(
              'Memuat data...',
              style: TextStyle(color: AppColors.greyMedium, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// Widget: Error State
// ================================================================
class _ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded,
                  color: AppColors.error, size: 56),
              const SizedBox(height: 16),
              const Text(
                'Gagal Terhubung ke Server',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
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
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// Widget: Empty State
// ================================================================
class _EmptyStateWidget extends StatelessWidget {
  final String message;

  const _EmptyStateWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books_outlined,
              color: Colors.grey.shade400,
              size: 56,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
