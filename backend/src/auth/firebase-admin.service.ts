import { Injectable, Logger } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import * as admin from "firebase-admin";

@Injectable()
export class FirebaseAdminService {
  private readonly logger = new Logger(FirebaseAdminService.name);

  constructor(private readonly config: ConfigService) {
    if (admin.apps.length > 0) {
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
      return;
    }

    this.logger.warn("Firebase Admin uses application default credentials.");
    admin.initializeApp({
      credential: admin.credential.applicationDefault(),
    });
  }

  verifyIdToken(token: string) {
    return admin.auth().verifyIdToken(token);
  }
}
