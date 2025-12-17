# **PROJECT MASTER PLAN: WARGA+ (The Civic Lifestyle App)**

Versi Dokumen: 5.0 (Final Pivot)  
Konsep UI: Chat-Stream & Redacted Document  
Core Value: Information without Fatigue. Prestige without Punishment.

## **1\. USER INTERFACE & FLOW (THE CHAT EXPERIENCE)**

### **1.1 Layar Baca Utama (Chat Stream)**

Widget utama bukan lagi soal kuis, tapi ChatStoryView.

* **Narrator:** "Bung Warga" (AI Persona) mengirim pesan bertahap.  
* **User Action:** User menekan tombol respon di bawah layar untuk memajukan cerita.  
* **Progress Bar:** Bar tipis di atas layar (0% \- 100%) menunjukkan progres *Sub-Modul* saat ini.  
* **Interupsi:**  
  * *Gambar/Meme:* Bung Warga mengirim gambar pendukung.  
  * *Mini Quiz:* Sekali-kali Bung Warga bertanya, "Menurut lo gimana?" (Tidak ada hukuman nyawa, hanya respon beda dari AI).

### **1.2 Struktur Konten (Hierarchy)**

1. **Rilisan (The Issue):** Topik Besar (misal: "Cacat Wawasan Sejarah").  
2. **Sub-Modul (The Chat Session):** Sesi chatting 2-3 menit (misal: "Part 1: Mitos 1 Maret").  
3. **Summary Card (The Save Point):** Kartu visual ringkasan fakta setelah Sub-Modul selesai.

### **1.3 Mode Khusus: Redacted Document (Sensor Mode)**

Digunakan untuk konten "Hot Takes", Sarkasme, atau Isu Sensitif Singkat.

* **UI:** Teks hitam di atas kertas putih kusam. Banyak kata disensor (blok hitam).  
* **Interaksi:** User tap blok hitam \-\> Sensor terbuka \-\> Efek suara *glitch/typing*.  
* **Vibe:** Rahasia, Eksklusif, Pemberontak.

## **2\. SISTEM LOYALITAS (PRESTIGE SYSTEM)**

### **2.1 Kartu Identitas Warga (Dynamic ID)**

Halaman Profil user berbentuk KTP Digital yang bisa di-share.

* **Variabel Berubah:**  
  * *Avatar:* Berubah ekspresi sesuai Streak.  
  * *Title/Gelar:* Berubah sesuai topik terbanyak yang dibaca (e.g., "History Buff", "Policy Watcher").  
  * *Stats:* Jumlah Rilisan selesai, Total Streak.

### **2.2 Receipt of Knowledge (Shareable Asset)**

Setelah menyelesaikan **Satu Rilisan Penuh**:

* Aplikasi men-generate gambar "Struk Belanja".  
* List item: Poin-poin fakta utama yang dipelajari.  
* Footer: "Dibayar dengan: Akal Sehat".

### **2.3 Jurnal Refleksi**

Di akhir Rilisan, user diajak menulis 1 kalimat refleksi. Ini disimpan di "Jurnal Pribadi" di profil mereka, menciptakan ikatan emosional bahwa aplikasi ini adalah *diary* intelektual mereka.

## **3\. SPESIFIKASI TEKNIS (FLUTTER)**

### **3.1 Data Model (Firestore)**

Struktur JSON diperbarui untuk mengakomodasi Chat & Redacted Mode.

// Collection: releases  
{  
  "release\_id": "sejarah\_01",  
  "title": "Manipulasi Sejarah 101",  
  "cover\_image": "url...",  
  "sub\_modules": \[  
    {  
      "id": "sub\_01",  
      "title": "Serangan Umum",  
      "type": "chat\_stream", // Tipe Chat  
      "chat\_script": \[  
        {"role": "ai", "text": "Eh, lo tau film Janur Kuning ga?"},  
        {"role": "user\_option", "choices": \["Tau, film jadul", "Gak tau"\]},  
        {"role": "ai", "text": "Itu film propaganda wajib zaman Orba..."},  
        {"role": "card\_summary", "facts": \["Sultan HB IX inisiator asli", "Soeharto pelaksana lapangan"\]}  
      \]  
    },  
    {  
      "id": "sub\_02\_bonus",  
      "title": "Mitos Supersemar",  
      "type": "redacted\_doc", // Tipe Dokumen Sensor  
      "content": "Naskah asli Supersemar itu \[HILANG\]. Ada \[TIGA\] versi palsu di arsip nasional."  
    }  
  \]  
}

### **3.2 Tech Stack Tambahan**

* **Screenshot Package:** screenshot atau davinci (Flutter package) untuk mengubah Widget (KTP/Struk) menjadi gambar PNG agar bisa di-share ke Instagram/WhatsApp.  
* **Local Storage:** shared\_preferences untuk menyimpan *draft* chat jika user keluar aplikasi di tengah jalan.

## **4\. ROADMAP EKSEKUSI (NEXT STEPS)**

### **Minggu Ini: UI Chat & Data**

1. **Refactor UI:** Buat widget ChatBubble dan UserResponseButton.  
2. **Logic:** Buat *state management* sederhana. Jika user klik tombol A, array chat indeks berikutnya muncul.  
3. **Data:** Konversi "Vertical Slice Serangan 1 Maret" (yang kemarin kuis) menjadi format "Skrip Chatting".

### **Minggu Depan: Loyalty & Share**

1. **Design:** Buat layout Widget "Struk Wawasan" (Receipt).  
2. **Function:** Implementasi fitur *Generate Image from Widget* untuk share ke sosmed.

### **Minggu Berikutnya: Redacted Mode**

1. **Widget:** Buat RedactedText widget (Teks dengan background hitam, jika diklik background jadi transparan).

## **5\. EXECUTIVE SUMMARY (UNTUK DIRI SENDIRI)**

"Warga+" bertransformasi dari aplikasi kuis menjadi **Portal Jurnalisme Chat**. Kita tidak menguji user, kita **mengobrol** dengan user. Kita tidak menghukum user dengan 'Game Over', kita memberi penghargaan user dengan **Identitas Digital** yang keren untuk dipamerkan. Riset berat (seperti PDF Cacat Wawasan) akan 'dicincang' menjadi percakapan santai yang mudah dicerna, didukung AI untuk konteks, dan ditutup dengan refleksi pribadi.