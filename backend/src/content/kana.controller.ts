import { Controller, Get } from "@nestjs/common";
import { ContentService } from "./content.service";

@Controller("kana")
export class KanaController {
  constructor(private readonly content: ContentService) {}

  @Get("hiragana")
  getHiragana() {
    return this.content.getKana("HIRAGANA");
  }

  @Get("katakana")
  getKatakana() {
    return this.content.getKana("KATAKANA");
  }
}
