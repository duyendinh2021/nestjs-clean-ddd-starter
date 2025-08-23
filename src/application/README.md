# 🔄 Application Layer

## 📝 Mục đích

Application Layer chứa **application logic** và **use cases**. Layer này orchestrate domain objects để thực hiện business workflows và xử lý application-specific logic.

## 📂 Cấu trúc thư mục

```
application/
├── use-cases/         # Application use cases (business workflows)
├── dtos/             # Data Transfer Objects cho application
├── interfaces/       # Application interfaces và contracts
├── services/         # Application services
└── index.ts          # Export tất cả application objects
```

## 🎯 Nguyên tắc

### ✅ Application Layer được phép:

- Orchestrate domain objects
- Implement use cases và workflows
- Define application-specific DTOs
- Coordinate với Infrastructure layer
- Handle cross-cutting concerns (logging, validation)
- Manage transactions

### ❌ Application Layer KHÔNG được phép:

- Chứa business rules (thuộc Domain layer)
- Direct database access (sử dụng repository interfaces)
- HTTP request/response handling (thuộc Presentation layer)
- Framework-specific code (trừ dependency injection)

## 📋 Code Convention

### Use Cases

```typescript
// ✅ Good: Clear use case with single responsibility
export interface UseCase<TRequest, TResponse> {
  execute(request: TRequest): Promise<TResponse>;
}

@Injectable()
export class CreateUserUseCase
  implements UseCase<CreateUserRequest, CreateUserResponse>
{
  constructor(
    private readonly userRepository: UserRepository,
    private readonly emailService: EmailService,
    private readonly logger: Logger,
  ) {}

  async execute(request: CreateUserRequest): Promise<CreateUserResponse> {
    // 1. Validate input
    this.validateRequest(request);

    // 2. Check business rules
    await this.checkUserNotExists(request.email);

    // 3. Create domain object
    const user = new User(
      uuidv4(),
      request.email,
      request.firstName,
      request.lastName,
    );

    // 4. Save to repository
    await this.userRepository.save(user);

    // 5. Handle side effects
    await this.sendWelcomeEmail(user);

    // 6. Log operation
    this.logger.log(`User created: ${user.id}`);

    // 7. Return response
    return new CreateUserResponse(user.id, user.email);
  }

  private validateRequest(request: CreateUserRequest): void {
    if (!request.email || !request.firstName || !request.lastName) {
      throw new Error('Missing required fields');
    }
  }

  private async checkUserNotExists(email: string): Promise<void> {
    const existingUser = await this.userRepository.findByEmail(email);
    if (existingUser) {
      throw new Error('User already exists');
    }
  }

  private async sendWelcomeEmail(user: User): Promise<void> {
    try {
      await this.emailService.sendWelcomeEmail(user.email, user.fullName);
    } catch (error) {
      this.logger.error(`Failed to send welcome email: ${error.message}`);
      // Don't fail the entire operation for email issues
    }
  }
}

// ❌ Bad: Multiple responsibilities, business logic in application layer
@Injectable()
export class UserService {
  async createUser(data: any): Promise<any> {
    // Bad: Business validation in application layer
    if (data.age < 18) {
      throw new Error('User must be 18 or older');
    }

    // Bad: Direct database access
    const result = await this.database.query('INSERT INTO users...');

    // Bad: HTTP response logic in application layer
    return { status: 'success', data: result };
  }
}
```

### DTOs (Data Transfer Objects)

```typescript
// ✅ Good: Input/Output DTOs với validation
export class CreateUserRequest {
  constructor(
    public readonly email: string,
    public readonly firstName: string,
    public readonly lastName: string,
    public readonly dateOfBirth?: Date,
  ) {
    this.validate();
  }

  private validate(): void {
    if (!this.email || !this.firstName || !this.lastName) {
      throw new Error('Email, firstName, and lastName are required');
    }

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(this.email)) {
      throw new Error('Invalid email format');
    }
  }
}

export class CreateUserResponse {
  constructor(
    public readonly userId: string,
    public readonly email: string,
    public readonly createdAt: Date = new Date(),
  ) {}
}

export class GetUserResponse {
  constructor(
    public readonly id: string,
    public readonly email: string,
    public readonly fullName: string,
    public readonly isActive: boolean,
    public readonly createdAt: Date,
  ) {}

  // Factory method to create from domain entity
  static fromDomain(user: User): GetUserResponse {
    return new GetUserResponse(
      user.id,
      user.email,
      user.fullName,
      user.isActive,
      user.createdAt,
    );
  }
}

// ❌ Bad: Anemic DTO without validation
export class CreateUserDto {
  email: string;
  firstName: string;
  lastName: string;
  // No validation, no encapsulation
}
```

