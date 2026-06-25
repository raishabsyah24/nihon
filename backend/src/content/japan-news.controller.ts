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
import { ContentService } from "./content.service";
import { AdminRoute } from "./admin-route";

@Controller()
export class JapanNewsController {
  constructor(private readonly content: ContentService) {}

  @Get("japan-news")
  getPublished(@Query("category") category?: string) {
    return this.content.getJapanNews(category);
  }

  @Get("japan-news/:idOrSlug")
  getPublishedById(@Param("idOrSlug") idOrSlug: string) {
    return this.content.getJapanNewsDetail(idOrSlug);
  }

  @Get("admin/japan-news")
  @AdminRoute()
  getAll() {
    return this.content.findAll("japanNews");
  }

  @Post("admin/japan-news")
  @AdminRoute()
  create(@Body() body: Record<string, unknown>) {
    return this.content.create("japanNews", body);
  }

  @Patch("admin/japan-news/:id")
  @AdminRoute()
  update(@Param("id") id: string, @Body() body: Record<string, unknown>) {
    return this.content.update("japanNews", id, body);
  }

  @Delete("admin/japan-news/:id")
  @AdminRoute()
  remove(@Param("id") id: string) {
    return this.content.remove("japanNews", id);
  }
}
