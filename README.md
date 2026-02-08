# OHDSI WhiteRabbit Docker

A Dockerized build of OHDSI **WhiteRabbit** with:

- **CLI mode** (default)
- **GUI mode** (optional via Xvfb + VNC)

---

## Quick start (end‑user guide)

### 1) Pull the image from Docker Hub

```bash
docker pull edence/ohdsi-whiterabbit-docker:main
```

### 2) Run WhiteRabbit in CLI mode (default)

Pass any WhiteRabbit CLI arguments directly to the container:

```bash
docker run --rm edence/ohdsi-whiterabbit-docker:main --help
```

Example:

```bash
docker run --rm \
  -v /path/on/host:/data \
  edence/ohdsi-whiterabbit-docker:main \
  --input /data/your-file.csv --output /data/scan-report
```

**Note:** WhiteRabbit’s CLI options are defined by the tool itself.  
Use `--help` or refer to OHDSI documentation for the exact parameters.

---

## GUI mode (optional)

GUI mode runs WhiteRabbit in a headless X server with optional VNC.

### Run GUI with VNC

```bash
docker run --rm -p 5900:5900 \
  -e ENABLE_VNC=1 \
  -e VNC_PASSWORD=ohdsi \
  edence/ohdsi-whiterabbit-docker:main gui
```

Then connect using any VNC client:

```
Host: localhost:5900
Password: ohdsi
```

---

## Working with files (input/output)

Mount a host folder into the container (recommended at `/data`):

```bash
docker run --rm \
  -v /your/local/folder:/data \
  edence/ohdsi-whiterabbit-docker:main \
  --input /data/input.csv --output /data/output
```

---

## Java options

If you need more memory or JVM tuning:

```bash
docker run --rm \
  -e WR_JAVA_OPTS="-Xmx4g" \
  edence/ohdsi-whiterabbit-docker:main --help
```

---

## Troubleshooting

### “Username and password required” in GitHub Actions
This is a CI error caused by missing Docker Hub secrets.  
Make sure `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` are set in repo secrets.

### GUI not showing in VNC
- Ensure `-p 5900:5900` is set
- Ensure `ENABLE_VNC=1` is set
- Check container logs: `docker logs <container_id>`

---

# Developer guide

## Build locally

```bash
docker build -t ohdsi-whiterabbit .
```

Optionally pin WhiteRabbit version:

```bash
docker build --build-arg WR_REF=v2.0.5 -t ohdsi-whiterabbit .
```

## Run locally (CLI)

```bash
docker run --rm ohdsi-whiterabbit --help
```

---

# License & attribution

WhiteRabbit is an OHDSI tool.  
Please follow the OHDSI project’s licensing and attribution requirements.

