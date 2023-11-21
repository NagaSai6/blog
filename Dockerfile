FROM ghost:5-alpine as cloudinary
RUN apk add g++ make python3
RUN su-exec node yarn add ghost-storage-cloudinary-mod

FROM ghost:5-alpine
COPY --chown=node:node --from=cloudinary $GHOST_INSTALL/node_modules $GHOST_INSTALL/node_modules
COPY --chown=node:node --from=cloudinary $GHOST_INSTALL/node_modules/ghost-storage-cloudinary-mod $GHOST_INSTALL/content/adapters/storage/ghost-storage-cloudinary-mod
# Here, we use the Ghost CLI to set some pre-defined values.
RUN set -ex; \
    su-exec node ghost config storage.active ghost-storage-cloudinary-mod; \
    su-exec node ghost config storage.ghost-storage-cloudinary-mod.upload.use_filename true; \
    su-exec node ghost config storage.ghost-storage-cloudinary-mod.upload.unique_filename false; \
    su-exec node ghost config storage.ghost-storage-cloudinary-mod.upload.overwrite false; \
    su-exec node ghost config storage.ghost-storage-cloudinary-mod.fetch.quality auto; \
    su-exec node ghost config storage.ghost-storage-cloudinary-mod.fetch.cdn_subdomain true; \
    su-exec node ghost config mail.transport "SMTP"; \
    su-exec node ghost config mail.options.service "Mailgun";