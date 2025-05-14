# DocTech Project Docker Setup

This repository contains a Docker-based setup for the DocTech website and dashboard applications, along with a PostgreSQL database. The setup uses Docker volumes to store product images and PDF files, making them accessible to both applications.

## Project Structure

- `docTech/` - Next.js website for customer-facing content
- `docTech Dashboard/` - Vite-based admin dashboard for product management
- `init-db/` - Database initialization scripts
- `docker-compose.yml` - Docker Compose configuration

## Docker Volumes

The setup includes three Docker volumes:

1. `postgres-data` - Stores the PostgreSQL database data
2. `product-images` - Stores product images (shared between both applications)
3. `product-docs` - Stores product PDF documents (shared between both applications)

## Getting Started

### Prerequisites

- Docker and Docker Compose installed on your system
- Git (to clone the repository)

### Running the Applications

1. Clone the repository:
   ```
   git clone <repository-url>
   cd DocProject
   ```

2. Start the Docker containers:
   ```
   docker-compose up -d
   ```

3. Access the applications:
   - Website: http://localhost:3000
   - Dashboard: http://localhost:5173

## How It Works

### Database

The PostgreSQL database is initialized with the schema defined in `init-db/01-schema.sql`. Both applications connect to this database using the environment variables defined in the Docker Compose file.

### File Storage

Instead of storing images and PDFs as base64 strings in the database, this setup:

1. Stores files in Docker volumes
2. Saves only the file paths in the database
3. Serves the files via the web servers

When a new product is added through the dashboard:
1. Images and PDFs are uploaded to the server
2. Files are saved to the appropriate Docker volume
3. File paths are stored in the database
4. The website can access these files using the stored paths

## Configuration

Environment variables for each service are defined in the `docker-compose.yml` file. You can modify these as needed.

## Troubleshooting

- **Database Connection Issues**: Ensure the PostgreSQL container is running with `docker ps`. Check the logs with `docker logs doctech-postgres`.
- **File Upload Problems**: Check the dashboard container logs with `docker logs doctech-dashboard`.
- **Website Access Issues**: Check the website container logs with `docker logs doctech-website`.

## Development

To make changes to the applications:

1. Stop the containers: `docker-compose down`
2. Make your changes to the source code
3. Rebuild the containers: `docker-compose up -d --build`
