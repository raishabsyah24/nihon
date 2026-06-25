import {
  BookOpen,
  BriefcaseBusiness,
  CalendarDays,
  FileQuestion,
  Layers,
  Newspaper,
  type LucideIcon
} from "lucide-react";

export type FieldKind =
  | "text"
  | "textarea"
  | "select"
  | "number"
  | "datetime"
  | "lines"
  | "vocabulary"
  | "examples";

export type ResourceField = {
  name: string;
  label: string;
  kind: FieldKind;
  required?: boolean;
  options?: string[];
  help?: string;
};

export type ResourceConfig = {
  key: string;
  title: string;
  endpoint: string;
  icon: LucideIcon;
  fields: ResourceField[];
  columns: string[];
};

const statusField: ResourceField = {
  name: "status",
  label: "Status",
  kind: "select",
  options: ["DRAFT", "PUBLISHED"],
  required: true
};

const slugHelp = "Huruf kecil, angka, dan tanda hubung. Contoh: jlpt-n5-kotoba.";

const questionFields: ResourceField[] = [
  { name: "questionSetId", label: "Question Set ID", kind: "text" },
  { name: "category", label: "Kategori", kind: "text" },
  { name: "prompt", label: "Pertanyaan", kind: "textarea", required: true },
  { name: "options", label: "Pilihan jawaban", kind: "lines", required: true },
  {
    name: "answerIndex",
    label: "Index jawaban benar",
    kind: "number",
    required: true,
    help: "Mulai dari 0 sesuai urutan pilihan jawaban."
  },
  { name: "explanation", label: "Pembahasan", kind: "textarea" },
  { name: "sortOrder", label: "Urutan", kind: "number" },
  statusField
];

