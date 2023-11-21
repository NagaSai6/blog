# Stage 1: Build the ghost-storage-cloudinary package
FROM node:14-alpine as cloudinary_builder

WORKDIR /app

# Install dependencies for building the package
RUN apk add g++ make python3

# Add ghost-storage-cloudinary package
RUN yarn add ghost-storage-cloudinary

# Stage 2: Copy the node_modules to the final image
FROM ghost:5-alpine

# Set the working directory
WORKDIR $GHOST_INSTALL

# Copy the node_modules and ghost-storage-cloudinary package from the builder stage
COPY --from=cloudinary_builder /app/node_modules ./node_modules
COPY --from=cloudinary_builder /app/node_modules/ghost-storage-cloudinary ./content/adapters/storage/ghost-storage-cloudinary

# Configure Ghost
RUN set -ex; \
    su-exec node ghost config storage.active ghost-storage-cloudinary; \
    su-exec node ghost config storage.ghost-storage-cloudinary.upload.use_filename true; \
    su-exec node ghost config storage.ghost-storage-cloudinary.upload.unique_filename false; \
    su-exec node ghost config storage.ghost-storage-cloudinary.upload.overwrite false; \
    su-exec node ghost config storage.ghost-storage-cloudinary.fetch.quality auto; \
    su-exec node ghost config storage.ghost-storage-cloudinary.fetch.cdn_subdomain true; \
    su-exec node ghost config mail.transport "SMTP"; \
    su-exec node ghost config mail.options.service "Mailgun";
