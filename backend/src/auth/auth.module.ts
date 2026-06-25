import { Module } from "@nestjs/common";
import { FirebaseAdminService } from "./firebase-admin.service";
import { FirebaseAuthGuard } from "./firebase-auth.guard";
import { RolesGuard } from "./roles.guard";
import { UsersService } from "./users.service";

@Module({
  providers: [
    FirebaseAdminService,
    FirebaseAuthGuard,
    RolesGuard,
    UsersService,
  ],
  exports: [FirebaseAdminService, FirebaseAuthGuard, RolesGuard, UsersService],
})
export class AuthModule {}
