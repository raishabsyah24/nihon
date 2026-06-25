import { User } from "@prisma/client";

export type RequestUser = User;

export type AuthenticatedRequest = Request & {
  user: RequestUser;
};
