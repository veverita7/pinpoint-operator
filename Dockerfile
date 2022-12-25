# Build the manager binary
FROM golang:1.19 as builder

ARG TARGETOS
ARG TARGETARCH

WORKDIR /workspace

# Copy the Go Modules manifests
COPY go.mod go.mod
COPY go.sum go.sum
RUN go mod download

# Copy the go source
COPY main.go main.go
COPY api/ api/
COPY controllers/ controllers/

# Build
RUN CGO_ENABLED=0 GOOS=${TARGETOS:-linux} GOARCH=${TARGETARCH} go build -a -o manager main.go

# Use distroless as minimal base image to package the manager binary
FROM gcr.io/distroless/static:nonroot

LABEL org.opencontainers.image.source=https://github.com/veverita7/pinpoint-operator
LABEL org.opencontainers.image.licenses=Apache-2.0
LABEL org.opencontainers.image.description="Pinpoint Operator"

WORKDIR /usr/local/bin

COPY --from=builder /workspace/manager pinpoint-operator

USER 65532:65532

ENTRYPOINT ["pinpoint-operator"]
