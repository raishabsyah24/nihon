import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Query,
} from "@nestjs/common";
import { QuestionType } from "@prisma/client";
import { ContentService } from "./content.service";
import { AdminRoute } from "./admin-route";

@Controller()
export class QuestionsController {
  constructor(private readonly content: ContentService) {}

  @Get("jlpt/questions")
  getJlpt(@Query("level") level?: string) {
    return this.content.getJlpt(level);
  }

  @Get("jlpt/question-sets")
  getJlptQuestionSets(@Query("level") level?: string) {
    return this.content.getJlptQuestionSets(level);
  }

  @Get("jlpt/question-sets/:id")
  getJlptQuestionSet(@Param("id") id: string) {
    return this.content.getQuestionSet(id, QuestionType.JLPT);
  }

  @Get("jft/questions")
  getJft(@Query("category") category?: string) {
    return this.content.getJft(category);
  }

  @Get("jft/question-sets")
  getJftQuestionSets(@Query("category") category?: string) {
    return this.content.getJftQuestionSets(category);
  }

  @Get("jft/question-sets/:id")
  getJftQuestionSet(@Param("id") id: string) {
    return this.content.getQuestionSet(id, QuestionType.JFT);
  }

  @Get("admin/jlpt/question-sets")
  @AdminRoute()
  getAllJlptQuestionSets() {
    return this.content.findAll("questionSet", { type: QuestionType.JLPT });
  }

  @Post("admin/jlpt/question-sets")
  @AdminRoute()
  createJlptQuestionSet(@Body() body: Record<string, unknown>) {
    return this.content.create("questionSet", {
      ...body,
      type: QuestionType.JLPT,
    });
  }

  @Patch("admin/jlpt/question-sets/:id")
  @AdminRoute()
  updateJlptQuestionSet(
    @Param("id") id: string,
    @Body() body: Record<string, unknown>,
  ) {
    return this.content.update("questionSet", id, {
      ...body,
      type: QuestionType.JLPT,
    });
  }

  @Delete("admin/jlpt/question-sets/:id")
  @AdminRoute()
  removeJlptQuestionSet(@Param("id") id: string) {
    return this.content.remove("questionSet", id);
  }

  @Get("admin/jlpt/questions")
  @AdminRoute()
  getAllJlpt() {
    return this.content.findAll("question", { type: QuestionType.JLPT });
  }

  @Post("admin/jlpt/questions")
  @AdminRoute()
  createJlpt(@Body() body: Record<string, unknown>) {
    return this.content.create("question", {
      ...body,
      type: QuestionType.JLPT,
    });
  }

  @Patch("admin/jlpt/questions/:id")
  @AdminRoute()
  updateJlpt(@Param("id") id: string, @Body() body: Record<string, unknown>) {
    return this.content.update("question", id, {
      ...body,
      type: QuestionType.JLPT,
    });
  }

  @Delete("admin/jlpt/questions/:id")
  @AdminRoute()
  removeJlpt(@Param("id") id: string) {
    return this.content.remove("question", id);
  }

  @Get("admin/jft/questions")
  @AdminRoute()
  getAllJft() {
    return this.content.findAll("question", { type: QuestionType.JFT });
  }

  @Get("admin/jft/question-sets")
  @AdminRoute()
  getAllJftQuestionSets() {
    return this.content.findAll("questionSet", { type: QuestionType.JFT });
  }

  @Post("admin/jft/question-sets")
  @AdminRoute()
  createJftQuestionSet(@Body() body: Record<string, unknown>) {
    return this.content.create("questionSet", {
      ...body,
      type: QuestionType.JFT,
    });
  }

  @Patch("admin/jft/question-sets/:id")
  @AdminRoute()
  updateJftQuestionSet(
    @Param("id") id: string,
    @Body() body: Record<string, unknown>,
  ) {
    return this.content.update("questionSet", id, {
      ...body,
      type: QuestionType.JFT,
    });
  }

  @Delete("admin/jft/question-sets/:id")
  @AdminRoute()
  removeJftQuestionSet(@Param("id") id: string) {
    return this.content.remove("questionSet", id);
  }

  @Post("admin/jft/questions")
  @AdminRoute()
  createJft(@Body() body: Record<string, unknown>) {
    return this.content.create("question", { ...body, type: QuestionType.JFT });
  }

  @Patch("admin/jft/questions/:id")
  @AdminRoute()
  updateJft(@Param("id") id: string, @Body() body: Record<string, unknown>) {
    return this.content.update("question", id, {
      ...body,
      type: QuestionType.JFT,
    });
  }

  @Delete("admin/jft/questions/:id")
  @AdminRoute()
  removeJft(@Param("id") id: string) {
    return this.content.remove("question", id);
  }
}