### Application Services

```typescript
// ✅ Good: Application service coordinating multiple use cases
@Injectable()
export class UserApplicationService {
  constructor(
    private readonly createUserUseCase: CreateUserUseCase,
    private readonly getUserUseCase: GetUserUseCase,
    private readonly updateUserUseCase: UpdateUserUseCase,
    private readonly deleteUserUseCase: DeleteUserUseCase,
  ) {}

  async createUser(request: CreateUserRequest): Promise<CreateUserResponse> {
    return this.createUserUseCase.execute(request);
  }

  async getUserById(userId: string): Promise<GetUserResponse> {
    return this.getUserUseCase.execute(new GetUserRequest(userId));
  }

  async updateUser(userId: string, request: UpdateUserRequest): Promise<void> {
    const updateRequest = new UpdateUserUseCaseRequest(userId, request);
    await this.updateUserUseCase.execute(updateRequest);
  }

  async deleteUser(userId: string): Promise<void> {
    await this.deleteUserUseCase.execute(new DeleteUserRequest(userId));
  }

  // Complex workflow involving multiple use cases
  async transferUserData(fromUserId: string, toUserId: string): Promise<void> {
    const fromUser = await this.getUserUseCase.execute(
      new GetUserRequest(fromUserId),
    );
    const toUser = await this.getUserUseCase.execute(
      new GetUserRequest(toUserId),
    );

    // Coordinate multiple operations
    // Implementation here...
  }
}
```

### Interfaces

```typescript
// ✅ Good: Application interfaces for external dependencies
export interface EmailService {
  sendWelcomeEmail(email: string, name: string): Promise<void>;
  sendPasswordResetEmail(email: string, resetToken: string): Promise<void>;
  sendNotificationEmail(
    email: string,
    subject: string,
    content: string,
  ): Promise<void>;
}

export interface FileStorageService {
  uploadFile(file: Buffer, fileName: string): Promise<string>;
  downloadFile(fileId: string): Promise<Buffer>;
  deleteFile(fileId: string): Promise<void>;
}

export interface CacheService {
  get<T>(key: string): Promise<T | null>;
  set<T>(key: string, value: T, ttlSeconds?: number): Promise<void>;
  delete(key: string): Promise<void>;
  clear(): Promise<void>;
}

// Application-specific query interfaces
export interface UserQueryService {
  findUsersByRole(role: string): Promise<UserSummary[]>;
  getUserStatistics(): Promise<UserStatistics>;
  searchUsers(criteria: UserSearchCriteria): Promise<UserSearchResult>;
}
```

## 🔄 Workflow Examples

### 1. Simple CRUD Use Case

```typescript
@Injectable()
export class GetUserUseCase
  implements UseCase<GetUserRequest, GetUserResponse>
{
  constructor(
    private readonly userRepository: UserRepository,
    private readonly logger: Logger,
  ) {}

  async execute(request: GetUserRequest): Promise<GetUserResponse> {
    this.logger.log(`Getting user: ${request.userId}`);

    const user = await this.userRepository.findById(request.userId);
    if (!user) {
      throw new Error('User not found');
    }

    return GetUserResponse.fromDomain(user);
  }
}
```

### 2. Complex Business Workflow

