// Example Use Case
import { Injectable } from '@nestjs/common';
import { UseCase } from '../interfaces/use-case.interface';
import type { UserRepository } from '../../domain/repositories/user.repository';
import { User } from '../../domain/entities/user.entity';

export interface CreateUserRequest {
  email: string;
  name: string;
}

@Injectable()
export class CreateUserUseCase implements UseCase<CreateUserRequest, User> {
  constructor(private readonly userRepository: UserRepository) {}

  async execute(request: CreateUserRequest): Promise<User> {
    // Validate request
    if (!request.email || !request.name) {
      throw new Error('Email and name are required');
    }

    // Check if user already exists
    const existingUser = await this.userRepository.findByEmail(request.email);
    if (existingUser) {
      throw new Error('User with this email already exists');
    }

    // Create new user
    const user = new User(this.generateId(), request.email, request.name);

    // Validate business rules
    if (!user.isValid()) {
      throw new Error('Invalid user data');
    }

    // Save user
    await this.userRepository.save(user);

    return user;
  }

  private generateId(): string {
    return Date.now().toString() + Math.random().toString(36).substr(2, 9);
  }
}
