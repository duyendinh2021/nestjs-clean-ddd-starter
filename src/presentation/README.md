# 🌐 Presentation Layer

## 📝 Mục đích

Presentation Layer là **entry point** của ứng dụng, chịu trách nhiệm handle HTTP requests/responses, routing, validation, authentication và authorization. Layer này expose application functionality thông qua REST APIs, GraphQL, hoặc other protocols.

## 📂 Cấu trúc thư mục

```
presentation/
├── controllers/      # HTTP controllers xử lý requests
├── dto/             # Request/Response DTOs
├── middlewares/     # Express middlewares
└── index.ts         # Export tất cả presentation components
```

## 🎯 Nguyên tắc

### ✅ Presentation Layer được phép:

- Handle HTTP requests và responses
- Route requests đến appropriate use cases
- Validate input data
- Handle authentication và authorization
- Transform data giữa HTTP và application layers
- Handle HTTP-specific concerns (headers, status codes, etc.)

### ❌ Presentation Layer KHÔNG được phép:

- Chứa business logic (thuộc Domain layer)
- Chứa application workflows (thuộc Application layer)
- Direct database access (sử dụng Application layer)
- Complex data transformations (sử dụng Application DTOs)

## 📋 Code Convention

### Controllers

```typescript
// ✅ Good: Clean controller với single responsibility
@Controller('users')
@ApiTags('Users')
export class UserController {
  constructor(
    private readonly userApplicationService: UserApplicationService,
    private readonly logger: Logger,
  ) {}

  @Post()
  @ApiOperation({ summary: 'Create a new user' })
  @ApiResponse({ status: 201, description: 'User created successfully' })
  @ApiResponse({ status: 400, description: 'Invalid input data' })
  @ApiResponse({ status: 409, description: 'User already exists' })
  async createUser(@Body() dto: CreateUserDto): Promise<CreateUserResponseDto> {
    try {
      // 1. Transform DTO to application request
      const request = new CreateUserRequest(
        dto.email,
        dto.firstName,
        dto.lastName,
      );

      // 2. Execute use case
      const response = await this.userApplicationService.createUser(request);

      // 3. Transform response to presentation DTO
      return CreateUserResponseDto.fromApplication(response);
    } catch (error) {
      this.logger.error(`Failed to create user: ${error.message}`);
      throw new HttpException(error.message, HttpStatus.BAD_REQUEST);
    }
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get user by ID' })
  @ApiParam({ name: 'id', description: 'User ID' })
  @ApiResponse({ status: 200, description: 'User found' })
  @ApiResponse({ status: 404, description: 'User not found' })
  async getUserById(@Param('id') id: string): Promise<GetUserResponseDto> {
    try {
      const response = await this.userApplicationService.getUserById(id);
      return GetUserResponseDto.fromApplication(response);
    } catch (error) {
      this.logger.error(`Failed to get user ${id}: ${error.message}`);
      throw new HttpException('User not found', HttpStatus.NOT_FOUND);
    }
  }

  @Put(':id')
  @UseGuards(AuthGuard, OwnershipGuard)
  @ApiOperation({ summary: 'Update user' })
  @ApiParam({ name: 'id', description: 'User ID' })
  @ApiBearerAuth()
  async updateUser(
    @Param('id') id: string,
    @Body() dto: UpdateUserDto,
    @CurrentUser() currentUser: UserContext,
  ): Promise<void> {
    try {
      const request = new UpdateUserRequest(dto.firstName, dto.lastName);
      await this.userApplicationService.updateUser(id, request);
    } catch (error) {
      this.logger.error(`Failed to update user ${id}: ${error.message}`);
      throw new HttpException(error.message, HttpStatus.BAD_REQUEST);
    }
  }

  @Delete(':id')
  @UseGuards(AuthGuard, AdminGuard)
  @ApiOperation({ summary: 'Delete user' })
  @ApiParam({ name: 'id', description: 'User ID' })
  @ApiBearerAuth()
  @HttpCode(HttpStatus.NO_CONTENT)
  async deleteUser(@Param('id') id: string): Promise<void> {
    try {
      await this.userApplicationService.deleteUser(id);
    } catch (error) {
      this.logger.error(`Failed to delete user ${id}: ${error.message}`);
      throw new HttpException(error.message, HttpStatus.BAD_REQUEST);
    }
  }

  @Get()
  @UseGuards(AuthGuard)
  @ApiOperation({ summary: 'Get users with pagination' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiQuery({ name: 'role', required: false, type: String })
  async getUsers(
    @Query() query: GetUsersQueryDto,
  ): Promise<GetUsersResponseDto> {
    try {
      const request = new GetUsersRequest(
        query.page || 1,
        query.limit || 10,
        query.role,
      );
      const response = await this.userApplicationService.getUsers(request);
      return GetUsersResponseDto.fromApplication(response);
    } catch (error) {
      this.logger.error(`Failed to get users: ${error.message}`);
      throw new HttpException(error.message, HttpStatus.BAD_REQUEST);
    }
  }
}

// ❌ Bad: Controller với business logic
@Controller('users')
export class BadUserController {
  @Post()
  async createUser(@Body() data: any): Promise<any> {
    // Bad: Business validation trong controller
    if (data.age < 18) {
      throw new Error('User must be 18 or older');
    }

    // Bad: Direct database access
    const user = await this.userRepository.save(data);

    // Bad: Business logic trong controller
    if (user.isVip) {
      await this.sendVipWelcomeEmail(user);
    }

    return user;
  }
}
```

