# 🚀 Realtime Social Media App

A fullstack social media platform with realtime chat, reels video streaming, and modern scalable architecture using Laravel, Flutter, WebSocket, Redis, and Docker.

# ✨ Features & Demo

This project is a **Modern Social Media Application** that provides real-time interaction, media sharing, and user engagement features similar to popular platforms like Instagram and TikTok.

---

## 🚀 Core Features

### 📝 Post System

* Upload posts (image / media)
* View posts in home feed
* Explore other users' posts

📸 **Demo Screenshot**

![Post Feed](https://github.com/arsalfrlh/social-media-app-laravel-flutter/blob/main/Demo/post.png)

---

### 🎬 Reels (Short Video)

* Watch short-form videos
* Vertical scrolling (like TikTok / Instagram Reels)
* Smooth and continuous playback
* Media streaming support

📸 **Demo Screenshot**

![Reels](https://github.com/arsalfrlh/social-media-app-laravel-flutter/blob/main/Demo/reels.png)

---

### 💬 Realtime Messaging

* Send messages instantly (WebSocket)
* Update messages in real-time
* Delete messages in real-time
* Presence system (online/offline users)
* Live chat updates without refresh

📸 **Demo Screenshot**

![Chat](https://github.com/arsalfrlh/social-media-app-laravel-flutter/blob/main/Demo/message_us.png)

![Chat](https://github.com/arsalfrlh/social-media-app-laravel-flutter/blob/main/Demo/message.png)

---

### ❤️ Like System

* Like and unlike posts
* Engagement tracking

📸 **Demo Screenshot**

![Post Feed](https://github.com/arsalfrlh/social-media-app-laravel-flutter/blob/main/Demo/like.png)

---

### 💬 Comment System

* Add comments to posts
* View all comments
* Interactive discussions

📸 **Demo Screenshot**

![Comment](https://github.com/arsalfrlh/social-media-app-laravel-flutter/blob/main/Demo/comment.png)

---

### 👥 Follow System

* Follow / unfollow users
* Personalized feed based on following
* User relationship system

📸 **Demo Screenshot**

![Follow](https://github.com/arsalfrlh/social-media-app-laravel-flutter/blob/main/Demo/profile_us.png)

---

### 👤 User Profile

* View user profile
* Display posts, followers, and following
* Profile customization (bio, image, etc.)

📸 **Demo Screenshot**

![Profile](https://github.com/arsalfrlh/social-media-app-laravel-flutter/blob/main/Demo/reels_prof.png)

![Profile](https://github.com/arsalfrlh/social-media-app-laravel-flutter/blob/main/Demo/post_up.png)

🎥 **Demo Video**

[Watch Demo](https://github.com/arsalfrlh/social-media-app-laravel-flutter/blob/main/Demo/video.mp4)

---

## ⚡ Realtime Capabilities

Powered by **Laravel Reverb (WebSocket)**:

* 🔥 Live chat updates
* 🟢 Online / Offline user presence
* ⚡ Instant UI updates
* 🚫 No page refresh required

---

## 🧠 System Highlights

* **Backend**: Laravel + Octane + FrankenPHP
* **Realtime**: Laravel Reverb (WebSocket)
* **Frontend**: Flutter (cross-platform)
* **Storage**: MinIO (S3-compatible)
* **Cache & Queue**: Redis
* **Containerization**: Docker

---

## 🎯 User Experience

* Smooth scrolling (Feed & Reels)
* Real-time interaction
* Modern UI (mobile-first design)
* Optimized performance using caching & queue

---

## 📌 Notes

* Replace all image URLs with your actual screenshots.
* Replace video URLs with demo recordings (MP4 / YouTube / Drive).
* Recommended format:

  * Images: PNG / JPG
  * Videos: MP4 or YouTube embed

---

# 🧠 Technology Stack & Architecture

This project is built using a **modern, scalable, and real-time architecture** combining backend, frontend, and infrastructure technologies.

---

## 🏗️ Architecture Overview

The system follows a combination of modern architectural patterns:

### 🧩 Backend Architecture

* **MVC (Model-View-Controller)** – Laravel standard architecture
* **Event-Driven Architecture** – for real-time updates (chat, notifications)
* **RESTful API** – communication between backend and frontend
* **OOP (Object-Oriented Programming)** – clean and maintainable code structure
* **HLS Processing Pipeline** – video processing for reels

---

### 📱 Frontend Architecture

* **MVVM (Model-View-ViewModel)** – separation of UI and business logic
* **State Management**:

  * Provider
  * setState (lightweight UI updates)

---

### 🔄 Communication Protocols

* **HTTP (REST API)** → for standard requests (posts, auth, etc.)
* **WebSocket (Realtime)** → for:

  * Chat system
  * Online/offline presence
  * Live updates

---

## ⚙️ Backend Technologies (Laravel Ecosystem)

### 🚀 Core Backend

* Laravel (API Framework)
* Laravel Octane (High performance server)
* FrankenPHP (PHP application server)

---

### ⚡ Realtime System

* Laravel Reverb (WebSocket server)
* Broadcasting System (Events & Channels)
* Presence Channels (online/offline users)

---

### 🧵 Queue & Background Jobs

* Laravel Queue
* Redis (Queue driver)
* Job Processing (async tasks)

---

### 💾 Database & ORM

* MySQL (via Laragon)
* Eloquent ORM
* Query Builder

---

### 🔐 Authentication & Security

* Laravel Sanctum (API Authentication)
* Rate Limiting (API protection)
* Middleware-based security

---

### ⚡ Caching & Performance

* Redis (Cache, Session, Queue)
* Laravel Cache System
* Octane Worker Optimization

---

### 📂 File Storage & Media

* MinIO (S3-compatible object storage)
* Laravel Filesystem (S3 driver)

---

### 🎥 Video Processing (Reels)

* FFmpeg (video processing)
* HLS (HTTP Live Streaming)
* Video chunking & streaming pipeline

---

### 📡 API Features

* RESTful API design
* JSON-based communication
* API Resource transformation
* Validation & Request handling

---

## 📱 Frontend Technologies (Flutter)

### 🎯 Core

* Flutter (Cross-platform mobile framework)
* Dart (Programming language)

---

### 🌐 Networking

* Dio (HTTP client)
* WebSocket Channel (Realtime communication)

---

### 🧠 State Management

* Provider (main state management)
* setState (UI-level updates)

---

### 💾 Local Storage

* SharedPreferences (local persistence)

---

### 🎬 Media Handling

* Video Player (reels playback)
* File Picker (upload media)
* Cached Network Image (image optimization)

---

### 🎨 UI & UX

* Material Design
* Flutter SVG (vector assets)
* Custom UI Components

---

## 🐳 DevOps & Infrastructure

### 🐳 Containerization

* Docker
* Docker Compose

---

### 🌐 Services

* Redis (cache, queue, session)
* MinIO (object storage)
* External MySQL (Laragon)

---

### 🔗 Networking

* Docker Bridge Network
* Service-to-service communication

---

## 🔄 System Flow (Simplified)

1. User interacts via Flutter App
2. Request sent via HTTP (Dio) → Laravel API
3. Laravel processes data (Controller → Service → Model)
4. Data stored in MySQL / Redis / MinIO
5. Event triggered (if realtime needed)
6. Laravel Reverb broadcasts via WebSocket
7. Flutter receives realtime update instantly

---

## ⚡ Key Highlights

* 🔥 High performance backend using **Laravel Octane + FrankenPHP**
* ⚡ Realtime system using **WebSocket (Reverb)**
* 📦 Scalable infrastructure with **Docker**
* 🎥 Advanced media handling using **HLS streaming**
* 🧠 Clean architecture (MVC + MVVM + Event Driven)
* 🚀 Optimized performance with **Redis & Queue system**

---

## 🎯 Design Principles

* Separation of Concerns
* Scalability & Performance
* Reusability (OOP)
* Real-time user experience
* API-first development

---

# 🌐 Services & Access

This section provides access details for all services used in this project, including database, storage, WebSocket, Redis, and Docker containers.

---

## 🐳 Docker Containers

### List Running Containers

```bash
docker ps
```

### Access Laravel Container

```bash
docker exec -it frankenphp_laravel bash
```

---

## 🗄️ Database (MySQL - Laragon)

This project uses **external MySQL (Laragon)** instead of a Docker container.

### Database Configuration

* Host: `host.docker.internal`
* Port: `3308`
* Database: `laravel`
* Username: `root`
* Password: *(empty)*

---

### Access via phpMyAdmin (Laragon)

```text
http://localhost/phpmyadmin
```

---

### Access via MySQL CLI (optional)

```bash
mysql -h 127.0.0.1 -P 3308 -u root
```

---

## ⚡ Redis (Cache, Queue, Session)

Redis is used for:

* Queue system
* Cache
* Session
* Realtime broadcasting

---

### Access Redis CLI

```bash
docker exec -it redis_cache redis-cli
```

---

### Test Redis Connection

```bash
ping
```

Expected response:

```text
PONG
```

---

## 🗂️ Object Storage (MinIO - S3)

MinIO is used as an S3-compatible storage for:

* Images
* Videos
* Chat media

---

### MinIO Console (Web UI)

```text
http://localhost:9001
```

### Login Credentials

* Username: `minio`
* Password: `minio123`

---

### MinIO API Endpoint

```text
http://localhost:9000
```

---

### Default Bucket

```text
laravel
```

> ⚠️ Make sure to create the bucket manually if it does not exist.

---

## 🔌 WebSocket (Laravel Reverb)

Used for:

* Realtime chat
* Online / offline status
* Typing indicator
* Live updates

---

### WebSocket URL (Browser / Testing)

```text
ws://localhost:8080/app/fwu5zzprindi0hlvtl42
```

---

### WebSocket URL (Android Emulator)

```text
ws://10.0.2.2:8080/app/fwu5zzprindi0hlvtl42
```

---

### Important Notes

* WebSocket server must be running:

```bash
php artisan reverb:start
```

* Ensure `.env` configuration is correct:

```env
REVERB_HOST=localhost
REVERB_PORT=8080
```

---

## 🌍 Laravel API

Base URL:

```text
http://localhost:8081
```

---

### Example API Endpoint

```text
http://localhost:8081/api/message/{user_id}
```

---

## 📦 Queue Worker

Queue is used for:

* Background jobs
* Media processing
* Notifications

---

### Run Queue Worker

```bash
php artisan queue:work
```

---

## 🧪 Useful Debug Commands

### Check Logs

```bash
tail -f storage/logs/laravel.log
```

---

### Restart Containers

```bash
docker compose down
docker compose up -d
```

---

### Rebuild Containers

```bash
docker compose up --build -d
```

---

## ✅ Summary

| Service     | URL / Command                           |
| ----------- | --------------------------------------- |
| Laravel API | http://localhost:8081                   |
| WebSocket   | ws://localhost:8080                     |
| MinIO UI    | http://localhost:9001                   |
| phpMyAdmin  | http://localhost/phpmyadmin             |
| Redis CLI   | docker exec -it redis_cache redis-cli   |
| Laravel CLI | docker exec -it frankenphp_laravel bash |

---

🚀 All services are now accessible and ready for development.
