import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from "@nestjs/common";
import {
  DiscountKind,
  EntitlementSource,
  LearningContentType,
  LearningProgressStatus,
  LoyaltyTransactionType,
  OrderStatus,
  PackageContentType,
  Prisma,
  ProductPackageKind,
  PublishStatus,
} from "@prisma/client";
import { RequestUser } from "../auth/request-user.type";
import { PrismaService } from "../prisma/prisma.service";

type PackageWriteData = {
  kind?: ProductPackageKind;
  title?: string;
  slug?: string;
  subtitle?: string | null;
  previewDescription?: string | null;
  description?: string | null;
  level?: string | null;
  category?: string | null;
  price?: number;
  currency?: string;
  benefits?: Prisma.InputJsonValue;
  metadata?: Prisma.InputJsonValue;
  status?: PublishStatus;
  sortOrder?: number;
};

type PackageContentInput = {
  contentType: PackageContentType;
  contentId: string;
  title?: string | null;
  sortOrder: number;
};

type ProfileWriteData = {
  fullName?: string | null;
  phoneNumber?: string | null;
  addressLine?: string | null;
  city?: string | null;
  province?: string | null;
  postalCode?: string | null;
  country?: string;
  birthDate?: Date | null;
  metadata?: Prisma.InputJsonValue;
};

type PromoWriteData = {
  code?: string | null;
  title?: string;
  description?: string | null;
  discountKind?: DiscountKind;
  discountValue?: number;
  maxDiscount?: number | null;
  minimumSubtotal?: number;
  targetKind?: ProductPackageKind | null;
  startsAt?: Date | null;
  endsAt?: Date | null;
  usageLimit?: number | null;
  stackable?: boolean;
  status?: PublishStatus;
};

type VoucherWriteData = PromoWriteData & {
  code?: string;
  perUserLimit?: number;
};

type OrderWithItems = Prisma.OrderGetPayload<{ include: { items: true } }>;

@Injectable()
export class CommerceService {
  constructor(private readonly prisma: PrismaService) {}

  async getHomeCatalog() {
    const [kanaCount, kotobaCount, packages] = await Promise.all([
      this.prisma.kana.count(),
      this.prisma.kotoba.count({
        where: { status: PublishStatus.PUBLISHED },
      }),
      this.prisma.productPackage.findMany({
        where: { status: PublishStatus.PUBLISHED },
        orderBy: [{ sortOrder: "asc" }, { createdAt: "desc" }],
      }),
    ]);

    return {
      freeMenus: [
        {
          key: "kana",
          title: "Kana",
          description: "Hiragana dan Katakana gratis untuk semua user.",
          itemCount: kanaCount,
          isFree: true,
        },
        {
          key: "kotoba",
          title: "Kotoba",
          description: "Kosakata Jepang dengan kanji, kana, romaji, dan arti.",
          itemCount: kotobaCount,
          isFree: true,
        },
      ],
      paidMenus: [
        this.buildMenuPreview("jft", "JFT", packages, [
          ProductPackageKind.JFT_MATERIAL,
          ProductPackageKind.JFT_QUESTION,
        ]),
        this.buildMenuPreview("jlpt", "JLPT", packages, [
          ProductPackageKind.JLPT_MATERIAL,
          ProductPackageKind.JLPT_QUESTION,
        ]),
        this.buildMenuPreview("ssw", "SSW", packages, [
          ProductPackageKind.SSW_QUESTION,
        ]),
      ],
    };
  }

  listPublishedPackages(query: Record<string, unknown>) {
    const where = this.normalizePackageFilters(query, true);

    return this.prisma.productPackage.findMany({
      where,
      include: {
        contents: { orderBy: { sortOrder: "asc" } },
      },
      orderBy: [{ sortOrder: "asc" }, { createdAt: "desc" }],
    });
  }

  async getPublishedPackage(idOrSlug: string, userId?: string) {
    const item = await this.prisma.productPackage.findFirst({
      where: {
        status: PublishStatus.PUBLISHED,
        OR: [{ id: idOrSlug }, { slug: idOrSlug }],
      },
      include: {
        contents: { orderBy: { sortOrder: "asc" } },
      },
    });

    if (!item) {
      throw new NotFoundException("Package not found.");
    }

    const entitlement = userId
      ? await this.findActiveEntitlement(userId, item.id)
      : null;

    return {
      ...item,
      access: {
        isFree: false,
        hasAccess: Boolean(entitlement),
      },
    };
  }

  listAdminPackages(query: Record<string, unknown>) {
    const where = this.normalizePackageFilters(query, false);

    return this.prisma.productPackage.findMany({
      where,
      include: {
        contents: { orderBy: { sortOrder: "asc" } },
      },
      orderBy: [{ sortOrder: "asc" }, { createdAt: "desc" }],
    });
  }

  createPackage(body: Record<string, unknown>) {
    const data = this.normalizePackageData(body, false);

    return this.prisma.$transaction(async (tx) => {
      const item = await tx.productPackage.create({
        data: data as Prisma.ProductPackageUncheckedCreateInput,
      });

      await this.replacePackageContents(tx, item.id, body.contents);

      return tx.productPackage.findUnique({
        where: { id: item.id },
        include: { contents: { orderBy: { sortOrder: "asc" } } },
      });
    });
  }

