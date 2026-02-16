# -----------------------
# Stage 1: Build Flutter Web
# -----------------------
FROM ubuntu:22.04 AS build

# Install dependencies for Flutter
RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m flutteruser
USER flutteruser
WORKDIR /home/flutteruser/app

# Install Flutter in home directory
RUN git clone https://github.com/flutter/flutter.git -b stable /home/flutteruser/flutter
ENV PATH="/home/flutteruser/flutter/bin:/home/flutteruser/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Copy pubspec to leverage Docker cache
COPY --chown=flutteruser:flutteruser pubspec.* ./

# Get dependencies
RUN flutter pub get

# Copy the full project
COPY --chown=flutteruser:flutteruser . .

# Build production Flutter web
RUN flutter build web --release

# -----------------------
# Stage 2: Serve with Nginx
# -----------------------
FROM nginx:alpine

# Remove default Nginx content
RUN rm -rf /usr/share/nginx/html/*

# Copy built web files from the previous stage
COPY --from=build /home/flutteruser/app/build/web /usr/share/nginx/html

# Give Nginx permission to read files
RUN chown -R nginx:nginx /usr/share/nginx/html

# Expose port 80 (mapped to 5000 in docker-compose)
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
