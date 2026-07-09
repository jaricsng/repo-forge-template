# syntax=docker/dockerfile:1
# Multi-stage build: compile in a full Go image, ship a distroless runtime.
# Distroless has no shell, package manager, or extraneous binaries, which
# minimizes attack surface and keeps the CVE scan surface small.

FROM golang:1.22-bookworm AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /out/app ./cmd/app

FROM gcr.io/distroless/static-debian12:nonroot AS runtime
# distroless:nonroot already runs as uid 65532, satisfying policy/dockerfile_no_root.rego
USER nonroot:nonroot
COPY --from=build --chown=nonroot:nonroot /out/app /app
EXPOSE 8080
ENTRYPOINT ["/app"]
