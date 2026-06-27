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
import { CurrentUser } from "../auth/current-user.decorator";
import { FirebaseAuthGuard } from "../auth/firebase-auth.guard";
import { RequestUser } from "../auth/request-user.type";
import { AdminRoute } from "./admin-route";
import { ContentService } from "./content.service";

@Controller()
export class StudyMaterialsController {
  constructor(private readonly content: ContentService) {}

  @Get("study-materials/:idOrSlug")
  getStudyMaterial(@Param("idOrSlug") idOrSlug: string) {
    return this.content.getStudyMaterial(idOrSlug);
  }

  @Get("me/study-materials/:idOrSlug")
  @UseGuards(FirebaseAuthGuard)
  getMyStudyMaterial(
    @Param("idOrSlug") idOrSlug: string,
    @CurrentUser() user: RequestUser,
  ) {
    return this.content.getStudyMaterial(idOrSlug, user.id);
  }

  @Get("admin/study-materials")
  @AdminRoute()
  getAllStudyMaterials() {
    return this.content.findAll("studyMaterial");
  }

  @Post("admin/study-materials")
  @AdminRoute()
  createStudyMaterial(@Body() body: Record<string, unknown>) {
    return this.content.create("studyMaterial", body);
  }

  @Patch("admin/study-materials/:id")
  @AdminRoute()
  updateStudyMaterial(
    @Param("id") id: string,
    @Body() body: Record<string, unknown>,
  ) {
    return this.content.update("studyMaterial", id, body);
  }

  @Delete("admin/study-materials/:id")
  @AdminRoute()
  removeStudyMaterial(@Param("id") id: string) {
    return this.content.remove("studyMaterial", id);
  }
}
