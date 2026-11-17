<?php

namespace App\Database\Migrations;

use CodeIgniter\Database\Migration;

/**
 * Migration: Membuat tabel books
 *
 * Tabel ini menyimpan data buku di perpustakaan.
 */
class CreateBooksTable extends Migration
{
    /**
     * Jalankan saat migration naik (php spark migrate)
     */
    public function up()
    {
        $this->forge->addField([
            // Primary key, auto increment
            'id' => [
                'type'           => 'INT',
                'constraint'     => 11,
                'unsigned'       => true,
                'auto_increment' => true,
            ],
            // Judul buku
            'title' => [
                'type'       => 'VARCHAR',
                'constraint' => 150,
                'null'       => false,
            ],
            // Nama pengarang
            'author' => [
                'type'       => 'VARCHAR',
                'constraint' => 100,
                'null'       => false,
            ],
            // ISBN buku (International Standard Book Number)
            'isbn' => [
                'type'       => 'VARCHAR',
                'constraint' => 30,
                'null'       => false,
            ],
            // Nama penerbit
            'publisher' => [
                'type'       => 'VARCHAR',
                'constraint' => 100,
                'null'       => false,
            ],
            // Tahun terbit buku
            'published_year' => [
                'type'       => 'INT',
                'constraint' => 4,
                'null'       => false,
            ],
            // Kategori / genre buku
            'category' => [
                'type'       => 'VARCHAR',
                'constraint' => 50,
                'null'       => false,
            ],
            // Jumlah stok buku tersedia
            'stock' => [
                'type'       => 'INT',
                'constraint' => 11,
                'null'       => false,
                'default'    => 0,
            ],
            // Deskripsi buku (opsional, boleh kosong)
            'description' => [
                'type' => 'TEXT',
                'null' => true,
            ],
            // Timestamp otomatis
            'created_at' => [
                'type' => 'DATETIME',
                'null' => true,
            ],
            'updated_at' => [
                'type' => 'DATETIME',
                'null' => true,
            ],
        ]);

        // Tetapkan primary key
        $this->forge->addPrimaryKey('id');

        // Buat tabelnya dengan nama 'books'
        $this->forge->createTable('books');
    }

    /**
     * Jalankan saat migration turun / rollback (php spark migrate:rollback)
     */
    public function down()
    {
        // Hapus tabel books jika ada
        $this->forge->dropTable('books', true);
    }
}
