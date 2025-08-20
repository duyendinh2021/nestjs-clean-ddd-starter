import { Injectable } from '@nestjs/common';
import { UseCase } from '../interfaces/use-case.interface';

@Injectable()
export class GetHelloUseCase implements UseCase<void, string> {
  execute(): Promise<string> {
    return Promise.resolve('Hello World!');
  }
}
