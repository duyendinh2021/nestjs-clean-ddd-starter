# 🚀 NestJS Clean Architecture + DDD Starter

<p align="center">
  <a href="http://nestjs.com/" target="blank"><img src="https://nestjs.com/img/logo-small.svg" width="120" alt="Nest Logo" /></a>
</p>

<p align="center">
  A production-ready NestJS starter project implementing <strong>Clean Architecture</strong> and <strong>Domain-Driven Design (DDD)</strong> patterns with TypeScript.
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#architecture">Architecture</a> •
  <a href="#quick-start">Quick Start</a> •
  <a href="#project-structure">Structure</a> •
  <a href="#documentation">Documentation</a>
</p>

---

## ✨ Features

- 🏗️ **Clean Architecture** - Separation of concerns with clear layer boundaries
- 🎯 **Domain-Driven Design** - Rich domain models with business logic encapsulation
- 📦 **Modular Structure** - Well-organized codebase with feature modules
- 🔧 **Code Quality** - ESLint, Prettier, and EditorConfig setup
- 📝 **TypeScript** - Full type safety with strict configuration
- ✅ **Testing Ready** - Jest configuration for unit and e2e tests
- 🔄 **CI/CD Ready** - Pre-configured for modern development workflows
- 📚 **Documentation** - Comprehensive guides and examples

## 🏛️ Architecture

This project follows **Clean Architecture** principles with four main layers:

```
┌─────────────────────────────────────────────────────┐
│                  Presentation Layer                 │
│              (Controllers, DTOs, etc.)              │
├─────────────────────────────────────────────────────┤
│                 Application Layer                   │
│              (Use Cases, Services)                  │
├─────────────────────────────────────────────────────┤
│                   Domain Layer                      │
│        (Entities, Value Objects, Rules)             │
├─────────────────────────────────────────────────────┤
│                Infrastructure Layer                 │
│         (Database, External Services)               │
└─────────────────────────────────────────────────────┘
```

### 🎯 Design Principles

- **Dependency Inversion** - High-level modules don't depend on low-level modules
- **Single Responsibility** - Each class has one reason to change
- **Open/Closed Principle** - Open for extension, closed for modification
- **Interface Segregation** - Clients shouldn't depend on unused interfaces
- **Separation of Concerns** - Each layer has distinct responsibilities

## 🚀 Quick Start

### Prerequisites

- Node.js >= 20.0.0
- npm >= 10.0.0

### Installation

```bash
# Clone the repository
git clone https://github.com/duyendinh2021/nestjs-clean-ddd-starter.git
cd nestjs-clean-ddd-starter

# Install dependencies
npm install

# Start development server
npm run start:dev
```

### Available Scripts

```bash
npm run build          # Build the project
npm run start          # Start production server
npm run start:dev      # Start development server with watch
npm run start:debug    # Start with debug mode
npm run lint           # Lint and fix code issues
npm run test           # Run unit tests
npm run test:e2e       # Run end-to-end tests
npm run test:cov       # Run tests with coverage
npm run format:all     # Format all files with Prettier
npm run convert:lf     # Convert line endings to LF
```

## 📁 Project Structure

```
src/
├── 📂 common/                    # Shared utilities and helpers
│   ├── decorators/              # Custom decorators
│   ├── guards/                  # Authentication & authorization guards
│   ├── interceptors/            # Request/response interceptors
│   ├── filters/                 # Exception filters
│   ├── pipes/                   # Validation pipes
│   └── utils/                   # Utility functions
│
├── 📂 domain/                    # 🏛️ DOMAIN LAYER
│   ├── entities/                # Domain entities with business logic
│   ├── value-objects/           # Value objects (immutable)
│   ├── repositories/            # Repository interfaces
│   ├── services/                # Domain services
│   └── events/                  # Domain events
│
├── 📂 application/               # 🔄 APPLICATION LAYER
│   ├── use-cases/               # Application use cases
│   ├── dtos/                    # Data transfer objects
│   ├── interfaces/              # Application interfaces
│   └── services/                # Application services
│
├── 📂 infrastructure/            # 🔧 INFRASTRUCTURE LAYER
│   ├── database/                # Database configuration & models
│   ├── repositories/            # Repository implementations
│   ├── external-services/       # External API clients
│   └── config/                  # Configuration files
│
├── 📂 presentation/              # 🌐 PRESENTATION LAYER
│   ├── controllers/             # HTTP controllers
│   ├── middlewares/             # Express middlewares
│   └── dto/                     # Request/response DTOs
│
├── app.module.ts                # Main application module
└── main.ts                      # Application entry point
```

## 📚 Documentation

