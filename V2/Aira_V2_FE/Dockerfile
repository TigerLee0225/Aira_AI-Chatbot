# ---------------------------
# Stage 1: Build the application
# ---------------------------
FROM node:14 AS build

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json (or yarn.lock) first
COPY package*.json ./

# Install dependencies
RUN npm install
    
# Copy the rest of your application code
COPY . .
    
# Build the application in production mode
RUN npm run build
    
# ---------------------------
# Stage 2: Serve the built assets with Nginx
# ---------------------------
FROM nginx:stable-alpine
    
# Remove the default Nginx website
RUN rm -rf /usr/share/nginx/html/*
    
# Copy the production build from the previous stage
COPY --from=build /app/dist /usr/share/nginx/html

# Copy your custom Nginx configuration file
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80
    
# Start Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]