  async updatePackage(id: string, body: Record<string, unknown>) {
    await this.ensurePackageExists(id);
    const data = this.normalizePackageData(body, true);

    return this.prisma.$transaction(async (tx) => {
      await tx.productPackage.update({
        where: { id },
        data: data as Prisma.ProductPackageUncheckedUpdateInput,
      });

      if ("contents" in body) {
        await this.replacePackageContents(tx, id, body.contents);
      }

      return tx.productPackage.findUnique({
        where: { id },
        include: { contents: { orderBy: { sortOrder: "asc" } } },
      });
    });
  }

  async archivePackage(id: string) {
    await this.ensurePackageExists(id);

    return this.prisma.productPackage.update({
      where: { id },
      data: { status: PublishStatus.DRAFT },
    });
  }

  async getMyProfile(user: RequestUser) {
    const item = await this.prisma.user.findUnique({
      where: { id: user.id },
      include: {
        profile: true,
        loyaltyAccount: true,
      },
    });

    if (!item) {
      throw new NotFoundException("User not found.");
    }

    return item;
  }

  updateMyProfile(user: RequestUser, body: Record<string, unknown>) {
    if (!isRecord(body)) {
      throw new BadRequestException("Payload must be an object.");
    }

    const userData: Prisma.UserUpdateInput = {};
    const profileData = this.normalizeProfileData(body);

    if ("displayName" in body) {
      userData.displayName = normalizeNullableString(body.displayName);
    }

    if ("phoneNumber" in body) {
      userData.phoneNumber = normalizeNullableString(body.phoneNumber);
      profileData.phoneNumber = normalizeNullableString(body.phoneNumber);
    }

    return this.prisma.$transaction(async (tx) => {
      if (Object.keys(userData).length > 0) {
        await tx.user.update({
          where: { id: user.id },
          data: userData,
        });
      }

      if (Object.keys(profileData).length > 0) {
        await tx.userProfile.upsert({
          where: { userId: user.id },
          update: profileData,
          create: {
            userId: user.id,
            ...profileData,
          },
        });
      }

      return tx.user.findUnique({
        where: { id: user.id },
        include: {
          profile: true,
          loyaltyAccount: true,
        },
      });
    });
  }

  listMyEntitlements(user: RequestUser) {
    return this.prisma.userEntitlement.findMany({
      where: activeEntitlementWhere(user.id),
      include: {
        package: {
          include: { contents: { orderBy: { sortOrder: "asc" } } },
        },
      },
      orderBy: { createdAt: "desc" },
    });
  }

  listMyProgress(user: RequestUser) {
    return this.prisma.learningProgress.findMany({
      where: { userId: user.id },
      orderBy: { lastAccessedAt: "desc" },
    });
  }

  async getMyExamScheduleSelection(user: RequestUser) {
    const profile = await this.prisma.userProfile.findUnique({
      where: { userId: user.id },
      select: { metadata: true },
    });
    const scheduleId = getSelectedExamScheduleId(profile?.metadata);
    const schedule = scheduleId
      ? await this.prisma.examSchedule.findFirst({
          where: {
            id: scheduleId,
            status: PublishStatus.PUBLISHED,
          },
        })
      : null;

    return { schedule };
  }

  async selectMyExamSchedule(user: RequestUser, body: Record<string, unknown>) {
    if (!isRecord(body)) {
      throw new BadRequestException("Payload must be an object.");
    }

    const scheduleId = normalizeRequiredString(
      "examScheduleId",
      body.examScheduleId,
    );
    const schedule = await this.prisma.examSchedule.findFirst({
      where: {
        id: scheduleId,
        status: PublishStatus.PUBLISHED,
      },
    });

    if (!schedule) {
      throw new NotFoundException("Exam schedule not found.");
    }

    const profile = await this.prisma.userProfile.findUnique({
      where: { userId: user.id },
      select: { metadata: true },
    });
    const metadata = toMutableMetadata(profile?.metadata);
    metadata.selectedExamScheduleId = schedule.id;

    await this.prisma.userProfile.upsert({
      where: { userId: user.id },
      update: { metadata: metadata as Prisma.InputJsonValue },
      create: {
        userId: user.id,
        metadata: metadata as Prisma.InputJsonValue,
      },
    });

    return { schedule };
  }

  async clearMyExamScheduleSelection(user: RequestUser) {
    const profile = await this.prisma.userProfile.findUnique({
      where: { userId: user.id },
      select: { metadata: true },
    });
    const metadata = toMutableMetadata(profile?.metadata);
    metadata.selectedExamScheduleId = null;

    await this.prisma.userProfile.upsert({
      where: { userId: user.id },
      update: { metadata: metadata as Prisma.InputJsonValue },
      create: {
        userId: user.id,
        metadata: metadata as Prisma.InputJsonValue,
      },
    });

    return { schedule: null };
  }

