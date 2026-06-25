import { PrismaClient, Role } from "@prisma/client";

const prisma = new PrismaClient();

async function main() {
  await prisma.user.upsert({
    where: { firebaseUid: "seed-admin" },
    update: { role: Role.ADMIN },
    create: {
      firebaseUid: "seed-admin",
      email: "admin@nihoneikitai.local",
      displayName: "Nihon e Ikitai Admin",
      role: Role.ADMIN,
    },
  });

  const hiraganaRows = [
    ["あ", "a", "あさ"],
    ["い", "i", "いぬ"],
    ["う", "u", "うみ"],
    ["え", "e", "えき"],
    ["お", "o", "おちゃ"],
    ["か", "ka", "かさ"],
    ["き", "ki", "きもの"],
    ["く", "ku", "くるま"],
    ["け", "ke", "けさ"],
    ["こ", "ko", "こども"],
    ["さ", "sa", "さかな"],
    ["し", "shi", "しごと"],
    ["す", "su", "すし"],
    ["せ", "se", "せんせい"],
    ["そ", "so", "そら"],
    ["た", "ta", "たまご"],
    ["ち", "chi", "ちず"],
    ["つ", "tsu", "つき"],
    ["て", "te", "てがみ"],
    ["と", "to", "ともだち"],
    ["な", "na", "なまえ"],
    ["に", "ni", "にほん"],
    ["ぬ", "nu", "ぬの"],
    ["ね", "ne", "ねこ"],
    ["の", "no", "のみもの"],
    ["は", "ha", "はな"],
    ["ひ", "hi", "ひと"],
    ["ふ", "fu", "ふね"],
    ["へ", "he", "へや"],
    ["ほ", "ho", "ほん"],
    ["ま", "ma", "まち"],
    ["み", "mi", "みず"],
    ["む", "mu", "むし"],
    ["め", "me", "めがね"],
    ["も", "mo", "もり"],
    ["や", "ya", "やま"],
    ["ゆ", "yu", "ゆき"],
    ["よ", "yo", "よる"],
    ["ら", "ra", "らいねん"],
    ["り", "ri", "りんご"],
    ["る", "ru", "るす"],
    ["れ", "re", "れい"],
    ["ろ", "ro", "ろく"],
    ["わ", "wa", "わたし"],
    ["を", "wo", "を"],
    ["ん", "n", "ほん"],
  ] as const;

  const katakanaRows = [
    ["ア", "a", "アイス"],
    ["イ", "i", "インドネシア"],
    ["ウ", "u", "ウイルス"],
    ["エ", "e", "エアコン"],
    ["オ", "o", "オレンジ"],
    ["カ", "ka", "カメラ"],
    ["キ", "ki", "キロ"],
    ["ク", "ku", "クラス"],
    ["ケ", "ke", "ケーキ"],
    ["コ", "ko", "コーヒー"],
    ["サ", "sa", "サービス"],
    ["シ", "shi", "シャツ"],
    ["ス", "su", "スポーツ"],
    ["セ", "se", "セーター"],
    ["ソ", "so", "ソファ"],
    ["タ", "ta", "タクシー"],
    ["チ", "chi", "チケット"],
    ["ツ", "tsu", "ツアー"],
    ["テ", "te", "テレビ"],
    ["ト", "to", "トイレ"],
    ["ナ", "na", "ナイフ"],
    ["ニ", "ni", "ニュース"],
    ["ヌ", "nu", "ヌードル"],
    ["ネ", "ne", "ネクタイ"],
    ["ノ", "no", "ノート"],
    ["ハ", "ha", "ハンカチ"],
    ["ヒ", "hi", "ホテル"],
    ["フ", "fu", "フォーク"],
    ["ヘ", "he", "ヘルメット"],
    ["ホ", "ho", "ホーム"],
    ["マ", "ma", "マンガ"],
    ["ミ", "mi", "ミルク"],
    ["ム", "mu", "ムード"],
    ["メ", "me", "メール"],
    ["モ", "mo", "モデル"],
    ["ヤ", "ya", "ヤード"],
    ["ユ", "yu", "ユーロ"],
    ["ヨ", "yo", "ヨガ"],
    ["ラ", "ra", "ラジオ"],
    ["リ", "ri", "リモコン"],
    ["ル", "ru", "ルール"],
    ["レ", "re", "レストラン"],
    ["ロ", "ro", "ロビー"],
    ["ワ", "wa", "ワイン"],
    ["ヲ", "wo", "ヲ"],
    ["ン", "n", "パン"],
  ] as const;

  const hiraganaDakutenRows = [
    ["が", "ga", "がっこう"],
    ["ぎ", "gi", "ぎんこう"],
    ["ぐ", "gu", "ぐんて"],
    ["げ", "ge", "げんき"],
    ["ご", "go", "ごはん"],
    ["ざ", "za", "ざっし"],
    ["じ", "ji", "じかん"],
    ["ず", "zu", "ずこう"],
    ["ぜ", "ze", "ぜんぶ"],
    ["ぞ", "zo", "ぞう"],
    ["だ", "da", "だいがく"],
    ["ぢ", "ji", "ちぢむ"],
    ["づ", "zu", "つづく"],
    ["で", "de", "でんわ"],
    ["ど", "do", "どうろ"],
    ["ば", "ba", "ばす"],
    ["び", "bi", "びょういん"],
    ["ぶ", "bu", "ぶた"],
    ["べ", "be", "べんきょう"],
    ["ぼ", "bo", "ぼうし"],
  ] as const;

  const hiraganaHandakutenRows = [
    ["ぱ", "pa", "ぱん"],
    ["ぴ", "pi", "ぴあの"],
    ["ぷ", "pu", "ぷりん"],
    ["ぺ", "pe", "ぺん"],
    ["ぽ", "po", "ぽすと"],
  ] as const;

  const katakanaDakutenRows = [
    ["ガ", "ga", "ガイド"],
    ["ギ", "gi", "ギター"],
    ["グ", "gu", "グラス"],
    ["ゲ", "ge", "ゲーム"],
    ["ゴ", "go", "ゴルフ"],
    ["ザ", "za", "ザボン"],
    ["ジ", "ji", "ジーンズ"],
    ["ズ", "zu", "ズボン"],
    ["ゼ", "ze", "ゼリー"],
    ["ゾ", "zo", "ゾーン"],
    ["ダ", "da", "ダンス"],
    ["ヂ", "ji", "ヂ"],
    ["ヅ", "zu", "ヅ"],
    ["デ", "de", "データ"],
    ["ド", "do", "ドア"],
    ["バ", "ba", "バス"],
    ["ビ", "bi", "ビル"],
    ["ブ", "bu", "ブラシ"],
    ["ベ", "be", "ベッド"],
    ["ボ", "bo", "ボール"],
  ] as const;

  const katakanaHandakutenRows = [
    ["パ", "pa", "パン"],
    ["ピ", "pi", "ピアノ"],
    ["プ", "pu", "プール"],
    ["ペ", "pe", "ペン"],
    ["ポ", "po", "ポスト"],
  ] as const;

  const kanaRows = [
    ...hiraganaRows.map(([character, romaji, example]) => ({
      type: "HIRAGANA" as const,
      character,
      romaji,
      example,
    })),
    ...hiraganaDakutenRows.map(([character, romaji, example]) => ({
      type: "HIRAGANA" as const,
      character,
      romaji,
      example,
    })),
    ...hiraganaHandakutenRows.map(([character, romaji, example]) => ({
      type: "HIRAGANA" as const,
      character,
      romaji,
      example,
    })),
    ...katakanaRows.map(([character, romaji, example]) => ({
      type: "KATAKANA" as const,
      character,
      romaji,
      example,
    })),
    ...katakanaDakutenRows.map(([character, romaji, example]) => ({
      type: "KATAKANA" as const,
      character,
      romaji,
      example,
    })),
    ...katakanaHandakutenRows.map(([character, romaji, example]) => ({
      type: "KATAKANA" as const,
      character,
      romaji,
      example,
    })),
  ];

  for (const kana of kanaRows) {
    await prisma.kana.upsert({
      where: {
        type_character: {
          type: kana.type,
          character: kana.character,
        },
      },
      update: {
        ...kana,
        strokeOrder: placeholderStrokeSteps(kana.character),
      },
      create: {
        ...kana,
        strokeOrder: placeholderStrokeSteps(kana.character),
      },
    });
  }

  const kotobaRows = [
    {
      kanji: "日本",
      kana: "にほん",
      furigana: "にほん",
      romaji: "nihon",
      meaning: "Jepang",
      exampleSentence: "日本へ行きたいです。",
      status: "PUBLISHED" as const,
    },
    {
      kanji: "仕事",
      kana: "しごと",
      furigana: "しごと",
      romaji: "shigoto",
      meaning: "Pekerjaan",
      exampleSentence: "仕事を探しています。",
      status: "PUBLISHED" as const,
    },
    {
      kanji: "水",
      kana: "みず",
      furigana: "みず",
      romaji: "mizu",
      meaning: "Air",
      exampleSentence: "水を飲みます。",
      status: "PUBLISHED" as const,
    },
  ];

  for (const row of kotobaRows) {
    await prisma.kotoba.upsert({
      where: { id: `seed-kotoba-${row.romaji}` },
      update: row,
      create: {
        id: `seed-kotoba-${row.romaji}`,
        ...row,
      },
    });
  }

  const jlptN5Set = await prisma.questionSet.upsert({
    where: { slug: "jlpt-n5-kotoba-basic" },
    update: {
      title: "JLPT N5 Kotoba Basic",
      description: "Paket latihan kosakata dasar JLPT N5.",
      level: "N5",
      category: "kotoba",
      durationMinutes: 15,
      status: "PUBLISHED",
    },
    create: {
      id: "seed-set-jlpt-n5-kotoba",
      type: "JLPT",
      title: "JLPT N5 Kotoba Basic",
      slug: "jlpt-n5-kotoba-basic",
      description: "Paket latihan kosakata dasar JLPT N5.",
      level: "N5",
      category: "kotoba",
      durationMinutes: 15,
      status: "PUBLISHED",
    },
  });

  const jlptN4Set = await prisma.questionSet.upsert({
    where: { slug: "jlpt-n4-bunpou-basic" },
    update: {
      title: "JLPT N4 Bunpou Basic",
      description: "Paket latihan tata bahasa dasar JLPT N4.",
      level: "N4",
      category: "bunpou",
      durationMinutes: 20,
      status: "PUBLISHED",
    },
    create: {
      id: "seed-set-jlpt-n4-bunpou",
      type: "JLPT",
      title: "JLPT N4 Bunpou Basic",
      slug: "jlpt-n4-bunpou-basic",
      description: "Paket latihan tata bahasa dasar JLPT N4.",
      level: "N4",
      category: "bunpou",
      durationMinutes: 20,
      status: "PUBLISHED",
    },
  });

  const jftSet = await prisma.questionSet.upsert({
    where: { slug: "jft-basic-daily-expression" },
    update: {
      title: "JFT Basic Daily Expression",
      description: "Paket latihan ungkapan harian JFT Basic.",
      category: "daily",
      durationMinutes: 15,
      status: "PUBLISHED",
    },
    create: {
      id: "seed-set-jft-daily",
      type: "JFT",
      title: "JFT Basic Daily Expression",
      slug: "jft-basic-daily-expression",
      description: "Paket latihan ungkapan harian JFT Basic.",
      category: "daily",
      durationMinutes: 15,
      status: "PUBLISHED",
    },
  });

  const questionRows = [
    {
      id: "seed-question-jlpt-n5-nihon",
      type: "JLPT" as const,
      level: "N5",
      category: "kotoba",
      questionSetId: jlptN5Set.id,
      prompt: "「日本」の読み方はどれですか。",
      options: ["にほん", "にちほん", "ひほん", "じほん"],
      answerIndex: 0,
      explanation: "日本 dibaca にほん.",
      sortOrder: 1,
      status: "PUBLISHED" as const,
    },
    {
      id: "seed-question-jlpt-n5-mizu",
      type: "JLPT" as const,
      level: "N5",
      category: "kotoba",
      questionSetId: jlptN5Set.id,
      prompt: "Pilih arti dari 「水」.",
      options: ["Api", "Air", "Tanah", "Angin"],
      answerIndex: 1,
      explanation: "水 berarti air.",
      sortOrder: 2,
      status: "PUBLISHED" as const,
    },
    {
      id: "seed-question-jlpt-n4-because",
      type: "JLPT" as const,
      level: "N4",
      category: "bunpou",
      questionSetId: jlptN4Set.id,
      prompt: "「雨が降っています（　）傘を持って行きます。」",
      options: ["から", "まで", "より", "だけ"],
      answerIndex: 0,
      explanation: "から digunakan untuk menyatakan alasan.",
      sortOrder: 1,
      status: "PUBLISHED" as const,
    },
    {
      id: "seed-question-jft-arigatou",
      type: "JFT" as const,
      category: "daily",
      questionSetId: jftSet.id,
      prompt: "Pilih ungkapan yang tepat untuk mengucapkan terima kasih.",
      options: ["すみません", "ありがとう", "おはよう", "さようなら"],
      answerIndex: 1,
      explanation: "ありがとう berarti terima kasih.",
      sortOrder: 1,
      status: "PUBLISHED" as const,
    },
    {
      id: "seed-question-jft-eki",
      type: "JFT" as const,
      category: "daily",
      questionSetId: jftSet.id,
      prompt: "「駅」は tempat untuk apa?",
      options: ["Makan", "Naik kereta", "Belanja baju", "Tidur"],
      answerIndex: 1,
      explanation: "駅 berarti stasiun.",
      sortOrder: 2,
      status: "PUBLISHED" as const,
    },
  ];

  for (const question of questionRows) {
    await prisma.question.upsert({
      where: { id: question.id },
      update: question,
      create: question,
    });
  }

  const category = await prisma.sswCategory.upsert({
    where: { slug: "kaigo" },
    update: {
      title: "Kaigo",
      description: "Materi pengantar SSW bidang perawat lansia.",
      status: "PUBLISHED",
    },
    create: {
      title: "Kaigo",
      slug: "kaigo",
      description: "Materi pengantar SSW bidang perawat lansia.",
      status: "PUBLISHED",
    },
  });

  const module = await prisma.sswModule.upsert({
    where: { slug: "kaigo-intro" },
    update: {
      categoryId: category.id,
      title: "Pengantar Kaigo",
      summary: "Dasar pekerjaan dan kosakata umum di bidang kaigo.",
      content:
        "Modul awal untuk memahami pekerjaan kaigo, istilah dasar, dan contoh ungkapan di tempat kerja.",
      vocabulary: [
        {
          kanji: "介護",
          kana: "かいご",
          furigana: "かいご",
          romaji: "kaigo",
          meaning: "Perawatan lansia",
        },
        {
          kanji: "食事",
          kana: "しょくじ",
          furigana: "しょくじ",
          romaji: "shokuji",
          meaning: "Makan",
        },
        {
          kanji: "利用者",
          kana: "りようしゃ",
          furigana: "りようしゃ",
          romaji: "riyousha",
          meaning: "Pengguna layanan",
        },
      ],
      examples: [
        {
          japanese: "利用者の食事を手伝います。",
          furigana: "りようしゃのしょくじをてつだいます。",
          romaji: "riyousha no shokuji o tetsudaimasu.",
          meaning: "Membantu makan pengguna layanan.",
        },
        {
          japanese: "介護の仕事を勉強しています。",
          furigana: "かいごのしごとをべんきょうしています。",
          romaji: "kaigo no shigoto o benkyou shiteimasu.",
          meaning: "Saya sedang belajar pekerjaan kaigo.",
        },
      ],
      status: "PUBLISHED",
    },
    create: {
      categoryId: category.id,
      title: "Pengantar Kaigo",
      slug: "kaigo-intro",
      summary: "Dasar pekerjaan dan kosakata umum di bidang kaigo.",
      content:
        "Modul awal untuk memahami pekerjaan kaigo, istilah dasar, dan contoh ungkapan di tempat kerja.",
      vocabulary: [
        {
          kanji: "介護",
          kana: "かいご",
          furigana: "かいご",
          romaji: "kaigo",
          meaning: "Perawatan lansia",
        },
        {
          kanji: "食事",
          kana: "しょくじ",
          furigana: "しょくじ",
          romaji: "shokuji",
          meaning: "Makan",
        },
        {
          kanji: "利用者",
          kana: "りようしゃ",
          furigana: "りようしゃ",
          romaji: "riyousha",
          meaning: "Pengguna layanan",
        },
      ],
      examples: [
        {
          japanese: "利用者の食事を手伝います。",
          furigana: "りようしゃのしょくじをてつだいます。",
          romaji: "riyousha no shokuji o tetsudaimasu.",
          meaning: "Membantu makan pengguna layanan.",
        },
        {
          japanese: "介護の仕事を勉強しています。",
          furigana: "かいごのしごとをべんきょうしています。",
          romaji: "kaigo no shigoto o benkyou shiteimasu.",
          meaning: "Saya sedang belajar pekerjaan kaigo.",
        },
      ],
      status: "PUBLISHED",
    },
  });

  await prisma.question.upsert({
    where: { id: "seed-question-ssw-kaigo-focus" },
    update: {
      type: "SSW",
      category: "kaigo",
      prompt: "Apa fokus utama pekerjaan kaigo?",
      options: [
        "Perawatan lansia",
        "Teknik mesin",
        "Pertanian",
        "Pengolahan makanan",
      ],
      answerIndex: 0,
      explanation: "Kaigo berfokus pada perawatan lansia.",
      status: "PUBLISHED",
      sswModuleId: module.id,
    },
    create: {
      id: "seed-question-ssw-kaigo-focus",
      type: "SSW",
      category: "kaigo",
      prompt: "Apa fokus utama pekerjaan kaigo?",
      options: [
        "Perawatan lansia",
        "Teknik mesin",
        "Pertanian",
        "Pengolahan makanan",
      ],
      answerIndex: 0,
      explanation: "Kaigo berfokus pada perawatan lansia.",
      status: "PUBLISHED",
      sswModuleId: module.id,
    },
  });

  const scheduleRows = [
    {
      id: "seed-schedule-jft-jakarta",
      type: "JFT" as const,
      title: "JFT Basic Jakarta",
      location: "Jakarta",
      startsAt: new Date("2026-08-15T09:00:00.000Z"),
      endsAt: new Date("2026-08-15T12:00:00.000Z"),
      registerUrl: "https://example.com/jft",
      description:
        "Contoh jadwal JFT Basic untuk latihan membaca informasi ujian.",
      status: "PUBLISHED" as const,
    },
    {
      id: "seed-schedule-jlpt-indonesia",
      type: "JLPT" as const,
      title: "JLPT Indonesia",
      location: "Indonesia",
      startsAt: new Date("2026-12-06T09:00:00.000Z"),
      endsAt: new Date("2026-12-06T13:00:00.000Z"),
      registerUrl: "https://example.com/jlpt",
      description: "Contoh jadwal JLPT untuk N5 sampai N1.",
      status: "PUBLISHED" as const,
    },
    {
      id: "seed-schedule-ssw-kaigo-online",
      type: "SSW" as const,
      title: "SSW Kaigo Skill Test",
      location: "Online/CBT",
      startsAt: new Date("2026-09-20T08:00:00.000Z"),
      endsAt: new Date("2026-09-20T11:00:00.000Z"),
      registerUrl: "https://example.com/ssw-kaigo",
      description: "Contoh jadwal ujian keterampilan SSW bidang kaigo.",
      status: "PUBLISHED" as const,
    },
  ];

  for (const schedule of scheduleRows) {
    await prisma.examSchedule.upsert({
      where: { id: schedule.id },
      update: schedule,
      create: schedule,
    });
  }

  const newsRows = [
    {
      title: "Belajar Bahasa Jepang untuk Kerja",
      slug: "belajar-bahasa-jepang-untuk-kerja",
      thumbnail: null,
      body: "Berita demo tentang persiapan bahasa Jepang untuk kerja di Jepang. Mulai dari kosakata kerja seperti 仕事, latihan percakapan, sampai target lulus ujian.",
      category: "karier",
      publishedAt: new Date("2026-06-23T09:00:00.000Z"),
      status: "PUBLISHED" as const,
    },
    {
      title: "Tips Mengatur Jadwal Belajar JLPT",
      slug: "tips-mengatur-jadwal-belajar-jlpt",
      thumbnail: null,
      body: "Pisahkan waktu untuk kotoba, bunpou, dokkai, dan choukai. Target kecil seperti 毎日10語 atau 10 kosakata per hari akan lebih mudah dijaga.",
      category: "belajar",
      publishedAt: new Date("2026-06-22T09:00:00.000Z"),
      status: "PUBLISHED" as const,
    },
    {
      title: "Persiapan Ujian SSW Kaigo",
      slug: "persiapan-ujian-ssw-kaigo",
      thumbnail: null,
      body: "Untuk SSW bidang kaigo, pelajari istilah seperti 介護, 食事, dan 利用者 sambil membiasakan diri membaca instruksi sederhana di tempat kerja.",
      category: "ssw",
      publishedAt: new Date("2026-06-21T09:00:00.000Z"),
      status: "PUBLISHED" as const,
    },
  ];

  for (const news of newsRows) {
    await prisma.japanNews.upsert({
      where: { slug: news.slug },
      update: news,
      create: news,
    });
  }
}

