import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
} from "@nestjs/common";
import { ContentService } from "./content.service";
import { AdminRoute } from "./admin-route";

@Controller()
export class KotobaController {
  constructor(private readonly content: ContentService) {}

  @Get("kotoba")
  getPublished() {
    return this.content.findPublished("kotoba");
  }

  @Get("kotoba/:id")
  getPublishedById(@Param("id") id: string) {
    return this.content.findPublishedById("kotoba", id);
  }

  @Get("admin/kotoba")
  @AdminRoute()
  getAll() {
    return this.content.findAll("kotoba");
  }

  @Post("admin/kotoba")
  @AdminRoute()
  create(@Body() body: Record<string, unknown>) {
    return this.content.create("kotoba", body);
  }

  @Patch("admin/kotoba/:id")
  @AdminRoute()
  update(@Param("id") id: string, @Body() body: Record<string, unknown>) {
    return this.content.update("kotoba", id, body);
  }

  @Delete("admin/kotoba/:id")
  @AdminRoute()
  remove(@Param("id") id: string) {
    return this.content.remove("kotoba", id);
  }
}
