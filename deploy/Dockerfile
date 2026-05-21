# syntax=docker/dockerfile:1.7

# --- Stage 1: build the static dist/ ---
FROM elixir:1.18.2-otp-27-alpine AS builder
WORKDIR /src

# Copy everything; the build_index script needs lessons/, shared/, and tools/.
COPY . .

# Render the landing page + copy lesson slides + vendored reveal.js into /dist.
# The build_index script has no Hex deps; it uses only Elixir stdlib + EEx.
RUN elixir tools/build_index/build_index.exs \
        --lessons /src/lessons \
        --shared /src/shared/reveal \
        --out /dist

# --- Stage 2: serve dist/ with non-root nginx ---
FROM nginxinc/nginx-unprivileged:alpine
USER root
COPY deploy/nginx.conf.template /etc/nginx/templates/default.conf.template
COPY --from=builder /dist /usr/share/nginx/html
# Drop back to the unprivileged user the image ships with (UID 101).
USER 101
EXPOSE 8080
