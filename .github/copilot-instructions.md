# 🧑‍💻 Copilot Instructions for nestjs-clean-ddd-starter

## Big Picture Architecture

- This project implements **Clean Architecture** and **Domain-Driven Design (DDD)** using NestJS and TypeScript.
- The codebase is organized into four main layers:
  - **Domain Layer** (`src/domain/`): Business logic, entities, value objects, repository interfaces, domain events/services. No framework or infrastructure dependencies.
  - **Application Layer** (`src/application/`): Use cases, DTOs, application services, interfaces. Orchestrates domain objects and workflows. No direct database or HTTP logic.
  - **Infrastructure Layer** (`src/infrastructure/`): Implements repository/service interfaces, database models, external API clients, configuration. No business logic.
  - **Presentation Layer** (`src/presentation/`): Controllers, DTOs, middlewares, guards. Handles HTTP requests/responses, validation, authentication, authorization. No business logic or direct DB access.
- **Common Layer** (`src/common/`): Shared utilities, decorators, constants, pipes, interceptors, filters used across all layers.

## Data Flow & Service Boundaries

- Request → Presentation Controller → Application Use Case → Domain Entity/Service → Infrastructure Repository → Response
- Each layer only depends on the layer inside it (Dependency Inversion).
- Example: `UserController` (presentation) calls `CreateUserUseCase` (application), which uses `UserRepository` (domain interface), implemented by `TypeOrmUserRepository` (infrastructure).

## Developer Workflows

- **Build:** `npm run build` (TypeScript compilation)
- **Start:** `npm run start:dev` (development), `npm run start` (production)
- **Test:** `npm run test` (unit), `npm run test:e2e` (end-to-end)
- **Lint/Format:** `npm run lint`, `npm run format`
- **LF Line Endings:** All TypeScript files use LF (see `.editorconfig`, `.gitattributes`).
- **Scripts:** See `scripts/` for line ending conversion tools.

## Project-Specific Conventions

- **Entities**: Rich domain models with behavior, not just data containers. See `src/domain/entities/`.
- **Value Objects**: Immutable, validated, used for complex types. See `src/domain/value-objects/`.
- **Use Cases**: One class per business workflow, single responsibility. See `src/application/use-cases/`.
- **DTOs**: Strict validation, used for input/output at application and presentation layers. See `src/application/dtos/`, `src/presentation/dto/`.
- **Repositories**: Domain interfaces only, implemented in infrastructure. No business logic in infrastructure.
- **Controllers**: No business logic, only orchestration and validation. See `src/presentation/controllers/`.
- **Guards/Middlewares/Interceptors**: Shared in `src/common/`.
- **Testing**: Use Jest, mock dependencies for unit tests. See examples in README files.

## Integration Points & External Dependencies

- **Database**: TypeORM/Prisma (see infrastructure layer)
- **External Services**: Email, cache, file storage (see `src/infrastructure/external-services/`)
- **Configuration**: Centralized in `src/infrastructure/config/`
- **Validation**: `class-validator` for DTOs
- **API Documentation**: Swagger decorators in controllers

## Key Files & Directories

- `src/domain/README.md`: Domain modeling conventions and examples
- `src/application/README.md`: Use case and DTO patterns
- `src/infrastructure/README.md`: Repository and service implementation guidelines
- `src/presentation/README.md`: Controller, DTO, guard, middleware conventions
- `src/common/README.md`: Shared utilities and cross-cutting concerns
- `src/README.md`: High-level architecture overview
- `README.md`: Project summary, build/test instructions

## Example Patterns

- **Rich Entity**:
  ```typescript
  export class User extends BaseEntity {
    activate(): void {
      /* business logic */
    }
    changeEmail(newEmail: string): void {
      /* ... */
    }
  }
  ```
- **Use Case**:
  ```typescript
  export class CreateUserUseCase
    implements UseCase<CreateUserRequest, CreateUserResponse>
  {
    async execute(request: CreateUserRequest): Promise<CreateUserResponse> {
      /* ... */
    }
  }
  ```
- **Repository Interface**:
  ```typescript
  export interface UserRepository {
    findById(id: string): Promise<User | null>;
    save(user: User): Promise<void>;
  }
  ```
- **Controller**:
  ```typescript
  @Controller('users')
  export class UserController {
    constructor(private readonly userAppService: UserApplicationService) {}
    @Post() async create(@Body() dto: CreateUserDto) {
      /* ... */
    }
  }
  ```

---

**For more details, see the README in each layer's folder.**

---

## Feedback

If any section is unclear or missing, please provide feedback so this guide can be improved for future AI agents.
