import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from "@nestjs/common";
import {
  ExamType,
  PackageContentType,
  ProductPackageKind,
  PublishStatus,
  QuestionType,
} from "@prisma/client";
import { PrismaService } from "../prisma/prisma.service";

type PrismaModel =
  | "kotoba"
  | "question"
  | "questionSet"
  | "sswCategory"
  | "sswModule"
  | "studyMaterial"
  | "examSchedule"
  | "japanNews";

@Injectable()
export class ContentService {
  constructor(private readonly prisma: PrismaService) {}

  getHealth() {
    return {
      name: "Nihon e Ikitai API",
      status: "ok",
    };
  }

  getKana(type: "HIRAGANA" | "KATAKANA") {
    return this.prisma.kana.findMany({
      where: { type },
      orderBy: { romaji: "asc" },
    });
  }

  async findPublished(model: PrismaModel, where: Record<string, unknown> = {}) {
    return this.model(model).findMany({
      where: {
        ...where,
        status: PublishStatus.PUBLISHED,
      },
      orderBy: { createdAt: "desc" },
    });
  }

  async findPublishedById(
    model: PrismaModel,
    id: string,
    extraWhere: Record<string, unknown> = {},
  ) {
    const item = await this.model(model).findFirst({
      where: {
        id,
        ...extraWhere,
        status: PublishStatus.PUBLISHED,
      },
    });

    if (!item) {
      throw new NotFoundException("Content not found.");
    }

    return item;
  }

  findAll(model: PrismaModel, where: Record<string, unknown> = {}) {
    return this.model(model).findMany({
      where,
      orderBy: { createdAt: "desc" },
    });
  }

  async findById(
    model: PrismaModel,
    id: string,
    include?: Record<string, unknown>,
  ) {
    const item = await this.model(model).findUnique({
      where: { id },
      include,
    });

    if (!item) {
      throw new NotFoundException("Content not found.");
    }

    return item;
  }

  create(model: PrismaModel, data: Record<string, unknown>) {
    return this.model(model).create({
      data: validateContentInput(model, data, false),
    });
  }

  update(model: PrismaModel, id: string, data: Record<string, unknown>) {
    return this.model(model).update({
      where: { id },
      data: validateContentInput(model, data, true),
    });
  }

  remove(model: PrismaModel, id: string) {
    return this.model(model).delete({
      where: { id },
    });
  }

  getJlpt(level?: string) {
    return this.findPublished("question", {
      type: QuestionType.JLPT,
      ...(level ? { level } : {}),
    });
  }

  getJlptQuestionSets(level?: string) {
    return this.prisma.questionSet.findMany({
      where: {
        type: QuestionType.JLPT,
        status: PublishStatus.PUBLISHED,
        ...(level ? { level } : {}),
      },
      include: {
        _count: {
          select: { questions: true },
        },
      },
      orderBy: [{ level: "asc" }, { createdAt: "desc" }],
    });
  }

  getJft(category?: string) {
    return this.findPublished("question", {
      type: QuestionType.JFT,
      ...(category ? { category } : {}),
    });
  }

  getJftQuestionSets(category?: string) {
    return this.prisma.questionSet.findMany({
      where: {
        type: QuestionType.JFT,
        status: PublishStatus.PUBLISHED,
        ...(category ? { category } : {}),
      },
      include: {
        _count: {
          select: { questions: true },
        },
      },
      orderBy: { createdAt: "desc" },
    });
  }

  async getQuestionSet(id: string, type: QuestionType, userId?: string) {
    const item = await this.prisma.questionSet.findFirst({
      where: {
        id,
        type,
        status: PublishStatus.PUBLISHED,
      },
      include: {
        questions: {
          where: { status: PublishStatus.PUBLISHED },
          orderBy: [{ sortOrder: "asc" }, { createdAt: "asc" }],
        },
      },
    });

    if (!item) {
      throw new NotFoundException("Question set not found.");
    }

    const access = await this.resolveContentAccess(
      [{ contentType: PackageContentType.QUESTION_SET, contentId: item.id }],
      userId,
    );
    const lockedQuestionCount = access.hasAccess ? 0 : item.questions.length;

    return {
      ...item,
      questions: access.hasAccess ? item.questions : [],
      access: {
        ...access,
        lockedQuestionCount,
      },
    };
  }

