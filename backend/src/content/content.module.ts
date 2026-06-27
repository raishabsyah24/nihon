import { Module } from "@nestjs/common";
import { HealthController } from "./health.controller";
import { MeController } from "./me.controller";
import { KanaController } from "./kana.controller";
import { KotobaController } from "./kotoba.controller";
import { QuestionsController } from "./questions.controller";
import { SswController } from "./ssw.controller";
import { StudyMaterialsController } from "./study-materials.controller";
import { ExamSchedulesController } from "./exam-schedules.controller";
import { JapanNewsController } from "./japan-news.controller";
import { UsersController } from "./users.controller";
import { ContentService } from "./content.service";
import { CommerceController } from "./commerce.controller";
import { CommerceService } from "./commerce.service";
import { AuthModule } from "../auth/auth.module";

@Module({
  imports: [AuthModule],
  controllers: [
    HealthController,
    MeController,
    KanaController,
    KotobaController,
    QuestionsController,
    SswController,
    StudyMaterialsController,
    ExamSchedulesController,
    JapanNewsController,
    UsersController,
    CommerceController,
  ],
  providers: [ContentService, CommerceService],
})
export class ContentModule {}
