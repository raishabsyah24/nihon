import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  UseGuards,
} from "@nestjs/common";
import { QuestionType } from "@prisma/client";
import { CurrentUser } from "../auth/current-user.decorator";
import { FirebaseAuthGuard } from "../auth/firebase-auth.guard";
import { RequestUser } from "../auth/request-user.type";
import { ContentService } from "./content.service";
import { AdminRoute } from "./admin-route";

@Controller()
export class SswController {
  constructor(private readonly content: ContentService) {}

  @Get("ssw/categories")
  getCategories() {
    return this.content.getSswCategories();
  }

  @Get("ssw/modules/:id")
  getModule(@Param("id") id: string) {
    return this.content.getSswModule(id);
  }

  @Get("me/ssw/modules/:id")
  @UseGuards(FirebaseAuthGuard)
  getMyModule(@Param("id") id: string, @CurrentUser() user: RequestUser) {
    return this.content.getSswModule(id, user.id);
  }

  @Get("admin/ssw/categories")
  @AdminRoute()
  getAllCategories() {
    return this.content.findAll("sswCategory");
  }

  @Post("admin/ssw/categories")
  @AdminRoute()
  createCategory(@Body() body: Record<string, unknown>) {
    return this.content.create("sswCategory", body);
  }

  @Patch("admin/ssw/categories/:id")
  @AdminRoute()
  updateCategory(
    @Param("id") id: string,
    @Body() body: Record<string, unknown>,
  ) {
    return this.content.update("sswCategory", id, body);
  }

  @Delete("admin/ssw/categories/:id")
  @AdminRoute()
  removeCategory(@Param("id") id: string) {
    return this.content.remove("sswCategory", id);
  }

  @Get("admin/ssw/modules")
  @AdminRoute()
  getAllModules() {
    return this.content.findAll("sswModule");
  }

  @Post("admin/ssw/modules")
  @AdminRoute()
  createModule(@Body() body: Record<string, unknown>) {
    return this.content.create("sswModule", body);
  }

  @Patch("admin/ssw/modules/:id")
  @AdminRoute()
  updateModule(@Param("id") id: string, @Body() body: Record<string, unknown>) {
    return this.content.update("sswModule", id, body);
  }

  @Delete("admin/ssw/modules/:id")
  @AdminRoute()
  removeModule(@Param("id") id: string) {
    return this.content.remove("sswModule", id);
  }

  @Get("admin/ssw/questions")
  @AdminRoute()
  getAllQuestions() {
    return this.content.findAll("question", { type: QuestionType.SSW });
  }

  @Post("admin/ssw/questions")
  @AdminRoute()
  createQuestion(@Body() body: Record<string, unknown>) {
    return this.content.create("question", { ...body, type: QuestionType.SSW });
  }

  @Patch("admin/ssw/questions/:id")
  @AdminRoute()
  updateQuestion(
    @Param("id") id: string,
    @Body() body: Record<string, unknown>,
  ) {
    return this.content.update("question", id, {
      ...body,
      type: QuestionType.SSW,
    });
  }

  @Delete("admin/ssw/questions/:id")
  @AdminRoute()
  removeQuestion(@Param("id") id: string) {
    return this.content.remove("question", id);
  }
}
