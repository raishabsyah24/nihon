import { applyDecorators, UseGuards } from "@nestjs/common";
import { Role } from "@prisma/client";
import { FirebaseAuthGuard } from "../auth/firebase-auth.guard";
import { Roles } from "../auth/roles.decorator";
import { RolesGuard } from "../auth/roles.guard";

export function AdminRoute() {
  return applyDecorators(
    UseGuards(FirebaseAuthGuard, RolesGuard),
    Roles(Role.ADMIN),
  );
}
