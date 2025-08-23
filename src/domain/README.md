# 🏛️ Domain Layer

## 📝 Mục đích
Domain Layer là **lõi của ứng dụng**, chứa toàn bộ business logic và business rules. Layer này hoàn toàn độc lập và không phụ thuộc vào bất kỳ layer nào khác.

## 📂 Cấu trúc thư mục

```
domain/
├── entities/           # Domain entities với business logic
├── value-objects/      # Immutable objects định nghĩa bằng attributes
├── repositories/       # Repository interfaces (contracts)
├── services/          # Domain services cho complex business logic
├── events/            # Domain events
└── index.ts           # Export tất cả domain objects
```

## 🎯 Nguyên tắc

### ✅ Domain Layer được phép:
- Định nghĩa business rules và logic
- Chứa entities với identity và behavior
- Tạo value objects immutable
- Định nghĩa repository interfaces
- Phát sinh domain events
- Sử dụng domain services cho complex logic

### ❌ Domain Layer KHÔNG được phép:
- Import từ Application, Infrastructure, hoặc Presentation layers
- Phụ thuộc vào frameworks (NestJS, Express, etc.)
- Trực tiếp access database hoặc external services
- Chứa HTTP, database, hoặc infrastructure code

## 📋 Code Convention

### Entities
```typescript
// ✅ Good: Rich domain model with behavior
export class User extends BaseEntity {
  constructor(
    id: string,
    private _email: string,
    private _firstName: string,
    private _lastName: string,
    private _isActive: boolean = true,
  ) {
    super(id);
    this.validateEmail(_email);
  }

  // Business logic methods
  public activate(): void {
    if (this._isActive) {
      throw new Error('User is already active');
    }
    this._isActive = true;
    this.addDomainEvent(new UserActivatedEvent(this.id));
  }

  public deactivate(): void {
    if (!this._isActive) {
      throw new Error('User is already inactive');
    }
    this._isActive = false;
    this.addDomainEvent(new UserDeactivatedEvent(this.id));
  }

  public changeEmail(newEmail: string): void {
    this.validateEmail(newEmail);
    const oldEmail = this._email;
    this._email = newEmail;
    this.addDomainEvent(new UserEmailChangedEvent(this.id, oldEmail, newEmail));
  }

  // Getters
  public get email(): string { return this._email; }
  public get fullName(): string { return `${this._firstName} ${this._lastName}`; }
  public get isActive(): boolean { return this._isActive; }

  // Private validation
  private validateEmail(email: string): void {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      throw new Error('Invalid email format');
    }
  }
}

// ❌ Bad: Anemic domain model
export class User {
  public id: string;
  public email: string;
  public firstName: string;
  public lastName: string;
  public isActive: boolean;
  // No behavior, just data container
}
```

### Value Objects
```typescript
// ✅ Good: Immutable value object with validation
export class Money extends BaseValueObject {
  constructor(
    private readonly _amount: number,
    private readonly _currency: string,
  ) {
    super();
    this.validateAmount(_amount);
    this.validateCurrency(_currency);
  }

  public get amount(): number { return this._amount; }
  public get currency(): string { return this._currency; }

  public add(other: Money): Money {
    if (this._currency !== other._currency) {
      throw new Error('Cannot add different currencies');
    }
    return new Money(this._amount + other._amount, this._currency);
  }

  public multiply(factor: number): Money {
    return new Money(this._amount * factor, this._currency);
  }

  protected getEqualityComponents(): any[] {
    return [this._amount, this._currency];
  }

  private validateAmount(amount: number): void {
    if (amount < 0) {
      throw new Error('Amount cannot be negative');
    }
  }

  private validateCurrency(currency: string): void {
    const validCurrencies = ['USD', 'EUR', 'VND'];
    if (!validCurrencies.includes(currency)) {
      throw new Error(`Invalid currency: ${currency}`);
    }
  }
}
```

