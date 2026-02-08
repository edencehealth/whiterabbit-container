# OHDSI WhiteRabbit Docker

This image builds WhiteRabbit from the official OHDSI sources and supports:

- WhiteRabbit **CLI** (default)
- WhiteRabbit **GUI** (optional, via Xvfb + VNC)

## Build

```bash
docker build -t ohdsi-whiterabbit .