  async upsertMyProgress(user: RequestUser, body: Record<string, unknown>) {
    if (!isRecord(body)) {
      throw new BadRequestException("Payload must be an object.");
    }

    const contentType = normalizeEnum(
      "contentType",
      body.contentType,
      Object.values(LearningContentType),
    );
    const contentId = normalizeRequiredString("contentId", body.contentId);
    const packageId = normalizeNullableString(body.packageId);

    if (packageId) {
      await this.assertActiveEntitlement(user.id, packageId);
    }

    const progressPercent =
      "progressPercent" in body
        ? normalizeBoundedInt("progressPercent", body.progressPercent, 0, 100)
        : undefined;
    const status =
      "status" in body
        ? normalizeEnum(
            "status",
            body.status,
            Object.values(LearningProgressStatus),
          )
        : undefined;
    const score =
      "score" in body ? normalizeNullableInt("score", body.score) : undefined;
    const bestScore =
      "bestScore" in body
        ? normalizeNullableInt("bestScore", body.bestScore)
        : undefined;
    const attempts =
      "attempts" in body
        ? normalizeBoundedInt("attempts", body.attempts, 0, 9999)
        : undefined;
    const now = new Date();
    const progressData = {
      packageId,
      progressPercent,
      status,
      score,
      bestScore,
      attempts,
      lastAccessedAt: now,
      startedAt:
        status === LearningProgressStatus.IN_PROGRESS ? now : undefined,
      completedAt:
        status === LearningProgressStatus.COMPLETED ? now : undefined,
      metadata: normalizeOptionalJson(body.metadata),
    };

    return this.prisma.learningProgress.upsert({
      where: {
        userId_contentType_contentId: {
          userId: user.id,
          contentType,
          contentId,
        },
      },
      update: removeUndefined(progressData),
      create: {
        userId: user.id,
        contentType,
        contentId,
        ...removeUndefined(progressData),
      },
    });
  }

  async createOrder(user: RequestUser, body: Record<string, unknown>) {
    if (!isRecord(body)) {
      throw new BadRequestException("Payload must be an object.");
    }

    const packageRefs = normalizePackageRefs(body);
    const packages = await this.findPublishedPackagesByRefs(packageRefs);
    const subtotal = packages.reduce((total, item) => total + item.price, 0);
    const promo = await this.findBestPromo(packages, subtotal);
    const promoDiscount = promo ? computeDiscount(promo, subtotal) : 0;
    const subtotalAfterPromo = Math.max(0, subtotal - promoDiscount);
    const voucher = await this.findUsableVoucher(
      user.id,
      body.voucherCode,
      packages,
      subtotalAfterPromo,
    );
    const voucherDiscount = voucher
      ? computeDiscount(voucher, subtotalAfterPromo)
      : 0;
    const totalBeforePoints = Math.max(0, subtotalAfterPromo - voucherDiscount);
    const requestedPoints =
      "pointsToUse" in body
        ? normalizeBoundedInt("pointsToUse", body.pointsToUse, 0, 999999999)
        : 0;
    const loyaltyAccount = requestedPoints
      ? await this.prisma.loyaltyAccount.findUnique({
          where: { userId: user.id },
        })
      : null;
    const pointDiscount = Math.min(
      requestedPoints,
      loyaltyAccount?.pointsBalance ?? 0,
      totalBeforePoints,
    );
    const total = Math.max(0, totalBeforePoints - pointDiscount);
    const orderNumber = createOrderNumber();
    const metadata = buildDevelopmentPaymentMetadata(orderNumber, total, "IDR");

    return this.prisma.order.create({
      data: {
        orderNumber,
        user: { connect: { id: user.id } },
        status: OrderStatus.PENDING,
        subtotal,
        promoDiscount,
        voucherDiscount,
        pointDiscount,
        total,
        promo: promo ? { connect: { id: promo.id } } : undefined,
        voucher: voucher ? { connect: { id: voucher.id } } : undefined,
        pointsUsed: pointDiscount,
        metadata,
        items: {
          create: packages.map((item) => ({
            package: { connect: { id: item.id } },
            titleSnapshot: item.title,
            price: item.price,
            quantity: 1,
            subtotal: item.price,
          })),
        },
        voucherRedemption: voucher
          ? {
              create: {
                voucher: { connect: { id: voucher.id } },
                user: { connect: { id: user.id } },
                discountAmount: voucherDiscount,
              },
            }
          : undefined,
      },
      include: orderInclude,
    });
  }

  listMyOrders(user: RequestUser) {
    return this.prisma.order.findMany({
      where: { userId: user.id },
      include: orderInclude,
      orderBy: { createdAt: "desc" },
    });
  }

  async getMyOrder(user: RequestUser, id: string) {
    const item = await this.prisma.order.findFirst({
      where: { id, userId: user.id },
      include: orderInclude,
    });

    if (!item) {
      throw new NotFoundException("Order not found.");
    }

    return item;
  }

  async settleMyDevPayment(user: RequestUser, id: string) {
    return this.prisma.$transaction(async (tx) => {
      const order = await tx.order.findFirst({
        where: { id, userId: user.id },
        include: { items: true },
      });

      if (!order) {
        throw new NotFoundException("Order not found.");
      }

      if (order.status === OrderStatus.CANCELLED) {
        throw new BadRequestException("Cancelled order cannot be paid.");
      }

      if (order.status === OrderStatus.PAID) {
        return tx.order.findUnique({
          where: { id },
          include: orderInclude,
        });
      }

      return this.markOrderPaid(tx, order, "XENDIT_DEV");
    });
  }

