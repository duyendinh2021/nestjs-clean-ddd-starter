# 🧩 Common Layer

## 📝 Mục đích

Common Layer chứa **shared utilities**, **cross-cutting concerns** và **reusable components** được sử dụng bởi tất cả các layers khác. Layer này giúp tránh code duplication và tạo consistency across the application.

## 📂 Cấu trúc thư mục

```
common/
├── decorators/       # Custom decorators
├── guards/          # Shared guards
├── interceptors/    # Shared interceptors
├── filters/         # Exception filters
├── pipes/           # Validation và transformation pipes
├── constants/       # Application constants
├── utils/           # Utility functions
└── index.ts         # Export tất cả common components
```

## 🎯 Nguyên tắc

### ✅ Common Layer được phép:

- Chứa reusable utilities và helpers
- Define constants và enums
- Create custom decorators
- Implement shared guards, interceptors, filters
- Provide utility functions
- Cross-cutting concerns (logging, caching, etc.)

### ❌ Common Layer KHÔNG được phép:

- Chứa business logic specific
- Depend on specific domains
- Include framework-specific implementations
- Direct database access

## 📋 Code Convention

### Decorators

```typescript
// ✅ Good: Reusable custom decorators
import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { SetMetadata } from '@nestjs/common';

// Current User Decorator
export const CurrentUser = createParamDecorator(
  (data: unknown, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest();
    return request.user;
  },
);

// Roles Decorator
export const Roles = (...roles: string[]) => SetMetadata('roles', roles);

// Public Route Decorator
export const Public = () => SetMetadata('isPublic', true);

// API Key Required Decorator
export const ApiKeyRequired = () => SetMetadata('apiKeyRequired', true);

// Rate Limit Decorator
export const RateLimit = (limit: number, windowMs: number) =>
  SetMetadata('rateLimit', { limit, windowMs });

// Cache Decorator
export const Cache = (ttl: number = 300) => SetMetadata('cache', { ttl });

// Usage Examples:
/*
@Get('profile')
@Roles('admin', 'user')
async getProfile(@CurrentUser() user: UserContext) {
  return user;
}

@Post('login')
@Public()
async login(@Body() dto: LoginDto) {
  // Login logic
}

@Get('data')
@Cache(600) // Cache for 10 minutes
async getData() {
  // Data fetching logic
}
*/
```

### Constants

```typescript
// ✅ Good: Well-organized constants
export const API_CONSTANTS = {
  VERSION: 'v1',
  PREFIX: 'api',
  DEFAULT_PAGE_SIZE: 10,
  MAX_PAGE_SIZE: 100,
  DEFAULT_TIMEOUT: 30000,
} as const;

export const HTTP_STATUS_MESSAGES = {
  [HttpStatus.OK]: 'Success',
  [HttpStatus.CREATED]: 'Resource created successfully',
  [HttpStatus.BAD_REQUEST]: 'Invalid request data',
  [HttpStatus.UNAUTHORIZED]: 'Authentication required',
  [HttpStatus.FORBIDDEN]: 'Access denied',
  [HttpStatus.NOT_FOUND]: 'Resource not found',
  [HttpStatus.CONFLICT]: 'Resource already exists',
  [HttpStatus.INTERNAL_SERVER_ERROR]: 'Internal server error',
} as const;

export const VALIDATION_MESSAGES = {
  REQUIRED: 'This field is required',
  INVALID_EMAIL: 'Please provide a valid email address',
  INVALID_PASSWORD: 'Password must be at least 8 characters long',
  INVALID_UUID: 'Please provide a valid UUID',
  INVALID_DATE: 'Please provide a valid date',
  INVALID_PHONE: 'Please provide a valid phone number',
} as const;

export const CACHE_KEYS = {
  USER_PROFILE: (userId: string) => `user:profile:${userId}`,
  USER_PERMISSIONS: (userId: string) => `user:permissions:${userId}`,
  PRODUCT_DETAILS: (productId: string) => `product:details:${productId}`,
  CATEGORY_LIST: 'categories:list',
} as const;

export const EVENT_NAMES = {
  USER_CREATED: 'user.created',
  USER_UPDATED: 'user.updated',
  USER_DELETED: 'user.deleted',
  ORDER_PLACED: 'order.placed',
  ORDER_COMPLETED: 'order.completed',
  PAYMENT_PROCESSED: 'payment.processed',
} as const;

// Enums
export enum UserRole {
  ADMIN = 'admin',
  USER = 'user',
  MODERATOR = 'moderator',
}

export enum OrderStatus {
  PENDING = 'pending',
  CONFIRMED = 'confirmed',
  PROCESSING = 'processing',
  SHIPPED = 'shipped',
  DELIVERED = 'delivered',
  CANCELLED = 'cancelled',
}

export enum PaymentStatus {
  PENDING = 'pending',
  COMPLETED = 'completed',
  FAILED = 'failed',
  REFUNDED = 'refunded',
}
```

