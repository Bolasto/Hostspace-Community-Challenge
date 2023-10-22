# Step 1: Build the Vue.js application
FROM node:latest AS vue-builder

WORKDIR /app

# Copy the Vue.config.js app files
COPY . .

# Install dependencies and build the app
RUN npm install
RUN npm run build

# Specify the location where the artifacts are saved within the stage


# Step 2: Build the Python Flask proxy
FROM python:3.9 AS flask-builder

WORKDIR /app

# Copy the Flask app files
COPY . .

# Install Flask dependencies (You may need to adapt this depending on your setup)
RUN pip install -r requirements.txt

# Step 3: Create the final image with Nginx
FROM nginx:alpine


# Copy the built Vue.js app from the Vue builder stage
COPY --from=vue-builder /app/dist /app/dist

# Copy the Flask app from the Flask builder stage
COPY --from=flask-builder /app /app

# Copy the nginx configuration
COPY ./nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80 for Nginx
EXPOSE 80

# Define an environment variable to connect to Flask
ENV VUE_APP_PROXY_URL=http://127.0.0.1:5000/


# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