### Repository Interfaces
```typescript
// ✅ Good: Focus on domain needs, not implementation
export interface UserRepository {
  findById(id: string): Promise<User | null>;
  findByEmail(email: string): Promise<User | null>;
  findActiveUsers(): Promise<User[]>;
  save(user: User): Promise<void>;
  delete(id: string): Promise<void>;
  
  // Domain-specific queries
  findUsersByRole(role: string): Promise<User[]>;
  countActiveUsers(): Promise<number>;
}

// ❌ Bad: Implementation-specific methods
export interface UserRepository {
  findBySQL(sql: string): Promise<User[]>;
  findByQuery(query: any): Promise<User[]>;
  executeRawQuery(query: string): Promise<any>;
}
```

### Domain Services
```typescript
// ✅ Good: Complex business logic that doesn't belong to single entity
@Injectable()
export class UserDomainService {
  constructor(private readonly userRepository: UserRepository) {}

  public async canUserAccess(userId: string, resourceId: string): Promise<boolean> {
    const user = await this.userRepository.findById(userId);
    if (!user || !user.isActive) {
      return false;
    }

    // Complex business rules for access control
    return this.evaluateAccessRules(user, resourceId);
  }

  public async calculateUserScore(userId: string): Promise<number> {
    const user = await this.userRepository.findById(userId);
    if (!user) {
      throw new Error('User not found');
    }

    // Complex scoring algorithm
    return this.calculateScore(user);
  }

  private evaluateAccessRules(user: User, resourceId: string): boolean {
    // Complex business logic here
    return true;
  }

  private calculateScore(user: User): number {
    // Complex calculation here
    return 100;
  }
}
```

### Domain Events
```typescript
// ✅ Good: Domain event with relevant data
export class UserActivatedEvent implements DomainEvent {
  public readonly occurredOn: Date;

  constructor(
    public readonly userId: string,
    public readonly activatedBy?: string,
  ) {
    this.occurredOn = new Date();
  }

  public get eventName(): string {
    return 'UserActivated';
  }
}
```

## 🔄 Workflow Example

### 1. Tạo Entity mới
```typescript
// 1. Extend BaseEntity
export class Order extends BaseEntity {
  constructor(
    id: string,
    private _customerId: string,
    private _items: OrderItem[],
    private _status: OrderStatus = OrderStatus.PENDING,
  ) {
    super(id);
    this.validateOrder();
  }

  // 2. Thêm business methods
  public addItem(item: OrderItem): void {
    this._items.push(item);
    this.calculateTotal();
  }

  public confirm(): void {
    if (this._status !== OrderStatus.PENDING) {
      throw new Error('Only pending orders can be confirmed');
    }
    this._status = OrderStatus.CONFIRMED;
    this.addDomainEvent(new OrderConfirmedEvent(this.id));
  }

  // 3. Private validation và calculation
  private validateOrder(): void {
    if (!this._customerId) {
      throw new Error('Customer ID is required');
    }
  }
}
```

### 2. Tạo Repository Interface
```typescript
export interface OrderRepository {
  findById(id: string): Promise<Order | null>;
  findByCustomerId(customerId: string): Promise<Order[]>;
  findPendingOrders(): Promise<Order[]>;
  save(order: Order): Promise<void>;
  delete(id: string): Promise<void>;
}
```

### 3. Sử dụng trong Domain Service
```typescript
export class OrderDomainService {
  constructor(private readonly orderRepository: OrderRepository) {}

  public async canCancelOrder(orderId: string): Promise<boolean> {
    const order = await this.orderRepository.findById(orderId);
    return order?.canBeCancelled() ?? false;
  }
}
```

## 🚀 Best Practices

1. **Rich Domain Models**: Entities should contain behavior, not just data
2. **Immutable Value Objects**: Use value objects cho data without identity
3. **Domain Events**: Use events để communicate changes
4. **Validation**: Always validate trong domain objects
5. **Encapsulation**: Sử dụng private fields và public methods
6. **No Primitives**: Avoid primitive obsession, use value objects
7. **Single Responsibility**: Mỗi domain object có một responsibility
8. **Domain Language**: Sử dụng ubiquitous language của business

## 📚 Tài liệu tham khảo

- [Domain-Driven Design - Eric Evans](https://domainlanguage.com/ddd/)
- [Implementing Domain-Driven Design - Vaughn Vernon](https://vaughnvernon.co/)
- [Clean Architecture - Robert Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