### Utils

```typescript
// ✅ Good: Reusable utility functions
import { v4 as uuidv4 } from 'uuid';
import * as bcrypt from 'bcrypt';
import { BadRequestException } from '@nestjs/common';

export class StringUtils {
  static slugify(text: string): string {
    return text
      .toString()
      .toLowerCase()
      .trim()
      .replace(/\s+/g, '-')
      .replace(/[^\w\-]+/g, '')
      .replace(/\-\-+/g, '-')
      .replace(/^-+/, '')
      .replace(/-+$/, '');
  }

  static capitalize(text: string): string {
    return text.charAt(0).toUpperCase() + text.slice(1).toLowerCase();
  }

  static truncate(text: string, maxLength: number): string {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength - 3) + '...';
  }

  static generateRandomString(length: number): string {
    const chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let result = '';
    for (let i = 0; i < length; i++) {
      result += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return result;
  }
}

export class DateUtils {
  static formatDate(date: Date, format: string = 'YYYY-MM-DD'): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');

    return format
      .replace('YYYY', year.toString())
      .replace('MM', month)
      .replace('DD', day);
  }

  static addDays(date: Date, days: number): Date {
    const result = new Date(date);
    result.setDate(result.getDate() + days);
    return result;
  }

  static isExpired(date: Date): boolean {
    return new Date() > date;
  }

  static daysBetween(date1: Date, date2: Date): number {
    const timeDiff = Math.abs(date2.getTime() - date1.getTime());
    return Math.ceil(timeDiff / (1000 * 3600 * 24));
  }
}

export class ValidationUtils {
  static isValidEmail(email: string): boolean {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }

  static isValidUUID(uuid: string): boolean {
    const uuidRegex =
      /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
    return uuidRegex.test(uuid);
  }

  static isValidPhoneNumber(phone: string): boolean {
    const phoneRegex = /^\+?[\d\s\-\(\)]{10,}$/;
    return phoneRegex.test(phone);
  }

  static validatePassword(password: string): void {
    if (password.length < 8) {
      throw new BadRequestException(
        'Password must be at least 8 characters long',
      );
    }
    if (!/(?=.*[a-z])/.test(password)) {
      throw new BadRequestException(
        'Password must contain at least one lowercase letter',
      );
    }
    if (!/(?=.*[A-Z])/.test(password)) {
      throw new BadRequestException(
        'Password must contain at least one uppercase letter',
      );
    }
    if (!/(?=.*\d)/.test(password)) {
      throw new BadRequestException(
        'Password must contain at least one number',
      );
    }
  }
}

export class CryptoUtils {
  static generateUUID(): string {
    return uuidv4();
  }

  static async hashPassword(password: string): Promise<string> {
    const saltRounds = 12;
    return bcrypt.hash(password, saltRounds);
  }

  static async comparePassword(
    password: string,
    hash: string,
  ): Promise<boolean> {
    return bcrypt.compare(password, hash);
  }

  static generateRandomToken(length: number = 32): string {
    return StringUtils.generateRandomString(length);
  }
}

export class ArrayUtils {
  static chunk<T>(array: T[], size: number): T[][] {
    const chunks: T[][] = [];
    for (let i = 0; i < array.length; i += size) {
      chunks.push(array.slice(i, i + size));
    }
    return chunks;
  }

  static unique<T>(array: T[]): T[] {
    return [...new Set(array)];
  }

  static groupBy<T, K extends keyof any>(
    array: T[],
    key: (item: T) => K,
  ): Record<K, T[]> {
    return array.reduce(
      (groups, item) => {
        const group = key(item);
        groups[group] = groups[group] || [];
        groups[group].push(item);
        return groups;
      },
      {} as Record<K, T[]>,
    );
  }
}
```