### DTOs (Data Transfer Objects)

```typescript
// ✅ Good: Request DTOs với validation
export class CreateUserDto {
  @ApiProperty({
    description: 'User email address',
    example: 'john@example.com',
  })
  @IsEmail({}, { message: 'Invalid email format' })
  @IsNotEmpty({ message: 'Email is required' })
  email: string;

  @ApiProperty({ description: 'User first name', example: 'John' })
  @IsString({ message: 'First name must be a string' })
  @IsNotEmpty({ message: 'First name is required' })
  @Length(2, 50, { message: 'First name must be between 2 and 50 characters' })
  firstName: string;

  @ApiProperty({ description: 'User last name', example: 'Doe' })
  @IsString({ message: 'Last name must be a string' })
  @IsNotEmpty({ message: 'Last name is required' })
  @Length(2, 50, { message: 'Last name must be between 2 and 50 characters' })
  lastName: string;

  @ApiProperty({ description: 'User date of birth', required: false })
  @IsOptional()
  @IsDateString({}, { message: 'Invalid date format' })
  dateOfBirth?: string;
}

export class UpdateUserDto {
  @ApiProperty({ description: 'User first name', required: false })
  @IsOptional()
  @IsString({ message: 'First name must be a string' })
  @Length(2, 50, { message: 'First name must be between 2 and 50 characters' })
  firstName?: string;

  @ApiProperty({ description: 'User last name', required: false })
  @IsOptional()
  @IsString({ message: 'Last name must be a string' })
  @Length(2, 50, { message: 'Last name must be between 2 and 50 characters' })
  lastName?: string;
}

// Response DTOs
export class CreateUserResponseDto {
  @ApiProperty({ description: 'User ID' })
  id: string;

  @ApiProperty({ description: 'User email' })
  email: string;

  @ApiProperty({ description: 'Creation timestamp' })
  createdAt: Date;

  static fromApplication(response: CreateUserResponse): CreateUserResponseDto {
    const dto = new CreateUserResponseDto();
    dto.id = response.userId;
    dto.email = response.email;
    dto.createdAt = response.createdAt;
    return dto;
  }
}

export class GetUserResponseDto {
  @ApiProperty({ description: 'User ID' })
  id: string;

  @ApiProperty({ description: 'User email' })
  email: string;

  @ApiProperty({ description: 'User full name' })
  fullName: string;

  @ApiProperty({ description: 'User active status' })
  isActive: boolean;

  @ApiProperty({ description: 'Creation timestamp' })
  createdAt: Date;

  static fromApplication(response: GetUserResponse): GetUserResponseDto {
    const dto = new GetUserResponseDto();
    dto.id = response.id;
    dto.email = response.email;
    dto.fullName = response.fullName;
    dto.isActive = response.isActive;
    dto.createdAt = response.createdAt;
    return dto;
  }
}

// Query DTOs
export class GetUsersQueryDto {
  @ApiProperty({ description: 'Page number', required: false, default: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsInt({ message: 'Page must be an integer' })
  @Min(1, { message: 'Page must be greater than 0' })
  page?: number;

  @ApiProperty({ description: 'Items per page', required: false, default: 10 })
  @IsOptional()
  @Type(() => Number)
  @IsInt({ message: 'Limit must be an integer' })
  @Min(1, { message: 'Limit must be greater than 0' })
  @Max(100, { message: 'Limit cannot exceed 100' })
  limit?: number;

  @ApiProperty({ description: 'Filter by role', required: false })
  @IsOptional()
  @IsString({ message: 'Role must be a string' })
  role?: string;
}

// ❌ Bad: DTO without validation
export class BadCreateUserDto {
  email: string;
  firstName: string;
  lastName: string;
  // No validation, no documentation
}
```