export const resources = {
  kotoba: {
    key: "kotoba",
    title: "Kotoba",
    endpoint: "/admin/kotoba",
    icon: BookOpen,
    columns: ["kanji", "kana", "meaning", "status"],
    fields: [
      { name: "kanji", label: "Kanji", kind: "text" },
      { name: "kana", label: "Kana", kind: "text", required: true },
      { name: "furigana", label: "Furigana", kind: "text" },
      { name: "romaji", label: "Romaji", kind: "text" },
      { name: "meaning", label: "Arti", kind: "text", required: true },
      { name: "exampleSentence", label: "Contoh kalimat", kind: "textarea" },
      statusField
    ]
  },
  jlpt: {
    key: "jlpt",
    title: "Soal JLPT",
    endpoint: "/admin/jlpt/questions",
    icon: FileQuestion,
    columns: ["level", "category", "prompt", "status"],
    fields: [
      {
        name: "level",
        label: "Level",
        kind: "select",
        options: ["N5", "N4", "N3", "N2", "N1"],
        required: true
      },
      ...questionFields
    ]
  },
  jlptSets: {
    key: "jlptSets",
    title: "Paket JLPT",
    endpoint: "/admin/jlpt/question-sets",
    icon: FileQuestion,
    columns: ["title", "level", "category", "durationMinutes", "status"],
    fields: [
      { name: "title", label: "Judul paket", kind: "text", required: true },
      { name: "slug", label: "Slug", kind: "text", required: true, help: slugHelp },
      { name: "description", label: "Deskripsi", kind: "textarea" },
      {
        name: "level",
        label: "Level",
        kind: "select",
        options: ["N5", "N4", "N3", "N2", "N1"],
        required: true
      },
      {
        name: "category",
        label: "Kategori",
        kind: "select",
        options: ["kotoba", "bunpou", "dokkai", "choukai"],
        required: true
      },
      { name: "durationMinutes", label: "Durasi menit", kind: "number" },
      statusField
    ]
  },
  jft: {
    key: "jft",
    title: "Soal JFT",
    endpoint: "/admin/jft/questions",
    icon: FileQuestion,
    columns: ["category", "prompt", "status"],
    fields: questionFields
  },
  jftSets: {
    key: "jftSets",
    title: "Paket JFT",
    endpoint: "/admin/jft/question-sets",
    icon: FileQuestion,
    columns: ["title", "category", "durationMinutes", "status"],
    fields: [
      { name: "title", label: "Judul paket", kind: "text", required: true },
      { name: "slug", label: "Slug", kind: "text", required: true, help: slugHelp },
      { name: "description", label: "Deskripsi", kind: "textarea" },
      {
        name: "category",
        label: "Kategori",
        kind: "select",
        options: ["daily", "work", "life", "reading", "listening"],
        required: true
      },
      { name: "durationMinutes", label: "Durasi menit", kind: "number" },
      statusField
    ]
  },
  sswCategories: {
    key: "sswCategories",
    title: "Kategori SSW",
    endpoint: "/admin/ssw/categories",
    icon: Layers,
    columns: ["title", "slug", "status"],
    fields: [
      { name: "title", label: "Judul", kind: "text", required: true },
      { name: "slug", label: "Slug", kind: "text", required: true, help: slugHelp },
      { name: "description", label: "Deskripsi", kind: "textarea" },
      statusField
    ]
  },
  sswModules: {
    key: "sswModules",
    title: "Modul SSW",
    endpoint: "/admin/ssw/modules",
    icon: BriefcaseBusiness,
    columns: ["title", "slug", "categoryId", "vocabulary", "status"],
    fields: [
      { name: "categoryId", label: "Category ID", kind: "text", required: true },
      { name: "title", label: "Judul", kind: "text", required: true },
      { name: "slug", label: "Slug", kind: "text", required: true, help: slugHelp },
      { name: "summary", label: "Ringkasan", kind: "textarea" },
      { name: "content", label: "Materi", kind: "textarea", required: true },
      {
        name: "vocabulary",
        label: "Kosakata Jepang",
        kind: "vocabulary",
        help: "Satu baris per kosakata: kanji | kana | furigana | romaji | arti"
      },
      {
        name: "examples",
        label: "Contoh kalimat",
        kind: "examples",
        help: "Satu baris per contoh: kalimat Jepang | furigana | romaji | arti"
      },
      statusField
    ]
  },
  sswQuestions: {
    key: "sswQuestions",
    title: "Soal SSW",
    endpoint: "/admin/ssw/questions",
    icon: FileQuestion,
    columns: ["category", "sswModuleId", "prompt", "status"],
    fields: [
      { name: "sswModuleId", label: "SSW Module ID", kind: "text", required: true },
      ...questionFields
    ]
  },
  schedules: {
    key: "schedules",
    title: "Jadwal Ujian",
    endpoint: "/admin/exam-schedules",
    icon: CalendarDays,
    columns: ["type", "title", "startsAt", "status"],
    fields: [
      {
        name: "type",
        label: "Tipe ujian",
        kind: "select",
        options: ["JFT", "JLPT", "SSW"],
        required: true
      },
      { name: "title", label: "Judul", kind: "text", required: true },
      { name: "location", label: "Lokasi", kind: "text" },
      { name: "startsAt", label: "Tanggal mulai", kind: "datetime", required: true },
      { name: "endsAt", label: "Tanggal akhir", kind: "datetime" },
      { name: "registerUrl", label: "Link pendaftaran", kind: "text" },
      { name: "description", label: "Deskripsi", kind: "textarea" },
      statusField
    ]
  },
  news: {
    key: "news",
    title: "Berita Jepang",
    endpoint: "/admin/japan-news",
    icon: Newspaper,
    columns: ["title", "category", "publishedAt", "status"],
    fields: [
      { name: "title", label: "Judul", kind: "text", required: true },
      { name: "slug", label: "Slug", kind: "text", required: true, help: slugHelp },
      { name: "thumbnail", label: "Thumbnail URL", kind: "text" },
      { name: "body", label: "Isi berita", kind: "textarea", required: true },
      { name: "category", label: "Kategori", kind: "text" },
      { name: "publishedAt", label: "Tanggal publish", kind: "datetime" },
      statusField
    ]
  }
} satisfies Record<string, ResourceConfig>;

export const dashboardResources = [
  resources.kotoba,
  resources.jlptSets,
  resources.jlpt,
  resources.jftSets,
  resources.jft,
  resources.sswCategories,
  resources.sswModules,
  resources.sswQuestions,
  resources.schedules,
  resources.news
];