  getSchedules(type?: ExamType) {
    return this.prisma.examSchedule.findMany({
      where: {
        status: PublishStatus.PUBLISHED,
        ...(type ? { type } : {}),
      },
      orderBy: [{ startsAt: "asc" }, { createdAt: "desc" }],
    });
  }

  async getSchedule(id: string) {
    const item = await this.prisma.examSchedule.findFirst({
      where: { id, status: PublishStatus.PUBLISHED },
    });

    if (!item) {
      throw new NotFoundException("Schedule not found.");
    }

    return item;
  }

  getJapanNews(category?: string) {
    return this.prisma.japanNews.findMany({
      where: {
        status: PublishStatus.PUBLISHED,
        ...(category ? { category } : {}),
      },
      orderBy: [{ publishedAt: "desc" }, { createdAt: "desc" }],
    });
  }

  async getJapanNewsDetail(idOrSlug: string) {
    const item = await this.prisma.japanNews.findFirst({
      where: {
        status: PublishStatus.PUBLISHED,
        OR: [{ id: idOrSlug }, { slug: idOrSlug }],
      },
    });

    if (!item) {
      throw new NotFoundException("News not found.");
    }

    return item;
  }

  getSswCategories() {
    return this.prisma.sswCategory.findMany({
      where: { status: PublishStatus.PUBLISHED },
      include: {
        modules: {
          where: { status: PublishStatus.PUBLISHED },
          orderBy: { createdAt: "asc" },
        },
      },
      orderBy: { createdAt: "desc" },
    });
  }

  async getSswModule(id: string, userId?: string) {
    const item = await this.prisma.sswModule.findFirst({
      where: { id, status: PublishStatus.PUBLISHED },
      include: {
        category: true,
        questions: {
          where: { status: PublishStatus.PUBLISHED },
          orderBy: { createdAt: "asc" },
        },
      },
    });

    if (!item) {
      throw new NotFoundException("SSW module not found.");
    }

    const access = await this.resolveContentAccess(
      [
        { contentType: PackageContentType.SSW_MODULE, contentId: item.id },
        {
          contentType: PackageContentType.SSW_CATEGORY,
          contentId: item.categoryId,
        },
      ],
      userId,
    );
    const lockedQuestionCount = access.hasAccess ? 0 : item.questions.length;

    return {
      ...item,
      questions: access.hasAccess ? item.questions : [],
      access: {
        ...access,
        lockedQuestionCount,
      },
    };
  }

  async getStudyMaterial(idOrSlug: string, userId?: string) {
    const item = await this.prisma.studyMaterial.findFirst({
      where: {
        status: PublishStatus.PUBLISHED,
        OR: [{ id: idOrSlug }, { slug: idOrSlug }],
      },
    });

    if (!item) {
      throw new NotFoundException("Study material not found.");
    }

    const contentType =
      item.kind === ProductPackageKind.JFT_MATERIAL
        ? PackageContentType.JFT_MATERIAL
        : PackageContentType.JLPT_MATERIAL;
    const access = await this.resolveContentAccess(
      [{ contentType, contentId: item.id }],
      userId,
    );

    return {
      ...item,
      content: access.hasAccess ? item.content : null,
      sections: access.hasAccess ? item.sections : [],
      vocabulary: access.hasAccess ? item.vocabulary : [],
      examples: access.hasAccess ? item.examples : [],
      access,
    };
  }

  private model(model: PrismaModel) {
    return this.prisma[model] as unknown as {
      findMany(args?: unknown): Promise<unknown>;
      findFirst(args?: unknown): Promise<unknown>;
      findUnique(args?: unknown): Promise<unknown>;
      create(args: unknown): Promise<unknown>;
      update(args: unknown): Promise<unknown>;
      delete(args: unknown): Promise<unknown>;
    };
  }

