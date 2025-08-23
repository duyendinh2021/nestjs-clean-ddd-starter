# 🔧 Infrastructure Layer

## 📝 Mục đích

Infrastructure Layer chứa **technical details** và **external concerns**. Layer này implement các interfaces được định nghĩa trong Domain và Application layers, cung cấp concrete implementations cho database, external services, frameworks.

## 📂 Cấu trúc thư mục

```
infrastructure/
├── database/             # Database configuration và models
├── repositories/         # Repository implementations
├── external-services/    # External API clients và integrations
├── config/              # Configuration files và settings
└── index.ts             # Export tất cả infrastructure implementations
```

## 🎯 Nguyên tắc

### ✅ Infrastructure Layer được phép:

- Implement repository interfaces từ Domain layer
- Implement service interfaces từ Application layer
- Access databases, file systems, external APIs
- Sử dụng frameworks và third-party libraries
- Handle configuration và environment settings
- Implement caching, messaging, logging

### ❌ Infrastructure Layer KHÔNG được phép:

- Chứa business logic (thuộc Domain layer)
- Chứa application workflows (thuộc Application layer)
- Expose implementation details ra ngoài
- Directly modify domain objects state

## 📋 Code Convention

### Repository Implementations

```typescript
// ✅ Good: Clean repository implementation
@Injectable()
export class TypeOrmUserRepository implements UserRepository {
  constructor(
    @InjectRepository(UserEntity)
    private readonly userEntityRepository: Repository<UserEntity>,
    private readonly mapper: UserMapper,
  ) {}

  async findById(id: string): Promise<User | null> {
    const userEntity = await this.userEntityRepository.findOne({
      where: { id },
      relations: ['profile', 'roles'],
    });

    return userEntity ? this.mapper.toDomain(userEntity) : null;
  }

  async findByEmail(email: string): Promise<User | null> {
    const userEntity = await this.userEntityRepository.findOne({
      where: { email },
      relations: ['profile', 'roles'],
    });

    return userEntity ? this.mapper.toDomain(userEntity) : null;
  }

  async findActiveUsers(): Promise<User[]> {
    const userEntities = await this.userEntityRepository.find({
      where: { isActive: true },
      relations: ['profile', 'roles'],
    });

    return userEntities.map(entity => this.mapper.toDomain(entity));
  }

  async save(user: User): Promise<void> {
    const userEntity = this.mapper.toEntity(user);
    await this.userEntityRepository.save(userEntity);
  }

  async delete(id: string): Promise<void> {
    await this.userEntityRepository.delete(id);
  }

  // Domain-specific queries
  async findUsersByRole(role: string): Promise<User[]> {
    const userEntities = await this.userEntityRepository
      .createQueryBuilder('user')
      .innerJoin('user.roles', 'role')
      .where('role.name = :role', { role })
      .getMany();

    return userEntities.map(entity => this.mapper.toDomain(entity));
  }

  async countActiveUsers(): Promise<number> {
    return this.userEntityRepository.count({
      where: { isActive: true },
    });
  }
}

// ❌ Bad: Repository with business logic
@Injectable()
export class BadUserRepository implements UserRepository {
  async save(user: User): Promise<void> {
    // Bad: Business validation in infrastructure
    if (user.age < 18) {
      throw new Error('User must be 18 or older');
    }

    // Bad: Business logic in repository
    user.isActive = true;
    user.lastLoginAt = new Date();

    await this.userEntityRepository.save(user);
  }
}
```

### Database Entities (ORM Models)

```typescript
// ✅ Good: Clean database entity
@Entity('users')
export class UserEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  email: string;

  @Column({ name: 'first_name' })
  firstName: string;

  @Column({ name: 'last_name' })
  lastName: string;

  @Column({ name: 'is_active', default: true })
  isActive: boolean;

  @Column({ name: 'created_at' })
  createdAt: Date;

  @Column({ name: 'updated_at' })
  updatedAt: Date;

  @OneToOne(() => UserProfileEntity, profile => profile.user, { cascade: true })
  profile: UserProfileEntity;

  @ManyToMany(() => RoleEntity, role => role.users)
  @JoinTable({
    name: 'user_roles',
    joinColumn: { name: 'user_id', referencedColumnName: 'id' },
    inverseJoinColumn: { name: 'role_id', referencedColumnName: 'id' },
  })
  roles: RoleEntity[];

  @BeforeInsert()
  setCreatedAt() {
    this.createdAt = new Date();
    this.updatedAt = new Date();
  }

  @BeforeUpdate()
  setUpdatedAt() {
    this.updatedAt = new Date();
  }
}

// ❌ Bad: Entity with business methods
@Entity('users')
export class BadUserEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  // Bad: Business methods in infrastructure entity
  public activate(): void {
    this.isActive = true;
  }

  public calculateAge(): number {
    // Business logic in database entity
    return new Date().getFullYear() - this.dateOfBirth.getFullYear();
  }
}
```

### Mappers (Domain ↔ Infrastructure)

