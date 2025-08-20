# Clean Architecture + DDD Structure

Cấu trúc thư mục này được tổ chức theo nguyên tắc Clean Architecture và Domain-Driven Design (DDD):

## 📁 Cấu trúc thư mục

```
src/
├── common/                 # Shared utilities và helpers
│   ├── decorators/        # Custom decorators
│   ├── guards/           # Authentication và authorization guards
│   ├── interceptors/     # Request/Response interceptors
│   ├── filters/          # Exception filters
│   ├── pipes/            # Validation pipes
│   ├── constants/        # Application constants
│   └── utils/            # Utility functions
├── domain/                # Domain Layer (Business Rules)
│   ├── entities/         # Domain entities
│   ├── value-objects/    # Value objects
│   ├── repositories/     # Repository interfaces
│   ├── services/         # Domain services
│   └── events/           # Domain events
├── application/           # Application Layer (Use Cases)
│   ├── use-cases/        # Application use cases
│   ├── dtos/             # Data transfer objects
│   ├── interfaces/       # Application interfaces
│   └── services/         # Application services
├── infrastructure/        # Infrastructure Layer (External Concerns)
│   ├── database/         # Database configuration và models
│   ├── repositories/     # Repository implementations
│   ├── external-services/# External API clients
│   └── config/           # Configuration files
├── presentation/          # Presentation Layer (Controllers)
│   ├── controllers/      # HTTP controllers
│   ├── middlewares/      # Express middlewares
│   └── dto/              # Request/Response DTOs
└── main.ts               # Application entry point
```

## 🏗️ Nguyên tắc Clean Architecture

### 1. **Domain Layer** (Innermost)
- Chứa business logic core
- Không phụ thuộc vào layer nào khác
- Định nghĩa entities, value objects, domain services

### 2. **Application Layer**
- Chứa use cases và application logic
- Phụ thuộc vào Domain layer
- Orchestrates domain objects để thực hiện business workflows

### 3. **Infrastructure Layer**
- Implements interfaces từ Domain và Application layers
- Chứa database, external services, frameworks

### 4. **Presentation Layer** (Outermost)
- Handles HTTP requests/responses
- Phụ thuộc vào Application layer
- Controllers, middlewares, DTOs

## 🎯 Lợi ích

- **Separation of Concerns**: Mỗi layer có trách nhiệm riêng biệt
- **Testability**: Dễ dàng unit test từng layer
- **Maintainability**: Code dễ maintain và extend
- **Independence**: Domain logic không phụ thuộc vào frameworks
- **Flexibility**: Dễ dàng thay đổi database hoặc external services

## 🔄 Ví dụ Flow

1. **Request** → Presentation Layer (Controller)
2. **Controller** → Application Layer (Use Case)
3. **Use Case** → Domain Layer (Entity/Service)
4. **Domain** → Infrastructure Layer (Repository)
5. **Response** ← Trả về qua các layers

## 📋 Dependency Rules

`mermaid
graph TD
    A[Presentation Layer] --> B[Application Layer]
    B --> C[Domain Layer]
    A --> D[Infrastructure Layer]
    B --> D
    D --> C
`

- Các layer bên ngoài có thể phụ thuộc vào các layer bên trong
- Các layer bên trong KHÔNG được phụ thuộc vào các layer bên ngoài
- Domain Layer là independent nhất, không phụ thuộc vào ai

## 🧩 DDD Patterns được sử dụng

### Entities
- Có identity duy nhất
- Có business logic
- Có thể thay đổi state qua thời gian

### Value Objects
- Immutable objects
- Định nghĩa bằng attributes của chúng
- Không có identity

### Repositories
- Interface cho data access
- Encapsulate database operations
- Defined trong Domain, implemented trong Infrastructure

### Use Cases
- Represent application-specific business rules
- Orchestrate entities và repositories
- Input/Output boundaries rõ ràng

### Domain Services
- Business logic không thuộc về entity nào cụ thể
- Stateless operations
- Domain-specific algorithms

## 💡 Best Practices

1. **Dependency Inversion**: Use interfaces, inject dependencies
2. **Single Responsibility**: Mỗi class có một lý do để thay đổi
3. **Open/Closed**: Open for extension, closed for modification
4. **Interface Segregation**: Clients không phụ thuộc vào interfaces không dùng
5. **Liskov Substitution**: Objects có thể thay thế bằng instances của subtypes

## 🔧 NestJS Integration

- **Modules**: Organize features theo DDD bounded contexts
- **Providers**: Implement repositories và services
- **Controllers**: Presentation layer endpoints
- **Guards/Interceptors**: Cross-cutting concerns
- **DTOs**: Data transfer objects cho API

## 📚 Tài liệu tham khảo

- [Clean Architecture - Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Domain-Driven Design - Eric Evans](https://domainlanguage.com/ddd/)
- [NestJS Documentation](https://docs.nestjs.com/)