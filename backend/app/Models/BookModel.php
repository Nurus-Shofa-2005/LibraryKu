<?php

namespace App\Models;

use CodeIgniter\Model;

/**
 * BookModel
 *
 * Model untuk mengelola data buku di tabel 'books'.
 * Mewarisi CodeIgniter\Model sehingga memiliki fitur CRUD bawaan.
 */
class BookModel extends Model
{
    // Nama tabel di database
    protected $table = 'books';

    // Primary key tabel
    protected $primaryKey = 'id';

    // Tipe return data: 'array' atau 'object'
    protected $returnType = 'array';

    // Aktifkan soft delete (false = data benar-benar dihapus)
    protected $useSoftDeletes = false;

    // Kolom yang boleh diisi melalui insert/update (mass assignment protection)
    protected $allowedFields = [
        'title',
        'author',
        'isbn',
        'publisher',
        'published_year',
        'category',
        'stock',
        'description',
    ];

    // Aktifkan timestamps otomatis (created_at & updated_at)
    protected $useTimestamps = true;
    protected $createdField  = 'created_at';
    protected $updatedField  = 'updated_at';

    // ----------------------------------------------------------------
    // Aturan validasi untuk tambah buku (insert)
    // ----------------------------------------------------------------
    protected $validationRules = [
        'title'          => 'required|min_length[3]|max_length[150]',
        'author'         => 'required|min_length[3]|max_length[100]',
        'isbn'           => 'required|max_length[30]',
        'publisher'      => 'required|max_length[100]',
        'published_year' => 'required|integer|greater_than[999]|less_than[10000]',
        'category'       => 'required|max_length[50]',
        'stock'          => 'required|integer|greater_than_equal_to[0]',
        'description'    => 'permit_empty',
    ];

    // Pesan error validasi dalam Bahasa Indonesia
    protected $validationMessages = [
        'title' => [
            'required'   => 'Judul buku wajib diisi.',
            'min_length' => 'Judul buku minimal 3 karakter.',
            'max_length' => 'Judul buku maksimal 150 karakter.',
        ],
        'author' => [
            'required'   => 'Nama pengarang wajib diisi.',
            'min_length' => 'Nama pengarang minimal 3 karakter.',
            'max_length' => 'Nama pengarang maksimal 100 karakter.',
        ],
        'isbn' => [
            'required'   => 'ISBN wajib diisi.',
            'max_length' => 'ISBN maksimal 30 karakter.',
        ],
        'publisher' => [
            'required'   => 'Nama penerbit wajib diisi.',
            'max_length' => 'Nama penerbit maksimal 100 karakter.',
        ],
        'published_year' => [
            'required'          => 'Tahun terbit wajib diisi.',
            'integer'           => 'Tahun terbit harus berupa angka.',
            'greater_than'      => 'Tahun terbit tidak valid.',
            'less_than'         => 'Tahun terbit tidak valid.',
        ],
        'category' => [
            'required'   => 'Kategori wajib diisi.',
            'max_length' => 'Kategori maksimal 50 karakter.',
        ],
        'stock' => [
            'required'              => 'Stok wajib diisi.',
            'integer'               => 'Stok harus berupa angka.',
            'greater_than_equal_to' => 'Stok tidak boleh negatif.',
        ],
    ];

    // Lewati validasi otomatis (validasi dilakukan manual di controller)
    protected $skipValidation = false;
}
