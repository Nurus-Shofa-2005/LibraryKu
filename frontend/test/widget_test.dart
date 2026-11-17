import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/models/book_model.dart';

void main() {
  group('BookModel Unit Tests', () {
    test('BookModel fromJson dan toJson bekerja dengan benar', () {
      final jsonMap = {
        'id': 1,
        'title': 'Pemrograman Flutter',
        'author': 'John Doe',
        'isbn': '978-602-123-456-7',
        'publisher': 'Informatika',
        'published_year': 2023,
        'category': 'Sains & Teknologi',
        'stock': 15,
        'description': 'Buku panduan lengkap Flutter untuk pemula.',
      };

      final book = BookModel.fromJson(jsonMap);

      expect(book.id, 1);
      expect(book.title, 'Pemrograman Flutter');
      expect(book.author, 'John Doe');
      expect(book.isbn, '978-602-123-456-7');
      expect(book.publisher, 'Informatika');
      expect(book.publishedYear, 2023);
      expect(book.category, 'Sains & Teknologi');
      expect(book.stock, 15);
      expect(book.description, 'Buku panduan lengkap Flutter untuk pemula.');

      final serialized = book.toJson();
      expect(serialized['title'], 'Pemrograman Flutter');
      expect(serialized['stock'], 15);
      expect(serialized['published_year'], 2023);
    });

    test('BookModel menangani field string dari database (tipe casting)', () {
      final jsonFromString = {
        'id': '2',
        'title': 'Clean Code',
        'author': 'Robert C. Martin',
        'isbn': '978-013-235-088-4',
        'publisher': 'Prentice Hall',
        'published_year': '2008',
        'category': 'Teknologi',
        'stock': '5',
        'description': '',
      };

      final book = BookModel.fromJson(jsonFromString);

      expect(book.id, 2);
      expect(book.publishedYear, 2008);
      expect(book.stock, 5);
      expect(book.description, '');
    });
  });
}
