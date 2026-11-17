<?php

use CodeIgniter\Router\RouteCollection;

/**
 * @var RouteCollection $routes
 */

// -------------------------------------------------------
// Route default CI4 (jangan dihapus)
// -------------------------------------------------------
$routes->get('/', 'Home::index');

// -------------------------------------------------------
// REST API Routes untuk Buku
// Semua route dikelompokkan di bawah prefix /api
// -------------------------------------------------------
$routes->group('api', function ($routes) {

    // ---- Preflight OPTIONS (diperlukan untuk CORS Flutter Web) ----
    // Browser mengirim OPTIONS sebelum request POST/PUT/DELETE
    $routes->options('books', function () {
        return service('response')->setStatusCode(200)->setJSON(new \stdClass());
    });
    $routes->options('books/(:num)', function () {
        return service('response')->setStatusCode(200)->setJSON(new \stdClass());
    });

    // GET /api/books → Ambil semua buku
    $routes->get('books', 'Api\BookController::index');

    // GET /api/books/(:num) → Ambil satu buku berdasarkan ID
    $routes->get('books/(:num)', 'Api\BookController::show/$1');

    // POST /api/books → Tambah buku baru
    $routes->post('books', 'Api\BookController::create');

    // PUT /api/books/(:num) → Update buku berdasarkan ID
    $routes->put('books/(:num)', 'Api\BookController::update/$1');

    // DELETE /api/books/(:num) → Hapus buku berdasarkan ID
    $routes->delete('books/(:num)', 'Api\BookController::delete/$1');
});
