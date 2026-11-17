<?php

namespace App\Controllers\Api;

use App\Controllers\BaseController;
use App\Models\BookModel;
use CodeIgniter\HTTP\ResponseInterface;

/**
 * BookController
 *
 * Controller untuk REST API manajemen buku perpustakaan.
 * Endpoint:
 *   GET    /api/books          → index()   - Ambil semua buku
 *   GET    /api/books/{id}     → show()    - Ambil satu buku berdasarkan ID
 *   POST   /api/books          → create()  - Tambah buku baru
 *   PUT    /api/books/{id}     → update()  - Edit buku berdasarkan ID
 *   DELETE /api/books/{id}     → delete()  - Hapus buku berdasarkan ID
 *
 * Perbaikan:
 * - Validasi ISBN unik (is_unique)
 * - Saat edit, ISBN buku sendiri dikecualikan dari pengecekan duplikat
 * - Respons JSON konsisten {success, message, data, errors}
 */
class BookController extends BaseController
{
    protected BookModel $bookModel;

    public function __construct()
    {
        $this->bookModel = new BookModel();
    }

    // ================================================================
    // GET /api/books
    // Mengambil seluruh data buku dari database
    // ================================================================
    public function index(): ResponseInterface
    {
        $books = $this->bookModel->orderBy('id', 'DESC')->findAll();

        return $this->response
            ->setStatusCode(200)
            ->setJSON([
                'success' => true,
                'message' => 'Data buku berhasil diambil.',
                'data'    => $books,
                'errors'  => null,
            ]);
    }

    // ================================================================
    // GET /api/books/{id}
    // Mengambil satu data buku berdasarkan ID
    // ================================================================
    public function show(int $id): ResponseInterface
    {
        $book = $this->bookModel->find($id);

        if (!$book) {
            return $this->response
                ->setStatusCode(404)
                ->setJSON([
                    'success' => false,
                    'message' => "Buku dengan ID {$id} tidak ditemukan.",
                    'data'    => null,
                    'errors'  => null,
                ]);
        }

        return $this->response
            ->setStatusCode(200)
            ->setJSON([
                'success' => true,
                'message' => 'Data buku berhasil diambil.',
                'data'    => $book,
                'errors'  => null,
            ]);
    }

    // ================================================================
    // POST /api/books
    // Menambahkan data buku baru ke database
    // ================================================================
    public function create(): ResponseInterface
    {
        // Ambil data JSON dari body request
        $input = $this->request->getJSON(true);

        // Fallback ke form-data jika bukan JSON
        if (empty($input)) {
            $input = $this->request->getPost();
        }

        // ---- Validasi dengan aturan termasuk ISBN unik ----
        $validationRules = [
            'title'          => 'required|min_length[3]|max_length[150]',
            'author'         => 'required|min_length[3]|max_length[100]',
            'isbn'           => 'required|max_length[30]|is_unique[books.isbn]',
            'publisher'      => 'required|max_length[100]',
            'published_year' => 'required|integer|greater_than[999]|less_than[10000]',
            'category'       => 'required|max_length[50]',
            'stock'          => 'required|integer|greater_than_equal_to[0]',
            'description'    => 'permit_empty',
        ];

        $validationMessages = [
            'title'          => [
                'required'   => 'Judul buku wajib diisi.',
                'min_length' => 'Judul buku minimal 3 karakter.',
                'max_length' => 'Judul buku maksimal 150 karakter.',
            ],
            'author'         => [
                'required'   => 'Nama penulis wajib diisi.',
                'min_length' => 'Nama penulis minimal 3 karakter.',
                'max_length' => 'Nama penulis maksimal 100 karakter.',
            ],
            'isbn'           => [
                'required'   => 'ISBN wajib diisi.',
                'max_length' => 'ISBN maksimal 30 karakter.',
                'is_unique'  => 'ISBN sudah terdaftar. Gunakan ISBN yang berbeda.',
            ],
            'publisher'      => [
                'required'   => 'Nama penerbit wajib diisi.',
                'max_length' => 'Nama penerbit maksimal 100 karakter.',
            ],
            'published_year' => [
                'required'    => 'Tahun terbit wajib diisi.',
                'integer'     => 'Tahun terbit harus berupa angka.',
                'greater_than' => 'Tahun terbit tidak valid (minimal 1000).',
                'less_than'   => 'Tahun terbit tidak valid (maksimal 9999).',
            ],
            'category'       => [
                'required'   => 'Kategori wajib dipilih.',
                'max_length' => 'Kategori maksimal 50 karakter.',
            ],
            'stock'          => [
                'required'              => 'Stok wajib diisi.',
                'integer'               => 'Stok harus berupa angka bulat.',
                'greater_than_equal_to' => 'Stok tidak boleh kurang dari 0.',
            ],
        ];

        if (!$this->validate($validationRules, $validationMessages)) {
            return $this->response
                ->setStatusCode(422)
                ->setJSON([
                    'success' => false,
                    'message' => 'Validasi gagal. Periksa kembali data yang dikirim.',
                    'data'    => null,
                    'errors'  => $this->validator->getErrors(),
                ]);
        }

        // Simpan ke database (hanya field yang diizinkan)
        $allowedFields = ['title', 'author', 'isbn', 'publisher', 'published_year', 'category', 'stock', 'description'];
        $dataToSave = array_intersect_key($input, array_flip($allowedFields));

        $newId = $this->bookModel->insert($dataToSave, true);

        if (!$newId) {
            return $this->response
                ->setStatusCode(500)
                ->setJSON([
                    'success' => false,
                    'message' => 'Gagal menyimpan buku ke database.',
                    'data'    => null,
                    'errors'  => null,
                ]);
        }

        $newBook = $this->bookModel->find($newId);

        return $this->response
            ->setStatusCode(201)
            ->setJSON([
                'success' => true,
                'message' => 'Buku berhasil ditambahkan.',
                'data'    => $newBook,
                'errors'  => null,
            ]);
    }