### Pipes

```typescript
// ✅ Good: Reusable validation pipes
import {
  PipeTransform,
  Injectable,
  ArgumentMetadata,
  BadRequestException,
} from '@nestjs/common';
import { validate } from 'class-validator';
import { plainToClass } from 'class-transformer';

@Injectable()
export class ValidationPipe implements PipeTransform<any> {
  async transform(value: any, { metatype }: ArgumentMetadata) {
    if (!metatype || !this.toValidate(metatype)) {
      return value;
    }

    const object = plainToClass(metatype, value);
    const errors = await validate(object);

    if (errors.length > 0) {
      const messages = errors.map(error => {
        return Object.values(error.constraints || {}).join(', ');
      });
      throw new BadRequestException(
        `Validation failed: ${messages.join('; ')}`,
      );
    }

    return object;
  }

  private toValidate(metatype: Function): boolean {
    const types: Function[] = [String, Boolean, Number, Array, Object];
    return !types.includes(metatype);
  }
}

// UUID Validation Pipe
@Injectable()
export class ParseUUIDPipe implements PipeTransform<string, string> {
  transform(value: string): string {
    if (!ValidationUtils.isValidUUID(value)) {
      throw new BadRequestException(`${value} is not a valid UUID`);
    }
    return value;
  }
}

// Integer Parse Pipe
@Injectable()
export class ParseIntPipe implements PipeTransform<string, number> {
  transform(value: string): number {
    const parsed = parseInt(value, 10);
    if (isNaN(parsed)) {
      throw new BadRequestException(`${value} is not a valid integer`);
    }
    return parsed;
  }
}

// Optional Parse Pipe
@Injectable()
export class OptionalParsePipe implements PipeTransform {
  constructor(private readonly pipe: PipeTransform) {}

  transform(value: any, metadata: ArgumentMetadata) {
    if (value === undefined || value === null || value === '') {
      return undefined;
    }
    return this.pipe.transform(value, metadata);
  }
}
```

### Interceptors

```typescript
// ✅ Good: Shared interceptors
import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
  Logger,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { tap, map } from 'rxjs/operators';

// Logging Interceptor
@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  private readonly logger = new Logger(LoggingInterceptor.name);

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const request = context.switchToHttp().getRequest();
    const { method, url, body, params, query } = request;
    const now = Date.now();

    this.logger.log(`Incoming Request: ${method} ${url}`);
    this.logger.debug(
      `Request Details: ${JSON.stringify({ body, params, query })}`,
    );

    return next.handle().pipe(
      tap(() => {
        const responseTime = Date.now() - now;
        this.logger.log(
          `Request Completed: ${method} ${url} - ${responseTime}ms`,
        );
      }),
    );
  }
}

// Transform Response Interceptor
@Injectable()
export class TransformInterceptor<T> implements NestInterceptor<T, any> {
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    return next.handle().pipe(
      map(data => ({
        success: true,
        timestamp: new Date().toISOString(),
        path: context.switchToHttp().getRequest().url,
        data,
      })),
    );
  }
}

// Cache Interceptor
@Injectable()
export class CacheInterceptor implements NestInterceptor {
  constructor(private readonly cacheService: CacheService) {}

  async intercept(
    context: ExecutionContext,
    next: CallHandler,
  ): Promise<Observable<any>> {
    const request = context.switchToHttp().getRequest();
    const cacheKey = this.generateCacheKey(request);

    // Only cache GET requests
    if (request.method !== 'GET') {
      return next.handle();
    }

    const cachedResponse = await this.cacheService.get(cacheKey);
    if (cachedResponse) {
      return new Observable(observer => {
        observer.next(cachedResponse);
        observer.complete();
      });
    }

    return next.handle().pipe(
      tap(async response => {
        const ttl = this.extractTTLFromMetadata(context);
        await this.cacheService.set(cacheKey, response, ttl);
      }),
    );
  }

  private generateCacheKey(request: any): string {
    const { method, url, query } = request;
    return `${method}:${url}:${JSON.stringify(query)}`;
  }

  private extractTTLFromMetadata(context: ExecutionContext): number {
    const cacheMetadata = Reflect.getMetadata('cache', context.getHandler());
    return cacheMetadata?.ttl || 300; // Default 5 minutes
  }
}
```