  listAdminOrders(query: Record<string, unknown>) {
    const status =
      "status" in query && query.status
        ? normalizeEnum("status", query.status, Object.values(OrderStatus))
        : undefined;

    return this.prisma.order.findMany({
      where: { status },
      include: orderInclude,
      orderBy: { createdAt: "desc" },
    });
  }

  async updateOrderStatus(id: string, body: Record<string, unknown>) {
    if (!isRecord(body)) {
      throw new BadRequestException("Payload must be an object.");
    }

    const nextStatus = normalizeEnum(
      "status",
      body.status,
      Object.values(OrderStatus),
    );

    return this.prisma.$transaction(async (tx) => {
      const order = await tx.order.findUnique({
        where: { id },
        include: { items: true },
      });

      if (!order) {
        throw new NotFoundException("Order not found.");
      }

      if (order.status === nextStatus) {
        return tx.order.findUnique({
          where: { id },
          include: orderInclude,
        });
      }

      if (nextStatus === OrderStatus.CANCELLED) {
        if (order.status === OrderStatus.PAID) {
          throw new BadRequestException("Paid order cannot be cancelled.");
        }

        const now = new Date();
        return tx.order.update({
          where: { id },
          data: {
            status: OrderStatus.CANCELLED,
            cancelledAt: now,
            metadata: mergePaymentMetadata(order.metadata, {
              paymentStatus: "CANCELLED",
              cancelledAt: now.toISOString(),
            }),
          },
          include: orderInclude,
        });
      }

      if (nextStatus !== OrderStatus.PAID) {
        throw new BadRequestException("Only PAID or CANCELLED is allowed.");
      }

      return this.markOrderPaid(tx, order, "ADMIN_MANUAL");
    });
  }

  listAdminPromos(query: Record<string, unknown>) {
    const where = this.normalizePromotionFilters(query);

    return this.prisma.promo.findMany({
      where,
      include: {
        promoPackages: {
          include: {
            package: true,
          },
        },
      },
      orderBy: [{ status: "asc" }, { createdAt: "desc" }],
    });
  }

  createPromo(body: Record<string, unknown>) {
    const data = this.normalizePromoData(body, false);

    return this.prisma.promo.create({
      data: data as Prisma.PromoUncheckedCreateInput,
      include: {
        promoPackages: {
          include: {
            package: true,
          },
        },
      },
    });
  }

  updatePromo(id: string, body: Record<string, unknown>) {
    const data = this.normalizePromoData(body, true);

    return this.prisma.promo.update({
      where: { id },
      data: data as Prisma.PromoUncheckedUpdateInput,
      include: {
        promoPackages: {
          include: {
            package: true,
          },
        },
      },
    });
  }

  archivePromo(id: string) {
    return this.prisma.promo.update({
      where: { id },
      data: { status: PublishStatus.DRAFT },
    });
  }

  listAdminVouchers(query: Record<string, unknown>) {
    const where = this.normalizePromotionFilters(query);

    return this.prisma.voucher.findMany({
      where,
      include: {
        voucherPackages: {
          include: {
            package: true,
          },
        },
      },
      orderBy: [{ status: "asc" }, { createdAt: "desc" }],
    });
  }

  createVoucher(body: Record<string, unknown>) {
    const data = this.normalizeVoucherData(body, false);

    return this.prisma.voucher.create({
      data: data as Prisma.VoucherUncheckedCreateInput,
      include: {
        voucherPackages: {
          include: {
            package: true,
          },
        },
      },
    });
  }

  updateVoucher(id: string, body: Record<string, unknown>) {
    const data = this.normalizeVoucherData(body, true);

    return this.prisma.voucher.update({
      where: { id },
      data: data as Prisma.VoucherUncheckedUpdateInput,
      include: {
        voucherPackages: {
          include: {
            package: true,
          },
        },
      },
    });
  }

  archiveVoucher(id: string) {
    return this.prisma.voucher.update({
      where: { id },
      data: { status: PublishStatus.DRAFT },
    });
  }

  private normalizePromotionFilters(query: Record<string, unknown>) {
    const where: Prisma.PromoWhereInput & Prisma.VoucherWhereInput = {};

    if (query.status) {
      where.status = normalizeEnum(
        "status",
        query.status,
        Object.values(PublishStatus),
      );
    }

    if (query.targetKind) {
      where.targetKind = normalizeEnum(
        "targetKind",
        query.targetKind,
        Object.values(ProductPackageKind),
      );
    }

    return where;
  }

  private normalizePromoData(body: Record<string, unknown>, partial: boolean) {
    const data = this.normalizeDiscountData<PromoWriteData>(
      body,
      partial,
      false,
    );

    if ("code" in body) {
      data.code = normalizeNullableCode(body.code);
    }

    if ("stackable" in body) {
      data.stackable = Boolean(body.stackable);
    }

    return data;
  }

  private normalizeVoucherData(
    body: Record<string, unknown>,
    partial: boolean,
  ) {
    const data = this.normalizeDiscountData<VoucherWriteData>(
      body,
      partial,
      true,
    );

    if ("perUserLimit" in body) {
      data.perUserLimit = normalizeBoundedInt(
        "perUserLimit",
        body.perUserLimit,
        1,
        999999,
      );
    }

    return data;
  }

