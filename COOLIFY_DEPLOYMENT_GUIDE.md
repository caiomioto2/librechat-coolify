# Coolify Deployment Guide for LibreChat + GoMarble MCP

This guide will walk you through deploying LibreChat with GoMarble MCP integration using Coolify.

## Prerequisites

1. **Coolify Server**: A running Coolify instance
2. **Git Repository**: Access to push this repository to a Git provider (GitHub, GitLab, etc.)
3. **GoMarble API Key**: Your GoMarble API key for MCP integration
4. **Domain**: A domain name for your deployment (optional but recommended)

## Phase 1: Repository Setup

### 1.1 Initialize Git Repository

```bash
# Initialize git repository (if not already done)
git init
git add .
git commit -m "Initial commit: LibreChat + GoMarble MCP for Coolify deployment"

# Push to your Git provider (GitHub/GitLab/etc.)
git remote add origin https://github.com/yourusername/librechat-coolify.git
git branch -M main
git push -u origin main
```

### 1.2 Verify Files

Ensure these files are present in your repository:
- ✅ `Dockerfile.coolify` - Custom Docker image with MCP integration
- ✅ `coolify-docker-compose.yml` - Production-ready compose file
- ✅ `coolify-environment-template.env` - Environment variables template
- ✅ `deploy.sh` - Automated deployment script
- ✅ `healthcheck.sh` - Service health validation
- ✅ `server/` - GoMarble MCP server directory
- ✅ `librechat.yaml` - LibreChat configuration with MCP setup

## Phase 2: Coolify Configuration

### 2.1 Create New Service in Coolify

1. **Login to Coolify Dashboard**
2. **Go to Projects** → Create New Project → "LibreChat GoMarble"
3. **Add New Service** → Docker Compose

### 2.2 Git Repository Integration

1. **Source Code**:
   - Repository URL: `https://github.com/yourusername/librechat-coolify.git`
   - Branch: `main`
   - Docker Compose File: `coolify-docker-compose.yml`

### 2.3 Environment Variables

Copy the variables from `coolify-environment-template.env` and configure in Coolify:

#### Required Variables (⚠️ Must be set):

```env
# Application
DOMAIN_CLIENT=https://your-domain.com
DOMAIN_SERVER=https://your-domain.com

# Security (Generate secure random strings)
JWT_SECRET=your-super-secure-jwt-secret-key-here
JWT_REFRESH_SECRET=your-super-secure-jwt-refresh-secret-key-here
CREDS_KEY=your-32-character-encryption-key
CREDS_IV=your-16-character-initialization-vector

# Database Security
MEILI_MASTER_KEY=your-secure-meili-master-key
POSTGRES_PASSWORD=your-secure-postgres-password

# GoMarble MCP (CRITICAL!)
GOMARBLE_API_KEY=your-gomarble-api-key-here
```

#### Optional AI API Keys:

```env
GROQ_API_KEY=your-groq-api-key
MISTRAL_API_KEY=your-mistral-api-key
OPENROUTER_KEY=your-openrouter-api-key
OPENAI_API_KEY=your-openai-api-key
```

### 2.4 Generate Secure Keys

Use these commands to generate secure keys:

```bash
# JWT Secrets (64 characters each)
openssl rand -hex 32
openssl rand -hex 32

# Credential Encryption Key (32 characters)
openssl rand -hex 16

# Credential IV (16 characters)
openssl rand -hex 8

# MeiliSearch Master Key (32+ characters)
openssl rand -base64 32
```

### 2.5 Volume Configuration

Configure persistent volumes in Coolify:
- `librechat_mongodb_data` → `/data/db`
- `librechat_uploads` → `/app/uploads`
- `librechat_logs` → `/app/logs`
- `librechat_meilisearch_data` → `/meili_data`
- `librechat_vectordb_data` → `/var/lib/postgresql/data`

## Phase 3: Deployment

### 3.1 Deploy via Coolify

1. **Configure Service**:
   - Set all environment variables
   - Configure volumes
   - Set domain/subdomain if using

2. **Deploy**:
   - Click "Deploy" in Coolify dashboard
   - Monitor deployment logs

### 3.2 Manual Deployment (Alternative)

If you prefer manual deployment:

```bash
# Make scripts executable
chmod +x deploy.sh healthcheck.sh

# Run deployment
./deploy.sh

# Run health checks
./healthcheck.sh
```

## Phase 4: Verification & Testing