### Filters

```typescript
// ✅ Good: Shared exception filters
import {
  ExceptionFilter,
  Catch,
  ArgumentsHost,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';

@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  private readonly logger = new Logger(AllExceptionsFilter.name);

  catch(exception: unknown, host: ArgumentsHost): void {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse();
    const request = ctx.getRequest();

    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let message = 'Internal server error';

    if (exception instanceof HttpException) {
      status = exception.getStatus();
      const responseBody = exception.getResponse();
      message =
        typeof responseBody === 'string'
          ? responseBody
          : (responseBody as any).message;
    }

    const errorResponse = {
      success: false,
      statusCode: status,
      timestamp: new Date().toISOString(),
      path: request.url,
      method: request.method,
      message: Array.isArray(message) ? message : [message],
    };

    this.logger.error(
      `${request.method} ${request.url} - ${status} - ${JSON.stringify(message)}`,
      exception instanceof Error ? exception.stack : undefined,
    );

    response.status(status).json(errorResponse);
  }
}

// Validation Exception Filter
@Catch(HttpException)
export class ValidationExceptionFilter implements ExceptionFilter {
  catch(exception: HttpException, host: ArgumentsHost): void {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse();
    const status = exception.getStatus();

    if (status === HttpStatus.BAD_REQUEST) {
      const responseBody = exception.getResponse() as any;

      response.status(status).json({
        success: false,
        statusCode: status,
        message: 'Validation failed',
        errors: Array.isArray(responseBody.message)
          ? responseBody.message
          : [responseBody.message],
        timestamp: new Date().toISOString(),
      });
    } else {
      response.status(status).json(exception.getResponse());
    }
  }
}
```

## 🚀 Best Practices

1. **Reusability**: Design components để reuse across layers
2. **Single Responsibility**: Mỗi utility function có một purpose
3. **Type Safety**: Sử dụng TypeScript types và generics
4. **Error Handling**: Provide meaningful error messages
5. **Documentation**: Document complex utility functions
6. **Testing**: Unit test all utility functions
7. **Performance**: Optimize frequently used utilities
8. **Constants**: Use constants thay vì magic numbers/strings
9. **Validation**: Centralize validation logic
10. **Logging**: Consistent logging format

## 🧪 Testing Examples

```typescript
describe('StringUtils', () => {
  describe('slugify', () => {
    it('should convert text to slug', () => {
      expect(StringUtils.slugify('Hello World')).toBe('hello-world');
      expect(StringUtils.slugify('Special!@#$%Characters')).toBe(
        'specialcharacters',
      );
      expect(StringUtils.slugify('  Multiple   Spaces  ')).toBe(
        'multiple-spaces',
      );
    });
  });

  describe('capitalize', () => {
    it('should capitalize first letter', () => {
      expect(StringUtils.capitalize('hello')).toBe('Hello');
      expect(StringUtils.capitalize('WORLD')).toBe('World');
    });
  });
});

describe('ValidationUtils', () => {
  describe('isValidEmail', () => {
    it('should validate email addresses', () => {
      expect(ValidationUtils.isValidEmail('test@example.com')).toBe(true);
      expect(ValidationUtils.isValidEmail('invalid.email')).toBe(false);
      expect(ValidationUtils.isValidEmail('test@')).toBe(false);
    });
  });
});
```

## 📚 Tài liệu tham khảo

- [NestJS Custom Decorators](https://docs.nestjs.com/custom-decorators)
- [NestJS Pipes](https://docs.nestjs.com/pipes)
- [NestJS Interceptors](https://docs.nestjs.com/interceptors)
- [Class Validator](https://github.com/typestack/class-validator)
- [Class Transformer](https://github.com/typestack/class-transformer)
