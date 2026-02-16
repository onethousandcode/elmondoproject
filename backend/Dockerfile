# Stage 1: Build Flutter web
FROM cirrusci/flutter:stable AS build

WORKDIR /app

# Copy pubspec first to leverage Docker cache
COPY pubspec.* ./
RUN flutter pub get

# Copy the rest of your code
COPY . ./

# Build the web app
RUN flutter build web --release

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Remove default nginx content
RUN rm -rf /usr/share/nginx/html/*

# Copy built web app from previous stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Expose port 5000
EXPOSE 5000

CMD ["nginx", "-g", "daemon off;"]