### Guards (Authentication & Authorization)

```typescript
// ✅ Good: JWT Authentication Guard
@Injectable()
export class AuthGuard implements CanActivate {
  constructor(
    private readonly jwtService: JwtService,
    private readonly userRepository: UserRepository,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const token = this.extractTokenFromHeader(request);

    if (!token) {
      throw new UnauthorizedException('Token not provided');
    }

    try {
      const payload = await this.jwtService.verifyAsync(token);
      const user = await this.userRepository.findById(payload.sub);

      if (!user || !user.isActive) {
        throw new UnauthorizedException('Invalid user');
      }

      request.user = {
        id: user.id,
        email: user.email,
        roles: user.roles,
      };

      return true;
    } catch (error) {
      throw new UnauthorizedException('Invalid token');
    }
  }

  private extractTokenFromHeader(request: Request): string | undefined {
    const [type, token] = request.headers.authorization?.split(' ') ?? [];
    return type === 'Bearer' ? token : undefined;
  }
}

// Authorization Guard
@Injectable()
export class RoleGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.getAllAndOverride<string[]>('roles', [
      context.getHandler(),
      context.getClass(),
    ]);

    if (!requiredRoles) {
      return true;
    }

    const { user } = context.switchToHttp().getRequest();
    return requiredRoles.some(role => user.roles?.includes(role));
  }
}

// Resource Ownership Guard
@Injectable()
export class OwnershipGuard implements CanActivate {
  constructor(private readonly userRepository: UserRepository) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const user = request.user;
    const resourceId = request.params.id;

    // Check if user owns the resource or is admin
    if (user.roles.includes('admin')) {
      return true;
    }

    return user.id === resourceId;
  }
}
```

### Middlewares

