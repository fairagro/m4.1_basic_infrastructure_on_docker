#FROM postgres:16
FROM postgres:16.3

# Install dependencies needed to build extensions
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        git \
        postgresql-server-dev-16 \
        ca-certificates \
        curl \
	vim-tiny \
	procps \
        gnupg && \
    update-ca-certificates

# Install set_user extension
RUN git clone https://github.com/pgaudit/set_user.git /tmp/set_user && \
    cd /tmp/set_user && \
    make && make install && \
    cd / && rm -rf /tmp/set_user

# Install pg_stat_kcache extension
RUN git clone https://github.com/powa-team/pg_stat_kcache.git /tmp/pg_stat_kcache && \
    cd /tmp/pg_stat_kcache && \
    make && make install && \
    cd / && rm -rf /tmp/pg_stat_kcache

# Clean up to reduce image size
RUN apt-get remove -y build-essential make git postgresql-server-dev-16 && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Optionally set preload libraries (can also be done at runtime)
ENV POSTGRES_INITDB_ARGS="--auth-host=scram-sha-256"

