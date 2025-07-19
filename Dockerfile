FROM elixir:1.15-otp-26-alpine

# Install build dependencies
RUN apk add --no-cache \
    build-base \
    npm \
    git \
    python3 \
    inotify-tools

# Create app directory
WORKDIR /app

# Install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Copy mix files
COPY mix.exs mix.lock ./

# Install dependencies
RUN mix deps.get

# Copy config files first
COPY config ./config

# Copy assets
COPY assets ./assets

# Copy priv folder
COPY priv ./priv

# Copy source code
COPY lib ./lib

# Compile the project first (without assets)
RUN mix compile

EXPOSE 4000

CMD ["mix", "phx.server"]
