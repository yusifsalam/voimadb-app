# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

VoimaDB Vapor API is a REST API for managing powerlifting competitions, lifters, clubs, and results. Built with Vapor 4 framework and PostgreSQL database using Fluent ORM.

## Development Commands

### Build and Run
```bash
swift build                    # Build the project
swift run                      # Run the server (runs migrations automatically)
```

### Testing
```bash
swift test                     # Run all tests
swift test list               # List available tests
```

### Code Formatting
```bash
swiftformat .                 # Format all Swift files (swiftformat must be installed)
```

### Database
The application automatically runs migrations on startup via `app.autoMigrate()` in configure.swift:5-24.

## Architecture

### Entry Point Flow
1. **entrypoint.swift:6-30** - Application bootstrapping with async/await support
2. **configure.swift:5-30** - Database configuration, migration registration, and route setup
3. **routes.swift** - Controller registration (delegates to individual controllers)

### Database Layer (Fluent ORM)

**Models** (Sources/VoimaDBAPI/Models/):
- All models use custom integer IDs (`@ID(custom: .id, generatedBy: .database)`)
- All models conform to `Model, Content, @unchecked Sendable`
- Relationships use `@Parent`, `@OptionalParent`, and `@Children` property wrappers

**Core Entities**:
- `Lifter` - Athlete records with `@Children` relationship to results
- `Competition` - Events with event type (SBD/bench-only) and equipment (raw/equipped)
- `Result` - Competition results with all 3 attempts for squat/bench/deadlift, best lifts, total, and points
- `Club` - Powerlifting clubs
- `WeightClass` - Weight categories
- `AgeClass` - Age categories
- `TempResult` - Temporary storage for data imports

**Enums** (Models/Enums.swift):
- `Sex`: "M" | "F"
- `EventType`: "SBD" (powerlifting) | "B" (bench press)
- `Equipment`: "Raw" | "SinglePly"

**Migrations** (Sources/VoimaDBAPI/Migrations/):
- Migration order matters - referenced tables must be created first
- Current order in configure.swift:16-22: Lifters → AgeClass → Clubs → Competitions → WeightClass → Results → TempResults

### Controllers (RouteCollection Pattern)

**Controllers** (Sources/VoimaDBAPI/Controllers/):
- All controllers conform to `RouteCollection` protocol
- Controllers implement `boot(routes:)` to register their routes
- Registered in routes.swift using `app.register(collection:)`

**Available Controllers**:
- `LifterController` - Lifter endpoints under `/api/lifters`
- `CompetitionController` - Competition endpoints under `/api/competitions` (includes competition results)
- `ClubController` - Club endpoints under `/api/clubs`
- `ResultController` - Result endpoints under `/api/results`
- `WeightClassController` - Weight class endpoints under `/api/weightclasses`
- `AgeClassController` - Age class endpoints under `/api/ageclasses`
- `AuthController` - Authentication endpoints (user registration, login, logout, Apple Sign In, "me")

**Eager loading**: Results endpoints use `.with()` to eager-load related entities (lifter, competition, club) to avoid N+1 queries.

**Example**: `CompetitionController.results()` fetches competition results and eager-loads lifter and club relationships.

## Database Configuration

**Environment Variables**:
- `DATABASE_HOST` (default: localhost)
- `DATABASE_PORT` (default: 5432)
- `DATABASE_USERNAME` (default: voima)
- `DATABASE_PASSWORD` (default: voimadb)
- `DATABASE_NAME` (default: voimadb)

Connection configured in configure.swift:6-14 with TLS preference.

## Swift Settings

Package.swift:42-44 enables upcoming Swift features:
- `ExistentialAny` - requires explicit `any` keyword for existential types
