# My Rails API Project

This project is a Rails API application that demonstrates a full solution for matching `Partners` with a customer and fetch `Partner` details

## Table of Contents

- [Overview](#overview)
- [Tech Stack](#tech-stack)
- [Features](#features)
- [Installation](#installation)
- [API endpoints](#api-endpoints)
- [Assumptions](#assumptions)
- [Tech decisions and architecture](#tech-decisions-and-architecture)
  - [Why docker](#why-docker)
  - [Why Rails Over Sinatra](#why-rails-over-sinatra)
  - [Why PostgreSQL with Its PostGIS extension](#why-postgresql-with-its-postgis-extension)
  - [What is PostGIS](#what-is-postgis)
  - [Why Redis instead of Memcache](#why-redis-instead-of-memcache)
  - [Database Structure and Indexes](#database-structure-and-indexes)
    - [Why this structure](#why-this-structure)
    - [Indexes](#indexes)
  - [Sliding Cache](#sliding-cache)
  - [Backend Architecture & Design Patterns](#backend-architecture-and-design-patterns)
- [Run tests](#run-tests)

## Overview

This Rails API project provides endpoints for fetching partner data. It leverages a custom caching solution called **SlidingCache** to reduce load by caching partner data for a configurable period. The API is fully documented via Swagger and tested with RSpec.

## Tech-Stack

In this application, I used the following:

- **Ruby version:** 3.4.2
- **Rails version:** 8
- **Database:** PostgreSQL with the PostGIS extension (postgis:14-3.3)
- **Cache:** Redis

### Gems

- **Testing:**  
  - `rspec` for testing, along with supporting gems such as `factory_bot_rails`, `faker`, and `shoulda-matchers`.

- **Caching:**  
  - `redis` for interfacing with Redis.

- **Database:**  
  - `activerecord-postgis-adapter` for effective use of PostGIS in Rails.

- **Code Quality:**  
  - `rubocop` for enforcing code style and quality.


## Features

- **API Endpoints**: Provides endpoints to list and retrieve partner details.
- **SlidingCache**: Implements a sliding expiration cache using Redis.
- **RSpec Tests**: Extensive test coverage for caching logic and API endpoints.
- **Makefile**: Added a Makefile to help run the application 
- **Modular Architecture**: Uses service objects and serializers for clean code separation.

## Installation

### Prerequisites

- [Docker](https://www.docker.com/get-started)
- (Optional) [Docker Compose](https://docs.docker.com/compose/)

### Steps

1. **Clone the repository:**

   ```bash
   git clone git@github.com:kamal-buqaileh/around_home.git
   cd around_home
   ```
2. **Build and start the Docker containers**
   
   ```bash
   make build
   make up
   ```

   or
   
   ```bash
   docker-compose up --build
   ```
   The app should be listening to `localhost:3000` now

2. **Create Database**
   Access the container using
   ```bash
      make bash
   ```

   or

   ```bash
   docker-compose exec app bash
   ```

   Then run:
   
   ```bash
   rails db:create
   rails db:migrate
   ```
   Optional: run `seed`
   ```bash
   rails db:seed
   ```

## API endpoints

`GET /api/v1/partners`
Retrieves a list of partners based on provided query parameters (e.g., latitude, longitude, service_id, material_id, last_id, limit).

NOTE: I'm using `Keyset Pagination` in the matching query instead of `Offset` for better performance.

`GET /api/v1/partners/:id`
Retrieves detailed information for a single partner. If the partner is not found, the API returns a 404 error with an appropriate message.

--------------------------------------------

# Assumptions

1. Public API:
  The API is designed as a public interface, so there's no need for a dedicated customer table. This   assumption is based on the observation that users can browse services without signing in.

2. Extensible Services and Materials:
  The design anticipates that new services and materials may be added in the future. By maintaining separate tables for services and materials, new entries can be added easily—without modifying the codebase or writing complex queries.

3. Caching Strategy:
  A sliding cache is used to store expensive query results with a configurable expiration time (TTL). The current TTL is chosen to balance performance and traffic; however, this value can be adjusted as we gain a better understanding of the usage patterns.

# Tech-decisions-and-architecture

### Why Docker

- Consistent Environments: Docker packages the app with all its dependencies, ensuring it runs the same in development, testing, and production.
- Isolation: Containers isolate services (Rails, PostGIS, Redis), preventing conflicts and simplifying resource management.
- Simplified Deployment & Scaling: Docker makes deployment predictable and scaling straightforward.
- Quick Setup: Sharing the project is easy—new team members can get the app up and running in no time with a single Docker command.

--------------------------------------------

### Why Rails Over Sinatra
- Convention Over Configuration: Rails provides a robust, opinionated structure (MVC) that speeds up development by reducing boilerplate code.

- Integrated Tools: With built-in features like ActiveRecord, caching, and API-only mode, Rails handles many common tasks out of the box.

- Scalability & Maintainability: Rails’ modular architecture (service objects, serializers) and extensive community support make it easier to scale and maintain as the project grows.

- API-Only Mode: Rails has an API-only mode that strips away unnecessary middleware and view rendering, making it lightweight and optimized for serving JSON responses.

Overall, Rails was chosen for its productivity, comprehensive ecosystem, and the structured environment it offers—making it ideal for building and maintaining a feature-rich API.

--------------------------------------------

### Why PostgreSQL with Its PostGIS extension

- Robust and Reliable: PostgreSQL is a proven, enterprise-grade database known for its stability and performance.

- Advanced Features: Its support for advanced SQL features, indexing, and transactions makes it ideal for complex queries.

- Geospatial Capabilities: With the PostGIS extension, PostgreSQL efficiently handles spatial data and geolocation queries—perfect for matching partners based on location.

- Scalability: PostgreSQL scales well with the application's growing data and query complexity.


Overall, PostgreSQL with PostGIS provides the robust, feature-rich foundation needed for our API's performance and spatial data handling.

--------------------------------------------

### What is PostGIS

[PostGIS](https://postgis.net/) is a spatial database extension for PostgreSQL that adds support for geographic objects. It allows you to perform location-based queries and spatial operations directly within your database. With PostGIS, you can efficiently store, query, and analyze geospatial data, making it ideal for applications that require mapping, location-based filtering, or spatial analytics. This capability is particularly useful in our project for matching partners based on geographic location.

--------------------------------------------

### Why Redis instead of Memcache

While Memcache is indeed excellent for simple, high-speed caching, my decision leaned toward Redis because it aligns better with both the current needs and potential future requirements. The atomic operations, flexibility, and additional features in Redis provide a more robust foundation for our caching strategy—especially for our sliding expiration cache.

With that being said, we can discuss this part more if you think memcached would be a better fit.

--------------------------------------------

## Database Structure and Indexes

![Database drawio (2)](https://github.com/user-attachments/assets/339d9339-bc0c-419b-a1a3-180a8f90be7e)


### Why this structure

- I wanted to decouple things from each other
- This way, we can add new services and assign them to partners easily in the future
- For example, if we want to add a "Plumbing" service, we can add it to the "Services" table
and then assign it to a partner, allowing easy extendability for the services
- For the materials, we can add them easily here also
- No need to duplicate Materials and services for every partner
- In case we want to add a variation of the materials (Solid Wood, Bamboo, ..etc)
we can easily extend the Materials table or create a Variation/Categories table with a relation
to the Materials table

### Indexes
1. Partners Table Indexes:

    - GiST Index on geog: Enables fast spatial queries using functions like ST_DWithin and ST_Distance by narrowing down the search area quickly.
    - B-tree Index on rating: Supports efficient sorting of partners by rating.
      
3. Services Table Indexes:
  
    - Unique Index on name: Ensures service names are unique and allows fast lookups.

4. Materials TablIndexes:
  
    - Unique Index on name: Prevents duplicate material names and speeds up queries.

5. PartnerServices Table (Join table between Partners and Services) Indexes:
  
    - Composite Unique Index on [partner_id, service_id]: Prevents duplicate associations and accelerates join operations when fetching a partner's       services.

6. ServiceMaterials Table (Join table between Services and Materials)Indexes:
  
    - Composite Unique Index on [service_id, material_id]: Prevents duplicate associations and enhances the performance of join queries involving services and materials.
  

**Match Query Analyize**

By using the indexes mentioned above we will not have to do a Full Seq Scan of the tables when looking for records:

![Screenshot 2025-02-17 at 11 33 42 PM](https://github.com/user-attachments/assets/41912839-16c7-42ee-b363-ab21565eb9b9)


------------------------------------

## Sliding Cache

I used a sliding cache for the expensive query results (stored in Redis). Instead of a fixed expiration, the cache expiration is reset every time the data is accessed. This means:

- Adaptive Expiration: Frequently accessed data stays in the cache longer.
- Performance Improvement: Reduces repeated expensive database queries.
- Efficient Resource Use: Infrequently accessed data expires automatically.

This strategy helps keep our API responsive and minimizes unnecessary load on the database.

------------------------------------

## Backend Architecture and Design Patterns

![Backend drawio (1) drawio (1)](https://github.com/user-attachments/assets/26d5827e-be6a-4bc9-af51-b0c6a895d641)

The API is built using Ruby on Rails and follows a layered, modular architecture that emphasizes separation of concerns and adheres to SOLID principles. Key design patterns and strategies include:

- API Versioning:

  - Routes are namespaced (e.g., /api/v1/) to enable backward compatibility and easy evolution of the API.

- Controllers:

  - Serve as the entry point for HTTP requests.
  - Use strong parameters for secure input handling.
  - Delegate business logic to service objects and handle HTTP-specific concerns like response status and ETags.
 
- Service Objects:

  - Encapsulate business logic (e.g., matching partners, fetching partner details) to keep controllers lean.
  - Provide a single-responsibility interface (each service has a call method).
  - Log errors and manage fallback behavior.

- Query Objects:

  - Handle complex data retrieval logic, including spatial queries and joins.
  - Incorporate caching (using a custom sliding cache module) to avoid running expensive queries repeatedly.

- Serializers:

  - Format model data into structured JSON responses.
  - Use namespaced serializers (e.g., PartnerSerializers::DetailSerializer, PartnerSerializers::MatchSerializer) to tailor output for different endpoints (detailed vs. summary views).
  - Follow the JSON:API specification for consistency.

- Caching (Sliding Cache):

  - Caches expensive query results using Redis.
  - Uses a sliding expiration strategy: each time a cached record is accessed, its expiry resets.
  - Reduces database load and improves response times.
  
- Global Logging & Instrumentation:

  - Uses a global structured logger (e.g., StructuredLogger or SlidingCache with logging) to record errors and performance metrics.
  - Provides consistent JSON log outputs for easier debugging and monitoring.

**Benefits of Our Approach**
- Modularity: Each layer (controllers, services, queries, serializers) has a clear responsibility, making the codebase easy to understand and maintain.
- Scalability: The use of caching and efficient query objects ensures our API remains responsive under load.
- Extensibility: API versioning and a well-defined service layer allow us to introduce new features without breaking existing functionality.
- Testability: Isolated units (services, queries, serializers) are easy to test, which helps prevent regressions and improve reliability.


This architecture helps us build a robust, maintainable, and scalable API. Feel free to reach out if you have any questions or need further details on any component!

-----------------------------

## Run tests

To run the tests simply run the following:

1. Access the container
   ```bash
      make bash
   ```

   or

   ```bash
   docker-compose exec app bash
   ```
2. Run
   ```bash
   rspec
   ```
