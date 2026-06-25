import { Controller, Get, UseGuards } from "@nestjs/common";
import { CurrentUser } from "../auth/current-user.decorator";
import { FirebaseAuthGuard } from "../auth/firebase-auth.guard";
import { RequestUser } from "../auth/request-user.type";

@Controller("me")
export class MeController {
  @Get()
  @UseGuards(FirebaseAuthGuard)
  getMe(@CurrentUser() user: RequestUser) {
    return user;
  }
}
