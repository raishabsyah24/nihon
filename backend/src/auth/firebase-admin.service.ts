import { Injectable, Logger, ServiceUnavailableException } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import * as admin from "firebase-admin";

@Injectable()
export class FirebaseAdminService {
  private readonly logger = new Logger(FirebaseAdminService.name);
  private initialized = false;

  constructor(private readonly config: ConfigService) {
    if (admin.apps.length > 0) {
      this.initialized = true;
      return;
    }

    const serviceAccountJson = this.config.get<string>(
      "FIREBASE_SERVICE_ACCOUNT_JSON",
    );
    const projectId = this.config.get<string>("FIREBASE_PROJECT_ID");
    const clientEmail = this.config.get<string>("FIREBASE_CLIENT_EMAIL");
    const privateKey = this.config
      .get<string>("FIREBASE_PRIVATE_KEY")
      ?.replace(/\\n/g, "\n");

    if (serviceAccountJson) {
      admin.initializeApp({
        credential: admin.credential.cert(JSON.parse(serviceAccountJson)),
      });
      this.initialized = true;
      return;
    }

    if (projectId && clientEmail && privateKey) {
      admin.initializeApp({
        credential: admin.credential.cert({
          projectId,
          clientEmail,
          privateKey,
        }),
      });
      this.initialized = true;
      return;
    }

    this.logger.warn(
      "Firebase Admin is not configured. Authenticated routes are disabled until Firebase Admin env is provided.",
    );
  }

  verifyIdToken(token: string) {
    if (!this.initialized) {
      throw new ServiceUnavailableException(
        "Firebase Admin belum dikonfigurasi di backend.",
      );
    }

    return admin.auth().verifyIdToken(token);
  }
}
