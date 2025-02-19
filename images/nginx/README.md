# Custom Nginx Docker Image

This Docker image extends the official [Nginx alpine image](https://hub.docker.com/_/nginx/tags?name=mainline-alpine-otel) with additional functionality for templating
configuration files, waiting for dependencies, and OpenTelemetry integration.

## Features

- **Dynamic Configuration**: Uses [
  `goenvtemplator`](https://github.com/aurimasniekis/goenvtemplator) for advanced templating
- **Dependency Management**: Integrated [`wait4x`](https://wait4x.dev/) for service dependency
  orchestration
- **OpenTelemetry Support**: Built-in instrumentation for observability
- **Status Endpoint**: Configurable Nginx status endpoint
- **Custom Logging Formats**: Support for custom log formats

## Entrypoint Scripts

### `09-docker-gen-nginx-conf.sh`

This script handles configuration templating:

1. Processes the main `/etc/nginx/nginx.conf.tmpl` template
2. Supports additional template directories with configurable suffix
3. Preserves the original configuration as a backup

### `90-wait-for-x.sh`

This script ensures Nginx starts only after dependencies are available:

1. Processes `WAIT_FOR_*` environment variables for TCP service dependencies
2. Processes `WAIT_CMD_FOR_*` environment variables for custom wait commands
3. Configurable timeouts for each dependency

## Wait4x Environment Variables

### TCP Service Dependencies

```
WAIT_FOR_db:5432#30s
```

Format: `WAIT_FOR_<service>=<host>:<port>#<timeout>`

- `<service>`: Any identifier
- `<host>:<port>`: The service to wait for
- `<timeout>`: Optional timeout (default: 120s)

### Custom Wait Commands

```
WAIT_CMD_FOR_REDIS="redis redis://redis:6379 --timeout 60s"
```

Format: `WAIT_CMD_FOR_<service>="<wait4x command>"`

## Configuration Variables

### Core Configuration

| Variable               | Default              | Description                             |
|------------------------|----------------------|-----------------------------------------|
| `NGINX_USER`           | `nginx`              | User for Nginx worker processes         |
| `NGINX_PID_FILE`       | `/var/run/nginx.pid` | Path to PID file                        |
| `NGINX_MODULES`        | ``                   | Comma-separated list of modules to load |
| `NGINX_MODULES_CUSTOM` | ``                   | Comma-separated list of custom modules  |

### OpenTelemetry Configuration

| Variable                 | Default                     | Description                      |
|--------------------------|-----------------------------|----------------------------------|
| `NGINX_OTEL`             | `false`                     | Enable OpenTelemetry integration |
| `NGINX_OTEL_ENDPOINT`    | `host.docker.internal:4317` | OpenTelemetry collector endpoint |
| `NGINX_OTEL_INTERVAL`    | `5s`                        | Data export interval             |
| `NGINX_OTEL_BATCH_SIZE`  | `512`                       | Maximum batch size               |
| `NGINX_OTEL_BATCH_COUNT` | `4`                         | Maximum number of batches        |

### Status Endpoint Configuration

| Variable                   | Default     | Description                         |
|----------------------------|-------------|-------------------------------------|
| `NGINX_STATUS`             | `true`      | Enable status endpoint              |
| `NGINX_STATUS_PORT`        | `90`        | Port for status endpoint            |
| `NGINX_STATUS_SERVER_NAME` | `localhost` | Server name for status endpoint     |
| `NGINX_STATUS_PATH`        | `/status`   | Path for status endpoint            |
| `NGINX_STATUS_ALLOW`       | ``          | Comma-separated list of allowed IPs |
| `NGINX_STATUS_DENY`        | ``          | Comma-separated list of denied IPs  |

### Logging Configuration

| Variable                  | Default                     | Description                |
|---------------------------|-----------------------------|----------------------------|
| `NGINX_LOG_ACCESS_FORMAT` | `main`                      | Access log format          |
| `NGINX_LOG_ACCESS_PATH`   | `/var/log/nginx/access.log` | Access log path            |
| `NGINX_LOG_ACCESS`        | `<path> <format>`           | Complete access log config |
| `NGINX_LOG_ERROR_LEVEL`   | `notice`                    | Error log level            |
| `NGINX_LOG_ERROR_PATH`    | `/var/log/nginx/error.log`  | Error log path             |
| `NGINX_LOG_ERROR`         | `<path> <level>`            | Complete error log config  |

### Custom Log Formats

Define custom log formats using:

```
NGINX_LOG_FORMAT_<NAME>=<format>
NGINX_LOG_FORMAT_<NAME>_ESCAPE=<escape_type>
```

Example:

```
NGINX_LOG_FORMAT_JSON='{"time": "$time_local", "remote_addr": "$remote_addr"}'
NGINX_LOG_FORMAT_JSON_ESCAPE=json
```

### Template Configuration

| Variable                     | Default                | Description                              |
|------------------------------|------------------------|------------------------------------------|
| `NGINX_CONF_TEMPLATE_DIR`    | `/etc/nginx/templates` | Directory containing templates           |
| `NGINX_CONF_TEMPLATE_SUFFIX` | `.tmpl`                | Template file suffix                     |
| `NGINX_CONF_OUTPUT_DIR`      | `/etc/nginx/conf.d`    | Output directory for processed templates |

## Usage Example

```yaml
version: '3'
services:
  nginx:
    image: framjet/nginx:mainline-alpine-otel
    environment:
      # OpenTelemetry
      NGINX_OTEL: 'true'
      NGINX_OTEL_ENDPOINT: 'otel-collector:4317'

      # Wait for dependencies
      WAIT_FOR_db:5432#30s: 'postgres:5432#30s'
      WAIT_FOR_redis: 'redis:6379'
      WAIT_CMD_FOR_KAFKA: 'tcp kafka:9092 --timeout 60s'

      # Custom log format
      NGINX_LOG_FORMAT_JSON: '{"time": "$time_local", "remote_addr": "$remote_addr"}'
      NGINX_LOG_FORMAT_JSON_ESCAPE: 'json'
      NGINX_LOG_ACCESS: '/var/log/nginx/access.log json'

      # Status endpoint
      NGINX_STATUS_ALLOW: '127.0.0.1,10.0.0.0/8'
    ports:
      - '80:80'
      - '90:90'
```
