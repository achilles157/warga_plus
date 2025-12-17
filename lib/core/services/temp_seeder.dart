import 'package:flutter/material.dart';
import '../services/content_service.dart';

class TempSeeder {
  static final Map<String, dynamic> cacatWawasanData = {
    "release_id": "sejarah_critical_01",
    "title": "Cacat Wawasan: Sejarah yang Dipenjara",
    "description":
        "Membongkar manipulasi historiografi, mitos Orde Baru, hingga akar oligarki yang disembunyikan dari kurikulum sekolah.",
    "cover_image": "https://placehold.co/600x800/png?text=Sejarah+Kritis",
    "author": "Tim Riset Warga+",
    "created_at": "2024-05-20T10:00:00Z",
    "tags": ["history", "politics", "critical_thinking", "human_rights"],
    "total_xp": 500,
    "sub_modules": [
      {
        "id": "sub_00_intro",
        "title": "Intro: Sejarah Itu Senjata",
        "type": "chat_stream",
        "estimated_time": "3 min",
        "specific_tags": ["critical_thinking", "history"],
        "xp_reward": 30,
        "chat_script": [
          {
            "role": "ai",
            "text":
                "Halo Warga! 👋 Pernah ngerasa gak sih, pelajaran sejarah di sekolah itu kayak ada yang aneh? Kayak ada 'plot hole' di film?"
          },
          {
            "role": "user_choice",
            "options": ["Sering banget!", "Maksudnya gimana?", "Gak merhatiin"]
          },
          {
            "role": "ai",
            "text":
                "Jujur aja, riset terbaru nunjukin kalau sejarah sekolah kita itu bukan 'ruang hampa' yang netral."
          },
          {
            "role": "ai",
            "text":
                "Sejarah di sini dipakai negara sebagai 'medan perang'. Tujuannya? Buat mengonstruksi ingatan kita supaya patuh sama penguasa. 🤐"
          },
          {
            "role": "ai",
            "text":
                "Ada istilah akademis yang ngeri nih: 'Epistemic Blindness' atau Cacat Wawasan."
          },
          {
            "role": "ai",
            "text":
                "Artinya: Kita sengaja 'dibutakan' dari fakta-fakta tertentu yang bisa bikin posisi negara terancam."
          },
          {
            "role": "user_choice",
            "options": ["Contoh butanya dimana?", "Siapa yang bikin buta?"]
          },
          {
            "role": "ai",
            "text":
                "Banyak banget! Mulai dari peran sipil yang dikecilkan, perempuan yang ilang dari narasi, sampai oligarki ekonomi yang nggak pernah dibahas."
          },
          {
            "role": "ai",
            "text":
                "Contoh paling gampang ya Mitos Serangan Umum 1 Maret atau Supersemar. Narasi di buku sekolah itu seringkali 'Kebenaran Negara', bukan Kebenaran Faktual."
          },
          {
            "role": "ai",
            "text":
                "Akibatnya? Muncul fenomena 'Ingatan yang Dipenjara'. Kita susah move on dari narasi Orde Baru walaupun rezimnya udah lewat."
          },
          {
            "role": "ai",
            "text":
                "Gimana? Siap bongkar satu-satu mitos yang udah memenjara otak kita selama puluhan tahun ini? 🔥"
          },
          {
            "role": "summary_card",
            "title": "Poin Kunci: Intro",
            "content":
                "- Sejarah sekolah = Alat Legitimasi Kekuasaan (bukan sekadar ilmu).\n- Cacat Wawasan = Kondisi sistematis dimana siswa dibuat buta terhadap fakta alternatif.\n- Dampak: Generasi yang rentan disinformasi dan merindukan otoritarianisme."
          }
        ]
      },
      {
        "id": "sub_01_serangan_umum",
        "title": "Mitos Sang Jenderal (1 Maret)",
        "type": "chat_stream",
        "estimated_time": "4 min",
        "specific_tags": ["history", "military"],
        "xp_reward": 50,
        "chat_script": [
          {
            "role": "ai",
            "text":
                "Kita mulai bedah kasus pertama: Serangan Umum 1 Maret 1949 di Jogja."
          },
          {
            "role": "ai",
            "text":
                "Coba inget-inget buku paket SD/SMP lo dulu, atau film wajib 'Janur Kuning'. Siapa tokoh utamanya? 🤔"
          },
          {
            "role": "user_choice",
            "options": ["Soeharto dong", "Jenderal Sudirman", "Sultan HB IX"]
          },
          {
            "role": "ai",
            "text":
                "Mayoritas pasti jawab Letkol Soeharto. Di film itu, dia digambarkan kayak Rambo. Sendirian, heroik, inisiator tunggal."
          },
          {
            "role": "ai",
            "text":
                "Nah, riset historiografi modern membuktikan: Itu MITOS yang dibangun buat kultus individu Orde Baru! 🚫"
          },
          {
            "role": "ai",
            "text":
                "Fakta aslinya: Inisiator ide serangan itu adalah Sri Sultan Hamengku Buwono IX."
          },
          {
            "role": "user_choice",
            "options": ["Kenapa harus Sultan?", "Soeharto ngapain aja?"]
          },
          {
            "role": "ai",
            "text":
                "Jadi gini ceritanya. Sultan denger radio asing (BBC/ABC) kalau Belanda koar-koar di PBB bilang 'TNI udah bubar, Indonesia udah tamat'."
          },
          {
            "role": "ai",
            "text":
                "Sultan panas dong. Dia butuh cara buat ngebungkam mulut Belanda di dunia internasional."
          },
          {
            "role": "ai",
            "text":
                "Makanya, ini tuh sebenernya 'Serangan Diplomasi'. Tujuannya bukan menang perang militer (karena cuma nquasain Jogja 6 jam), tapi buat Show of Force ke Dewan Keamanan PBB."
          },
          {
            "role": "ai",
            "text":
                "Terus Soeharto? Dia itu pelaksana lapangan yang ditunjuk Jenderal Sudirman buat eksekusi idenya Sultan."
          },
          {
            "role": "user_choice",
            "options": ["Jadi buku sekolah bohong?", "Pemerintah ngakuin gak?"]
          },
          {
            "role": "ai",
            "text":
                "Buku lama memanipulasi porsinya. Peran Sultan dikecilin, peran Soeharto digedein banget biar legitimasi dia sebagai Presiden makin kuat."
          },
          {
            "role": "ai",
            "text":
                "Untungnya, Keppres No. 2 Tahun 2022 akhirnya resmi mengakui peran sentral Sultan HB IX. Negara butuh waktu puluhan tahun buat jujur. 😅"
          },
          {
            "role": "ai",
            "text":
                "Pelajaran pentingnya: Jangan telen mentah-mentah sejarah yang tokohnya cuma satu orang doang."
          },
          {
            "role": "summary_card",
            "title": "Fakta vs Mitos 1 Maret",
            "content":
                "✅ Inisiator: Sri Sultan HB IX (Ide serangan diplomatik)\n✅ Restu: Jenderal Sudirman\n✅ Pelaksana: Letkol Soeharto\n❌ Mitos: Soeharto inisiator tunggal (Propaganda Film Janur Kuning)"
          }
        ]
      },
      {
        "id": "sub_02_supersemar",
        "title": "Dokumen Hantu: Supersemar",
        "type": "redacted_doc",
        "estimated_time": "3 min",
        "specific_tags": ["history", "law_policy"],
        "xp_reward": 60,
        "content":
            "Surat Perintah Sebelas Maret (Supersemar) 1966 diajarkan di sekolah sebagai tonggak lahirnya Orde Baru demi memulihkan keamanan. Namun, validitas dokumen ini memiliki cacat fundamental yang jarang dibahas di kelas.\n\nFakta pertama yang paling meresahkan: Naskah asli Supersemar dinyatakan [HILANG]. Hingga hari ini, Arsip Nasional Republik Indonesia (ANRI) hanya menyimpan [TIGA] versi naskah yang berbeda satu sama lain, dan uji forensik Labfor Polri menyatakan ketiganya [TIDAK OTENTIK].\n\nKonteks keluarnya surat ini pun penuh manipulasi. Buku sejarah sekolah menutup mata terhadap fakta bahwa Presiden Soekarno kemungkinan besar menandatangani surat ini di bawah tekanan militer, bahkan ada kesaksian yang menyebutkan adanya todongan [SENJATA] oleh jenderal utusan Soeharto.\n\nLebih parah lagi, mandat Supersemar sejatinya hanyalah perintah administratif untuk memulihkan keamanan (kamtibmas), BUKAN transfer kekuasaan kepresidenan. Namun, Jenderal Soeharto menggunakan surat 'sakti' ini sebagai alat [KUDETA MERANGKAK] (creeping coup) untuk membubarkan PKI, menangkap menteri-menteri loyalis Soekarno, dan akhirnya menggulingkan Presiden yang sah secara inkonstitusional.\n\nGenerasi kita diajarkan untuk memuja stabilitas hasil Supersemar, namun dipaksa buta terhadap ilegalitas proses di baliknya."
      },
      {
        "id": "sub_03_tragedi_1965",
        "title": "Luka 1965 & Hantu Komunisme",
        "type": "chat_stream",
        "estimated_time": "5 min",
        "specific_tags": ["human_rights", "history"],
        "xp_reward": 70,
        "chat_script": []
      },
      {
        "id": "sub_04_oligarki",
        "title": "Oligarki & Mitos Swasembada",
        "type": "chat_stream",
        "estimated_time": "4 min",
        "specific_tags": ["economy_oligarchy", "environment"],
        "xp_reward": 60,
        "chat_script": []
      },
      {
        "id": "sub_05_papua",
        "title": "Papua: Integrasi atau Luka?",
        "type": "redacted_doc",
        "estimated_time": "3 min",
        "specific_tags": ["human_rights", "history"],
        "xp_reward": 80,
        "content": "..."
      },
      {
        "id": "sub_06_p5",
        "title": "P5 & Disiplin Tubuh: Sekolah atau Barak?",
        "type": "chat_stream",
        "estimated_time": "4 min",
        "specific_tags": ["critical_thinking", "law_policy"],
        "xp_reward": 50,
        "chat_script": []
      },
      {
        "id": "sub_07_digital",
        "title": "Sejarah TikTok & Nostalgia Orba",
        "type": "chat_stream",
        "estimated_time": "3 min",
        "specific_tags": ["critical_thinking", "history"],
        "xp_reward": 40,
        "chat_script": []
      },
      {
        "id": "sub_08_outro",
        "title": "Kesimpulan & Refleksi",
        "type": "chat_stream",
        "estimated_time": "3 min",
        "specific_tags": ["critical_thinking"],
        "xp_reward": 100,
        "chat_script": []
      },
      {
        "id": "sub_09_bibliography",
        "title": "Daftar Pustaka & Sumber Valid",
        "type": "chat_stream",
        "estimated_time": "3 min",
        "specific_tags": ["critical_thinking", "academic"],
        "xp_reward": 20,
        "chat_script": []
      }
    ]
  };

  static Future<void> seed() async {
    debugPrint("SEEDING FIRESTORE...");
    final cs = ContentService();
    await cs.importRelease(cacatWawasanData);
    debugPrint("SEED COMPLETE");
  }
}
