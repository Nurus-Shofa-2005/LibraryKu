<?php

namespace App\Filters;

use CodeIgniter\HTTP\RequestInterface;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\Filters\FilterInterface;

/**
 * CorsFilter
 *
 * Filter untuk menangani Cross-Origin Resource Sharing (CORS).
 * Wajib diaktifkan agar Flutter Web bisa berkomunikasi dengan API ini.
 *
 * Flutter Web berjalan di port berbeda (mis. localhost:50683) sedangkan
 * backend di localhost:8080, sehingga browser akan memblokir request
 * tanpa header CORS yang benar.
 */
class CorsFilter implements FilterInterface
{
    /**
     * Jalankan sebelum request diproses controller.
     * Tangani preflight request (OPTIONS) dari browser.
     */
    public function before(RequestInterface $request, $arguments = null)
    {
        // Tangani preflight request OPTIONS
        // Browser mengirim OPTIONS sebelum POST/PUT/DELETE untuk memeriksa CORS
        if (strtolower($request->getMethod()) === 'options') {
            $response = service('response');
            $response->setStatusCode(200);
            $response->setJSON(new \stdClass());
            $this->setHeaders($response);
            return $response;
        }
    }

    /**
     * Jalankan setelah response dikirim.
     * Tambahkan header CORS ke semua response.
     */
    public function after(RequestInterface $request, ResponseInterface $response, $arguments = null)
    {
        $this->setHeaders($response);
        return $response;
    }

    /**
     * Set header CORS yang diperlukan
     */
    private function setHeaders(ResponseInterface $response): void
    {
        $response->setHeader('Access-Control-Allow-Origin', '*');
        $response->setHeader('Access-Control-Allow-Headers', 'Content-Type, Accept, Authorization, X-Requested-With');
        $response->setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');
        $response->setHeader('Access-Control-Max-Age', '86400');
    }
}