- 📖 [Clean Architecture Guide](./CLEAN_ARCHITECTURE_GUIDE.md) - Detailed implementation guide
- 📋 [Implementation Summary](./IMPLEMENTATION_SUMMARY.md) - Overview of the implementation
- 🏗️ [Architecture Documentation](./src/README.md) - In-depth architecture explanation

## 🛠️ Development

### Code Quality

This project includes comprehensive code quality tools:

- **ESLint** - Static code analysis with TypeScript rules
- **Prettier** - Code formatting with consistent style
- **EditorConfig** - Consistent coding styles across editors
- **Husky** - Git hooks for quality assurance (optional)

### Line Endings

The project is configured for consistent LF line endings across all platforms:

```bash
npm run convert:lf    # Convert all files to LF endings
```

### Testing

```bash
# Unit tests
npm run test

# E2E tests
npm run test:e2e

# Test coverage
npm run test:cov

# Test in watch mode
npm run test:watch
```

## 🔧 Configuration

### Environment Variables

Create a `.env` file in the root directory:

```env
# Application
PORT=3000
NODE_ENV=development

# Database (when implemented)
DATABASE_URL=postgresql://user:password@localhost:5432/dbname

# JWT (when implemented)
JWT_SECRET=your-secret-key
```

### VS Code Settings

The project includes VS Code workspace settings for optimal development experience:

- Automatic formatting on save
- ESLint integration
- Consistent line endings (LF)
- TypeScript/Prettier as default formatters

## 🚀 Production Deployment

### Build for Production

```bash
npm run build
npm run start:prod
```

### Docker (Optional)

```dockerfile
FROM node:20-alpine

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

COPY dist/ ./dist/
EXPOSE 3000

CMD ["node", "dist/main"]
```

## 🤝 Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Commit Convention

This project follows [Conventional Commits](https://conventionalcommits.org/):

- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation changes
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks

## 📄 License

This project is [MIT licensed](LICENSE).

## 🙏 Acknowledgements

- [NestJS](https://nestjs.com/) - The progressive Node.js framework
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html) - by Uncle Bob
- [Domain-Driven Design](https://domainlanguage.com/ddd/) - by Eric Evans

---

<p align="center">
  Made with ❤️ for the NestJS community
</p>

[Nest](https://github.com/nestjs/nest) framework TypeScript starter repository.

## Project setup

```bash
$ npm install
```

## Compile and run the project

```bash
# development
$ npm run start

# watch mode
$ npm run start:dev

# production mode
$ npm run start:prod
```

## Run tests

```bash
# unit tests
$ npm run test

# e2e tests
$ npm run test:e2e

# test coverage
$ npm run test:cov
```

## Deployment

When you're ready to deploy your NestJS application to production, there are some key steps you can take to ensure it runs as efficiently as possible. Check out the [deployment documentation](https://docs.nestjs.com/deployment) for more information.

If you are looking for a cloud-based platform to deploy your NestJS application, check out [Mau](https://mau.nestjs.com), our official platform for deploying NestJS applications on AWS. Mau makes deployment straightforward and fast, requiring just a few simple steps:

```bash
$ npm install -g @nestjs/mau
$ mau deploy
```

With Mau, you can deploy your application in just a few clicks, allowing you to focus on building features rather than managing infrastructure.

## Resources

Check out a few resources that may come in handy when working with NestJS:

- Visit the [NestJS Documentation](https://docs.nestjs.com) to learn more about the framework.
- For questions and support, please visit our [Discord channel](https://discord.gg/G7Qnnhy).
- To dive deeper and get more hands-on experience, check out our official video [courses](https://courses.nestjs.com/).
- Deploy your application to AWS with the help of [NestJS Mau](https://mau.nestjs.com) in just a few clicks.
- Visualize your application graph and interact with the NestJS application in real-time using [NestJS Devtools](https://devtools.nestjs.com).
- Need help with your project (part-time to full-time)? Check out our official [enterprise support](https://enterprise.nestjs.com).
- To stay in the loop and get updates, follow us on [X](https://x.com/nestframework) and [LinkedIn](https://linkedin.com/company/nestjs).
- Looking for a job, or have a job to offer? Check out our official [Jobs board](https://jobs.nestjs.com).

## Support

Nest is an MIT-licensed open source project. It can grow thanks to the sponsors and support by the amazing backers. If you'd like to join them, please [read more here](https://docs.nestjs.com/support).

## Stay in touch

- Author - [Kamil MyÅ›liwiec](https://twitter.com/kammysliwiec)
- Website - [https://nestjs.com](https://nestjs.com/)
- Twitter - [@nestframework](https://twitter.com/nestframework)

## License

Nest is [MIT licensed](https://github.com/nestjs/nest/blob/master/LICENSE).
