# CORS Configuration Guide

## Overview

Cross-Origin Resource Sharing (CORS) is now fully configurable via environment variables, allowing you to control which origins can access your backend API.

## Configuration Options

### Environment Variables

| Variable | Description | Default (Dev) | Default (Prod) |
|----------|-------------|---------------|----------------|
| `CORS_ALLOWED_ORIGINS` | Comma-separated list of allowed origins | `http://localhost:5173,http://localhost:3000,http://localhost:8080` | **Must be set!** |
| `CORS_ALLOWED_METHODS` | Comma-separated list of allowed HTTP methods | `GET,POST,PUT,DELETE,OPTIONS,HEAD,PATCH` | `GET,POST,OPTIONS,HEAD` |
| `CORS_ALLOWED_HEADERS` | Comma-separated list of allowed headers | `*` | `Content-Type,Authorization,X-Requested-With` |
| `CORS_ALLOW_CREDENTIALS` | Allow credentials (cookies, auth headers) | `true` | `true` |
| `CORS_MAX_AGE` | Preflight cache duration in seconds | `3600` | `7200` |

## Environment-Specific Configuration

### Development Environment

In development, CORS is configured to be permissive for local testing:

```bash
# .env.dev (or set in docker-compose.dev.yml)
CORS_ALLOWED_ORIGINS=http://localhost:5173,http://localhost:3000,http://localhost:8080,http://127.0.0.1:5173
CORS_ALLOWED_METHODS=GET,POST,PUT,DELETE,OPTIONS,HEAD,PATCH
CORS_ALLOWED_HEADERS=*
CORS_ALLOW_CREDENTIALS=true
CORS_MAX_AGE=3600
```

**Default origins in dev:**
- `http://localhost:5173` - Vite dev server
- `http://localhost:3000` - Alternative frontend port / Grafana
- `http://localhost:8080` - Backend (same-origin)
- `http://127.0.0.1:*` - IPv4 localhost variations

### Production Environment

In production, CORS requires explicit configuration for security:

```bash
# .env.prod - REQUIRED CONFIGURATION
CORS_ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com

# Optional overrides (these have sensible defaults)
CORS_ALLOWED_METHODS=GET,POST,OPTIONS,HEAD
CORS_ALLOWED_HEADERS=Content-Type,Authorization,X-Requested-With
CORS_ALLOW_CREDENTIALS=true
CORS_MAX_AGE=7200
```

⚠️ **Important:** `CORS_ALLOWED_ORIGINS` **MUST** be set in production! The default is empty for security reasons.

## Common Scenarios

### Scenario 1: Local Development (Default)

No configuration needed! The defaults work out of the box:

```bash
./run-docker.sh dev
```

### Scenario 2: Custom Dev Port

Frontend running on port 4000:

```bash
# In .env.dev or docker-compose.dev.yml
CORS_ALLOWED_ORIGINS=http://localhost:4000,http://localhost:5173,http://localhost:8080
```

### Scenario 3: Production Deployment

Single domain:

```bash
# In .env.prod
CORS_ALLOWED_ORIGINS=https://myapp.com
```

Multiple domains (www + naked domain):

```bash
# In .env.prod
CORS_ALLOWED_ORIGINS=https://myapp.com,https://www.myapp.com
```

### Scenario 4: Multiple Environments

Different frontend URLs for staging/production:

```bash
# Staging
CORS_ALLOWED_ORIGINS=https://staging.myapp.com,https://staging-api.myapp.com

# Production
CORS_ALLOWED_ORIGINS=https://myapp.com,https://www.myapp.com,https://api.myapp.com
```

### Scenario 5: Mobile App + Web

Allow both web and mobile app origins:

```bash
CORS_ALLOWED_ORIGINS=https://myapp.com,capacitor://localhost,http://localhost
```

## Security Best Practices

### ✅ DO

1. **Explicitly list allowed origins in production**
   ```bash
   CORS_ALLOWED_ORIGINS=https://myapp.com
   ```

2. **Use HTTPS in production**
   ```bash
   CORS_ALLOWED_ORIGINS=https://myapp.com  # ✅ Secure
   ```

3. **Limit allowed methods in production**
   ```bash
   CORS_ALLOWED_METHODS=GET,POST,OPTIONS  # Only what you need
   ```

4. **Specify exact headers when possible**
   ```bash
   CORS_ALLOWED_HEADERS=Content-Type,Authorization
   ```

### ❌ DON'T

1. **Never use wildcards in production**
   ```bash
   CORS_ALLOWED_ORIGINS=*  # ❌ Security risk!
   ```

2. **Avoid HTTP in production**
   ```bash
   CORS_ALLOWED_ORIGINS=http://myapp.com  # ❌ Insecure!
   ```

3. **Don't allow unnecessary methods**
   ```bash
   CORS_ALLOWED_METHODS=*  # ❌ Too permissive!
   ```

4. **Don't leave production unconfigured**
   ```bash
   # Missing CORS_ALLOWED_ORIGINS in .env.prod  # ❌ Won't work!
   ```

## Troubleshooting

### Issue: CORS errors in browser console

**Error:**
```
Access to XMLHttpRequest at 'http://localhost:8080/graphql' from origin 'http://localhost:5173' 
has been blocked by CORS policy
```

**Solution:**
1. Check backend logs for CORS configuration:
   ```bash
   docker logs converter_backend
   # Look for: "Configuring CORS with allowed origins: [...]"
   ```

