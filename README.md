# Healthie Rails Interview Project

Rails API application for managing healthcare providers, their clients, and client notes.

## Overview

This application manages relationships between healthcare providers (e.g., dietitians) and their clients, including plan assignments and client notes/journal entries.

## Tech Stack

- **Ruby:** 3.3.11
- **Rails:** 8.1.3 (API-only)
- **Database:** SQLite3
- **Testing:** RSpec, FactoryBot, Faker

## Data Model

### Provider
- `name` (string, required)
- `email` (string, required, unique, validated format)
- Has many clients through provider_assignments

### Client
- `name` (string, required)
- `email` (string, required, unique, validated format)
- Has many providers through provider_assignments
- Has many notes

### ProviderAssignment (Join Table)
- `provider_id` (foreign key)
- `client_id` (foreign key)
- `plan` (enum: basic [0], premium [1], required, defaults to basic)
- Unique constraint on [provider_id, client_id]

### Note
- `client_id` (foreign key, required)
- `content` (text, required)
- `created_at` (timestamp, indexed)
- Belongs to client

## API Endpoints

### Providers

**Get provider with their clients:**
```
GET /api/v1/providers/:id?page=1&per_page=10
```
Returns provider details with assigned clients and their plan types.

Query parameters:
- `page` (optional, default: 1)
- `per_page` (optional, default: 10, max: 100)

**Get all notes from provider's clients:**
```
GET /api/v1/providers/:id/notes?page=1&per_page=10
```
Returns notes from all clients assigned to the provider, sorted by date (newest first).

Query parameters:
- `page` (optional, default: 1)
- `per_page` (optional, default: 10, max: 100)

### Clients

**Get client with their providers:**
```
GET /api/v1/clients/:id?page=1&per_page=10
```
Returns client details with assigned providers and plan types.

Query parameters:
- `page` (optional, default: 1)
- `per_page` (optional, default: 10, max: 100)

**Get all notes for a client:**
```
GET /api/v1/clients/:client_id/notes?page=1&per_page=10
```
Returns notes for the client, sorted by date (newest first).

Query parameters:
- `page` (optional, default: 1)
- `per_page` (optional, default: 10, max: 100)

**Create a note for a client:**
```
POST /api/v1/clients/:client_id/notes
Content-Type: application/json

{
  "note": {
    "content": "Note content here"
  }
}
```
Creates a new note for the client.

### Pagination

All endpoints support pagination with query parameters:
- `page` - Page number (default: 1)
- `per_page` - Items per page (default: 10, max: 100)

Paginated responses include:
```json
{
  "notes": [...],
  "pagination": {
    "current_page": 1,
    "per_page": 10,
    "total_pages": 3,
    "total_count": 22
  }
}
```

### Error Responses

- `404` - Resource not found (Provider/Client doesn't exist)
- `422` - Unprocessable entity (Validation errors)

## Setup

### Prerequisites
- Ruby 3.3.11 (using rbenv)
- Bundler

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   bundle install
   ```

3. Set up the database:
   ```bash
   ./bin/rails db:create db:migrate
   ```

4. Seed with fun sample data (TV doctors & superhero patients):
   ```bash
   ./bin/rails db:seed
   ```

   This creates:
   - 4 TV doctor providers (Dr. House, Dr. Yang, Dr. JD, Dr. Robinavitch)
   - 8 superhero clients (Batman, Spider-Man, Wonder Woman, Iron Man, etc.)
   - 14 provider-client assignments with different plan types
   - 22 health notes with entertaining content

## Running the Application

Start the Rails server:
```bash
./bin/rails server
```

The API will be available at `http://localhost:3000`

## Testing

Run the full test suite:
```bash
./bin/rspec
```

Run specific test files:
```bash
./bin/rspec spec/models/
./bin/rspec spec/requests/
```

**Test Coverage:**
- 25 model specs
- 15 request/integration specs (including pagination tests)
- All 40 specs passing

## Example Usage

### Using curl

Create test data:
```bash
# In Rails console (./bin/rails c)
provider = Provider.create!(name: "Dr. Smith", email: "smith@example.com")
client = Client.create!(name: "John Doe", email: "john@example.com")
ProviderAssignment.create!(provider: provider, client: client, plan: :premium)
```

Test endpoints:
```bash
# Get provider with clients
curl http://localhost:3000/api/v1/providers/1

# Get client with providers
curl http://localhost:3000/api/v1/clients/1

# Create a note
curl -X POST http://localhost:3000/api/v1/clients/1/notes \
  -H "Content-Type: application/json" \
  -d '{"note": {"content": "Feeling great today!"}}'

# Get client's notes
curl http://localhost:3000/api/v1/clients/1/notes

# Get all notes from provider's clients
curl http://localhost:3000/api/v1/providers/1/notes
```

## ActiveRecord Query Examples

```ruby
# All clients for a given provider
provider = Provider.find(1)
provider.clients

# All providers for a given client
client = Client.find(1)
client.providers

# All notes for a given client, sorted by date
client = Client.find(1)
client.notes.sorted_by_date

# All notes across all clients of a given provider, sorted by date
provider = Provider.find(1)
provider.clients.flat_map(&:notes).sort_by(&:created_at).reverse
```

## Project Structure

```
app/
├── controllers/
│   ├── concerns/
│   │   └── paginatable.rb      # Shared pagination logic
│   └── api/v1/
│       ├── providers_controller.rb
│       ├── clients_controller.rb
│       └── notes_controller.rb
├── models/
│   ├── provider.rb
│   ├── client.rb
│   ├── provider_assignment.rb
│   └── note.rb
spec/
├── models/          # Model unit tests
├── requests/        # API integration tests
└── factories/       # Test data factories
```

## Design Decisions

### Separate Provider and Client Tables
Chose to keep providers and clients as separate entities rather than a single `users` table with roles, because:
- Clear separation of concerns
- Different entities can have specific attributes
- The role "cannot change" per requirements (suggesting entity types, not permissions)
- Matches domain language

### ProviderAssignment Join Model
Used a proper join model instead of a simple join table to:
- Store additional attributes (plan type)
- Support validation and business logic
- Maintain referential integrity with foreign keys

### Integer Enum for Plan
Used integer storage for the plan enum following Rails conventions:
- More efficient storage and indexing
- Rails provides helper methods (basic?, premium!)
- Easy to extend with additional plan types

### Notes Sorted by Date
Added database index on `created_at` and a scope for efficient date-sorted queries.