```typescript
// ✅ Good: Logging middleware
@Injectable()
export class LoggingMiddleware implements NestMiddleware {
  private readonly logger = new Logger(LoggingMiddleware.name);

  use(req: Request, res: Response, next: NextFunction): void {
    const { method, originalUrl, ip } = req;
    const userAgent = req.get('User-Agent') || '';
    const startTime = Date.now();

    res.on('finish', () => {
      const { statusCode } = res;
      const contentLength = res.get('Content-Length');
      const responseTime = Date.now() - startTime;

      this.logger.log(
        `${method} ${originalUrl} ${statusCode} ${contentLength || 0}b - ${responseTime}ms - ${ip} ${userAgent}`,
      );
    });

    next();
  }
}

// CORS Middleware
@Injectable()
export class CorsMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction): void {
    res.header(
      'Access-Control-Allow-Origin',
      process.env.ALLOWED_ORIGINS || '*',
    );
    res.header(
      'Access-Control-Allow-Methods',
      'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
    );
    res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization');

    if (req.method === 'OPTIONS') {
      res.sendStatus(200);
    } else {
      next();
    }
  }
}

// Rate Limiting Middleware
@Injectable()
export class RateLimitMiddleware implements NestMiddleware {
  private readonly limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // limit each IP to 100 requests per windowMs
    message: 'Too many requests from this IP, please try again later.',
  });

  use(req: Request, res: Response, next: NextFunction): void {
    this.limiter(req, res, next);
  }
}
```

### Exception Filters

```typescript
// ✅ Good: Global exception filter
@Catch()
export class GlobalExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(GlobalExceptionFilter.name);

  catch(exception: unknown, host: ArgumentsHost): void {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();

    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let message = 'Internal server error';

    if (exception instanceof HttpException) {
      status = exception.getStatus();
      const responseBody = exception.getResponse();
      message =
        typeof responseBody === 'string'
          ? responseBody
          : (responseBody as any).message;
    } else if (exception instanceof Error) {
      message = exception.message;
    }

    const errorResponse = {
      statusCode: status,
      timestamp: new Date().toISOString(),
      path: request.url,
      method: request.method,
      message,
    };

    this.logger.error(
      `${request.method} ${request.url} - ${status} - ${message}`,
      exception instanceof Error ? exception.stack : undefined,
    );

    response.status(status).json(errorResponse);
  }
}

// Domain Exception Filter
@Catch(DomainException)
export class DomainExceptionFilter implements ExceptionFilter {
  catch(exception: DomainException, host: ArgumentsHost): void {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();

    response.status(HttpStatus.BAD_REQUEST).json({
      statusCode: HttpStatus.BAD_REQUEST,
      message: exception.message,
      timestamp: new Date().toISOString(),
    });
  }
}
```

## 🔄 Workflow Examples

### 1. Simple CRUD Controller

```typescript
@Controller('products')
@ApiTags('Products')
export class ProductController {
  constructor(
    private readonly productApplicationService: ProductApplicationService,
  ) {}

  @Post()
  async create(
    @Body() dto: CreateProductDto,
  ): Promise<CreateProductResponseDto> {
    const request = new CreateProductRequest(dto.name, dto.price, dto.category);
    const response =
      await this.productApplicationService.createProduct(request);
    return CreateProductResponseDto.fromApplication(response);
  }

  @Get()
  async findAll(
    @Query() query: GetProductsQueryDto,
  ): Promise<GetProductsResponseDto> {
    const request = new GetProductsRequest(
      query.page,
      query.limit,
      query.category,
    );
    const response = await this.productApplicationService.getProducts(request);
    return GetProductsResponseDto.fromApplication(response);
  }

  @Get(':id')
  async findOne(@Param('id') id: string): Promise<GetProductResponseDto> {
    const response = await this.productApplicationService.getProductById(id);
    return GetProductResponseDto.fromApplication(response);
  }

  @Put(':id')
  @UseGuards(AuthGuard)
  async update(
    @Param('id') id: string,
    @Body() dto: UpdateProductDto,
  ): Promise<void> {
    const request = new UpdateProductRequest(dto.name, dto.price);
    await this.productApplicationService.updateProduct(id, request);
  }

  @Delete(':id')
  @UseGuards(AuthGuard, AdminGuard)
  @HttpCode(HttpStatus.NO_CONTENT)
  async remove(@Param('id') id: string): Promise<void> {
    await this.productApplicationService.deleteProduct(id);
  }
}
```

### 2. File Upload Controller

