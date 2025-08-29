# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

### Building and Running
```bash
# Build the project
swift build

# Run tests (automatically uses in-memory repository)
swift test

# Run the application (development mode)
swift run App

# Run with in-memory database (no PostgreSQL needed)
swift run App --in-memory-testing

# Run with custom configuration
swift run App --hostname 0.0.0.0 --port 8080 --log-level debug

# Build for production
swift build -c release
```

### Database Setup
Ensure PostgreSQL is running with credentials from `.env`:
```bash
POSTGRES_HOST=localhost
POSTGRES_USERNAME=voima
POSTGRES_PASSWORD=voimadb  
POSTGRES_DATABASE=voimadb
POSTGRES_PORT=5432
```

### Testing
- Use Bruno API collection in `/server/bruno/VoimaDB/` for API testing
- Tests automatically inject in-memory repository via `inMemoryTesting: true`
- Run `swift test` for unit tests

## Architecture Overview

This is a **VoimaDB Competition Management API** built with Swift/Hummingbird 2.15.0 following clean architecture principles with PostgreSQL session management and user authentication.

### Core Patterns

**Repository Pattern**: Clean separation between data access and business logic
- `CompetitionRepository` and `UserRepository` protocols define contracts
- Memory repositories (`CompetitionMemoryRepository`, `UserMemoryRepository`) for testing/development
- PostgreSQL repositories (`CompetitionPostgresRepository`, `UserPostgresRepository`) for production
- Repositories are injected into controllers and middleware via constructor dependency injection

**Dependency Injection**: Environment-based repository selection
```swift
// Application builder chooses repositories based on arguments
if !arguments.inMemoryTesting {
    let competitionRepository = CompetitionPostgresRepository(client: client, logger: logger)
    let userRepository = UserPostgresRepository(client: client, logger: logger)
} else {
    let competitionRepository = CompetitionMemoryRepository()
    let userRepository = UserMemoryRepository()
}
```

**Authentication & Session Management**: Built on Hummingbird-Auth 2.0
- Uses bcrypt for secure password hashing with NIOThreadPool for non-blocking operations
- PostgreSQL-backed session persistence using `PostgresPersistDriver`
- Database migrations using `PostgresMigrations` for schema management
- Dual authentication system:
  - `BasicAuthenticator` for email/password login
  - `SessionAuthenticator` for session-based authenticated routes
- Context-based authentication with `BasicSessionRequestContext<UUID, User>`

**Controller Structure**: RESTful controllers with async/await
- Controllers receive repository dependencies 
- All operations are async and use proper HTTP status codes
- Clear separation between route handling and business logic

### Database Architecture

**Schema Management**: PostgreSQL migrations with `hummingbird-postgres`
- Formal migration system using `DatabaseMigrations` and `PostgresMigrations`
- Migrations defined in `Sources/App/Migrations/` directory
- Auto-applied during application startup via `beforeServerStarts` hook
- Session storage integrated with `PostgresPersistDriver`

**Current Schema**:
```sql
-- Competitions table
CREATE TABLE competitions (
    "id" SERIAL PRIMARY KEY,
    "name" text NOT NULL,
    "description" text,
    "date" timestamp NOT NULL,
    "city" text NOT NULL,
    "country" text NOT NULL
);

-- Users table  
CREATE TABLE users (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL UNIQUE,
    "password_hash" TEXT NOT NULL,
    "created_at" TIMESTAMP NOT NULL DEFAULT NOW()
);
```

### Project Structure
```
Sources/App/
├── App.swift                               # CLI entry point
├── Application+build.swift                 # App configuration & DI setup
├── Controllers/
│   ├── AuthController.swift               # User auth endpoints (register/login/me)
│   └── CompetitionController.swift         # Competition REST endpoints
├── Migrations/
│   ├── CreateCompetitionsMigration.swift   # Competition table migration
│   └── CreateUserMigration.swift           # User table migration
├── Models/
│   └── User.swift                          # User domain model with PasswordAuthenticatable
└── Repositories/
    ├── Competition.swift                   # Competition domain model
    ├── CompetitionRepository.swift         # Competition repository protocol
    ├── CompetitionMemoryRepository.swift   # Competition in-memory implementation
    ├── CompetitionPostgresRepository.swift # Competition PostgreSQL implementation
    ├── UserRepository.swift               # User repository protocol
    ├── UserMemoryRepository.swift          # User in-memory implementation
    └── UserPostgresRepository.swift        # User PostgreSQL implementation
```

### API Routes

**Public Routes**:
- `GET /health` - Health check
- `POST /auth/register` - Register new user (requires JSON: `{name, email, password}`)

**Authentication Routes**:
- `POST /auth/login` - Login with Basic auth, creates session

**Protected Routes** (require session authentication):
- `GET /auth/me` - Get current authenticated user info

**Competition Routes**:
- `GET /competitions` - List all competitions  
- `GET /competitions/:id` - Get specific competition (Int ID)
- `POST /competitions` - Create competition
- `PATCH /competitions/:id` - Update competition
- `DELETE /competitions/:id` - Delete competition
- `DELETE /competitions` - Delete all competitions

### Testing Strategy
- Tests use `HummingbirdTesting` framework
- In-memory repository automatically injected for all tests
- Integration-style testing of complete request/response cycle
- Use `--in-memory-testing` flag for development without PostgreSQL

## Development Guidelines

### Adding New Features
1. **New Entity Pattern**: Follow Competition model structure
   - Create domain model in `Repositories/`
   - Define repository protocol with CRUD operations
   - Implement both memory and PostgreSQL repositories
   - Create controller with dependency injection
   - Register routes in `Application+build.swift`

2. **Database Changes**: Update appropriate `PostgresRepository.createTable()` method

3. **Repository Implementation**: Always implement protocol first, then concrete implementations

### Architecture Conventions
- Use dependency injection for all repository access
- Maintain async/await throughout the call chain
- Follow RESTful conventions for new endpoints
- Use proper HTTP status codes and error handling
- All repositories must be `Sendable` for Swift concurrency
- Integer IDs for competitions, UUID IDs for users
- Use Hummingbird-Auth for authentication patterns
- Never store plaintext passwords - always use bcrypt hashing

### Authentication Usage

**User Registration Flow**:
```bash
# Register new user
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name": "alice", "email": "alice@example.com", "password": "secretpassword"}'
```

**Login & Session Flow**:
```bash
# Login with basic auth (creates session)
curl -X POST http://localhost:8080/auth/login \
  -u alice@example.com:secretpassword \
  -c cookies.txt

# Use session cookie for authenticated requests
curl -X GET http://localhost:8080/auth/me \
  -b cookies.txt
```

**Authentication Components**:
- `SessionMiddleware` with `PostgresPersistDriver` - Manages session persistence in database
- `BasicAuthenticator` - Validates email/password credentials via closure
- `SessionAuthenticator` - Validates session cookies and loads user via closure
- `PasswordAuthenticatable` conformance on User model for bcrypt integration

### Environment Configuration
- Environment variables loaded via `Environment.dotEnv()`
- CLI arguments override environment variables
- Use `inMemoryTesting` flag to bypass database requirements during development