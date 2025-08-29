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

This is a **VoimaDB Competition Management API** built with Swift/Hummingbird following clean architecture principles.

### Core Patterns

**Repository Pattern**: Clean separation between data access and business logic
- `CompetitionRepository` protocol defines the contract
- `CompetitionMemoryRepository` for testing/development
- `CompetitionPostgresRepository` for production
- Repositories are injected into controllers via constructor dependency injection

**Dependency Injection**: Environment-based repository selection
```swift
// Application builder chooses repository based on arguments
if !arguments.inMemoryTesting {
    let repository = CompetitionPostgresRepository(client: client, logger: logger)
} else {
    let repository = CompetitionMemoryRepository()
}
```

**Controller Structure**: RESTful controllers with async/await
- Controllers receive repository dependencies 
- All operations are async and use proper HTTP status codes
- Clear separation between route handling and business logic

### Database Architecture

**Schema Management**: Automatic table creation on startup
- No formal migration system - uses `CREATE TABLE IF NOT EXISTS`
- Schema defined in `CompetitionPostgresRepository.createTable()`
- Database initialized in `beforeServerStarts` hook

**Current Schema**:
```sql
CREATE TABLE competitions (
    "id" SERIAL PRIMARY KEY,
    "name" text NOT NULL,
    "description" text,
    "date" timestamp NOT NULL,
    "city" text NOT NULL,
    "country" text NOT NULL
)
```

### Project Structure
```
Sources/App/
├── App.swift                          # CLI entry point
├── Application+build.swift            # App configuration & DI setup
├── Controllers/
│   └── CompetitionController.swift    # REST endpoints
└── Repositories/
    ├── Competition.swift              # Domain model
    ├── CompetitionRepository.swift    # Repository protocol
    ├── CompetitionMemoryRepository.swift    # In-memory implementation
    └── CompetitionPostgresRepository.swift  # PostgreSQL implementation
```

### API Routes
- `GET /health` - Health check
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

2. **Database Changes**: Update `CompetitionPostgresRepository.createTable()` method

3. **Repository Implementation**: Always implement protocol first, then concrete implementations

### Architecture Conventions
- Use dependency injection for all repository access
- Maintain async/await throughout the call chain
- Follow RESTful conventions for new endpoints
- Use proper HTTP status codes and error handling
- All repositories must be `Sendable` for Swift concurrency
- Integer IDs (not UUIDs) for primary keys

### Environment Configuration
- Environment variables loaded via `Environment.dotEnv()`
- CLI arguments override environment variables
- Use `inMemoryTesting` flag to bypass database requirements during development