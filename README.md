# 🇮🇩 WargaPlus

![App Logo](assets/logo/app_logo.png)

> **Platform Edukasi & Interaksi Warga Berbasis Gamifikasi & AI**

**WargaPlus** adalah aplikasi mobile inovatif yang mengajak pengguna untuk memahami isu sosial, sejarah, dan hukum dengan cara yang interaktif. Dilengkapi dengan asisten AI "Bung Warga", sistem dokumen tersensor (redacted reader), dan koleksi lencana pencapaian.

---

## ✨ Fitur Utama (v1.0)

### 🤖 1. Chat dengan Bung Warga (AI)
Diskusikan topik sensitif dengan **Bung Warga**, AI yang dirancang untuk memberikan perspektif berimbang.
- **Mode Netral:** Jawaban objektif berbasis fakta.
- **Mode Thinking:** Analisis mendalam untuk memicu pemikiran kritis.

### 🕵️‍♂️ 2. Redacted Document Reader
Pengalaman membaca unik di mana pengguna ditantang untuk memahami konteks dari dokumen-dokumen "rahasia" yang sebagian teksnya disensor (redacted).
- *Contoh Konten:* Rilis Dokumen Politik, Arsip Sejarah.

### 🏅 3. Gamifikasi & Badges
Jadilah warga teladan dan kumpulkan lencana berdasarkan aktivitas membaca dan interaksi Anda:
- **Statesman & Lawmaker:** Untuk penguasaan isu hukum/negara.
- **Historian:** Untuk pembaca setia arsip sejarah.
- **Earth Guardian:** Peduli isu lingkungan.
- **Oligarch Hunter:** (Langka) Untuk investigasi mendalam.

### 📅 4. Lini Masa (Timeline)
Akses konten yang dirilis secara berkala (Seasons/Chapters) melalui antarmuka timeline yang intuitif. Konten v1.0 meliputi:
- KUHP 2025
- Bencana Sumatra
- Cacat Wawasan (Logical Fallacies)

---

## 🛠️ Teknologi yang Digunakan

Project ini dibangun menggunakan ekosistem **Flutter** dan **Firebase**:

* **Framework:** Flutter (Dart)
* **Backend & Auth:** Firebase (Authentication, Firestore)
* **State Management:** (Sesuai implementasi, misal: Provider/Riverpod/Bloc)
* **AI Integration:** Integrasi LLM untuk "Bung Warga"
* **Aset:** Custom UI Assets & Badges

---

## 🚀 Cara Menjalankan (Local Development)

Ikuti langkah ini untuk menjalankan project di mesin lokal Anda:

1.  **Clone Repository**
    ```bash
    git clone [https://github.com/username-anda/warga_plus.git](https://github.com/username-anda/warga_plus.git)
    cd warga_plus
    ```

2.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

3.  **Konfigurasi Firebase**
    * Pastikan Anda memiliki file `google-services.json` (Android) atau `GoogleService-Info.plist` (iOS) di folder masing-masing.
    * Atau gunakan FlutterFire CLI untuk mengonfigurasi ulang.

4.  **Jalankan Aplikasi**
    ```bash
    flutter run
    ```

---

## 📂 Struktur Project

```text
lib/
├── core/            # Konfigurasi, Tema, Layanan Global (Auth, AI)
├── features/        # Fitur modular (Auth, Home, Reader, Profile, Admin)
│   ├── auth/        # Login & Register
│   ├── home/        # Timeline & Dashboard
│   ├── reader/      # Chat Stream & Redacted Reader UI
│   ├── profile/     # User Profile & Badges
│   └── admin/       # Portal Admin & Import JSON
├── main.dart        # Entry point
└── firebase_options.dart
```

---

### 🤝 Berkontribusi
Kontribusi sangat diterima! Jika Anda ingin menambahkan fitur atau memperbaiki bug:
- Fork repository ini.
- Buat branch fitur baru (git checkout -b fitur-keren).
- Commit perubahan Anda (git commit -m 'Menambah fitur keren').
- Push ke branch tersebut (git push origin fitur-keren).
- Buat Pull Request.

### 📄 Lisensi
Hak Cipta © 2025 WargaPlus.
