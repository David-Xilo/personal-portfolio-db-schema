FROM postgres:17.5

# Create initialization script to configure PostgreSQL for container networking
RUN echo '#!/bin/bash' > /docker-entrypoint-initdb.d/setup_networking.sh && \
    echo 'set -e' >> /docker-entrypoint-initdb.d/setup_networking.sh && \
    echo 'echo "host all all 0.0.0.0/0 md5" >> "$PGDATA/pg_hba.conf"' >> /docker-entrypoint-initdb.d/setup_networking.sh && \
    echo 'echo "listen_addresses = '"'"'*'"'"'" >> "$PGDATA/postgresql.conf"' >> /docker-entrypoint-initdb.d/setup_networking.sh && \
    chmod +x /docker-entrypoint-initdb.d/setup_networking.sh

# Expose the standard PostgreSQL port
EXPOSE 5432
