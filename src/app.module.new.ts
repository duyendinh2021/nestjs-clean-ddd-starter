import { Module } from '@nestjs/common';
import { AppController } from './presentation/controllers/app.controller';
import { GetHelloUseCase } from './application/use-cases/get-hello.use-case';

@Module({
  imports: [],
  controllers: [AppController],
  providers: [GetHelloUseCase],
})
export class AppModule {}
