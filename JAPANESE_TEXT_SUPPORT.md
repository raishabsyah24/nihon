# Japanese Text Support

Nihon e Ikitai mendukung teks Jepang end-to-end untuk:

- Kanji
- Hiragana
- Katakana
- Furigana
- Romaji
- Arti bahasa Indonesia

## Backend

Backend menerima JSON UTF-8 dari mobile dan admin web. PostgreSQL harus dibuat dengan encoding UTF-8, yang merupakan default PostgreSQL modern.

Field yang sudah eksplisit mendukung teks Jepang:

- `Kana.character`
- `Kana.example`
- `Kotoba.kanji`
- `Kotoba.kana`
- `Kotoba.furigana`
- `Kotoba.romaji`
- `Kotoba.meaning`
- `Question.prompt`
- `Question.options`
- `Question.explanation`
- `QuestionSet.title`
- `QuestionSet.description`
- `SswModule.content`
- `SswModule.vocabulary`
- `SswModule.examples`
- `ExamSchedule.title`
- `ExamSchedule.description`
- `JapanNews.title`
- `JapanNews.body`

## Admin Web

Form admin bisa menulis teks Jepang langsung di input dan textarea.

Format kosakata SSW:

```txt
kanji | kana | furigana | romaji | arti
介護 | かいご | かいご | kaigo | Perawatan lansia
食事 | しょくじ | しょくじ | shokuji | Makan
```

Format contoh kalimat SSW:

```txt
kalimat Jepang | furigana | romaji | arti
利用者の食事を手伝います。 | りようしゃのしょくじをてつだいます。 | riyousha no shokuji o tetsudaimasu. | Membantu makan pengguna layanan.
```

## Mobile

Mobile menampilkan kosakata dan contoh kalimat Jepang di detail modul SSW. Font fallback Jepang sudah ditambahkan agar kanji, hiragana, dan katakana lebih stabil tampil di Android/iOS.

Layar jadwal ujian dan berita Jepang juga aman untuk judul, deskripsi, kategori, dan isi berita yang memuat kanji, hiragana, katakana, romaji, serta arti Indonesia.