function placeholderStrokeSteps(character: string) {
  const count = strokeCount(character);
  return Array.from({ length: count }, (_, index) => ({
    step: index + 1,
    note: `Latihan stroke ${index + 1} untuk ${character}. Ikuti arah goresan secara perlahan.`,
  }));
}

function strokeCount(character: string) {
  if (
    [
      "い",
      "う",
      "こ",
      "し",
      "す",
      "そ",
      "て",
      "の",
      "ひ",
      "へ",
      "る",
      "ろ",
      "ん",
      "イ",
      "エ",
      "ク",
      "ケ",
      "コ",
      "シ",
      "ス",
      "セ",
      "ニ",
      "ノ",
      "フ",
      "ヘ",
      "リ",
      "ル",
      "レ",
      "ロ",
      "ン",
    ].includes(character)
  ) {
    return 2;
  }

  if (
    [
      "あ",
      "お",
      "き",
      "さ",
      "せ",
      "た",
      "な",
      "に",
      "は",
      "ほ",
      "ま",
      "み",
      "む",
      "も",
      "ゆ",
      "ら",
      "り",
      "れ",
      "わ",
      "を",
      "ア",
      "オ",
      "キ",
      "サ",
      "チ",
      "テ",
      "ナ",
      "ネ",
      "ハ",
      "マ",
      "ム",
      "メ",
      "モ",
      "ヤ",
      "ユ",
      "ヨ",
      "ヲ",
    ].includes(character)
  ) {
    return 3;
  }

  if (["ぬ", "ね", "め", "カ", "タ", "ホ", "ミ"].includes(character)) {
    return 4;
  }

  return 2;
}

main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (error) => {
    console.error(error);
    await prisma.$disconnect();
    process.exit(1);
  });
