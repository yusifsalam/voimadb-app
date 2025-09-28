# Powerlifting Competition API

A Vapor-based REST API for managing powerlifting competitions, lifters, clubs, and results.

## Database Schema

This API implements the following database tables:
- `age_class` - Age categories for competitions
- `clubs` - Powerlifting clubs
- `competitions` - Competition events
- `lifters` - Individual powerlifters
- `results` - Competition results for each lifter
- `temp_results` - Temporary results storage (for imports)
- `weight_class` - Weight categories

## Setup

1. Install PostgreSQL and create a database
2. Copy `.env.example` to `.env` and update database credentials
3. Build and run the application:

```bash
swift build
swift run
```

The application will automatically run migrations on startup.

## API Endpoints

### Lifters
- `GET /api/lifters` - Get all lifters
- `GET /api/lifters/:id` - Get lifter by ID

### Competitions
- `GET /api/competitions` - Get all competitions
- `GET /api/competitions/:id` - Get competition by ID
- `GET /api/competitions/:id/results` - Get results for a competition

### Clubs
- `GET /api/clubs` - Get all clubs
- `GET /api/clubs/:id` - Get club by ID

### Results
- `GET /api/results` - Get all results with lifter, competition, and club data
- `GET /api/results/:id` - Get result by ID

### Weight Classes
- `GET /api/weightclasses` - Get all weight classes

### Age Classes
- `GET /api/ageclasses` - Get all age classes