2. Verify your frontend origin is in the allowed list:
   ```bash
   echo $CORS_ALLOWED_ORIGINS
   ```

3. Restart backend after changing CORS config:
   ```bash
   docker compose restart backend
   ```

### Issue: OPTIONS preflight fails

**Symptom:** Browser makes OPTIONS request that fails

**Solution:**
Ensure `OPTIONS` is in allowed methods:
```bash
CORS_ALLOWED_METHODS=GET,POST,OPTIONS,HEAD
```

### Issue: Credentials not working

**Symptom:** Cookies or Authorization headers not sent

**Solution:**
1. Set `CORS_ALLOW_CREDENTIALS=true`
2. Do NOT use `*` in allowed origins (credentials require specific origins)
3. Frontend must set `credentials: 'include'` in fetch/Apollo config

### Issue: Production CORS not working

**Symptom:** Works locally but fails in production

**Checklist:**
1. ✅ Set `CORS_ALLOWED_ORIGINS` in `.env.prod`
2. ✅ Use HTTPS origins (not HTTP)
3. ✅ Include both `www` and naked domain if needed
4. ✅ Restart services after config change
5. ✅ Check backend logs for actual loaded config

## Verification

### Test CORS Configuration

1. **Check backend logs on startup:**
   ```bash
   docker logs converter_backend 2>&1 | grep -i cors
   ```
   
   Expected output:
   ```
   Configuring CORS with allowed origins: [http://localhost:5173, http://localhost:3000, ...]
   ```

2. **Test with curl:**
   ```bash
   curl -I -X OPTIONS \
     -H "Origin: http://localhost:5173" \
     -H "Access-Control-Request-Method: POST" \
     http://localhost:8080/graphql
   ```
   
   Should return:
   ```
   Access-Control-Allow-Origin: http://localhost:5173
   Access-Control-Allow-Methods: POST
   Access-Control-Allow-Credentials: true
   ```

3. **Check in browser DevTools:**
   - Open Network tab
   - Look for preflight OPTIONS requests
   - Check response headers for `Access-Control-*` headers

## Configuration Examples

### Example 1: Basic Local Development

```bash
# .env.dev
CORS_ALLOWED_ORIGINS=http://localhost:5173,http://localhost:8080
```

### Example 2: Docker Compose Development

```yaml
# docker-compose.dev.yml
services:
  backend:
    environment:
      - CORS_ALLOWED_ORIGINS=http://localhost:5173,http://frontend:80
```

### Example 3: Production with Multiple Domains

```bash
# .env.prod
CORS_ALLOWED_ORIGINS=https://app.example.com,https://www.app.example.com,https://admin.example.com
CORS_ALLOWED_METHODS=GET,POST,PUT,DELETE,OPTIONS
CORS_ALLOWED_HEADERS=Content-Type,Authorization,X-API-Key
CORS_ALLOW_CREDENTIALS=true
CORS_MAX_AGE=7200
```

### Example 4: Testing Environment

```bash
# .env.test
CORS_ALLOWED_ORIGINS=http://localhost:5173,http://test.example.com
CORS_ALLOWED_METHODS=GET,POST,PUT,DELETE,OPTIONS,PATCH
```

## Integration with Frontend

### Vue.js + Apollo Client

The frontend Apollo client is already configured to send credentials. No additional changes needed if CORS is properly configured.

```javascript
// src/config/apollo.js
const httpLink = createHttpLink({
  uri: import.meta.env.VITE_GRAPHQL_URL,
  credentials: 'include'  // Sends cookies
});
```

### Fetch API

```javascript
fetch('http://localhost:8080/graphql', {
  method: 'POST',
  credentials: 'include',  // Required for CORS with credentials
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({ query: '...' })
});
```

## Monitoring

CORS configuration is logged on application startup:

```
INFO  c.c.b.config.WebConfig - Configuring CORS with allowed origins: [http://localhost:5173, ...]
DEBUG c.c.b.config.WebConfig - CORS allowed methods: [GET, POST, PUT, DELETE, OPTIONS, HEAD]
DEBUG c.c.b.config.WebConfig - CORS allow credentials: true
DEBUG c.c.b.config.WebConfig - CORS max age: 3600 seconds
```

Set logging level to DEBUG to see full CORS configuration:

```bash
LOGGING_LEVEL_COM_CONVERTER=DEBUG
```

## Migration from Hardcoded Configuration

The previous hardcoded CORS configuration:

```java
// Old configuration (hardcoded)
.allowedOrigins("http://localhost:5173", "http://localhost:3000", "http://localhost:8080")
```

Is now environment-driven:

```bash
# New configuration (environment variable)
CORS_ALLOWED_ORIGINS=http://localhost:5173,http://localhost:3000,http://localhost:8080
```

**No breaking changes** - the defaults match the previous hardcoded values for development!

## Additional Resources

- [MDN: CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)
- [Spring Framework: CORS Support](https://docs.spring.io/spring-framework/reference/web/webmvc-cors.html)
- [OWASP: CORS Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/CORS_Cheat_Sheet.html)

## Support

If you encounter CORS issues:

1. Check this guide's Troubleshooting section
2. Verify configuration in backend logs
3. Test with curl to isolate frontend vs backend issues
4. Check browser DevTools Network tab for CORS headers

