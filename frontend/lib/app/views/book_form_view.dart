import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/book_controller.dart';
import '../models/book_model.dart';
import 'dashboard_view.dart' show AppColors;

/// BookFormView - Form Tambah dan Edit Buku
///
/// Mode Tambah: BookFormView()           → POST /api/books
/// Mode Edit  : BookFormView(book: data) → PUT  /api/books/{id}
///
/// Perbaikan:
/// - Navigasi otomatis ke halaman sebelumnya setelah sukses
/// - Input dipertahankan saat gagal
/// - Tombol dinonaktifkan saat submit (cegah double submit)
/// - Pesan error dari server tampil di dalam form
/// - Validasi lengkap dengan pesan bahasa Indonesia
class BookFormView extends StatefulWidget {
  final BookModel? book;

  const BookFormView({super.key, this.book});

  @override
  State<BookFormView> createState() => _BookFormViewState();
}

class _BookFormViewState extends State<BookFormView> {
  final BookController controller = Get.find<BookController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Text controllers untuk setiap field
  late final TextEditingController _titleCtrl;
  late final TextEditingController _authorCtrl;
  late final TextEditingController _isbnCtrl;
  late final TextEditingController _publisherCtrl;
  late final TextEditingController _yearCtrl;
  late final TextEditingController _stockCtrl;
  late final TextEditingController _descCtrl;

  String? _selectedCategory;

  final List<String> _categories = [
    'Fiksi',
    'Non-Fiksi',
    'Sains & Teknologi',
    'Sejarah',
    'Biografi',
    'Pendidikan',
    'Agama',
    'Ekonomi & Bisnis',
    'Hukum',
    'Kesehatan',
    'Seni & Budaya',
    'Lainnya',
  ];

  bool get _isEditMode => widget.book != null;