  private async resolveContentAccess(
    lookups: Array<{ contentType: PackageContentType; contentId: string }>,
    userId?: string,
  ) {
    const packageContents = await this.prisma.packageContent.findMany({
      where: {
        OR: lookups,
        package: { status: PublishStatus.PUBLISHED },
      },
      include: { package: true },
      orderBy: { sortOrder: "asc" },
    });

    const packages = Array.from(
      new Map(
        packageContents.map((content) => [
          content.package.id,
          {
            id: content.package.id,
            slug: content.package.slug,
            title: content.package.title,
            kind: content.package.kind,
            level: content.package.level,
            category: content.package.category,
            price: content.package.price,
            currency: content.package.currency,
          },
        ]),
      ).values(),
    );

    if (packages.length === 0) {
      return {
        isFree: true,
        hasAccess: true,
        packages,
      };
    }

    if (!userId) {
      return {
        isFree: false,
        hasAccess: false,
        packages,
      };
    }

    const entitlement = await this.prisma.userEntitlement.findFirst({
      where: {
        userId,
        packageId: { in: packages.map((item) => item.id) },
        revokedAt: null,
        OR: [{ expiresAt: null }, { expiresAt: { gt: new Date() } }],
      },
    });

    return {
      isFree: false,
      hasAccess: Boolean(entitlement),
      packages,
    };
  }
}

type FieldKind =
  | "string"
  | "slug"
  | "number"
  | "stringArray"
  | "jsonArray"
  | "date"
  | "status"
  | "questionType"
  | "materialKind"
  | "examType";

type FieldRule = {
  kind: FieldKind;
  required?: boolean;
};

type ModelRules = Record<string, FieldRule>;

const contentRules: Record<PrismaModel, ModelRules> = {
  kotoba: {
    kanji: { kind: "string" },
    kana: { kind: "string", required: true },
    furigana: { kind: "string" },
    romaji: { kind: "string" },
    meaning: { kind: "string", required: true },
    exampleSentence: { kind: "string" },
    status: { kind: "status" },
  },
  question: {
    type: { kind: "questionType", required: true },
    questionSetId: { kind: "string" },
    sswModuleId: { kind: "string" },
    level: { kind: "string" },
    category: { kind: "string" },
    prompt: { kind: "string", required: true },
    options: { kind: "stringArray", required: true },
    answerIndex: { kind: "number", required: true },
    explanation: { kind: "string" },
    sortOrder: { kind: "number" },
    status: { kind: "status" },
  },
  questionSet: {
    type: { kind: "questionType", required: true },
    title: { kind: "string", required: true },
    slug: { kind: "slug", required: true },
    description: { kind: "string" },
    level: { kind: "string" },
    category: { kind: "string" },
    durationMinutes: { kind: "number" },
    status: { kind: "status" },
  },
  sswCategory: {
    title: { kind: "string", required: true },
    slug: { kind: "slug", required: true },
    description: { kind: "string" },
    status: { kind: "status" },
  },
  sswModule: {
    categoryId: { kind: "string", required: true },
    title: { kind: "string", required: true },
    slug: { kind: "slug", required: true },
    summary: { kind: "string" },
    content: { kind: "string", required: true },
    vocabulary: { kind: "jsonArray" },
    examples: { kind: "jsonArray" },
    status: { kind: "status" },
  },
  studyMaterial: {
    kind: { kind: "materialKind", required: true },
    title: { kind: "string", required: true },
    slug: { kind: "slug", required: true },
    level: { kind: "string" },
    category: { kind: "string" },
    summary: { kind: "string" },
    content: { kind: "string", required: true },
    sections: { kind: "jsonArray" },
    vocabulary: { kind: "jsonArray" },
    examples: { kind: "jsonArray" },
    status: { kind: "status" },
  },
  examSchedule: {
    type: { kind: "examType", required: true },
    title: { kind: "string", required: true },
    location: { kind: "string" },
    startsAt: { kind: "date", required: true },
    endsAt: { kind: "date" },
    registerUrl: { kind: "string" },
    description: { kind: "string" },
    status: { kind: "status" },
  },
  japanNews: {
    title: { kind: "string", required: true },
    slug: { kind: "slug", required: true },
    thumbnail: { kind: "string" },
    body: { kind: "string", required: true },
    category: { kind: "string" },
    publishedAt: { kind: "date" },
    status: { kind: "status" },
  },
};

