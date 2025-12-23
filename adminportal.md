ARSITEKTUR ADMIN PORTAL: "THE GATEKEEPER"

Versi: Final (Zero Budget Optimized)
Fokus: Quality Control (QC), Data Integrity, & Security.

1. FILOSOFI DESAIN

Mengapa kita memisahkan "Pembuatan Konten" dari "Aplikasi Admin"?

Pemisahan Kekuasaan (Separation of Concerns):

Browser (Gemini/ChatGPT): Adalah "Pabrik". Tempat bahan mentah (PDF) diolah menjadi barang setengah jadi (JSON) secara GRATIS dan cepat.

Aplikasi Admin: Adalah "Quality Control". Tempat barang setengah jadi diperiksa kelengkapannya sebelum dijual ke user (Upload ke Firestore).

1. MEKANISME QUALITY CONTROL (QC)

Aplikasi Admin bertindak sebagai filter agar "Sampah" tidak masuk ke database.

Layer 1: Validasi Sintaks (Syntax Guard)

Masalah: Seringkali saat copy-paste dari AI, format JSON rusak (kurang tanda koma, kurung kurawal tidak tertutup, atau ada teks markdown ```json).

Solusi Sistem: Fungsi jsonDecode() dibungkus dalam try-catch.

Hasil: Jika admin mem-paste teks sampah, aplikasi menolak dan menampilkan pesan error merah. Tombol "Upload" tetap terkunci (disabled).

Layer 2: Validasi Struktur (Schema Guard)

Masalah: JSON valid, tapi isinya salah (misal: lupa mencantumkan ai_context atau id).

Solusi Sistem: Logic if (!data.containsKey('ai_context')).

Hasil: Aplikasi memberi peringatan keras. "Warning: AI Context hilang!". Ini mencegah fitur Live Chat menjadi bodoh karena tidak punya data.

Layer 3: Visual Verification (Human Guard)

Masalah: JSON valid, struktur benar, tapi isinya ngawur (misal: Judulnya "Test 123").

Solusi Sistem: Tampilan "Preview Data" di sebelah kanan layar admin.

Hasil: Admin bisa melihat sekilas: "Oh, judulnya benar 'Serangan Umum', XP-nya 50, jumlah chat 15 bubble". Jika oke, baru tekan Upload.

2. MEKANISME KEAMANAN (SECURITY LAYERS)

Bagaimana kita memastikan hanya Anda yang bisa mengakses ini?

Layer 1: UI Hiding (Obscurity) Ini Sudah dilakukan sebelumnya.

Layer 2: Database Lock (Authorization - Firestore Rules)

Kode: allow write: if isAdmin();

Efek: Ini adalah benteng terakhir. Meskipun hacker bisa menembus aplikasi, saat mereka mencoba mengirim data ke Firestore, Google Cloud akan menolaknya di level server karena UID mereka tidak memiliki hak akses write.

3. ALUR KERJA (WORKFLOW) BARU

Langkah 1: Generasi (Di Laptop/Browser)

Buka PDF Riset.

Buka Gemini Web (Gratis).

Gunakan Prompt Template.

Output: Raw JSON.

Langkah 2: Validasi (Di Aplikasi Admin)

Paste JSON ke Admin Portal.

Sistem otomatis cek error.

Sistem menampilkan Preview.

Langkah 3: Publikasi (Ke Cloud)

Klik "Upload".

Data releases diperbarui.

Data ai_context tersimpan di dalam sub-modul tersebut.

Langkah 4: Konsumsi (Di Aplikasi User)

User buka modul.

User baca chat.

User klik "Tanya AI" -> AI menjawab cerdas karena ai_context sudah terjamin ada oleh Langkah 2.

5. KESIMPULAN

Desain ini mengubah Admin Portal dari sekadar "Form Input" menjadi "Sistem Kendali Mutu". Ini adalah pendekatan paling profesional untuk Solo Developer yang ingin aplikasinya Scale-Up (berkembang) tanpa mengorbankan kualitas data atau keamanan.