  @override
  void initState() {
    super.initState();
    final b = widget.book;

    _titleCtrl = TextEditingController(text: b?.title ?? '');
    _authorCtrl = TextEditingController(text: b?.author ?? '');
    _isbnCtrl = TextEditingController(text: b?.isbn ?? '');
    _publisherCtrl = TextEditingController(text: b?.publisher ?? '');
    _yearCtrl = TextEditingController(
      text: b?.publishedYear != null ? b!.publishedYear.toString() : '',
    );
    _stockCtrl = TextEditingController(
      text: b?.stock != null ? b!.stock.toString() : '',
    );
    _descCtrl = TextEditingController(text: b?.description ?? '');

    _selectedCategory = b?.category;

    // Pastikan kategori dari data ada di list
    if (_selectedCategory != null && !_categories.contains(_selectedCategory)) {
      _categories.add(_selectedCategory!);
    }

    // Bersihkan error saat form dibuka
    controller.clearError();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _authorCtrl.dispose();
    _isbnCtrl.dispose();
    _publisherCtrl.dispose();
    _yearCtrl.dispose();
    _stockCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey,
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Buku' : 'Tambah Buku'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            controller.clearError();
            Get.back();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---- Judul Buku ----
                    _label('Judul Buku *'),
                    _textField(
                      controller: _titleCtrl,
                      hint: 'Masukkan judul buku',
                      icon: Icons.book_outlined,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Judul buku wajib diisi.';
                        }
                        if (val.trim().length < 3) {
                          return 'Judul minimal 3 karakter.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ---- Penulis / Pengarang ----
                    _label('Penulis *'),
                    _textField(
                      controller: _authorCtrl,
                      hint: 'Masukkan nama penulis',
                      icon: Icons.person_outline,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Nama penulis wajib diisi.';
                        }
                        if (val.trim().length < 3) {
                          return 'Nama penulis minimal 3 karakter.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ---- ISBN ----
                    _label('ISBN *'),
                    _textField(
                      controller: _isbnCtrl,
                      hint: 'Contoh: 978-602-123-456-7',
                      icon: Icons.qr_code,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'ISBN wajib diisi.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ---- Penerbit ----
                    _label('Penerbit *'),
                    _textField(
                      controller: _publisherCtrl,
                      hint: 'Masukkan nama penerbit',
                      icon: Icons.business_outlined,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Penerbit wajib diisi.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ---- Tahun Terbit & Stok ----
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Tahun Terbit *'),
                              TextFormField(
                                controller: _yearCtrl,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                ],
                                decoration: const InputDecoration(
                                  hintText: 'Contoh: 2023',
                                  prefixIcon: Icon(
                                    Icons.calendar_today_outlined,
                                    color: AppColors.greyMedium,
                                    size: 20,
                                  ),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Tahun terbit tidak valid.';
                                  }
                                  final year = int.tryParse(val);
                                  if (year == null || year < 1000 || year > 9999) {
                                    return 'Tahun terbit tidak valid.';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Stok *'),
                              TextFormField(
                                controller: _stockCtrl,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: const InputDecoration(
                                  hintText: 'Jumlah stok',
                                  prefixIcon: Icon(
                                    Icons.inventory_2_outlined,
                                    color: AppColors.greyMedium,
                                    size: 20,
                                  ),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Stok wajib diisi.';
                                  }
                                  final stock = int.tryParse(val);
                                  if (stock == null || stock < 0) {
                                    return 'Stok tidak boleh kurang dari 0.';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ---- Kategori ----
                    _label('Kategori *'),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      hint: const Text('Pilih kategori buku'),
                      items: _categories
                          .map((cat) => DropdownMenuItem<String>(
                                value: cat,
                                child: Text(cat),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedCategory = val),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.category_outlined,
                          color: AppColors.greyMedium,
                          size: 20,
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Kategori wajib dipilih.';
                        }
                        return null;
                      },
                      isExpanded: true,
                    ),
                    const SizedBox(height: 16),

                    // ---- Deskripsi (opsional) ----
                    _label('Deskripsi (Opsional)'),
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Masukkan sinopsis atau deskripsi buku...',
                        alignLabelWithHint: true,
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(bottom: 60),
                          child: Icon(
                            Icons.description_outlined,
                            color: AppColors.greyMedium,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ---- Pesan Error Server ----
                    // Tampil ketika ada error dari server (ISBN duplikat, dll)
                    Obx(() {
                      if (controller.errorMessage.isNotEmpty) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF5F5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: AppColors.error,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  controller.errorMessage.value,
                                  style: const TextStyle(
                                    color: AppColors.error,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),

                    // ---- Tombol Submit ----
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          // Nonaktifkan tombol saat sedang submit (cegah double submit)
                          onPressed: controller.isSubmitting.value
                              ? null
                              : _handleSubmit,
                          icon: controller.isSubmitting.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  _isEditMode
                                      ? Icons.save_rounded
                                      : Icons.add_rounded,
                                ),
                          label: Text(
                            controller.isSubmitting.value
                                ? 'Menyimpan...'
                                : (_isEditMode
                                    ? 'Simpan Perubahan'
                                    : 'Tambah Buku'),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------
  // Header form
  // ----------------------------------------------------------------
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navy, AppColors.navyLight],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _isEditMode ? Icons.edit_rounded : Icons.add_circle_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditMode ? 'Edit Buku' : 'Tambah Buku Baru',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _isEditMode
                    ? 'Perbarui informasi buku'
                    : 'Isi semua data buku dengan benar',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      );

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.greyMedium, size: 20),
      ),
      validator: validator,
    );
  }

  // ----------------------------------------------------------------
  // handleSubmit: Validasi → kirim ke API → navigasi jika sukses
  // ----------------------------------------------------------------
  Future<void> _handleSubmit() async {
    // Tutup keyboard
    FocusScope.of(context).unfocus();

    // Bersihkan error server sebelumnya
    controller.clearError();

    // Validasi form Flutter (semua field)
    if (!_formKey.currentState!.validate()) {
      // Ada field yang tidak valid, jangan kirim request
      return;
    }

    // Buat objek dari input form
    final BookModel bookData = BookModel(
      title: _titleCtrl.text.trim(),
      author: _authorCtrl.text.trim(),
      isbn: _isbnCtrl.text.trim(),
      publisher: _publisherCtrl.text.trim(),
      publishedYear: int.parse(_yearCtrl.text.trim()),
      category: _selectedCategory!,
      stock: int.parse(_stockCtrl.text.trim()),
      description: _descCtrl.text.trim(),
    );

    bool success;

    if (_isEditMode) {
      success = await controller.updateBook(widget.book!.id!, bookData);
    } else {
      success = await controller.createBook(bookData);
    }

    // Navigasi kembali HANYA jika sukses dan widget masih aktif
    if (success && mounted) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      } else {
        Get.back();
      }
    }
    // Jika gagal: tetap di halaman form, error ditampilkan di atas tombol
  }
}
