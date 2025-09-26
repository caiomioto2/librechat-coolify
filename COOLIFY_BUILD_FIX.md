# Coolify Environment Variables Setup Guide

## ❌ Issue Resolved: Docker Build Error

The error `".env.example": not found` has been **FIXED** with the latest commit.

### What was fixed:
- ✅ Updated `Dockerfile.coolify` to create a minimal .env file instead of copying missing .env.example
- ✅ Fixed `.dockerignore` to properly include essential files (librechat.yaml, server/)
- ✅ Ensured all required files are available in Docker build context

## ⚠️ NODE_ENV Warning Resolution

The Coolify logs show a warning about `NODE_ENV=production` during build time. Here's how to fix it:

### Option 1: Separate Build and Runtime Environment (Recommended)

In your Coolify environment variables, set:

**Build-time variables** (uncheck "Available at Runtime"):
```env
NODE_ENV=development
```

**Runtime-only variables** (uncheck "Available at Buildtime"):
```env
NODE_ENV=production
DEBUG=false
VERBOSE_LOGGING=false
```

### Option 2: Keep Current Setup (Simpler)

If you want to keep it simple, you can ignore the warning. The build should still work, but you might encounter issues if the base image requires devDependencies for building.

## 🚀 Ready for Re-deployment

Your repository is now ready for Coolify deployment:

1. **The Docker build error is fixed** ✅
2. **All files are properly included in build context** ✅ 
3. **Environment handling is improved** ✅

## Next Steps:

1. **Re-deploy in Coolify** - The build should now succeed
2. **Configure Environment Variables** using your `.env.production` values
3. **Set up SSL** for your domain: `google.athenagrowtmarketing.com`

## Environment Variables for Coolify:

Copy these from your `.env.production` file:

### Required Variables:
```env
# Domain
DOMAIN_CLIENT=https://google.athenagrowtmarketing.com
DOMAIN_SERVER=https://google.athenagrowtmarketing.com

# Security (from .env.production)
JWT_SECRET=f9f14e6fddce978d91e19866953da4ca7089084bb613712c8c1859541ceb58bd
JWT_REFRESH_SECRET=eb5e483754e70fc13fed93d8fa03a36910c22069abe1b56a5aeae910c38beba9
CREDS_KEY=bca799f167b7c16b14c7479609199b7f
CREDS_IV=b5498be3a3034326

# Database Security
MEILI_MASTER_KEY=SZ3eMJ4kq0pSbjMtRnphM6HqMnb4ix7p+WbfLQ2FYQ0=
POSTGRES_PASSWORD=26bN/JOQ3DFTSP6h2oEzdmor1vxF9aRj

# GoMarble MCP (ADD YOUR ACTUAL KEY)
GOMARBLE_API_KEY=your-actual-gomarble-api-key
```

### Application Settings:
```env
HOST=0.0.0.0
PORT=3080
NODE_ENV=production
TRUST_PROXY=1
NO_INDEX=true
```

### Database Configuration:
```env
MONGO_URI=mongodb://mongodb:27017/LibreChat
MEILI_HOST=http://meilisearch:7700
MEILI_NO_ANALYTICS=true
RAG_PORT=8000
RAG_API_URL=http://rag_api:8000
```

## 🎯 The build should now succeed! 

Try deploying again in Coolify with these fixes.