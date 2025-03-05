FROM python:3.11-slim

WORKDIR /app

# Install Bazel dependencies
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    git \
    unzip \
    zip \
    wget \
    pkg-config \
    g++ \
    default-jdk \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Bazelisk with architecture detection
RUN ARCH=$(uname -m); \
    if [ "$ARCH" = "x86_64" ]; then \
      curl -Lo /usr/local/bin/bazel https://github.com/bazelbuild/bazelisk/releases/download/v1.25.0/bazelisk-linux-amd64; \
    elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then \
      curl -Lo /usr/local/bin/bazel https://github.com/bazelbuild/bazelisk/releases/download/v1.25.0/bazelisk-linux-arm64; \
    else \
      echo "Unsupported architecture: $ARCH"; \
      exit 1; \
    fi && \
    chmod +x /usr/local/bin/bazel

# Copy Bazel files first for better caching
COPY .bazelrc MODULE.bazel /app/
COPY requirements.txt requirements_lock.txt /app/

# Copy the rest of the application
COPY . /app/

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Collect static files (optional)
# Skip static collection during build as it might cause issues
# We'll run it after container starts if needed
# RUN bazel run //:manage -- collectstatic --noinput

EXPOSE 8000

# Run the application
CMD ["sh", "-c", "echo 'Waiting for database...' && sleep 5 && bazel run //:manage -- runserver 0.0.0.0:8000"]
# CMD ["bazel", "run", "//:manage", "--", "runserver", "0.0.0.0:8000"]