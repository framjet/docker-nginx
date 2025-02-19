# Nginx with JWT Authentication

This Docker image extends the [framjet/nginx](https://github.com/framjet/docker-nginx/tree/main/images/nginx) base image with JWT
authentication capabilities.

## Features

This image includes all features from the base [framjet/nginx](https://github.com/framjet/docker-nginx/tree/main/images/nginx)
image, plus:

- **JWT Authentication**: Built-in support for JSON Web Token authentication
- **Configurable JWT Validation**: Supports various JWT validation options

## JWT Module

This image incorporates the [nginx-auth-jwt](https://github.com/kjdev/nginx-auth-jwt) module (
version 0.9.0), which provides:

- JWT validation in the Nginx authentication phase
- Support for multiple signing algorithms (HS256, HS384, HS512, RS256, RS384, RS512, ES256, ES384,
  ES512)
- Configurable JWT claim validation
- Forwarding of validated claims as headers

## Usage Example

```nginx
server {
    listen 80;
    server_name example.com;

    # JWT Authentication configuration
    auth_jwt "Protected API";
    auth_jwt_key_file /etc/nginx/jwt/keys.json;
    
    # Optional JWT validation settings
    auth_jwt_leeway 30;  # 30 seconds leeway for expiration
    auth_jwt_require exp iat; # Require expiration and issued-at claims
    
    location /api/ {
        proxy_pass http://backend;
        
        # Forward validated claims as headers
        auth_jwt_claim_set $jwt_name name;
        proxy_set_header X-User-Name $jwt_name;
    }
}
```

## Environment Variables

In addition to all environment variables supported by the base image, this image pre-configures:

| Variable               | Default                    | Description                           |
|------------------------|----------------------------|---------------------------------------|
| `NGINX_MODULES_CUSTOM` | `ngx_http_auth_jwt_module` | Enables the JWT authentication module |

## Docker Compose Example

```yaml
version: '3'
services:
  nginx:
    image: framjet/nginx-jwt
    volumes:
      - ./jwt-keys.json:/etc/nginx/jwt/keys.json:ro
      - ./nginx.conf.tmpl:/etc/nginx/templates/default.conf:ro
    ports:
      - '80:80'
```

## JWT Keys Format

The module supports multiple key formats. Example `keys.json`:

```json
{
  "keys": [
    {
      "kid": "key1",
      "kty": "oct",
      "k": "base64-encoded-secret-key"
    },
    {
      "kid": "key2",
      "kty": "RSA",
      "n": "public-key-modulus",
      "e": "public-key-exponent"
    }
  ]
}
```

## Building Custom Variants

This image demonstrates how to extend the base Nginx image with additional modules. If you need to
build your own variant with different modules, you can use this image as a reference.

## Related Images

- [framjet/nginx](https://github.com/framjet/docker-nginx/tree/main/images/nginx) - Base Nginx image with templating and
  OpenTelemetry support
