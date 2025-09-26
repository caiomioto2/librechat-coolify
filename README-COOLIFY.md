# LibreChat + GoMarble MCP - Coolify Deployment

🚀 **Ready-to-deploy LibreChat with GoMarble MCP integration for Coolify**

This repository contains a production-ready deployment of LibreChat with GoMarble MCP (Model Context Protocol) integration, specifically optimized for Coolify deployment.

## 🎯 What's Included

- **✅ Custom Docker Image**: Extended LibreChat with GoMarble MCP server
- **✅ Production Docker Compose**: Coolify-optimized multi-service setup  
- **✅ Automated Deployment**: One-click deployment with health checks
- **✅ Security Hardening**: Production security configurations
- **✅ Persistent Storage**: Properly configured volumes for data persistence
- **✅ Health Monitoring**: Comprehensive health check system

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   LibreChat     │    │   MongoDB       │    │   MeiliSearch   │
│   (Main App)    │────│   (Database)    │    │   (Search)      │
│   Port: 3080    │    │   Port: 27017   │    │   Port: 7700    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
          │
          ├─────────────────┐    ┌─────────────────┐
          │   RAG API       │    │   VectorDB      │
          │   Port: 8000    │────│   (PostgreSQL)  │
          │                 │    │   Port: 5432    │
          └─────────────────┘    └─────────────────┘
          │
          └── GoMarble MCP Server (Integrated)
              ├── Facebook Ads API
              ├── Google Ads API  
              └── Google Analytics API
```

## 🚀 Quick Start

### Option 1: Coolify Dashboard Deployment

1. **Import Repository** in Coolify
2. **Set Environment Variables** (see `coolify-environment-template.env`)
3. **Deploy** via Coolify dashboard

### Option 2: Manual Deployment

```bash
# 1. Clone this repository
git clone <your-repo-url>
cd librechat-coolify

# 2. Configure environment variables
cp coolify-environment-template.env .env
# Edit .env with your actual values

# 3. Deploy
./deploy.sh

# 4. Verify health
./healthcheck.sh
```

## 🔑 Required Configuration

### Essential Environment Variables

```env
# ⚠️ REQUIRED - GoMarble MCP Integration
GOMARBLE_API_KEY=your-gomarble-api-key-here

# ⚠️ REQUIRED - Security Keys (Generate secure random values)
JWT_SECRET=your-super-secure-jwt-secret
JWT_REFRESH_SECRET=your-super-secure-jwt-refresh-secret
CREDS_KEY=your-32-character-encryption-key
CREDS_IV=your-16-character-initialization-vector

# ⚠️ REQUIRED - Database Security
MEILI_MASTER_KEY=your-secure-meili-master-key
POSTGRES_PASSWORD=your-secure-postgres-password

# ⚠️ REQUIRED - Domain Configuration
DOMAIN_CLIENT=https://your-domain.com
DOMAIN_SERVER=https://your-domain.com
```

## 🎨 GoMarble MCP Features

Once deployed, users can access marketing data through natural language:

### Available Capabilities

- **📊 Facebook Ads**: Performance metrics, campaign analysis, audience insights
- **🎯 Google Ads**: Campaign data, keyword performance, conversion tracking  
- **📈 Google Analytics**: Traffic analysis, user behavior, conversion funnels
- **📋 Cross-Platform**: Unified reporting across all marketing channels

### Example Queries

```
"Show me my Facebook ad performance for the last 30 days"
"Compare Google Ads vs Facebook Ads ROI this month"  
"Analyze website traffic sources from Google Analytics"
"What are my top performing ad campaigns?"
```

## 📋 Deployment Files Overview

| File | Purpose |
|------|---------|
| `Dockerfile.coolify` | Custom image with MCP integration |
| `coolify-docker-compose.yml` | Production multi-service setup |
| `coolify-environment-template.env` | Environment variables template |
| `deploy.sh` | Automated deployment script |
| `healthcheck.sh` | Health monitoring script |
| `COOLIFY_DEPLOYMENT_GUIDE.md` | Complete deployment documentation |

## 🆘 Quick Troubleshooting

```bash
# Check service health
./healthcheck.sh quick

# View application logs  
docker logs librechat-api -f

# Test GoMarble MCP
./healthcheck.sh mcp
```

---

## 🎉 Ready to Deploy!

📖 **Full Documentation**: See `COOLIFY_DEPLOYMENT_GUIDE.md` for complete setup instructions.

🔑 **Environment Setup**: Copy and configure `coolify-environment-template.env`

🚀 **Deploy**: Import into Coolify or run `./deploy.sh`

**Need help?** Check the troubleshooting section in the deployment guide!

---

**Made with ❤️ for the LibreChat community**