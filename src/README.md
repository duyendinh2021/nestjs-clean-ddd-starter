# Clean Architecture + DDD Structure

Cáº¥u trÃºc thÆ° má»¥c nÃ y Ä‘Æ°á»£c tá»• chá»©c theo nguyÃªn táº¯c Clean Architecture vÃ  Domain-Driven Design (DDD):

## ðŸ“ Cáº¥u trÃºc thÆ° má»¥c

```
src/
â”œâ”€â”€ common/                 # Shared utilities vÃ  helpers
â”‚   â”œâ”€â”€ decorators/        # Custom decorators
â”‚   â”œâ”€â”€ guards/           # Authentication vÃ  authorization guards
â”‚   â”œâ”€â”€ interceptors/     # Request/Response interceptors
â”‚   â”œâ”€â”€ filters/          # Exception filters
â”‚   â”œâ”€â”€ pipes/            # Validation pipes
â”‚   â”œâ”€â”€ constants/        # Application constants
â”‚   â””â”€â”€ utils/            # Utility functions
â”œâ”€â”€ domain/                # Domain Layer (Business Rules)
â”‚   â”œâ”€â”€ entities/         # Domain entities
â”‚   â”œâ”€â”€ value-objects/    # Value objects
â”‚   â”œâ”€â”€ repositories/     # Repository interfaces
â”‚   â”œâ”€â”€ services/         # Domain services
â”‚   â””â”€â”€ events/           # Domain events
â”œâ”€â”€ application/           # Application Layer (Use Cases)
â”‚   â”œâ”€â”€ use-cases/        # Application use cases
â”‚   â”œâ”€â”€ dtos/             # Data transfer objects
â”‚   â”œâ”€â”€ interfaces/       # Application interfaces
â”‚   â””â”€â”€ services/         # Application services
â”œâ”€â”€ infrastructure/        # Infrastructure Layer (External Concerns)
â”‚   â”œâ”€â”€ database/         # Database configuration vÃ  models
â”‚   â”œâ”€â”€ repositories/     # Repository implementations
â”‚   â”œâ”€â”€ external-services/# External API clients
â”‚   â””â”€â”€ config/           # Configuration files
â”œâ”€â”€ presentation/          # Presentation Layer (Controllers)
â”‚   â”œâ”€â”€ controllers/      # HTTP controllers
â”‚   â”œâ”€â”€ middlewares/      # Express middlewares
â”‚   â””â”€â”€ dto/              # Request/Response DTOs
â””â”€â”€ main.ts               # Application entry point
```

## ðŸ—ï¸ NguyÃªn táº¯c Clean Architecture

### 1. **Domain Layer** (Innermost)
- Chá»©a business logic core
- KhÃ´ng phá»¥ thuá»™c vÃ o layer nÃ o khÃ¡c
- Äá»‹nh nghÄ©a entities, value objects, domain services

### 2. **Application Layer**
- Chá»©a use cases vÃ  application logic
- Phá»¥ thuá»™c vÃ o Domain layer
- Orchestrates domain objects Ä‘á»ƒ thá»±c hiá»‡n business workflows

### 3. **Infrastructure Layer**
- Implements interfaces tá»« Domain vÃ  Application layers
- Chá»©a database, external services, frameworks

### 4. **Presentation Layer** (Outermost)
- Handles HTTP requests/responses
- Phá»¥ thuá»™c vÃ o Application layer
- Controllers, middlewares, DTOs

## ðŸŽ¯ Lá»£i Ã­ch

- **Separation of Concerns**: Má»—i layer cÃ³ trÃ¡ch nhiá»‡m riÃªng biá»‡t
- **Testability**: Dá»… dÃ ng unit test tá»«ng layer
- **Maintainability**: Code dá»… maintain vÃ  extend
- **Independence**: Domain logic khÃ´ng phá»¥ thuá»™c vÃ o frameworks
- **Flexibility**: Dá»… dÃ ng thay Ä‘á»•i database hoáº·c external services

## ðŸ“ VÃ­ dá»¥ Flow

1. **Request** â†’ Presentation Layer (Controller)
2. **Controller** â†’ Application Layer (Use Case)
3. **Use Case** â†’ Domain Layer (Entity/Service)
4. **Domain** â†’ Infrastructure Layer (Repository)
5. **Response** â† Tráº£ vá» qua cÃ¡c layers
