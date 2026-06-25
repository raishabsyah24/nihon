import { Injectable } from "@nestjs/common";
import { Role } from "@prisma/client";
import { DecodedIdToken } from "firebase-admin/auth";
import { PrismaService } from "../prisma/prisma.service";

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  async syncFirebaseUser(decoded: DecodedIdToken) {
    return this.prisma.user.upsert({
      where: { firebaseUid: decoded.uid },
      update: {
        email: decoded.email,
        displayName: decoded.name,
        photoUrl: decoded.picture,
      },
      create: {
        firebaseUid: decoded.uid,
        email: decoded.email,
        displayName: decoded.name,
        photoUrl: decoded.picture,
        role: Role.USER,
      },
    });
  }

  findAll() {
    return this.prisma.user.findMany({
      orderBy: { createdAt: "desc" },
    });
  }
}
