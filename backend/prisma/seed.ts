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

  const [jlptN3Set, jlptN2Set, jlptN1Set] = await Promise.all(
    [
      {
        id: "seed-set-jlpt-n3-reading-basic",
        slug: "jlpt-n3-reading-basic",
        title: "JLPT N3 Reading Basic",
        description: "Paket latihan bacaan dan tata bahasa transisi JLPT N3.",
        level: "N3",
        category: "dokkai",
        durationMinutes: 25,
      },
      {
        id: "seed-set-jlpt-n2-formal-expression",
        slug: "jlpt-n2-formal-expression",
        title: "JLPT N2 Formal Expression",
        description:
          "Paket latihan ungkapan formal, kosakata abstrak, dan bacaan JLPT N2.",
        level: "N2",
        category: "bunpou",
        durationMinutes: 30,
      },
      {
        id: "seed-set-jlpt-n1-advanced-reading",
        slug: "jlpt-n1-advanced-reading",
        title: "JLPT N1 Advanced Reading",
        description:
          "Paket latihan pemahaman teks kompleks dan ungkapan mahir JLPT N1.",
        level: "N1",
        category: "dokkai",
        durationMinutes: 35,
      },
    ].map((set) =>
      prisma.questionSet.upsert({
        where: { slug: set.slug },
        update: {
          title: set.title,
          description: set.description,
          level: set.level,
          category: set.category,
          durationMinutes: set.durationMinutes,
          status: "PUBLISHED",
        },
        create: {
          id: set.id,
          type: "JLPT",
          title: set.title,
          slug: set.slug,
          description: set.description,
          level: set.level,
          category: set.category,
          durationMinutes: set.durationMinutes,
          status: "PUBLISHED",
        },
      }),
    ),
  );

  const jftSet = await prisma.questionSet.upsert({
    where: { slug: "jft-basic-daily-expression" },
    update: {
      title: "JFT Basic A1 Daily Expression",
      description: "Paket latihan ungkapan harian JFT Basic A1.",
      level: "A1",
      category: "daily",
      durationMinutes: 15,
      status: "PUBLISHED",
    },
    create: {
      id: "seed-set-jft-daily",
      type: "JFT",
      title: "JFT Basic A1 Daily Expression",
      slug: "jft-basic-daily-expression",
      description: "Paket latihan ungkapan harian JFT Basic A1.",
      level: "A1",
      category: "daily",
      durationMinutes: 15,
      status: "PUBLISHED",
    },
  });

  const [jftA2Set, jftB1Set, jftB2Set] = await Promise.all(
    [
      {
        id: "seed-set-jft-a2-public-life",
        slug: "jft-basic-a2-public-life",
        title: "JFT Basic A2 Public Life",
        description:
          "Paket latihan JFT A2 untuk jadwal, lokasi, belanja, dan layanan umum.",
        level: "A2",
        category: "life",
        durationMinutes: 18,
      },
      {
        id: "seed-set-jft-b1-work-instruction",
        slug: "jft-basic-b1-work-instruction",
        title: "JFT Basic B1 Work Instruction",
        description:
          "Paket latihan JFT B1 untuk instruksi kerja dan percakapan tempat kerja.",
        level: "B1",
        category: "work",
        durationMinutes: 20,
      },
      {
        id: "seed-set-jft-b2-reading-context",
        slug: "jft-basic-b2-reading-context",
        title: "JFT Basic B2 Reading Context",
        description:
          "Paket latihan JFT B2 untuk bacaan lebih panjang dan pemahaman konteks.",
        level: "B2",
        category: "reading",
        durationMinutes: 22,
      },
    ].map((set) =>
      prisma.questionSet.upsert({
        where: { slug: set.slug },
        update: {
          title: set.title,
          description: set.description,
          level: set.level,
          category: set.category,
          durationMinutes: set.durationMinutes,
          status: "PUBLISHED",
        },
        create: {
          id: set.id,
          type: "JFT",
          title: set.title,
          slug: set.slug,
          description: set.description,
          level: set.level,
          category: set.category,
          durationMinutes: set.durationMinutes,
          status: "PUBLISHED",
        },
      }),
    ),
  );

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
      id: "seed-question-jlpt-n3-koto",
      type: "JLPT" as const,
      level: "N3",
      category: "bunpou",
      questionSetId: jlptN3Set.id,
      prompt: "「日本へ行くことにしました。」の意味に近いものはどれですか。",
      options: [
        "Saya memutuskan pergi ke Jepang.",
        "Saya sedang pergi ke Jepang.",
        "Saya pernah pergi ke Jepang.",
        "Saya dilarang pergi ke Jepang.",
      ],
      answerIndex: 0,
      explanation:
        "ことにしました digunakan saat pembicara sudah mengambil keputusan.",
      sortOrder: 1,
      status: "PUBLISHED" as const,
    },
    {
      id: "seed-question-jlpt-n3-reading-notice",
      type: "JLPT" as const,
      level: "N3",
      category: "dokkai",
      questionSetId: jlptN3Set.id,
      prompt:
        "「会議は午後三時から四時までです。五分前に会議室へ来てください。」何時に会議室へ行きますか。",
      options: ["2時55分", "3時05分", "4時00分", "4時05分"],
      answerIndex: 0,
      explanation:
        "五分前 berarti 5 menit sebelum mulai. Mulai 3:00, jadi datang 2:55.",
      sortOrder: 2,
      status: "PUBLISHED" as const,
    },
    {
      id: "seed-question-jlpt-n2-ni-tsurete",
      type: "JLPT" as const,
      level: "N2",
      category: "bunpou",
      questionSetId: jlptN2Set.id,
      prompt: "日本語が上手になる（　）、仕事のチャンスも増えます。",
      options: ["につれて", "に対して", "によって", "として"],
      answerIndex: 0,
      explanation:
        "につれて menyatakan perubahan yang terjadi seiring perubahan lain.",
      sortOrder: 1,
      status: "PUBLISHED" as const,
    },
    {
      id: "seed-question-jlpt-n2-formal-mail",
      type: "JLPT" as const,
      level: "N2",
      category: "kotoba",
      questionSetId: jlptN2Set.id,
      prompt:
        "Email formal: 「資料を（　）いただけますでしょうか。」Kata yang paling sopan adalah?",
      options: ["送って", "送付して", "投げて", "出して"],
      answerIndex: 1,
      explanation:
        "送付して lebih formal untuk konteks bisnis dibanding 送って.",
      sortOrder: 2,
      status: "PUBLISHED" as const,
    },
    {
      id: "seed-question-jlpt-n1-yue-ni",
      type: "JLPT" as const,
      level: "N1",
      category: "bunpou",
      questionSetId: jlptN1Set.id,
      prompt: "努力した（　）、合格の喜びは大きかった。",
      options: ["ゆえに", "ものの", "どころか", "にしては"],
      answerIndex: 0,
      explanation:
        "ゆえに berarti karena/oleh sebab itu, cocok untuk alasan formal.",
      sortOrder: 1,
      status: "PUBLISHED" as const,
    },
    {
      id: "seed-question-jlpt-n1-abstract-reading",
      type: "JLPT" as const,
      level: "N1",
      category: "dokkai",
      questionSetId: jlptN1Set.id,
      prompt:
        "「効率を追求するあまり、学ぶ楽しさを見失ってはならない。」Penulis ingin menekankan apa?",
      options: [
        "Efisiensi penting, tetapi rasa senang belajar juga harus dijaga.",
        "Efisiensi tidak diperlukan dalam belajar.",
        "Belajar harus selalu cepat tanpa istirahat.",
        "Kesenangan belajar tidak ada hubungannya dengan hasil.",
      ],
      answerIndex: 0,
      explanation:
        "Kalimat menegaskan jangan kehilangan 楽しさ saat terlalu mengejar efisiensi.",
      sortOrder: 2,
      status: "PUBLISHED" as const,
    },
    {
      id: "seed-question-jft-arigatou",
      type: "JFT" as const,
      level: "A1",
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
      level: "A1",
      category: "daily",
      questionSetId: jftSet.id,
      prompt: "「駅」は tempat untuk apa?",
      options: ["Makan", "Naik kereta", "Belanja baju", "Tidur"],
      answerIndex: 1,
      explanation: "駅 berarti stasiun.",
      sortOrder: 2,
      status: "PUBLISHED" as const,
    },
    {
      id: "seed-question-jft-a2-kippu",
      type: "JFT" as const,
      level: "A2",
      category: "life",
      questionSetId: jftA2Set.id,
      prompt: "「切符を買います。」Kegiatan apa yang dilakukan?",
      options: ["Membeli tiket", "Mencari kamar", "Membaca buku", "Memasak"],
      answerIndex: 0,
      explanation: "切符 berarti tiket, 買います berarti membeli.",
      sortOrder: 1,
      status: "PUBLISHED" as const,
    },
    {
      id: "seed-question-jft-a2-schedule",
      type: "JFT" as const,
      level: "A2",
      category: "life",
      questionSetId: jftA2Set.id,
      prompt: "「バスは午前八時に出ます。」Informasi yang benar adalah?",
      options: [
        "Bus berangkat pukul 08.00 pagi",
        "Bus tiba pukul 08.00 malam",
        "Bus libur hari ini",
        "Bus berhenti selama 8 jam",
      ],
      answerIndex: 0,
      explanation: "午前八時 berarti jam 8 pagi, 出ます berarti berangkat.",
      sortOrder: 2,
      status: "PUBLISHED" as const,
    },
    {
      id: "seed-question-jft-b1-safety",
      type: "JFT" as const,
      level: "B1",
      category: "work",
      questionSetId: jftB1Set.id,
      prompt:
        "Atasan berkata: 「作業の前に、必ず手袋をしてください。」Apa yang harus dilakukan?",
      options: [
        "Memakai sarung tangan sebelum bekerja",
        "Melepas sarung tangan saat bekerja",
        "Membersihkan ruangan setelah pulang",
        "Menulis laporan sebelum makan",
      ],
      answerIndex: 0,
      explanation:
        "作業の前に berarti sebelum bekerja, 手袋をしてください berarti pakai sarung tangan.",
      sortOrder: 1,
      status: "PUBLISHED" as const,
    },
    {
      id: "seed-question-jft-b1-report",
      type: "JFT" as const,
      level: "B1",
      category: "work",
      questionSetId: jftB1Set.id,
      prompt:
        "「問題があったら、すぐ報告してください。」Respons paling tepat adalah?",
      options: [
        "はい、すぐ報告します。",
        "いいえ、休みます。",
        "昨日買いました。",
        "とても暑いです。",
      ],
      answerIndex: 0,
      explanation:
        "Instruksi meminta segera melapor jika ada masalah, jadi respons setuju paling tepat.",
      sortOrder: 2,
      status: "PUBLISHED" as const,
    },
    {
      id: "seed-question-jft-b2-notice",
      type: "JFT" as const,
      level: "B2",
      category: "reading",
      questionSetId: jftB2Set.id,
      prompt:
        "Pemberitahuan: 「明日は点検のため、入口Aは使えません。入口Bをご利用ください。」Apa maksudnya?",
      options: [
        "Besok gunakan pintu B karena pintu A tidak bisa dipakai",
        "Besok pintu B ditutup untuk libur",
        "Hari ini semua pintu bisa dipakai",
        "Pemeriksaan dibatalkan karena pintu A rusak",
      ],
      answerIndex: 0,
      explanation:
        "入口Aは使えません dan 入口Bをご利用ください berarti gunakan pintu B.",
      sortOrder: 1,
      status: "PUBLISHED" as const,
    },
    {
      id: "seed-question-jft-b2-context",
      type: "JFT" as const,
      level: "B2",
      category: "reading",
      questionSetId: jftB2Set.id,
      prompt:
        "「急ぎではありませんが、今週中に確認していただけると助かります。」Nada kalimat ini adalah?",
      options: [
        "Permintaan sopan dengan batas waktu minggu ini",
        "Larangan keras untuk mengecek dokumen",
        "Keluhan karena pekerjaan sudah selesai",
        "Pemberitahuan bahwa tidak perlu dicek",
      ],
      answerIndex: 0,
      explanation:
        "急ぎではありませんが dan いただけると助かります menunjukkan permintaan sopan.",
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

  const materialRows = [
    {
      id: "jft-basic-a1-material",
      kind: "JFT_MATERIAL" as const,
      title: "Materi JFT Basic A1",
      slug: "jft-basic-a1-material",
      level: "A1",
      category: "JFT Basic",
      summary:
        "Fondasi komunikasi harian: salam, perkenalan, benda sekitar, dan kalimat sederhana.",
      content:
        "Level A1 membantu user memahami ungkapan yang sering muncul dalam situasi sangat dekat: menyapa, menyebut nama, bertanya benda, dan memahami instruksi pendek.",
      sections: [
        {
          title: "Target belajar",
          body: "User mampu memperkenalkan diri, memahami pertanyaan sederhana, dan menjawab dengan pola kalimat pendek.",
        },
        {
          title: "Pola inti",
          body: "Gunakan pola A wa B desu untuk memperkenalkan orang, benda, asal, pekerjaan, atau status.",
        },
      ],
      vocabulary: [
        {
          kanji: "日本",
          kana: "にほん",
          furigana: "にほん",
          romaji: "nihon",
          meaning: "Jepang",
        },
        {
          kanji: "名前",
          kana: "なまえ",
          furigana: "なまえ",
          romaji: "namae",
          meaning: "nama",
        },
      ],
      examples: [
        {
          japanese: "わたしはインドネシア人です。",
          furigana: "わたしはインドネシアじんです。",
          romaji: "watashi wa Indoneshia-jin desu.",
          meaning: "Saya orang Indonesia.",
        },
      ],
      status: "PUBLISHED" as const,
    },
    {
      id: "jft-basic-a2-material",
      kind: "JFT_MATERIAL" as const,
      title: "Materi JFT Basic A2",
      slug: "jft-basic-a2-material",
      level: "A2",
      category: "JFT Basic",
      summary:
        "Aktivitas harian, kebutuhan sederhana, dan percakapan pendek di tempat umum.",
      content:
        "Level A2 menguatkan kemampuan membaca informasi pendek, memahami instruksi umum, dan memilih respons yang sesuai dalam situasi sehari-hari.",
      sections: [
        {
          title: "Target belajar",
          body: "User mampu memahami jadwal, harga, lokasi, dan percakapan praktis yang memakai kosakata umum.",
        },
        {
          title: "Pola inti",
          body: "Gunakan kata kerja bentuk masu untuk menyatakan aktivitas harian dan rencana sederhana.",
        },
      ],
      vocabulary: [
        {
          kanji: "時間",
          kana: "じかん",
          furigana: "じかん",
          romaji: "jikan",
          meaning: "waktu",
        },
        {
          kanji: "買います",
          kana: "かいます",
          furigana: "かいます",
          romaji: "kaimasu",
          meaning: "membeli",
        },
      ],
      examples: [
        {
          japanese: "駅で切符を買います。",
          furigana: "えきできっぷをかいます。",
          romaji: "eki de kippu o kaimasu.",
          meaning: "Membeli tiket di stasiun.",
        },
      ],
      status: "PUBLISHED" as const,
    },
    {
      id: "jft-basic-b1-material",
      kind: "JFT_MATERIAL" as const,
      title: "Materi JFT Basic B1",
      slug: "jft-basic-b1-material",
      level: "B1",
      category: "JFT Basic",
      summary:
        "Instruksi kerja, informasi layanan, dan bacaan menengah yang lebih panjang.",
      content:
        "Level B1 menyiapkan user memahami informasi kerja yang berisi alasan, urutan tindakan, larangan, dan pilihan respons yang tepat.",
      sections: [
        {
          title: "Target belajar",
          body: "User mampu memahami instruksi bertahap dan mencari inti informasi dari pengumuman atau pesan pendek.",
        },
        {
          title: "Pola inti",
          body: "Latih pola te kudasai, te mo ii desu, dan te wa ikemasen untuk instruksi dan aturan.",
        },
      ],
      vocabulary: [
        {
          kanji: "説明",
          kana: "せつめい",
          furigana: "せつめい",
          romaji: "setsumei",
          meaning: "penjelasan",
        },
        {
          kanji: "確認",
          kana: "かくにん",
          furigana: "かくにん",
          romaji: "kakunin",
          meaning: "konfirmasi",
        },
      ],
      examples: [
        {
          japanese: "作業の前に説明を確認してください。",
          furigana: "さぎょうのまえにせつめいをかくにんしてください。",
          romaji: "sagyou no mae ni setsumei o kakunin shite kudasai.",
          meaning: "Sebelum bekerja, pastikan penjelasannya.",
        },
      ],
      status: "PUBLISHED" as const,
    },
    {
      id: "jft-basic-b2-material",
      kind: "JFT_MATERIAL" as const,
      title: "Materi JFT Basic B2",
      slug: "jft-basic-b2-material",
      level: "B2",
      category: "JFT Basic",
      summary:
        "Pemahaman situasi panjang, alasan, opini sederhana, dan konteks tempat kerja.",
      content:
        "Level B2 memperkuat kemampuan memilih kesimpulan yang tepat dari beberapa informasi dan memahami maksud pembicara dalam konteks kerja.",
      sections: [
        {
          title: "Target belajar",
          body: "User mampu membandingkan informasi, membaca kondisi, dan memahami alasan di balik sebuah instruksi.",
        },
        {
          title: "Pola inti",
          body: "Latih node, kara, tame ni, dan hou ga ii untuk alasan, tujuan, dan saran.",
        },
      ],
      vocabulary: [
        {
          kanji: "理由",
          kana: "りゆう",
          furigana: "りゆう",
          romaji: "riyuu",
          meaning: "alasan",
        },
        {
          kanji: "安全",
          kana: "あんぜん",
          furigana: "あんぜん",
          romaji: "anzen",
          meaning: "aman/keselamatan",
        },
      ],
      examples: [
        {
          japanese: "安全のために、手袋を使ったほうがいいです。",
          furigana: "あんぜんのために、てぶくろをつかったほうがいいです。",
          romaji: "anzen no tame ni, tebukuro o tsukatta hou ga ii desu.",
          meaning: "Demi keselamatan, sebaiknya menggunakan sarung tangan.",
        },
      ],
      status: "PUBLISHED" as const,
    },
    ...["N5", "N4", "N3", "N2", "N1"].map((level, index) => ({
      id: `jlpt-${level.toLowerCase()}-material`,
      kind: "JLPT_MATERIAL" as const,
      title: `Materi JLPT ${level}`,
      slug: `jlpt-${level.toLowerCase()}-material`,
      level,
      category: "JLPT",
      summary: `Peta belajar JLPT ${level}: kotoba, bunpou, dokkai, dan latihan pemahaman bertahap.`,
      content:
        index < 2
          ? "Materi dasar berfokus pada pola kalimat umum, kosakata harian, dan bacaan pendek."
          : "Materi lanjutan berfokus pada variasi ungkapan, bacaan lebih panjang, dan pemahaman konteks.",
      sections: [
        {
          title: "Target belajar",
          body: `User memahami area utama JLPT ${level} dan memiliki urutan belajar yang jelas sebelum latihan soal.`,
        },
        {
          title: "Ritme latihan",
          body: "Pelajari kosakata, baca contoh kalimat, lalu ulangi pola tata bahasa dengan soal pendek.",
        },
      ],
      vocabulary: [
        {
          kanji: "毎日",
          kana: "まいにち",
          furigana: "まいにち",
          romaji: "mainichi",
          meaning: "setiap hari",
        },
        {
          kanji: "勉強",
          kana: "べんきょう",
          furigana: "べんきょう",
          romaji: "benkyou",
          meaning: "belajar",
        },
      ],
      examples: [
        {
          japanese: "毎日、日本語を勉強します。",
          furigana: "まいにち、にほんごをべんきょうします。",
          romaji: "mainichi, nihongo o benkyou shimasu.",
          meaning: "Saya belajar bahasa Jepang setiap hari.",
        },
      ],
      status: "PUBLISHED" as const,
    })),
  ];

  for (const material of materialRows) {
    const materialData = {
      kind: material.kind,
      title: material.title,
      slug: material.slug,
      level: material.level,
      category: material.category,
      summary: material.summary,
      content: material.content,
      sections: material.sections.map((section) => ({ ...section })),
      vocabulary: material.vocabulary.map((item) => ({ ...item })),
      examples: material.examples.map((item) => ({ ...item })),
      status: material.status,
    };

    await prisma.studyMaterial.upsert({
      where: { id: material.id },
      update: materialData,
      create: {
        id: material.id,
        ...materialData,
      },
    });
  }

  const packageRows = [
    {
      id: "seed-package-jft-material-a1",
      kind: "JFT_MATERIAL",
      title: "Paket JFT Basic A1",
      slug: "jft-basic-a1-material",
      subtitle: "Materi dan soal JFT Basic A1",
      previewDescription:
        "Preview paket JFT Basic A1 untuk kosakata, pola kalimat, situasi harian, dan latihan soal.",
      description:
        "Paket JFT Basic A1 berisi materi ringkas, contoh dialog, latihan soal, pembahasan, dan evaluasi kemampuan awal.",
      level: "A1",
      category: "JFT Basic",
      price: 99000,
      sortOrder: 10,
      benefits: [
        "Materi ringkas",
        "Latihan soal",
        "Pembahasan",
        "Progress belajar",
      ],
      metadata: { access: "paid", productGroup: "jft" },
      status: "PUBLISHED",
      contents: [
        {
          contentType: "JFT_MATERIAL",
          contentId: "jft-basic-a1-material",
          title: "Materi JFT Basic A1",
        },
        {
          contentType: "QUESTION_SET",
          contentId: jftSet.id,
          title: jftSet.title,
        },
      ],
    },
    {
      id: "seed-package-jft-material-a2",
      kind: "JFT_MATERIAL",
      title: "Paket JFT Basic A2",
      slug: "jft-basic-a2-material",
      subtitle: "Materi dan soal JFT Basic A2",
      previewDescription:
        "Preview paket JFT Basic A2 untuk aktivitas harian, kerja, layanan publik, dan latihan soal.",
      description:
        "Paket JFT Basic A2 membantu user memahami teks pendek, percakapan praktis, kosakata umum, dan latihan kesiapan ujian.",
      level: "A2",
      category: "JFT Basic",
      price: 119000,
      sortOrder: 20,
      benefits: [
        "Materi tematik",
        "Latihan soal",
        "Pembahasan",
        "Progress belajar",
      ],
      metadata: { access: "paid", productGroup: "jft" },
      status: "PUBLISHED",
      contents: [
        {
          contentType: "JFT_MATERIAL",
          contentId: "jft-basic-a2-material",
          title: "Materi JFT Basic A2",
        },
        {
          contentType: "QUESTION_SET",
          contentId: jftA2Set.id,
          title: jftA2Set.title,
        },
      ],
    },
    {
      id: "seed-package-jft-material-b1",
      kind: "JFT_MATERIAL",
      title: "Paket JFT Basic B1",
      slug: "jft-basic-b1-material",
      subtitle: "Materi dan soal JFT Basic B1",
      previewDescription:
        "Preview paket JFT Basic B1 untuk instruksi, informasi kerja, komunikasi panjang, dan latihan soal.",
      description:
        "Paket JFT Basic B1 menyiapkan user membaca informasi lebih kompleks, memahami percakapan kerja, dan mengukur kesiapan ujian.",
      level: "B1",
      category: "JFT Basic",
      price: 139000,
      sortOrder: 30,
      benefits: [
        "Materi lanjutan",
        "Latihan soal",
        "Pembahasan",
        "Progress belajar",
      ],
      metadata: { access: "paid", productGroup: "jft" },
      status: "PUBLISHED",
      contents: [
        {
          contentType: "JFT_MATERIAL",
          contentId: "jft-basic-b1-material",
          title: "Materi JFT Basic B1",
        },
        {
          contentType: "QUESTION_SET",
          contentId: jftB1Set.id,
          title: jftB1Set.title,
        },
      ],
    },
    {
      id: "seed-package-jft-material-b2",
      kind: "JFT_MATERIAL",
      title: "Paket JFT Basic B2",
      slug: "jft-basic-b2-material",
      subtitle: "Materi dan soal JFT Basic B2",
      previewDescription:
        "Preview paket JFT Basic B2 untuk pemahaman teks, situasi detail, dan latihan soal.",
      description:
        "Paket JFT Basic B2 berisi penguatan bacaan, kosakata kerja, pemahaman situasi panjang, latihan soal, dan evaluasi.",
      level: "B2",
      category: "JFT Basic",
      price: 159000,
      sortOrder: 40,
      benefits: [
        "Materi penguatan",
        "Latihan soal",
        "Pembahasan",
        "Progress belajar",
      ],
      metadata: { access: "paid", productGroup: "jft" },
      status: "PUBLISHED",
      contents: [
        {
          contentType: "JFT_MATERIAL",
          contentId: "jft-basic-b2-material",
          title: "Materi JFT Basic B2",
        },
        {
          contentType: "QUESTION_SET",
          contentId: jftB2Set.id,
          title: jftB2Set.title,
        },
      ],
    },
    {
      id: "seed-package-jft-question-a1",
      kind: "JFT_QUESTION",
      title: "Soal JFT Basic A1",
      slug: "jft-basic-a1-question",
      subtitle: "Latihan soal JFT pemula",
      previewDescription:
        "Preview latihan soal JFT Basic A1 untuk kosakata dan ekspresi harian.",
      description:
        "Paket soal JFT Basic A1 berisi latihan pilihan ganda, pembahasan, dan evaluasi kemampuan awal.",
      level: "A1",
      category: "JFT Basic",
      price: 59000,
      sortOrder: 50,
      benefits: ["Latihan soal", "Pembahasan", "Riwayat nilai"],
      metadata: { access: "paid", productGroup: "jft" },
      status: "DRAFT",
      contents: [
        {
          contentType: "QUESTION_SET",
          contentId: jftSet.id,
          title: jftSet.title,
        },
      ],
    },
    {
      id: "seed-package-jft-question-a2",
      kind: "JFT_QUESTION",
      title: "Soal JFT Basic A2",
      slug: "jft-basic-a2-question",
      subtitle: "Latihan soal JFT target A2",
      previewDescription:
        "Preview latihan soal JFT Basic A2 untuk situasi harian dan kerja sederhana.",
      description:
        "Paket soal JFT Basic A2 berisi latihan bertahap untuk mengevaluasi kesiapan ujian.",
      level: "A2",
      category: "JFT Basic",
      price: 69000,
      sortOrder: 60,
      benefits: ["Latihan soal", "Pembahasan", "Riwayat nilai"],
      metadata: { access: "paid", productGroup: "jft" },
      status: "DRAFT",
      contents: [
        {
          contentType: "QUESTION_SET",
          contentId: jftA2Set.id,
          title: jftA2Set.title,
        },
      ],
    },
    {
      id: "seed-package-jft-question-b1",
      kind: "JFT_QUESTION",
      title: "Soal JFT Basic B1",
      slug: "jft-basic-b1-question",
      subtitle: "Latihan soal JFT lanjutan",
      previewDescription:
        "Preview latihan soal JFT Basic B1 untuk instruksi kerja dan informasi lebih panjang.",
      description:
        "Paket soal JFT Basic B1 berisi latihan bertahap untuk pemahaman bacaan dan situasi kerja.",
      level: "B1",
      category: "JFT Basic",
      price: 79000,
      sortOrder: 65,
      benefits: ["Latihan soal", "Pembahasan", "Riwayat nilai"],
      metadata: { access: "paid", productGroup: "jft" },
      status: "DRAFT",
      contents: [
        {
          contentType: "QUESTION_SET",
          contentId: jftB1Set.id,
          title: jftB1Set.title,
        },
      ],
    },
    {
      id: "seed-package-jft-question-b2",
      kind: "JFT_QUESTION",
      title: "Soal JFT Basic B2",
      slug: "jft-basic-b2-question",
      subtitle: "Latihan soal JFT penguatan",
      previewDescription:
        "Preview latihan soal JFT Basic B2 untuk bacaan, instruksi, dan konteks detail.",
      description:
        "Paket soal JFT Basic B2 berisi latihan penguatan untuk user yang ingin mencoba soal lebih menantang.",
      level: "B2",
      category: "JFT Basic",
      price: 89000,
      sortOrder: 66,
      benefits: ["Latihan soal", "Pembahasan", "Riwayat nilai"],
      metadata: { access: "paid", productGroup: "jft" },
      status: "DRAFT",
      contents: [
        {
          contentType: "QUESTION_SET",
          contentId: jftB2Set.id,
          title: jftB2Set.title,
        },
      ],
    },
    {
      id: "seed-package-jlpt-material-n5",
      kind: "JLPT_MATERIAL",
      title: "Paket JLPT N5",
      slug: "jlpt-n5-material",
      subtitle: "Materi dan soal JLPT N5",
      previewDescription:
        "Preview paket JLPT N5 untuk kotoba, bunpou, dokkai, choukai dasar, dan latihan soal.",
      description:
        "Paket JLPT N5 membantu user membangun fondasi kosakata, pola kalimat, latihan membaca dasar, pembahasan, dan evaluasi.",
      level: "N5",
      category: "JLPT",
      price: 129000,
      sortOrder: 70,
      benefits: ["Materi N5", "Latihan soal", "Pembahasan", "Progress belajar"],
      metadata: { access: "paid", productGroup: "jlpt" },
      status: "PUBLISHED",
      contents: [
        {
          contentType: "JLPT_MATERIAL",
          contentId: "jlpt-n5-material",
          title: "Materi JLPT N5",
        },
        {
          contentType: "QUESTION_SET",
          contentId: jlptN5Set.id,
          title: jlptN5Set.title,
        },
      ],
    },
    {
      id: "seed-package-jlpt-question-n5",
      kind: "JLPT_QUESTION",
      title: "Soal JLPT N5",
      slug: "jlpt-n5-question",
      subtitle: "Latihan soal JLPT N5",
      previewDescription:
        "Preview soal JLPT N5 untuk kosakata dan pemahaman kalimat dasar.",
      description:
        "Paket soal JLPT N5 berisi latihan pilihan ganda, pembahasan, dan evaluasi nilai.",
      level: "N5",
      category: "JLPT",
      price: 69000,
      sortOrder: 80,
      benefits: ["Latihan soal N5", "Pembahasan", "Riwayat nilai"],
      metadata: { access: "paid", productGroup: "jlpt" },
      status: "DRAFT",
      contents: [
        {
          contentType: "QUESTION_SET",
          contentId: jlptN5Set.id,
          title: jlptN5Set.title,
        },
      ],
    },
    {
      id: "seed-package-jlpt-material-n4",
      kind: "JLPT_MATERIAL",
      title: "Paket JLPT N4",
      slug: "jlpt-n4-material",
      subtitle: "Materi dan soal JLPT N4",
      previewDescription:
        "Preview paket JLPT N4 untuk kosakata, tata bahasa, bacaan pendek, dan latihan soal.",
      description:
        "Paket JLPT N4 memperkuat pola kalimat, bacaan, pemahaman konteks sehari-hari, dan evaluasi kesiapan ujian.",
      level: "N4",
      category: "JLPT",
      price: 149000,
      sortOrder: 90,
      benefits: ["Materi N4", "Latihan soal", "Pembahasan", "Progress belajar"],
      metadata: { access: "paid", productGroup: "jlpt" },
      status: "PUBLISHED",
      contents: [
        {
          contentType: "JLPT_MATERIAL",
          contentId: "jlpt-n4-material",
          title: "Materi JLPT N4",
        },
        {
          contentType: "QUESTION_SET",
          contentId: jlptN4Set.id,
          title: jlptN4Set.title,
        },
      ],
    },
    {
      id: "seed-package-jlpt-question-n4",
      kind: "JLPT_QUESTION",
      title: "Soal JLPT N4",
      slug: "jlpt-n4-question",
      subtitle: "Latihan soal JLPT N4",
      previewDescription:
        "Preview soal JLPT N4 untuk bunpou dan pemahaman kalimat.",
      description:
        "Paket soal JLPT N4 berisi latihan pilihan ganda, pembahasan, dan evaluasi nilai.",
      level: "N4",
      category: "JLPT",
      price: 79000,
      sortOrder: 100,
      benefits: ["Latihan soal N4", "Pembahasan", "Riwayat nilai"],
      metadata: { access: "paid", productGroup: "jlpt" },
      status: "DRAFT",
      contents: [
        {
          contentType: "QUESTION_SET",
          contentId: jlptN4Set.id,
          title: jlptN4Set.title,
        },
      ],
    },
    {
      id: "seed-package-jlpt-material-n3",
      kind: "JLPT_MATERIAL",
      title: "Paket JLPT N3",
      slug: "jlpt-n3-material",
      subtitle: "Materi dan soal JLPT N3",
      previewDescription:
        "Preview paket JLPT N3 untuk bacaan, tata bahasa, kosakata menengah, dan latihan soal.",
      description:
        "Paket JLPT N3 disiapkan untuk user yang naik dari N4 menuju bacaan dan struktur lebih kompleks, lengkap dengan latihan soal.",
      level: "N3",
      category: "JLPT",
      price: 179000,
      sortOrder: 110,
      benefits: ["Materi N3", "Latihan soal", "Pembahasan", "Progress belajar"],
      metadata: { access: "paid", productGroup: "jlpt" },
      status: "PUBLISHED",
      contents: [
        {
          contentType: "JLPT_MATERIAL",
          contentId: "jlpt-n3-material",
          title: "Materi JLPT N3",
        },
        {
          contentType: "QUESTION_SET",
          contentId: jlptN3Set.id,
          title: jlptN3Set.title,
        },
      ],
    },
    {
      id: "seed-package-jlpt-question-n3",
      kind: "JLPT_QUESTION",
      title: "Soal JLPT N3",
      slug: "jlpt-n3-question",
      subtitle: "Latihan soal JLPT N3",
      previewDescription:
        "Preview soal JLPT N3 untuk latihan bertahap sebelum tryout.",
      description:
        "Paket soal JLPT N3 berisi latihan pilihan ganda, pembahasan, dan evaluasi nilai.",
      level: "N3",
      category: "JLPT",
      price: 89000,
      sortOrder: 120,
      benefits: ["Latihan soal N3", "Pembahasan", "Riwayat nilai"],
      metadata: { access: "paid", productGroup: "jlpt" },
      status: "DRAFT",
      contents: [
        {
          contentType: "QUESTION_SET",
          contentId: jlptN3Set.id,
          title: jlptN3Set.title,
        },
      ],
    },
    {
      id: "seed-package-jlpt-material-n2",
      kind: "JLPT_MATERIAL",
      title: "Paket JLPT N2",
      slug: "jlpt-n2-material",
      subtitle: "Materi dan soal JLPT N2",
      previewDescription:
        "Preview paket JLPT N2 untuk bacaan panjang, ungkapan formal, kosakata luas, dan latihan soal.",
      description:
        "Paket JLPT N2 disiapkan untuk user yang mengejar kemampuan akademik dan kerja lebih kuat, lengkap dengan latihan soal.",
      level: "N2",
      category: "JLPT",
      price: 199000,
      sortOrder: 130,
      benefits: ["Materi N2", "Latihan soal", "Pembahasan", "Progress belajar"],
      metadata: { access: "paid", productGroup: "jlpt" },
      status: "PUBLISHED",
      contents: [
        {
          contentType: "JLPT_MATERIAL",
          contentId: "jlpt-n2-material",
          title: "Materi JLPT N2",
        },
        {
          contentType: "QUESTION_SET",
          contentId: jlptN2Set.id,
          title: jlptN2Set.title,
        },
      ],
    },
    {
      id: "seed-package-jlpt-question-n2",
      kind: "JLPT_QUESTION",
      title: "Soal JLPT N2",
      slug: "jlpt-n2-question",
      subtitle: "Latihan soal JLPT N2",
      previewDescription:
        "Preview soal JLPT N2 untuk latihan bacaan, kosakata, dan tata bahasa.",
      description:
        "Paket soal JLPT N2 berisi latihan pilihan ganda, pembahasan, dan evaluasi nilai.",
      level: "N2",
      category: "JLPT",
      price: 99000,
      sortOrder: 140,
      benefits: ["Latihan soal N2", "Pembahasan", "Riwayat nilai"],
      metadata: { access: "paid", productGroup: "jlpt" },
      status: "DRAFT",
      contents: [
        {
          contentType: "QUESTION_SET",
          contentId: jlptN2Set.id,
          title: jlptN2Set.title,
        },
      ],
    },
    {
      id: "seed-package-jlpt-material-n1",
      kind: "JLPT_MATERIAL",
      title: "Paket JLPT N1",
      slug: "jlpt-n1-material",
      subtitle: "Materi dan soal JLPT N1",
      previewDescription:
        "Preview paket JLPT N1 untuk teks kompleks, ungkapan abstrak, kosakata mahir, dan latihan soal.",
      description:
        "Paket JLPT N1 disiapkan untuk user tingkat mahir yang butuh materi, latihan soal, pembahasan, dan evaluasi konsisten.",
      level: "N1",
      category: "JLPT",
      price: 229000,
      sortOrder: 150,
      benefits: ["Materi N1", "Latihan soal", "Pembahasan", "Progress belajar"],
      metadata: { access: "paid", productGroup: "jlpt" },
      status: "PUBLISHED",
      contents: [
        {
          contentType: "JLPT_MATERIAL",
          contentId: "jlpt-n1-material",
          title: "Materi JLPT N1",
        },
        {
          contentType: "QUESTION_SET",
          contentId: jlptN1Set.id,
          title: jlptN1Set.title,
        },
      ],
    },
    {
      id: "seed-package-jlpt-question-n1",
      kind: "JLPT_QUESTION",
      title: "Soal JLPT N1",
      slug: "jlpt-n1-question",
      subtitle: "Latihan soal JLPT N1",
      previewDescription: "Preview soal JLPT N1 untuk latihan tingkat mahir.",
      description:
        "Paket soal JLPT N1 berisi latihan pilihan ganda, pembahasan, dan evaluasi nilai.",
      level: "N1",
      category: "JLPT",
      price: 119000,
      sortOrder: 160,
      benefits: ["Latihan soal N1", "Pembahasan", "Riwayat nilai"],
      metadata: { access: "paid", productGroup: "jlpt" },
      status: "DRAFT",
      contents: [
        {
          contentType: "QUESTION_SET",
          contentId: jlptN1Set.id,
          title: jlptN1Set.title,
        },
      ],
    },
    {
      id: "seed-package-ssw-question-kaigo",
      kind: "SSW_QUESTION",
      title: "Soal SSW Kaigo",
      slug: "ssw-kaigo-question",
      subtitle: "Latihan soal SSW bidang kaigo",
      previewDescription:
        "Preview soal SSW Kaigo untuk istilah kerja, situasi perawatan, dan pemahaman instruksi.",
      description:
        "Paket soal SSW Kaigo berisi latihan pilihan ganda, pembahasan, dan evaluasi untuk persiapan ujian keterampilan.",
      level: "SSW",
      category: "Kaigo",
      price: 99000,
      sortOrder: 170,
      benefits: ["Latihan soal SSW", "Pembahasan", "Riwayat nilai"],
      metadata: { access: "paid", productGroup: "ssw" },
      status: "PUBLISHED",
      contents: [
        {
          contentType: "SSW_MODULE",
          contentId: module.id,
          title: module.title,
        },
      ],
    },
  ] as const;

  for (const packageRow of packageRows) {
    const { contents, id, benefits, metadata, ...data } = packageRow;
    const packageData = {
      ...data,
      benefits: Array.from(benefits),
      metadata: { ...metadata },
    };

    const savedPackage = await prisma.productPackage.upsert({
      where: { slug: packageRow.slug },
      update: packageData,
      create: {
        id,
        ...packageData,
      },
    });

    await prisma.packageContent.deleteMany({
      where: { packageId: savedPackage.id },
    });

    for (const [index, content] of contents.entries()) {
      await prisma.packageContent.create({
        data: {
          packageId: savedPackage.id,
          contentType: content.contentType,
          contentId: content.contentId,
          title: content.title,
          sortOrder: index + 1,
        },
      });
    }
  }

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