  private normalizeDiscountData<T extends PromoWriteData>(
    body: Record<string, unknown>,
    partial: boolean,
    requireCode: boolean,
  ) {
    if (!isRecord(body)) {
      throw new BadRequestException("Payload must be an object.");
    }

    const data: T = {} as T;
    const requiredFields = ["title", "discountKind", "discountValue"];

    if (requireCode) {
      requiredFields.push("code");
    }

    if (!partial) {
      for (const field of requiredFields) {
        if (!(field in body)) {
          throw new BadRequestException(`${field} is required.`);
        }
      }
    }

    if ("code" in body) {
      const code = requireCode
        ? normalizeCode(body.code)
        : normalizeNullableCode(body.code);
      (data as PromoWriteData | VoucherWriteData).code = code;
    }

    if ("title" in body) {
      data.title = normalizeRequiredString("title", body.title);
    }

    if ("description" in body) {
      data.description = normalizeNullableString(body.description);
    }

    if ("discountKind" in body) {
      data.discountKind = normalizeEnum(
        "discountKind",
        body.discountKind,
        Object.values(DiscountKind),
      );
    }

    if ("discountValue" in body) {
      data.discountValue = normalizeBoundedInt(
        "discountValue",
        body.discountValue,
        0,
        999999999,
      );
    }

    if ("maxDiscount" in body) {
      data.maxDiscount = normalizeNullableInt("maxDiscount", body.maxDiscount);
    }

    if ("minimumSubtotal" in body) {
      data.minimumSubtotal = normalizeBoundedInt(
        "minimumSubtotal",
        body.minimumSubtotal,
        0,
        999999999,
      );
    }

    if ("targetKind" in body) {
      data.targetKind = body.targetKind
        ? normalizeEnum(
            "targetKind",
            body.targetKind,
            Object.values(ProductPackageKind),
          )
        : null;
    }

    if ("startsAt" in body) {
      data.startsAt = body.startsAt
        ? normalizeDate("startsAt", body.startsAt)
        : null;
    }

    if ("endsAt" in body) {
      data.endsAt = body.endsAt ? normalizeDate("endsAt", body.endsAt) : null;
    }

    if ("usageLimit" in body) {
      data.usageLimit = normalizeNullableInt("usageLimit", body.usageLimit);
    }

    if ("status" in body) {
      data.status = normalizeEnum(
        "status",
        body.status,
        Object.values(PublishStatus),
      );
    }

    if (Object.keys(data).length === 0) {
      throw new BadRequestException("Payload does not contain valid fields.");
    }

    return data;
  }

  private normalizePackageFilters(
    query: Record<string, unknown>,
    publishedOnly: boolean,
  ) {
    const where: Prisma.ProductPackageWhereInput = publishedOnly
      ? { status: PublishStatus.PUBLISHED }
      : {};

    if (query.kind) {
      where.kind = normalizeEnum(
        "kind",
        query.kind,
        Object.values(ProductPackageKind),
      );
    }

    if (query.level) {
      where.level = String(query.level).trim();
    }

    if (query.category) {
      where.category = String(query.category).trim();
    }

    if (!publishedOnly && query.status) {
      where.status = normalizeEnum(
        "status",
        query.status,
        Object.values(PublishStatus),
      );
    }

    return where;
  }

  private normalizePackageData(
    body: Record<string, unknown>,
    partial: boolean,
  ) {
    if (!isRecord(body)) {
      throw new BadRequestException("Payload must be an object.");
    }

    const data: PackageWriteData = {};
    const requiredFields = ["kind", "title", "slug", "price"];

    if (!partial) {
      for (const field of requiredFields) {
        if (!(field in body)) {
          throw new BadRequestException(`${field} is required.`);
        }
      }
    }

    if ("kind" in body) {
      data.kind = normalizeEnum(
        "kind",
        body.kind,
        Object.values(ProductPackageKind),
      );
    }

    if ("title" in body) {
      data.title = normalizeRequiredString("title", body.title);
    }

    if ("slug" in body) {
      data.slug = normalizeSlug(body.slug);
    }

    for (const field of [
      "subtitle",
      "previewDescription",
      "description",
      "level",
      "category",
    ] as const) {
      if (field in body) {
        data[field] = normalizeNullableString(body[field]);
      }
    }

    if ("price" in body) {
      data.price = normalizeBoundedInt("price", body.price, 0, 999999999);
    }

    if ("currency" in body) {
      data.currency = normalizeRequiredString("currency", body.currency)
        .toUpperCase()
        .slice(0, 12);
    }

    if ("benefits" in body) {
      data.benefits = normalizeOptionalJson(body.benefits);
    }

    if ("metadata" in body) {
      data.metadata = normalizeOptionalJson(body.metadata);
    }

    if ("status" in body) {
      data.status = normalizeEnum(
        "status",
        body.status,
        Object.values(PublishStatus),
      );
    }

    if ("sortOrder" in body) {
      data.sortOrder = normalizeBoundedInt(
        "sortOrder",
        body.sortOrder,
        -999999,
        999999,
      );
    }

    if (Object.keys(data).length === 0 && !("contents" in body)) {
      throw new BadRequestException("Payload does not contain valid fields.");
    }

    return data;
  }

