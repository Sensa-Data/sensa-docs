# Use the official nginx base image
FROM nginx:alpine

# Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

# Copy bookdown output to nginx web root
COPY site-public/ /usr/share/nginx/html/

# Remove default Nginx configuration
RUN rm -rf /etc/nginx/conf.d/*
# Copy your custom Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/engine_guide.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
