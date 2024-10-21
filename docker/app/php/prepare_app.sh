#!/bin/bash

cd /app
php artisan migrate --force
php artisan route:cache
php artisan config:cache
npm install
npm run dev &