  private async replacePackageContents(
    tx: Prisma.TransactionClient,
    packageId: string,
    rawContents: unknown,
  ) {
    if (rawContents === undefined) {
      return;
    }

    if (!Array.isArray(rawContents)) {
      throw new BadRequestException("contents must be an array.");
    }

    const contents = rawContents.map((item, index) =>
      normalizePackageContent(item, index),
    );

    await tx.packageContent.deleteMany({ where: { packageId } });

    for (const content of contents) {
      await tx.packageContent.create({
        data: {
          packageId,
          ...content,
        },
      });
    }
  }

  private async ensurePackageExists(id: string) {
    const item = await this.prisma.productPackage.findUnique({
      where: { id },
      select: { id: true },
    });

    if (!item) {
      throw new NotFoundException("Package not found.");
    }
  }

  private normalizeProfileData(body: Record<string, unknown>) {
    const data: ProfileWriteData = {};

    for (const field of [
      "fullName",
      "phoneNumber",
      "addressLine",
      "city",
      "province",
      "postalCode",
    ] as const) {
      if (field in body) {
        data[field] = normalizeNullableString(body[field]);
      }
    }

    if ("country" in body) {
      data.country = normalizeRequiredString("country", body.country);
    }

    if ("birthDate" in body) {
      data.birthDate = body.birthDate
        ? normalizeDate("birthDate", body.birthDate)
        : null;
    }

    if ("metadata" in body) {
      data.metadata = normalizeOptionalJson(body.metadata);
    }

    return data;
  }

  private async findPublishedPackagesByRefs(refs: string[]) {
    const packages = await this.prisma.productPackage.findMany({
      where: {
        status: PublishStatus.PUBLISHED,
        OR: [{ id: { in: refs } }, { slug: { in: refs } }],
      },
      orderBy: { sortOrder: "asc" },
    });

    if (packages.length !== refs.length) {
      throw new BadRequestException("One or more packages are not available.");
    }

    return packages;
  }

  private async findBestPromo(
    packages: PackageForDiscount[],
    subtotal: number,
  ) {
    const promos = await this.prisma.promo.findMany({
      where: {
        code: null,
        status: PublishStatus.PUBLISHED,
        minimumSubtotal: { lte: subtotal },
      },
    });

    return promos
      .filter((promo) => isActiveNow(promo))
      .filter(
        (promo) => !promo.usageLimit || promo.usedCount < promo.usageLimit,
      )
      .filter((promo) => matchesTargetKind(promo.targetKind, packages))
      .map((promo) => ({
        promo,
        discount: computeDiscount(promo, subtotal),
      }))
      .sort((left, right) => right.discount - left.discount)[0]?.promo;
  }

  private async findUsableVoucher(
    userId: string,
    rawCode: unknown,
    packages: PackageForDiscount[],
    subtotal: number,
  ) {
    const code = normalizeNullableString(rawCode)?.toUpperCase();
    if (!code) {
      return null;
    }

    const voucher = await this.prisma.voucher.findUnique({
      where: { code },
      include: {
        redemptions: { where: { userId } },
      },
    });

    if (!voucher || voucher.status !== PublishStatus.PUBLISHED) {
      throw new BadRequestException("Voucher is not valid.");
    }

    if (!isActiveNow(voucher)) {
      throw new BadRequestException("Voucher is not active.");
    }

    if (voucher.minimumSubtotal > subtotal) {
      throw new BadRequestException("Order total is below voucher minimum.");
    }

    if (voucher.usageLimit && voucher.usedCount >= voucher.usageLimit) {
      throw new BadRequestException("Voucher usage limit has been reached.");
    }

    if (voucher.redemptions.length >= voucher.perUserLimit) {
      throw new BadRequestException("Voucher has already been redeemed.");
    }

    if (!matchesTargetKind(voucher.targetKind, packages)) {
      throw new BadRequestException("Voucher cannot be used for this package.");
    }

    return voucher;
  }

  private async findActiveEntitlement(userId: string, packageId: string) {
    return this.prisma.userEntitlement.findFirst({
      where: {
        ...activeEntitlementWhere(userId),
        packageId,
      },
    });
  }

  private async assertActiveEntitlement(userId: string, packageId: string) {
    const entitlement = await this.findActiveEntitlement(userId, packageId);

    if (!entitlement) {
      throw new ForbiddenException("Package has not been purchased.");
    }
  }