function validateContentInput(
  model: PrismaModel,
  data: Record<string, unknown>,
  partial: boolean,
) {
  if (!isRecord(data)) {
    throw new BadRequestException("Payload must be an object.");
  }

  const rules = contentRules[model];
  const output: Record<string, unknown> = {};

  for (const [field, rule] of Object.entries(rules)) {
    if (!(field in data)) {
      if (!partial && rule.required) {
        throw new BadRequestException(`${field} is required.`);
      }
      continue;
    }

    output[field] = normalizeField(field, data[field], rule, partial);
  }

  if (Object.keys(output).length === 0) {
    throw new BadRequestException("Payload does not contain valid fields.");
  }

  validateQuestionAnswer(output);
  validateScheduleRange(output);

  return output;
}

function normalizeField(
  field: string,
  value: unknown,
  rule: FieldRule,
  partial: boolean,
) {
  if (value === null || value === undefined || value === "") {
    if (rule.required) {
      throw new BadRequestException(`${field} cannot be empty.`);
    }
    return null;
  }

  switch (rule.kind) {
    case "string":
      return String(value).trim();
    case "slug":
      return normalizeSlug(field, value);
    case "number":
      return normalizeNumber(field, value);
    case "stringArray":
      return normalizeStringArray(
        field,
        value,
        Boolean(rule.required && !partial),
      );
    case "jsonArray":
      return normalizeJsonArray(field, value);
    case "date":
      return normalizeDate(field, value);
    case "status":
      return normalizeEnum(field, value, Object.values(PublishStatus));
    case "questionType":
      return normalizeEnum(field, value, Object.values(QuestionType));
    case "materialKind":
      return normalizeEnum(field, value, [
        ProductPackageKind.JFT_MATERIAL,
        ProductPackageKind.JLPT_MATERIAL,
      ]);
    case "examType":
      return normalizeEnum(field, value, Object.values(ExamType));
  }
}

function normalizeSlug(field: string, value: unknown) {
  const slug = String(value).trim().toLowerCase();
  if (!/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(slug)) {
    throw new BadRequestException(
      `${field} must use lowercase letters, numbers, and hyphens.`,
    );
  }
  return slug;
}

function normalizeNumber(field: string, value: unknown) {
  const number = typeof value === "number" ? value : Number(value);
  if (!Number.isFinite(number)) {
    throw new BadRequestException(`${field} must be a number.`);
  }
  return number;
}

function normalizeStringArray(
  field: string,
  value: unknown,
  required: boolean,
) {
  if (!Array.isArray(value)) {
    throw new BadRequestException(`${field} must be an array.`);
  }

  const rows = value
    .map((item) => String(item).trim())
    .filter((item) => item.length > 0);

  if (required && rows.length === 0) {
    throw new BadRequestException(`${field} cannot be empty.`);
  }

  return rows;
}

function normalizeJsonArray(field: string, value: unknown) {
  if (!Array.isArray(value)) {
    throw new BadRequestException(`${field} must be an array.`);
  }
  return value;
}

function normalizeDate(field: string, value: unknown) {
  const date = value instanceof Date ? value : new Date(String(value));
  if (Number.isNaN(date.getTime())) {
    throw new BadRequestException(`${field} must be a valid date.`);
  }
  return date;
}

function normalizeEnum(field: string, value: unknown, options: string[]) {
  const text = String(value).trim().toUpperCase();
  if (!options.includes(text)) {
    throw new BadRequestException(
      `${field} must be one of: ${options.join(", ")}.`,
    );
  }
  return text;
}

function validateQuestionAnswer(data: Record<string, unknown>) {
  if (!Array.isArray(data.options) || typeof data.answerIndex !== "number") {
    return;
  }

  if (data.answerIndex < 0 || data.answerIndex >= data.options.length) {
    throw new BadRequestException("answerIndex must point to an option.");
  }
}

function validateScheduleRange(data: Record<string, unknown>) {
  if (!(data.startsAt instanceof Date) || !(data.endsAt instanceof Date)) {
    return;
  }

  if (data.endsAt.getTime() < data.startsAt.getTime()) {
    throw new BadRequestException("endsAt must be after startsAt.");
  }
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
