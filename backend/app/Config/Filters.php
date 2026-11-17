<?php

namespace Config;

use App\Filters\CorsFilter;
use CodeIgniter\Config\BaseConfig;
use CodeIgniter\Filters\CSRF;
use CodeIgniter\Filters\DebugToolbar;
use CodeIgniter\Filters\Honeypot;
use CodeIgniter\Filters\InvalidChars;
use CodeIgniter\Filters\SecureHeaders;

class Filters extends BaseConfig
{
    /**
     * Alias untuk Filter class
     *
     * @var array<string, class-string|list<class-string>>
     */
    public array $aliases = [
        'csrf'          => CSRF::class,
        'toolbar'       => DebugToolbar::class,
        'honeypot'      => Honeypot::class,
        'invalidchars'  => InvalidChars::class,
        'secureheaders' => SecureHeaders::class,
        // Filter CORS untuk Flutter Web
        'cors'          => CorsFilter::class,
    ];

    /**
     * Filter yang selalu dijalankan pada setiap request
     *
     * @var array<string, array<string, array<string, string>>>|array<string, list<string>>
     */
    public array $globals = [
        'before' => [
            // Aktifkan CORS sebelum semua request diproses
            // Ini diperlukan agar Flutter Web bisa berkomunikasi dengan API
            'cors',
        ],
        'after' => [
            // CORS juga perlu dijalankan setelah request untuk response header
            'cors',
        ],
    ];

    /**
     * Filter berdasarkan HTTP method
     *
     * @var array<string, list<string>>
     */
    public array $methods = [];

    /**
     * Filter berdasarkan pola URI
     *
     * @var array<string, array<string, list<string>>>
     */
    public array $filters = [];
}
