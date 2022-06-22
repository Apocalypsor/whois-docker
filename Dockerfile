FROM --platform=${BUILDPLATFORM} golang:alpine AS build

WORKDIR /src

ARG CGO_ENABLED=0
ARG TARGETOS
ARG TARGETARCH

COPY whois .

RUN go mod tidy \
    && GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o /out/whois .

FROM alpine

WORKDIR /app

COPY --from=build /out/whois /app/whois
COPY --from=build /src/config.toml /app/config.toml
COPY --from=build /src/*_list /app/

RUN set -xe \
    && chmod +x /app/whois

CMD /app/whois