import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Query,
  UseGuards,
} from "@nestjs/common";
import { CurrentUser } from "../auth/current-user.decorator";
import { FirebaseAuthGuard } from "../auth/firebase-auth.guard";
import { RequestUser } from "../auth/request-user.type";
import { AdminRoute } from "./admin-route";
import { CommerceService } from "./commerce.service";

@Controller()
export class CommerceController {
  constructor(private readonly commerce: CommerceService) {}

  @Get("catalog/home")
  getHomeCatalog() {
    return this.commerce.getHomeCatalog();
  }

  @Get("packages")
  getPackages(@Query() query: Record<string, unknown>) {
    return this.commerce.listPublishedPackages(query);
  }

  @Get("packages/:idOrSlug")
  getPackage(@Param("idOrSlug") idOrSlug: string) {
    return this.commerce.getPublishedPackage(idOrSlug);
  }

  @Get("me/packages/:idOrSlug")
  @UseGuards(FirebaseAuthGuard)
  getMyPackage(
    @Param("idOrSlug") idOrSlug: string,
    @CurrentUser() user: RequestUser,
  ) {
    return this.commerce.getPublishedPackage(idOrSlug, user.id);
  }

  @Get("me/profile")
  @UseGuards(FirebaseAuthGuard)
  getMyProfile(@CurrentUser() user: RequestUser) {
    return this.commerce.getMyProfile(user);
  }

  @Patch("me/profile")
  @UseGuards(FirebaseAuthGuard)
  updateMyProfile(
    @CurrentUser() user: RequestUser,
    @Body() body: Record<string, unknown>,
  ) {
    return this.commerce.updateMyProfile(user, body);
  }

  @Get("me/entitlements")
  @UseGuards(FirebaseAuthGuard)
  getMyEntitlements(@CurrentUser() user: RequestUser) {
    return this.commerce.listMyEntitlements(user);
  }

  @Get("me/progress")
  @UseGuards(FirebaseAuthGuard)
  getMyProgress(@CurrentUser() user: RequestUser) {
    return this.commerce.listMyProgress(user);
  }

  @Get("me/exam-schedule")
  @UseGuards(FirebaseAuthGuard)
  getMyExamScheduleSelection(@CurrentUser() user: RequestUser) {
    return this.commerce.getMyExamScheduleSelection(user);
  }

  @Post("me/exam-schedule")
  @UseGuards(FirebaseAuthGuard)
  selectMyExamSchedule(
    @CurrentUser() user: RequestUser,
    @Body() body: Record<string, unknown>,
  ) {
    return this.commerce.selectMyExamSchedule(user, body);
  }

  @Delete("me/exam-schedule")
  @UseGuards(FirebaseAuthGuard)
  clearMyExamScheduleSelection(@CurrentUser() user: RequestUser) {
    return this.commerce.clearMyExamScheduleSelection(user);
  }

  @Post("me/progress")
  @UseGuards(FirebaseAuthGuard)
  upsertMyProgress(
    @CurrentUser() user: RequestUser,
    @Body() body: Record<string, unknown>,
  ) {
    return this.commerce.upsertMyProgress(user, body);
  }

  @Post("orders")
  @UseGuards(FirebaseAuthGuard)
  createOrder(
    @CurrentUser() user: RequestUser,
    @Body() body: Record<string, unknown>,
  ) {
    return this.commerce.createOrder(user, body);
  }

  @Get("me/orders")
  @UseGuards(FirebaseAuthGuard)
  getMyOrders(@CurrentUser() user: RequestUser) {
    return this.commerce.listMyOrders(user);
  }

  @Get("me/orders/:id")
  @UseGuards(FirebaseAuthGuard)
  getMyOrder(@CurrentUser() user: RequestUser, @Param("id") id: string) {
    return this.commerce.getMyOrder(user, id);
  }

  @Post("me/orders/:id/payments/dev/settle")
  @UseGuards(FirebaseAuthGuard)
  settleMyDevPayment(
    @CurrentUser() user: RequestUser,
    @Param("id") id: string,
  ) {
    return this.commerce.settleMyDevPayment(user, id);
  }

  @Get("admin/packages")
  @AdminRoute()
  getAdminPackages(@Query() query: Record<string, unknown>) {
    return this.commerce.listAdminPackages(query);
  }

  @Post("admin/packages")
  @AdminRoute()
  createPackage(@Body() body: Record<string, unknown>) {
    return this.commerce.createPackage(body);
  }

  @Patch("admin/packages/:id")
  @AdminRoute()
  updatePackage(
    @Param("id") id: string,
    @Body() body: Record<string, unknown>,
  ) {
    return this.commerce.updatePackage(id, body);
  }

  @Delete("admin/packages/:id")
  @AdminRoute()
  archivePackage(@Param("id") id: string) {
    return this.commerce.archivePackage(id);
  }

  @Get("admin/orders")
  @AdminRoute()
  getAdminOrders(@Query() query: Record<string, unknown>) {
    return this.commerce.listAdminOrders(query);
  }

  @Patch("admin/orders/:id/status")
  @AdminRoute()
  updateOrderStatus(
    @Param("id") id: string,
    @Body() body: Record<string, unknown>,
  ) {
    return this.commerce.updateOrderStatus(id, body);
  }

  @Get("admin/promos")
  @AdminRoute()
  getAdminPromos(@Query() query: Record<string, unknown>) {
    return this.commerce.listAdminPromos(query);
  }

  @Post("admin/promos")
  @AdminRoute()
  createPromo(@Body() body: Record<string, unknown>) {
    return this.commerce.createPromo(body);
  }

  @Patch("admin/promos/:id")
  @AdminRoute()
  updatePromo(@Param("id") id: string, @Body() body: Record<string, unknown>) {
    return this.commerce.updatePromo(id, body);
  }

  @Delete("admin/promos/:id")
  @AdminRoute()
  archivePromo(@Param("id") id: string) {
    return this.commerce.archivePromo(id);
  }

  @Get("admin/vouchers")
  @AdminRoute()
  getAdminVouchers(@Query() query: Record<string, unknown>) {
    return this.commerce.listAdminVouchers(query);
  }

  @Post("admin/vouchers")
  @AdminRoute()
  createVoucher(@Body() body: Record<string, unknown>) {
    return this.commerce.createVoucher(body);
  }

  @Patch("admin/vouchers/:id")
  @AdminRoute()
  updateVoucher(
    @Param("id") id: string,
    @Body() body: Record<string, unknown>,
  ) {
    return this.commerce.updateVoucher(id, body);
  }

  @Delete("admin/vouchers/:id")
  @AdminRoute()
  archiveVoucher(@Param("id") id: string) {
    return this.commerce.archiveVoucher(id);
  }
}