  private async applyPaidOrderLoyalty(
    tx: Prisma.TransactionClient,
    order: {
      id: string;
      userId: string;
      pointsUsed: number;
      total: number;
    },
    pointsEarned: number,
  ) {
    let account = await tx.loyaltyAccount.findUnique({
      where: { userId: order.userId },
    });
    account ??= await tx.loyaltyAccount.create({
      data: { userId: order.userId },
    });
    let balance = account.pointsBalance;

    if (order.pointsUsed > 0) {
      if (balance < order.pointsUsed) {
        throw new BadRequestException("Not enough loyalty points.");
      }

      balance -= order.pointsUsed;
      account = await tx.loyaltyAccount.update({
        where: { id: account.id },
        data: {
          pointsBalance: balance,
          lifetimeSpent: { increment: order.pointsUsed },
        },
      });
      await tx.loyaltyTransaction.create({
        data: {
          userId: order.userId,
          accountId: account.id,
          orderId: order.id,
          type: LoyaltyTransactionType.SPEND,
          points: -order.pointsUsed,
          balanceAfter: balance,
          note: "Point digunakan untuk potongan pembelian paket.",
        },
      });
    }

    if (pointsEarned > 0) {
      balance += pointsEarned;
      account = await tx.loyaltyAccount.update({
        where: { id: account.id },
        data: {
          pointsBalance: balance,
          lifetimeEarned: { increment: pointsEarned },
        },
      });
      await tx.loyaltyTransaction.create({
        data: {
          userId: order.userId,
          accountId: account.id,
          orderId: order.id,
          type: LoyaltyTransactionType.EARN,
          points: pointsEarned,
          balanceAfter: account.pointsBalance,
          note: "Point dari pembelian paket. Setiap Rp10 = 1 point.",
        },
      });
    }
  }

  private async markOrderPaid(
    tx: Prisma.TransactionClient,
    order: OrderWithItems,
    paymentSource: string,
  ) {
    const now = new Date();
    const pointsEarned = Math.floor(order.total / 10);

    await tx.order.update({
      where: { id: order.id },
      data: {
        status: OrderStatus.PAID,
        paidAt: now,
        pointsEarned,
        metadata: mergePaymentMetadata(order.metadata, {
          paymentStatus: "PAID",
          paymentSource,
          paidAt: now.toISOString(),
        }),
      },
    });

    for (const item of order.items) {
      const entitlement = await tx.userEntitlement.findUnique({
        where: {
          userId_packageId: {
            userId: order.userId,
            packageId: item.packageId,
          },
        },
      });

      if (entitlement) {
        await tx.userEntitlement.update({
          where: { id: entitlement.id },
          data: {
            source: EntitlementSource.PURCHASE,
            sourceOrderId: order.id,
            startsAt: now,
            expiresAt: null,
            revokedAt: null,
          },
        });
      } else {
        await tx.userEntitlement.create({
          data: {
            userId: order.userId,
            packageId: item.packageId,
            source: EntitlementSource.PURCHASE,
            sourceOrderId: order.id,
            startsAt: now,
          },
        });
      }
    }

    await this.applyPaidOrderLoyalty(tx, order, pointsEarned);

    if (order.promoId) {
      await tx.promo.update({
        where: { id: order.promoId },
        data: { usedCount: { increment: 1 } },
      });
    }

    if (order.voucherId) {
      await tx.voucher.update({
        where: { id: order.voucherId },
        data: { usedCount: { increment: 1 } },
      });
    }

    return tx.order.findUnique({
      where: { id: order.id },
      include: orderInclude,
    });
  }

  private buildMenuPreview(
    key: string,
    title: string,
    packages: PackageForDiscount[],
    kinds: ProductPackageKind[],
  ) {
    const rows = packages.filter((item) => kinds.includes(item.kind));
    const minPrice = rows.length
      ? Math.min(...rows.map((item) => item.price))
      : null;

    return {
      key,
      title,
      description:
        key === "ssw"
          ? "Informasi SSW bisa dibaca gratis, latihan soal tersedia dalam paket."
          : `Materi dan soal ${title} tersedia dalam paket berbayar.`,
      packageCount: rows.length,
      minPrice,
      currency: "IDR",
      isFree: false,
    };
  }
}

type PackageForDiscount = {
  id: string;
  kind: ProductPackageKind;
  title: string;
  slug: string;
  price: number;
};

const orderInclude = {
  user: {
    select: {
      id: true,
      email: true,
      displayName: true,
      phoneNumber: true,
    },
  },
  items: {
    include: {
      package: true,
    },
  },
  promo: true,
  voucher: true,
  voucherRedemption: true,
  loyaltyTransactions: true,
} satisfies Prisma.OrderInclude;

function activeEntitlementWhere(
  userId: string,
): Prisma.UserEntitlementWhereInput {
  return {
    userId,
    revokedAt: null,
    OR: [{ expiresAt: null }, { expiresAt: { gt: new Date() } }],
  };
}

function normalizePackageRefs(body: Record<string, unknown>) {
  const source = body.packageIds ?? body.packages;
  if (!Array.isArray(source)) {
    throw new BadRequestException("packageIds must be an array.");
  }

  const refs = Array.from(
    new Set(source.map((item) => String(item).trim()).filter(Boolean)),
  );

  if (refs.length === 0) {
    throw new BadRequestException("packageIds cannot be empty.");
  }

  return refs;
}

function normalizePackageContent(
  value: unknown,
  index: number,
): PackageContentInput {
  if (!isRecord(value)) {
    throw new BadRequestException("Each content item must be an object.");
  }

  return {
    contentType: normalizeEnum(
      "contentType",
      value.contentType,
      Object.values(PackageContentType),
    ),
    contentId: normalizeRequiredString("contentId", value.contentId),
    title: normalizeNullableString(value.title),
    sortOrder:
      "sortOrder" in value
        ? normalizeBoundedInt("sortOrder", value.sortOrder, -999999, 999999)
        : index + 1,
  };
}

