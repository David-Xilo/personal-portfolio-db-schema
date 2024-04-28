# Use the official PostgreSQL image from the Docker Hub
FROM postgres:latest

# Set environment variables
# ENV POSTGRES_DB=mydatabase
# ENV POSTGRES_USER=myuser
# ENV POSTGRES_PASSWORD=mypassword

# Expose the PostgreSQL port
EXPOSE 5432

# Copy initialization scripts from tables directory
COPY ./schema/tables/*.sql /docker-entrypoint-initdb.d/

# Copy initialization scripts from constraints directory
COPY ./schema/constraints/*.sql /docker-entrypoint-initdb.d/

# Define the directory to be used as a volume
# VOLUME /var/lib/postgresql/data

# Set default command
CMD ["postgres"]