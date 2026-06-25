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
import { ExamType } from "@prisma/client";
import { ContentService } from "./content.service";
import { AdminRoute } from "./admin-route";

@Controller()
export class ExamSchedulesController {
  constructor(private readonly content: ContentService) {}

  @Get("exam-schedules")
  getPublished(@Query("type") type?: ExamType) {
    return this.content.getSchedules(type);
  }

  @Get("exam-schedules/:id")
  getPublishedById(@Param("id") id: string) {
    return this.content.getSchedule(id);
  }

  @Get("admin/exam-schedules")
  @AdminRoute()
  getAll() {
    return this.content.findAll("examSchedule");
  }

  @Post("admin/exam-schedules")
  @AdminRoute()
  create(@Body() body: Record<string, unknown>) {
    return this.content.create("examSchedule", body);
  }

  @Patch("admin/exam-schedules/:id")
  @AdminRoute()
  update(@Param("id") id: string, @Body() body: Record<string, unknown>) {
    return this.content.update("examSchedule", id, body);
  }

  @Delete("admin/exam-schedules/:id")
  @AdminRoute()
  remove(@Param("id") id: string) {
    return this.content.remove("examSchedule", id);
  }
}