    // ================================================================
    // PUT /api/books/{id}
    // Mengubah data buku berdasarkan ID
    // ================================================================
    public function update(int $id): ResponseInterface
    {
        // Periksa apakah buku ada
        $book = $this->bookModel->find($id);

        if (!$book) {
            return $this->response
                ->setStatusCode(404)
                ->setJSON([
                    'success' => false,
                    'message' => "Buku dengan ID {$id} tidak ditemukan.",
                    'data'    => null,
                    'errors'  => null,
                ]);
        }

        // Ambil data dari JSON body
        $input = $this->request->getJSON(true);

        if (empty($input)) {
            $input = $this->request->getRawInput();
        }

        // ---- Validasi dengan ISBN unique exclude ID buku yang sedang diedit ----
        // Sintaks: is_unique[table.field,ignore_field,ignore_value]
        $isbnRule = "if_exist|max_length[30]|is_unique[books.isbn,id,{$id}]";

        $validationRules = [
            'title'          => 'if_exist|min_length[3]|max_length[150]',
            'author'         => 'if_exist|min_length[3]|max_length[100]',
            'isbn'           => $isbnRule,
            'publisher'      => 'if_exist|max_length[100]',
            'published_year' => 'if_exist|integer|greater_than[999]|less_than[10000]',
            'category'       => 'if_exist|max_length[50]',
            'stock'          => 'if_exist|integer|greater_than_equal_to[0]',
            'description'    => 'permit_empty',
        ];

        $validationMessages = [
            'title'  => [
                'min_length' => 'Judul buku minimal 3 karakter.',
                'max_length' => 'Judul buku maksimal 150 karakter.',
            ],
            'author' => [
                'min_length' => 'Nama penulis minimal 3 karakter.',
                'max_length' => 'Nama penulis maksimal 100 karakter.',
            ],
            'isbn'   => [
                'max_length' => 'ISBN maksimal 30 karakter.',
                'is_unique'  => 'ISBN sudah terdaftar pada buku lain.',
            ],
            'publisher'      => [
                'max_length' => 'Nama penerbit maksimal 100 karakter.',
            ],
            'published_year' => [
                'integer'      => 'Tahun terbit harus berupa angka.',
                'greater_than' => 'Tahun terbit tidak valid (minimal 1000).',
                'less_than'    => 'Tahun terbit tidak valid (maksimal 9999).',
            ],
            'category' => [
                'max_length' => 'Kategori maksimal 50 karakter.',
            ],
            'stock'    => [
                'integer'               => 'Stok harus berupa angka bulat.',
                'greater_than_equal_to' => 'Stok tidak boleh kurang dari 0.',
            ],
        ];

        if (!$this->validate($validationRules, $validationMessages)) {
            return $this->response
                ->setStatusCode(422)
                ->setJSON([
                    'success' => false,
                    'message' => 'Validasi gagal. Periksa kembali data yang dikirim.',
                    'data'    => null,
                    'errors'  => $this->validator->getErrors(),
                ]);
        }

        // Update data di database
        $allowedFields = ['title', 'author', 'isbn', 'publisher', 'published_year', 'category', 'stock', 'description'];
        $dataToUpdate = array_intersect_key($input, array_flip($allowedFields));

        $this->bookModel->update($id, $dataToUpdate);

        $updatedBook = $this->bookModel->find($id);

        return $this->response
            ->setStatusCode(200)
            ->setJSON([
                'success' => true,
                'message' => 'Buku berhasil diperbarui.',
                'data'    => $updatedBook,
                'errors'  => null,
            ]);
    }

    // ================================================================
    // DELETE /api/books/{id}
    // Menghapus data buku berdasarkan ID
    // ================================================================
    public function delete(int $id): ResponseInterface
    {
        $book = $this->bookModel->find($id);

        if (!$book) {
            return $this->response
                ->setStatusCode(404)
                ->setJSON([
                    'success' => false,
                    'message' => "Buku dengan ID {$id} tidak ditemukan.",
                    'data'    => null,
                    'errors'  => null,
                ]);
        }

        $this->bookModel->delete($id);

        return $this->response
            ->setStatusCode(200)
            ->setJSON([
                'success' => true,
                'message' => "Buku \"{$book['title']}\" berhasil dihapus.",
                'data'    => null,
                'errors'  => null,
            ]);
    }
}
