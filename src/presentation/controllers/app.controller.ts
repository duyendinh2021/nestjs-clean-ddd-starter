import { Controller, Get } from '@nestjs/common';
import { GetHelloUseCase } from '../../application/use-cases/get-hello.use-case';

@Controller()
export class AppController {
  constructor(private readonly getHelloUseCase: GetHelloUseCase) {}

  @Get()
  async getHello(): Promise<string> {
    return await this.getHelloUseCase.execute();
  }
}
