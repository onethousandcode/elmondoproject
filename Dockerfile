# Stage 1: Build Flutter Web
FROM ubuntu:22.04 AS build

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m flutteruser
USER flutteruser
WORKDIR /home/flutteruser/app

# Install Flutter in home directory
RUN git clone https://github.com/flutter/flutter.git -b stable /home/flutteruser/flutter
ENV PATH="/home/flutteruser/flutter/bin:/home/flutteruser/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Copy pubspec files as flutteruser
COPY --chown=flutteruser:flutteruser pubspec.* ./

# Run flutter doctor and get dependencies
RUN flutter doctor -v
RUN flutter pub get

# Copy rest of project as flutteruser
COPY --chown=flutteruser:flutteruser . .

# Build web
RUN flutter build web --release
