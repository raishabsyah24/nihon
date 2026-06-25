import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from "@nestjs/common";
import { FirebaseAdminService } from "./firebase-admin.service";
import { UsersService } from "./users.service";

@Injectable()
export class FirebaseAuthGuard implements CanActivate {
  constructor(
    private readonly firebase: FirebaseAdminService,
    private readonly users: UsersService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const authorization = request.headers.authorization;

    if (!authorization?.startsWith("Bearer ")) {
      throw new UnauthorizedException("Missing Firebase ID token.");
    }

    const token = authorization.replace("Bearer ", "").trim();
    const decoded = await this.firebase.verifyIdToken(token);
    request.user = await this.users.syncFirebaseUser(decoded);

    return true;
  }
}
