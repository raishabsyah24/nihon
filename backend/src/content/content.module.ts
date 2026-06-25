import { Module } from "@nestjs/common";
import { HealthController } from "./health.controller";
import { MeController } from "./me.controller";
import { KanaController } from "./kana.controller";
import { KotobaController } from "./kotoba.controller";
import { QuestionsController } from "./questions.controller";
import { SswController } from "./ssw.controller";
import { ExamSchedulesController } from "./exam-schedules.controller";
import { JapanNewsController } from "./japan-news.controller";
import { UsersController } from "./users.controller";
import { ContentService } from "./content.service";
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
    ExamSchedulesController,
    JapanNewsController,
    UsersController,
  ],
  providers: [ContentService],
})
export class ContentModule {}
