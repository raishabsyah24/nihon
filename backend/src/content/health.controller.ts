import { Controller, Get } from "@nestjs/common";
import { ContentService } from "./content.service";

@Controller("health")
export class HealthController {
  constructor(private readonly content: ContentService) {}

  @Get()
  getHealth() {
    return this.content.getHealth();
  }
}
