/// BookModel - Model data untuk satu buku
///
/// Kelas ini merepresentasikan struktur data buku yang berasal dari API.
/// Menggunakan factory constructor [fromJson] untuk parsing JSON response
/// dan method [toJson] untuk konversi ke Map saat mengirim data ke API.
class BookModel {
  final int? id;           // ID buku (nullable karena belum ada saat tambah baru)
  final String title;      // Judul buku
  final String author;     // Nama pengarang
  final String isbn;       // Nomor ISBN
  final String publisher;  // Nama penerbit
  final int publishedYear; // Tahun terbit
  final String category;   // Kategori/genre buku
  final int stock;         // Jumlah stok yang tersedia
  final String description;// Deskripsi/sinopsis buku
  final String? createdAt; // Waktu data dibuat (dari server)
  final String? updatedAt; // Waktu data terakhir diupdate (dari server)

  /// Constructor utama - semua field wajib diisi
  const BookModel({
    this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.publisher,
    required this.publishedYear,
    required this.category,
    required this.stock,
    required this.description,
    this.createdAt,
    this.updatedAt,
  });

  // -------------------------------------------------------
  // fromJson: Parsing JSON (Map) → BookModel
  // Dipanggil saat menerima response dari API
  // -------------------------------------------------------
  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      // int.tryParse digunakan untuk handle jika API mengembalikan ID sebagai String
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      title: json['title']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      isbn: json['isbn']?.toString() ?? '',
      publisher: json['publisher']?.toString() ?? '',
      // published_year bisa berupa int atau String dari API
      publishedYear: json['published_year'] is int
          ? json['published_year']
          : int.tryParse(json['published_year']?.toString() ?? '0') ?? 0,
      category: json['category']?.toString() ?? '',
      // stock bisa berupa int atau String dari API
      stock: json['stock'] is int
          ? json['stock']
          : int.tryParse(json['stock']?.toString() ?? '0') ?? 0,
      description: json['description']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  // -------------------------------------------------------
  // toJson: BookModel → Map<String, dynamic>
  // Dipanggil saat mengirim data ke API (POST / PUT)
  // -------------------------------------------------------
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
      'isbn': isbn,
      'publisher': publisher,
      'published_year': publishedYear,
      'category': category,
      'stock': stock,
      'description': description,
    };
  }

  /// copyWith: Membuat salinan BookModel dengan field tertentu yang diubah
  /// Berguna untuk update state tanpa mengubah objek asli
  BookModel copyWith({
    int? id,
    String? title,
    String? author,
    String? isbn,
    String? publisher,
    int? publishedYear,
    String? category,
    int? stock,
    String? description,
    String? createdAt,
    String? updatedAt,
  }) {
    return BookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      isbn: isbn ?? this.isbn,
      publisher: publisher ?? this.publisher,
      publishedYear: publishedYear ?? this.publishedYear,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'BookModel(id: $id, title: $title, author: $author, '
        'isbn: $isbn, stock: $stock)';
  }
}
