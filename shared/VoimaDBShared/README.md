# VoimaDBShared

Shared Swift package containing common types used by both the VoimaDB API server and iOS client.

## Purpose

This package provides a single source of truth for:
- **Request DTOs**: Types sent from client to server
- **Response DTOs**: Types returned from server to client
- **Enums**: Shared enumerations (Sex, EventType, Equipment)

## Benefits

- ✅ Type-safe API communication
- ✅ Compiler catches API mismatches
- ✅ No code duplication
- ✅ Single source of truth for data models
- ✅ Easier refactoring across server and client

## Architecture

### Requests/
Types sent FROM client TO server (e.g., registration data, login credentials)

### Responses/
Types returned FROM server TO client (e.g., user data, authentication tokens)

### Enums/
Shared enumerations used in both directions

## Usage

### Server (Vapor API)

```swift
// Add to Package.swift dependencies:
.package(path: "../../shared/VoimaDBShared")

// Import in controllers:
import VoimaDBShared

// Use in endpoints:
func register(req: Request) async throws -> UserResponse {
    let request = try req.content.decode(UserRegistrationRequest.self)
    // ... process request ...
    return userModel.toResponse()
}
```

### Client (iOS)

```swift
// Add via Xcode: File → Add Package Dependencies → Add Local
// Select: shared/VoimaDBShared

// Import in services:
import VoimaDBShared

// Use in API calls:
func register(...) async throws -> UserResponse {
    let request = UserRegistrationRequest(...)
    let data = try JSONEncoder().encode(request)
    // ... send request ...
    return try JSONDecoder().decode(UserResponse.self, from: data)
}
```

## Development

### Build
```bash
cd shared/VoimaDBShared
swift build
```

### Test
```bash
swift test
```

### Requirements

- Swift 6.0+
- iOS 17+ / macOS 13+
