# Use the official Elixir image based on Alpine Linux
FROM elixir:1.17-alpine AS build

# Install build dependencies
RUN apk add --no-cache build-base npm git python3

# Set build ENV
ENV MIX_ENV=prod

# Create and set the working directory
WORKDIR /app

# Install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Copy mix files
COPY mix.exs mix.lock ./

# Install mix dependencies
RUN mix deps.get --only=prod
RUN mkdir config

# Copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

# Copy assets
COPY assets assets

# Install npm dependencies and compile assets
RUN cd assets && npm ci --only=production

# Copy source code
COPY priv priv
COPY lib lib

# Compile assets
RUN mix assets.deploy

# Compile the release
RUN mix compile

# Copy runtime configuration (must be after compile)
COPY config/runtime.exs config/

# Generate the release
RUN mix release

# Start a new stage for the final image
FROM alpine:3.19 AS app

# Install runtime dependencies
RUN apk add --no-cache libstdc++ openssl ncurses-libs sqlite

# Create app user
RUN addgroup -g 1000 app && \
    adduser -u 1000 -G app -s /bin/sh -D app

# Create necessary directories
RUN mkdir -p /app/data /app/uploads && \
    chown -R app:app /app

# Set the working directory
WORKDIR /app

# Copy the release from the build stage
COPY --from=build --chown=app:app /app/_build/prod/rel/myhp ./

# Switch to app user
USER app

# Expose the port
EXPOSE 4000

# Set environment variables
ENV MIX_ENV=prod
ENV DATABASE_PATH=/app/data/myhp.db
ENV UPLOAD_PATH=/app/uploads

# Create volume for data persistence
VOLUME ["/app/data", "/app/uploads"]

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:4000/ || exit 1

# Start the application
CMD ["./bin/myhp", "start"]