function computeDiscount(
  discountable: {
    discountKind: DiscountKind;
    discountValue: number;
    maxDiscount: number | null;
  },
  subtotal: number,
) {
  const rawDiscount =
    discountable.discountKind === DiscountKind.PERCENTAGE
      ? Math.floor((subtotal * discountable.discountValue) / 100)
      : discountable.discountValue;
  const limitedDiscount = discountable.maxDiscount
    ? Math.min(rawDiscount, discountable.maxDiscount)
    : rawDiscount;

  return Math.max(0, Math.min(subtotal, limitedDiscount));
}

function matchesTargetKind(
  targetKind: ProductPackageKind | null,
  packages: PackageForDiscount[],
) {
  if (!targetKind) {
    return true;
  }

  return packages.some((item) => item.kind === targetKind);
}

function isActiveNow(item: { startsAt: Date | null; endsAt: Date | null }) {
  const now = Date.now();
  const startsAt = item.startsAt?.getTime() ?? Number.NEGATIVE_INFINITY;
  const endsAt = item.endsAt?.getTime() ?? Number.POSITIVE_INFINITY;

  return startsAt <= now && endsAt >= now;
}

function createOrderNumber() {
  const random = Math.random().toString(36).slice(2, 8).toUpperCase();
  return `NEI-${Date.now()}-${random}`;
}

function buildDevelopmentPaymentMetadata(
  orderNumber: string,
  amount: number,
  currency: string,
): Prisma.InputJsonObject {
  return {
    paymentProvider: "XENDIT",
    paymentMode: "SANDBOX",
    paymentStatus: "PENDING",
    paymentReference: orderNumber,
    paymentExternalId: orderNumber,
    paymentAmount: amount,
    paymentCurrency: currency,
    paymentCheckoutUrl: `https://checkout-staging.xendit.co/web/${orderNumber}`,
    paymentDescription:
      "Development payment. Hubungkan XENDIT_SECRET_KEY untuk invoice Xendit asli.",
  };
}

function mergePaymentMetadata(
  value: unknown,
  updates: Prisma.InputJsonObject,
): Prisma.InputJsonObject {
  return {
    ...toMutableMetadata(value),
    ...updates,
  } as Prisma.InputJsonObject;
}

function normalizeSlug(value: unknown) {
  const slug = normalizeRequiredString("slug", value).toLowerCase();
  if (!/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(slug)) {
    throw new BadRequestException(
      "slug must use lowercase letters, numbers, and hyphens.",
    );
  }
  return slug;
}

function normalizeCode(value: unknown) {
  const code = normalizeRequiredString("code", value).toUpperCase();
  if (!/^[A-Z0-9][A-Z0-9_-]{2,31}$/.test(code)) {
    throw new BadRequestException(
      "code must use 3-32 uppercase letters, numbers, underscore, or hyphen.",
    );
  }
  return code;
}

function normalizeNullableCode(value: unknown) {
  const text = normalizeNullableString(value);
  return text ? normalizeCode(text) : null;
}

function normalizeRequiredString(field: string, value: unknown) {
  const text = normalizeNullableString(value);
  if (!text) {
    throw new BadRequestException(`${field} is required.`);
  }
  return text;
}

function normalizeNullableString(value: unknown) {
  if (value === null || value === undefined || value === "") {
    return null;
  }
  return String(value).trim();
}

function normalizeBoundedInt(
  field: string,
  value: unknown,
  min: number,
  max: number,
) {
  const number = typeof value === "number" ? value : Number(value);
  if (!Number.isInteger(number) || number < min || number > max) {
    throw new BadRequestException(`${field} must be an integer.`);
  }
  return number;
}

function normalizeNullableInt(field: string, value: unknown) {
  if (value === null || value === undefined || value === "") {
    return null;
  }
  return normalizeBoundedInt(field, value, -999999999, 999999999);
}

function normalizeDate(field: string, value: unknown) {
  const date = value instanceof Date ? value : new Date(String(value));
  if (Number.isNaN(date.getTime())) {
    throw new BadRequestException(`${field} must be a valid date.`);
  }
  return date;
}

function normalizeEnum<T extends string>(
  field: string,
  value: unknown,
  options: readonly T[],
) {
  const text = String(value ?? "")
    .trim()
    .toUpperCase();
  if (!options.includes(text as T)) {
    throw new BadRequestException(
      `${field} must be one of: ${options.join(", ")}.`,
    );
  }
  return text as T;
}

function normalizeOptionalJson(
  value: unknown,
): Prisma.InputJsonValue | undefined {
  if (value === undefined) {
    return undefined;
  }

  if (value === null || Array.isArray(value) || isRecord(value)) {
    return value as Prisma.InputJsonValue;
  }

  throw new BadRequestException("JSON field must be an object or array.");
}

function getSelectedExamScheduleId(value: unknown) {
  const metadata = toMutableMetadata(value);
  const scheduleId = metadata.selectedExamScheduleId;
  return typeof scheduleId === "string" && scheduleId.trim()
    ? scheduleId.trim()
    : null;
}

function toMutableMetadata(value: unknown): Record<string, unknown> {
  return isRecord(value) ? { ...value } : {};
}

function removeUndefined<T extends Record<string, unknown>>(value: T) {
  return Object.fromEntries(
    Object.entries(value).filter((entry) => entry[1] !== undefined),
  ) as T;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