```typescript
// ✅ Good: Clean mapping between domain and infrastructure
@Injectable()
export class UserMapper {
  toDomain(entity: UserEntity): User {
    if (!entity) return null;

    return new User(
      entity.id,
      entity.email,
      entity.firstName,
      entity.lastName,
      entity.isActive,
      entity.createdAt,
    );
  }

  toEntity(domain: User): UserEntity {
    const entity = new UserEntity();
    entity.id = domain.id;
    entity.email = domain.email;
    entity.firstName = domain.firstName;
    entity.lastName = domain.lastName;
    entity.isActive = domain.isActive;
    entity.createdAt = domain.createdAt;
    entity.updatedAt = new Date();
    return entity;
  }

  toDomainList(entities: UserEntity[]): User[] {
    return entities.map(entity => this.toDomain(entity));
  }

  toEntityList(domains: User[]): UserEntity[] {
    return domains.map(domain => this.toEntity(domain));
  }
}
```

### External Service Implementations

```typescript
// ✅ Good: External service implementation
@Injectable()
export class SendGridEmailService implements EmailService {
  private readonly client: MailService;

  constructor(@Inject('EMAIL_CONFIG') private readonly config: EmailConfig) {
    this.client = new MailService();
    this.client.setApiKey(config.apiKey);
  }

  async sendWelcomeEmail(email: string, name: string): Promise<void> {
    const msg = {
      to: email,
      from: this.config.fromEmail,
      subject: 'Welcome to Our Platform!',
      templateId: this.config.welcomeTemplateId,
      dynamicTemplateData: {
        firstName: name,
        platformName: this.config.platformName,
      },
    };

    try {
      await this.client.send(msg);
    } catch (error) {
      throw new Error(`Failed to send welcome email: ${error.message}`);
    }
  }

  async sendPasswordResetEmail(
    email: string,
    resetToken: string,
  ): Promise<void> {
    const resetUrl = `${this.config.frontendUrl}/reset-password?token=${resetToken}`;

    const msg = {
      to: email,
      from: this.config.fromEmail,
      subject: 'Password Reset Request',
      templateId: this.config.passwordResetTemplateId,
      dynamicTemplateData: {
        resetUrl,
        expirationHours: 24,
      },
    };

    try {
      await this.client.send(msg);
    } catch (error) {
      throw new Error(`Failed to send password reset email: ${error.message}`);
    }
  }

  async sendNotificationEmail(
    email: string,
    subject: string,
    content: string,
  ): Promise<void> {
    const msg = {
      to: email,
      from: this.config.fromEmail,
      subject,
      html: content,
    };

    try {
      await this.client.send(msg);
    } catch (error) {
      throw new Error(`Failed to send notification email: ${error.message}`);
    }
  }
}
```

### Configuration

```typescript
// ✅ Good: Configuration management
export interface DatabaseConfig {
  host: string;
  port: number;
  username: string;
  password: string;
  database: string;
  synchronize: boolean;
  logging: boolean;
}

export interface RedisConfig {
  host: string;
  port: number;
  password?: string;
  db: number;
}

export interface EmailConfig {
  apiKey: string;
  fromEmail: string;
  frontendUrl: string;
  platformName: string;
  welcomeTemplateId: string;
  passwordResetTemplateId: string;
}

@Injectable()
export class ConfigService {
  getDatabaseConfig(): DatabaseConfig {
    return {
      host: process.env.DB_HOST || 'localhost',
      port: parseInt(process.env.DB_PORT || '5432'),
      username: process.env.DB_USERNAME || 'postgres',
      password: process.env.DB_PASSWORD || 'password',
      database: process.env.DB_NAME || 'nestjs_app',
      synchronize: process.env.NODE_ENV !== 'production',
      logging: process.env.NODE_ENV === 'development',
    };
  }

  getRedisConfig(): RedisConfig {
    return {
      host: process.env.REDIS_HOST || 'localhost',
      port: parseInt(process.env.REDIS_PORT || '6379'),
      password: process.env.REDIS_PASSWORD,
      db: parseInt(process.env.REDIS_DB || '0'),
    };
  }

  getEmailConfig(): EmailConfig {
    return {
      apiKey: process.env.SENDGRID_API_KEY,
      fromEmail: process.env.FROM_EMAIL || 'noreply@example.com',
      frontendUrl: process.env.FRONTEND_URL || 'http://localhost:3000',
      platformName: process.env.PLATFORM_NAME || 'My Platform',
      welcomeTemplateId: process.env.WELCOME_TEMPLATE_ID,
      passwordResetTemplateId: process.env.PASSWORD_RESET_TEMPLATE_ID,
    };
  }
}
```

### Caching Implementation

