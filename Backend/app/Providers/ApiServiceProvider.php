<?php

namespace App\Providers;

use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Support\ServiceProvider;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;

class ApiServiceProvider extends ServiceProvider
{
    /**
     * Register services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap services.
     */
    public function boot(): void
    {
        // Default API
        RateLimiter::for('api', function(Request $request){
            return $request->user()
                ? Limit::perMinute(60)->by($request->user()->id)
                : Limit::perMinute(30)->by($request->ip());
        });

        // Login
        RateLimiter::for('login', function(Request $request){
            return Limit::perMinute(5)->by($request->ip());
        });

        // Register
        RateLimiter::for('register', function(Request $request){
            return Limit::perMinute(3)->by($request->ip());
        });

        // Message (real-time)
        RateLimiter::for('message', function(Request $request){
            return Limit::perMinute(120)->by($request->user()?->id ?: $request->ip());
        });

        // Like / Reaction
        RateLimiter::for('interaction', function(Request $request){
            return Limit::perMinute(60)->by($request->user()?->id ?: $request->ip());
        });
    }
}
