import { Controller, Get } from "@nestjs/common";
import { UsersService } from "../auth/users.service";
import { AdminRoute } from "./admin-route";

@Controller("admin/users")
export class UsersController {
  constructor(private readonly users: UsersService) {}

  @Get()
  @AdminRoute()
  getUsers() {
    return this.users.findAll();
  }
}