```typescript
// ✅ Good: Cache service implementation
@Injectable()
export class RedisCacheService implements CacheService {
  private readonly client: Redis;

  constructor(@Inject('REDIS_CONFIG') private readonly config: RedisConfig) {
    this.client = new Redis({
      host: config.host,
      port: config.port,
      password: config.password,
      db: config.db,
      retryDelayOnFailover: 100,
      maxRetriesPerRequest: 3,
    });
  }

  async get<T>(key: string): Promise<T | null> {
    try {
      const value = await this.client.get(key);
      return value ? JSON.parse(value) : null;
    } catch (error) {
      console.error(`Redis GET error for key ${key}:`, error);
      return null;
    }
  }

  async set<T>(key: string, value: T, ttlSeconds?: number): Promise<void> {
    try {
      const serialized = JSON.stringify(value);
      if (ttlSeconds) {
        await this.client.setex(key, ttlSeconds, serialized);
      } else {
        await this.client.set(key, serialized);
      }
    } catch (error) {
      console.error(`Redis SET error for key ${key}:`, error);
      throw new Error(`Failed to cache value: ${error.message}`);
    }
  }

  async delete(key: string): Promise<void> {
    try {
      await this.client.del(key);
    } catch (error) {
      console.error(`Redis DELETE error for key ${key}:`, error);
    }
  }

  async clear(): Promise<void> {
    try {
      await this.client.flushdb();
    } catch (error) {
      console.error('Redis CLEAR error:', error);
      throw new Error(`Failed to clear cache: ${error.message}`);
    }
  }
}
```

## 🔄 Workflow Examples

### 1. Database Setup với TypeORM

```typescript
// database/database.module.ts
@Module({
  imports: [
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) => ({
        type: 'postgres',
        ...configService.getDatabaseConfig(),
        entities: [UserEntity, RoleEntity, UserProfileEntity],
        migrations: ['dist/migrations/*.js'],
        cli: {
          migrationsDir: 'src/migrations',
        },
      }),
      inject: [ConfigService],
    }),
    TypeOrmModule.forFeature([UserEntity, RoleEntity, UserProfileEntity]),
  ],
  exports: [TypeOrmModule],
})
export class DatabaseModule {}
```

### 2. Repository Module

```typescript
// repositories/repository.module.ts
@Module({
  imports: [DatabaseModule],
  providers: [
    UserMapper,
    {
      provide: 'UserRepository',
      useClass: TypeOrmUserRepository,
    },
    {
      provide: 'RoleRepository',
      useClass: TypeOrmRoleRepository,
    },
  ],
  exports: ['UserRepository', 'RoleRepository'],
})
export class RepositoryModule {}
```

### 3. External Services Module

```typescript
// external-services/external-services.module.ts
@Module({
  imports: [ConfigModule],
  providers: [
    {
      provide: 'EmailService',
      useClass: SendGridEmailService,
    },
    {
      provide: 'CacheService',
      useClass: RedisCacheService,
    },
    {
      provide: 'FileStorageService',
      useClass: S3FileStorageService,
    },
  ],
  exports: ['EmailService', 'CacheService', 'FileStorageService'],
})
export class ExternalServicesModule {}
```

## 🚀 Best Practices

1. **Dependency Inversion**: Implement interfaces từ higher layers
2. **Configuration Management**: Centralize configuration và use environment variables
3. **Error Handling**: Handle infrastructure errors gracefully
4. **Connection Pooling**: Sử dụng connection pooling cho database
5. **Retry Logic**: Implement retry cho external services
6. **Circuit Breaker**: Prevent cascade failures
7. **Monitoring**: Add logging và monitoring cho infrastructure operations
8. **Security**: Secure credentials và sensitive data
9. **Performance**: Optimize database queries và cache frequently accessed data
10. **Testing**: Use integration tests cho infrastructure components

## 🧪 Testing Examples

```typescript
// Integration test for repository
describe('TypeOrmUserRepository', () => {
  let repository: TypeOrmUserRepository;
  let module: TestingModule;

  beforeEach(async () => {
    module = await Test.createTestingModule({
      imports: [
        TypeOrmModule.forRoot({
          type: 'sqlite',
          database: ':memory:',
          entities: [UserEntity],
          synchronize: true,
        }),
        TypeOrmModule.forFeature([UserEntity]),
      ],
      providers: [TypeOrmUserRepository, UserMapper],
    }).compile();

    repository = module.get<TypeOrmUserRepository>(TypeOrmUserRepository);
  });

  afterEach(async () => {
    await module.close();
  });

  it('should save and find user', async () => {
    // Arrange
    const user = new User('123', 'test@example.com', 'John', 'Doe');

    // Act
    await repository.save(user);
    const found = await repository.findById('123');

    // Assert
    expect(found).toBeDefined();
    expect(found.email).toBe('test@example.com');
  });
});
```

## 📚 Tài liệu tham khảo

- [TypeORM Documentation](https://typeorm.io/)
- [NestJS Database Integration](https://docs.nestjs.com/techniques/database)
- [Redis Documentation](https://redis.io/documentation)
- [Infrastructure as Code](https://docs.microsoft.com/en-us/devops/deliver/what-is-infrastructure-as-code)
