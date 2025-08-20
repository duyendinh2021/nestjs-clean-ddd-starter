# Hướng dẫn sử dụng Clean Architecture + DDD

## 🚀 Cách sử dụng cấu trúc mới

### 1. Tạo một Entity mới

```typescript
// src/domain/entities/product.entity.ts
export class Product {
  constructor(
    public readonly id: string,
    public readonly name: string,
    public readonly price: number,
    public readonly category: string,
  ) {}

  public applyDiscount(discountPercent: number): Product {
    if (discountPercent < 0 || discountPercent > 100) {
      throw new Error('Invalid discount percentage');
    }

    const newPrice = this.price * (1 - discountPercent / 100);
    return new Product(this.id, this.name, newPrice, this.category);
  }
}
```

### 2. Tạo Repository Interface

```typescript
// src/domain/repositories/product.repository.ts
import { Product } from '../entities/product.entity';

export interface ProductRepository {
  findById(id: string): Promise<Product | null>;
  findByCategory(category: string): Promise<Product[]>;
  save(product: Product): Promise<void>;
  delete(id: string): Promise<void>;
}
```

### 3. Tạo Use Case

```typescript
// src/application/use-cases/get-product-by-id.use-case.ts
import { Injectable } from '@nestjs/common';
import { UseCase } from '../interfaces/use-case.interface';
import { ProductRepository } from '../../domain/repositories/product.repository';
import { Product } from '../../domain/entities/product.entity';

@Injectable()
export class GetProductByIdUseCase implements UseCase<string, Product> {
  constructor(private readonly productRepository: ProductRepository) {}

  async execute(productId: string): Promise<Product> {
    const product = await this.productRepository.findById(productId);

    if (!product) {
      throw new Error('Product not found');
    }

    return product;
  }
}
```

### 4. Implement Repository trong Infrastructure

```typescript
// src/infrastructure/repositories/product.repository.impl.ts
import { Injectable } from '@nestjs/common';
import { ProductRepository } from '../../domain/repositories/product.repository';
import { Product } from '../../domain/entities/product.entity';

@Injectable()
export class ProductRepositoryImpl implements ProductRepository {
  private products: Product[] = []; // In-memory store for demo

  async findById(id: string): Promise<Product | null> {
    return this.products.find(p => p.id === id) || null;
  }

  async findByCategory(category: string): Promise<Product[]> {
    return this.products.filter(p => p.category === category);
  }

  async save(product: Product): Promise<void> {
    const index = this.products.findIndex(p => p.id === product.id);
    if (index >= 0) {
      this.products[index] = product;
    } else {
      this.products.push(product);
    }
  }

  async delete(id: string): Promise<void> {
    this.products = this.products.filter(p => p.id !== id);
  }
}
```

### 5. Tạo Controller

```typescript
// src/presentation/controllers/product.controller.ts
import { Controller, Get, Param } from '@nestjs/common';
import { GetProductByIdUseCase } from '../../application/use-cases/get-product-by-id.use-case';

@Controller('products')
export class ProductController {
  constructor(private readonly getProductByIdUseCase: GetProductByIdUseCase) {}

  @Get(':id')
  async getProduct(@Param('id') id: string) {
    return await this.getProductByIdUseCase.execute(id);
  }
}
```

### 6. Cấu hình Module

```typescript
// src/modules/product.module.ts
import { Module } from '@nestjs/common';
import { ProductController } from '../presentation/controllers/product.controller';
import { GetProductByIdUseCase } from '../application/use-cases/get-product-by-id.use-case';
import { ProductRepositoryImpl } from '../infrastructure/repositories/product.repository.impl';
import { ProductRepository } from '../domain/repositories/product.repository';

@Module({
  controllers: [ProductController],
  providers: [
    GetProductByIdUseCase,
    {
      provide: ProductRepository,
      useClass: ProductRepositoryImpl,
    },
  ],
})
export class ProductModule {}
```

## 📚 Nguyên tắc cần tuân thủ

### ✅ DO (Nên làm):

- Đặt business logic trong Domain layer
- Sử dụng interfaces để define dependencies
- Inject dependencies qua constructor
- Validate input trong Use Cases
- Sử dụng Value Objects cho complex data types
- Tạo domain events cho side effects

### ❌ DON'T (Không nên):

- Import infrastructure code vào domain layer
- Đặt business logic trong controllers
- Trực tiếp access database từ controllers
- Hardcode dependencies
- Mix presentation logic với business logic

## 🔧 Testing Strategy

### Unit Tests:

- Test Domain entities và services riêng biệt
- Mock dependencies trong Use Cases
- Test business rules isolation

### Integration Tests:

- Test full flow từ controller đến repository
- Sử dụng test database
- Test các scenarios thực tế

### Example Unit Test:

```typescript
// tests/domain/entities/product.entity.spec.ts
describe('Product Entity', () => {
  it('should apply discount correctly', () => {
    const product = new Product('1', 'Test Product', 100, 'Electronics');
    const discountedProduct = product.applyDiscount(20);

    expect(discountedProduct.price).toBe(80);
  });

  it('should throw error for invalid discount', () => {
    const product = new Product('1', 'Test Product', 100, 'Electronics');

    expect(() => product.applyDiscount(-10)).toThrow(
      'Invalid discount percentage',
    );
  });
});
```

## 📝 Next Steps

1. **Thêm Database Integration**: Cài đặt TypeORM hoặc Prisma
2. **Authentication & Authorization**: Implement JWT guards
3. **Validation**: Thêm class-validator cho DTOs
4. **Logging**: Implement structured logging
5. **Error Handling**: Global exception filters
6. **Documentation**: Swagger/OpenAPI integration
7. **Testing**: Comprehensive test coverage