```typescript
@Controller('files')
@ApiTags('Files')
export class FileController {
  constructor(
    private readonly fileApplicationService: FileApplicationService,
  ) {}

  @Post('upload')
  @UseGuards(AuthGuard)
  @UseInterceptors(FileInterceptor('file'))
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    description: 'File upload',
    type: FileUploadDto,
  })
  async uploadFile(
    @UploadedFile() file: Express.Multer.File,
    @CurrentUser() user: UserContext,
  ): Promise<FileUploadResponseDto> {
    if (!file) {
      throw new BadRequestException('File is required');
    }

    const request = new UploadFileRequest(
      file.buffer,
      file.originalname,
      user.id,
    );
    const response = await this.fileApplicationService.uploadFile(request);
    return FileUploadResponseDto.fromApplication(response);
  }

  @Get(':id/download')
  @UseGuards(AuthGuard)
  async downloadFile(
    @Param('id') id: string,
    @Res() res: Response,
  ): Promise<void> {
    const file = await this.fileApplicationService.getFile(id);

    res.set({
      'Content-Type': file.mimeType,
      'Content-Disposition': `attachment; filename="${file.originalName}"`,
    });

    res.send(file.data);
  }
}
```

## 🚀 Best Practices

1. **Single Responsibility**: Mỗi controller handle một resource type
2. **Input Validation**: Sử dụng DTOs với class-validator
3. **Error Handling**: Use exception filters cho consistent error responses
4. **Authentication**: Implement proper authentication và authorization
5. **Documentation**: Sử dụng Swagger/OpenAPI decorators
6. **Logging**: Log all requests và important operations
7. **Rate Limiting**: Protect against abuse
8. **CORS**: Configure properly cho frontend integration
9. **Security Headers**: Add security headers
10. **Testing**: Unit test controllers với mocked dependencies

## 🧪 Testing Examples

```typescript
describe('UserController', () => {
  let controller: UserController;
  let service: jest.Mocked<UserApplicationService>;

  beforeEach(async () => {
    const mockService = {
      createUser: jest.fn(),
      getUserById: jest.fn(),
      updateUser: jest.fn(),
      deleteUser: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      controllers: [UserController],
      providers: [
        {
          provide: UserApplicationService,
          useValue: mockService,
        },
      ],
    }).compile();

    controller = module.get<UserController>(UserController);
    service = module.get(UserApplicationService);
  });

  describe('createUser', () => {
    it('should create user successfully', async () => {
      // Arrange
      const dto = new CreateUserDto();
      dto.email = 'test@example.com';
      dto.firstName = 'John';
      dto.lastName = 'Doe';

      const expectedResponse = new CreateUserResponse(
        '123',
        'test@example.com',
      );
      service.createUser.mockResolvedValue(expectedResponse);

      // Act
      const result = await controller.createUser(dto);

      // Assert
      expect(result.id).toBe('123');
      expect(result.email).toBe('test@example.com');
      expect(service.createUser).toHaveBeenCalledWith(
        expect.objectContaining({
          email: 'test@example.com',
          firstName: 'John',
          lastName: 'Doe',
        }),
      );
    });

    it('should throw BadRequestException when service throws error', async () => {
      // Arrange
      const dto = new CreateUserDto();
      dto.email = 'test@example.com';
      dto.firstName = 'John';
      dto.lastName = 'Doe';

      service.createUser.mockRejectedValue(new Error('User already exists'));

      // Act & Assert
      await expect(controller.createUser(dto)).rejects.toThrow(HttpException);
    });
  });
});
```

## 📚 Tài liệu tham khảo

- [NestJS Controllers](https://docs.nestjs.com/controllers)
- [NestJS Guards](https://docs.nestjs.com/guards)
- [NestJS Interceptors](https://docs.nestjs.com/interceptors)
- [Class Validator](https://github.com/typestack/class-validator)
- [Swagger/OpenAPI](https://docs.nestjs.com/openapi/introduction)