```typescript
@Injectable()
export class ProcessOrderUseCase
  implements UseCase<ProcessOrderRequest, ProcessOrderResponse>
{
  constructor(
    private readonly orderRepository: OrderRepository,
    private readonly userRepository: UserRepository,
    private readonly paymentService: PaymentService,
    private readonly inventoryService: InventoryService,
    private readonly emailService: EmailService,
    private readonly eventBus: EventBus,
  ) {}

  async execute(request: ProcessOrderRequest): Promise<ProcessOrderResponse> {
    // 1. Get order and validate
    const order = await this.orderRepository.findById(request.orderId);
    if (!order) {
      throw new Error('Order not found');
    }

    // 2. Check inventory
    await this.checkInventoryAvailability(order);

    // 3. Process payment
    const paymentResult = await this.paymentService.processPayment(
      order.totalAmount,
      request.paymentMethod,
    );

    // 4. Update order status
    order.markAsPaid(paymentResult.transactionId);
    await this.orderRepository.save(order);

    // 5. Reserve inventory
    await this.inventoryService.reserveItems(order.items);

    // 6. Send confirmation email
    const user = await this.userRepository.findById(order.customerId);
    await this.emailService.sendOrderConfirmation(user.email, order);

    // 7. Publish domain events
    order.domainEvents.forEach(event => this.eventBus.publish(event));

    return new ProcessOrderResponse(
      order.id,
      order.status,
      paymentResult.transactionId,
    );
  }

  private async checkInventoryAvailability(order: Order): Promise<void> {
    for (const item of order.items) {
      const available = await this.inventoryService.checkAvailability(
        item.productId,
        item.quantity,
      );
      if (!available) {
        throw new Error(
          `Insufficient inventory for product: ${item.productId}`,
        );
      }
    }
  }
}
```

### 3. Query Use Case với Caching

```typescript
@Injectable()
export class GetUserProfileUseCase
  implements UseCase<GetUserProfileRequest, GetUserProfileResponse>
{
  constructor(
    private readonly userRepository: UserRepository,
    private readonly cacheService: CacheService,
    private readonly logger: Logger,
  ) {}

  async execute(
    request: GetUserProfileRequest,
  ): Promise<GetUserProfileResponse> {
    const cacheKey = `user_profile_${request.userId}`;

    // Try cache first
    const cached =
      await this.cacheService.get<GetUserProfileResponse>(cacheKey);
    if (cached) {
      this.logger.log(`User profile served from cache: ${request.userId}`);
      return cached;
    }

    // Get from repository
    const user = await this.userRepository.findById(request.userId);
    if (!user) {
      throw new Error('User not found');
    }

    const response = GetUserProfileResponse.fromDomain(user);

    // Cache for 5 minutes
    await this.cacheService.set(cacheKey, response, 300);

    this.logger.log(`User profile loaded and cached: ${request.userId}`);
    return response;
  }
}
```

## 🚀 Best Practices

1. **Single Responsibility**: Mỗi use case chỉ làm một việc
2. **Input Validation**: Validate input trong DTOs hoặc use cases
3. **Error Handling**: Handle errors gracefully và provide meaningful messages
4. **Logging**: Log important operations và errors
5. **Transaction Management**: Sử dụng transactions cho multi-step operations
6. **Async/Await**: Sử dụng async/await cho all I/O operations
7. **Dependency Injection**: Inject dependencies thông qua constructor
8. **Testing**: Easy to unit test với mocked dependencies

## 🧪 Testing Examples

```typescript
describe('CreateUserUseCase', () => {
  let useCase: CreateUserUseCase;
  let userRepository: jest.Mocked<UserRepository>;
  let emailService: jest.Mocked<EmailService>;

  beforeEach(() => {
    userRepository = {
      findByEmail: jest.fn(),
      save: jest.fn(),
    } as any;

    emailService = {
      sendWelcomeEmail: jest.fn(),
    } as any;

    useCase = new CreateUserUseCase(userRepository, emailService, logger);
  });

  it('should create user successfully', async () => {
    // Arrange
    userRepository.findByEmail.mockResolvedValue(null);
    userRepository.save.mockResolvedValue();
    emailService.sendWelcomeEmail.mockResolvedValue();

    const request = new CreateUserRequest('test@example.com', 'John', 'Doe');

    // Act
    const result = await useCase.execute(request);

    // Assert
    expect(result.email).toBe('test@example.com');
    expect(userRepository.save).toHaveBeenCalled();
    expect(emailService.sendWelcomeEmail).toHaveBeenCalled();
  });

  it('should throw error if user already exists', async () => {
    // Arrange
    const existingUser = new User('123', 'test@example.com', 'Jane', 'Doe');
    userRepository.findByEmail.mockResolvedValue(existingUser);

    const request = new CreateUserRequest('test@example.com', 'John', 'Doe');

    // Act & Assert
    await expect(useCase.execute(request)).rejects.toThrow(
      'User already exists',
    );
  });
});
```

## 📚 Tài liệu tham khảo

- [Clean Architecture - Application Layer](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Use Case Driven Development](https://www.ibm.com/docs/en/rational-soft-arch/9.5?topic=development-use-case-driven)
- [CQRS Pattern](https://docs.microsoft.com/en-us/azure/architecture/patterns/cqrs)