### 4.1 Access Application

- **Application URL**: `https://your-domain.com` or `http://localhost:3080`
- **Health Check**: `https://your-domain.com/api/health`

### 4.2 Verify GoMarble MCP Integration

1. **Login to LibreChat**
2. **Start a new conversation**
3. **Test MCP Tools**: Try asking questions about marketing data
   - "Show me my Facebook ad performance"
   - "Analyze my Google Ads campaigns"
   - "Get Google Analytics data for last month"

### 4.3 Run Health Checks

```bash
# Quick health check
./healthcheck.sh quick

# Full health check
./healthcheck.sh

# MCP-specific check
./healthcheck.sh mcp
```

## Troubleshooting

### Common Issues

#### 1. GoMarble API Key Issues
```bash
# Check if API key is set
docker logs librechat-api | grep -i gomarble

# Test API key directly
curl -H "Authorization: Bearer YOUR_API_KEY" https://apps.gomarble.ai/mcp-api/sse
```

#### 2. Service Not Starting
```bash
# Check all container logs
docker compose -f coolify-docker-compose.yml logs

# Check specific service
docker logs librechat-api
docker logs librechat-mongodb
```

#### 3. Database Connection Issues
```bash
# Test MongoDB connection
docker exec librechat-mongodb mongosh --eval "db.adminCommand('ping')"

# Test PostgreSQL connection
docker exec librechat-vectordb pg_isready -U myuser -d mydatabase
```

#### 4. MCP Server Issues
```bash
# Check MCP server files
docker exec librechat-api ls -la /app/server/

# Check MCP configuration
docker exec librechat-api cat /app/librechat.yaml | grep -A 10 mcpServers
```

### Log Analysis

```bash
# View application logs
docker logs librechat-api --tail=100 -f

# View all service logs
docker compose -f coolify-docker-compose.yml logs -f

# Search for specific errors
docker logs librechat-api 2>&1 | grep -i error
```

## Security Considerations

### Production Security Checklist

- ✅ **Change all default passwords and keys**
- ✅ **Use HTTPS with valid SSL certificates**
- ✅ **Secure API keys in Coolify secrets**
- ✅ **Configure firewall rules**
- ✅ **Regular security updates**
- ✅ **Database backups**

### Environment Security

```yaml
# Use Coolify secrets for sensitive data
secrets:
  - gomarble_api_key
  - jwt_secret
  - jwt_refresh_secret
  - database_passwords
```

## Maintenance

### Regular Tasks

```bash
# Update containers
docker compose -f coolify-docker-compose.yml pull
docker compose -f coolify-docker-compose.yml up -d

# Backup databases
docker exec librechat-mongodb mongodump --out /backup
docker exec librechat-vectordb pg_dump -U myuser mydatabase > backup.sql

# View resource usage
docker stats
```

### Monitoring

- **Health Checks**: Set up automated health monitoring
- **Log Monitoring**: Configure log aggregation
- **Resource Monitoring**: Monitor CPU, memory, and disk usage
- **Uptime Monitoring**: Use external monitoring services

## Support

### Getting Help

1. **Check Logs**: Always start with container logs
2. **Health Checks**: Run the health check script
3. **Coolify Community**: Coolify Discord/Forums
4. **LibreChat Documentation**: https://docs.librechat.ai
5. **GoMarble Support**: GoMarble documentation and support

### Useful Commands

```bash
# Restart services
docker compose -f coolify-docker-compose.yml restart

# Scale services (if needed)
docker compose -f coolify-docker-compose.yml up -d --scale api=2

# Clean up
docker system prune -a

# Export/Import volumes
docker run --rm -v librechat_mongodb_data:/data -v $(pwd):/backup ubuntu tar czf /backup/mongodb.tar.gz -C /data .
```

## Next Steps

Once deployed successfully:

1. **Configure Additional AI Providers**: Add more API keys as needed
2. **Set Up User Management**: Configure authentication and registration
3. **Customize Interface**: Modify `librechat.yaml` for your needs
4. **Set Up Monitoring**: Implement comprehensive monitoring
5. **Plan Backups**: Set up automated backup strategies

---

**🎉 Congratulations!** You now have LibreChat with GoMarble MCP integration running on Coolify!

For the latest updates and documentation, visit:
- **LibreChat**: https://docs.librechat.ai
- **Coolify**: https://docs.coolify.io  
- **GoMarble**: https://gomarble.ai/docs