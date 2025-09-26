#!/bin/bash

# Coolify Deployment Script for LibreChat + GoMarble MCP
# This script automates the deployment process

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

success() {
    echo -e "${GREEN}[SUCCESS] $1${NC}"
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

# Check if required environment variables are set
check_env_vars() {
    log "Checking required environment variables..."
    
    local required_vars=(
        "GOMARBLE_API_KEY"
        "JWT_SECRET"
        "JWT_REFRESH_SECRET"
        "CREDS_KEY"
        "CREDS_IV"
        "MEILI_MASTER_KEY"
        "POSTGRES_PASSWORD"
    )
    
    local missing_vars=()
    
    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ]; then
            missing_vars+=("$var")
        fi
    done
    
    if [ ${#missing_vars[@]} -ne 0 ]; then
        error "Missing required environment variables:"
        for var in "${missing_vars[@]}"; do
            echo "  - $var"
        done
        error "Please set these variables in your Coolify environment configuration."
        exit 1
    fi
    
    success "All required environment variables are set"
}

# Validate Docker Compose file
validate_docker_compose() {
    log "Validating Docker Compose configuration..."
    
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        error "Docker Compose is not available"
        exit 1
    fi
    
    # Use docker compose (new syntax) if available, otherwise fall back to docker-compose
    local compose_cmd="docker compose"
    if ! docker compose version &> /dev/null; then
        compose_cmd="docker-compose"
    fi
    
    if $compose_cmd -f coolify-docker-compose.yml config > /dev/null; then
        success "Docker Compose configuration is valid"
    else
        error "Docker Compose configuration is invalid"
        exit 1
    fi
}

# Check Docker daemon
check_docker() {
    log "Checking Docker daemon..."
    
    if ! docker info > /dev/null 2>&1; then
        error "Docker daemon is not running or accessible"
        exit 1
    fi
    
    success "Docker daemon is running"
}

# Build custom image
build_image() {
    log "Building custom LibreChat image..."
    
    # Build the custom image with GoMarble MCP integration
    docker build -f Dockerfile.coolify -t librechat-gomarble:latest .
    
    if [ $? -eq 0 ]; then
        success "Custom image built successfully"
    else
        error "Failed to build custom image"
        exit 1
    fi
}

# Deploy services
deploy_services() {
    log "Deploying LibreChat services..."
    
    # Use docker compose (new syntax) if available, otherwise fall back to docker-compose
    local compose_cmd="docker compose"
    if ! docker compose version &> /dev/null; then
        compose_cmd="docker-compose"
    fi
    
    # Deploy using the Coolify-optimized compose file
    $compose_cmd -f coolify-docker-compose.yml up -d
    
    if [ $? -eq 0 ]; then
        success "Services deployed successfully"
    else
        error "Failed to deploy services"
        exit 1
    fi
}

# Wait for services to be healthy
wait_for_services() {
    log "Waiting for services to be healthy..."
    
    local services=("librechat-mongodb" "librechat-meilisearch" "librechat-vectordb" "librechat-rag-api" "librechat-api")
    local timeout=300  # 5 minutes
    local elapsed=0
    
    while [ $elapsed -lt $timeout ]; do
        local healthy_count=0
        
        for service in "${services[@]}"; do
            if docker ps --format "table {{.Names}}\t{{.Status}}" | grep "$service" | grep -q "healthy\|Up"; then
                ((healthy_count++))
            fi
        done
        
        if [ $healthy_count -eq ${#services[@]} ]; then
            success "All services are healthy"
            return 0
        fi
        
        echo -n "."
        sleep 10
        ((elapsed += 10))
    done
    
    error "Services did not become healthy within $timeout seconds"
    return 1
}

# Run health checks
run_health_checks() {
    log "Running comprehensive health checks..."
    
    # Check MongoDB
    if docker exec librechat-mongodb mongosh --eval "db.adminCommand('ping')" > /dev/null 2>&1; then
        success "MongoDB is responsive"
    else
        error "MongoDB health check failed"
        return 1
    fi
    
    # Check MeiliSearch
    if curl -sf "http://localhost:7700/health" > /dev/null 2>&1; then
        success "MeiliSearch is responsive"
    else
        warning "MeiliSearch health check failed (may not be exposed)"
    fi
    
    # Check main application
    local app_port=${PORT:-3080}
    if curl -sf "http://localhost:$app_port/api/health" > /dev/null 2>&1; then
        success "LibreChat API is responsive"
    else
        error "LibreChat API health check failed"
        return 1
    fi
    
    success "Health checks completed successfully"
}

# Display service information
display_service_info() {
    log "Deployment Information:"
    echo
    echo "🚀 LibreChat is now running!"
    echo "   URL: http://localhost:${PORT:-3080}"
    echo
    echo "📊 Service Status:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep librechat
    echo
    echo "🔧 Useful Commands:"
    echo "   View logs: docker logs librechat-api"
    echo "   Stop services: docker compose -f coolify-docker-compose.yml down"
    echo "   Restart: docker compose -f coolify-docker-compose.yml restart"
    echo
    echo "🔑 GoMarble MCP Integration:"
    echo "   Status: $([ -n "$GOMARBLE_API_KEY" ] && echo "✅ Configured" || echo "❌ Missing API Key")"
    echo
}

# Main deployment function
main() {
    log "Starting LibreChat + GoMarble MCP deployment..."
    echo
    
    # Pre-deployment checks
    check_env_vars
    check_docker
    validate_docker_compose
    
    # Build and deploy
    build_image
    deploy_services
    
    # Post-deployment verification
    if wait_for_services; then
        run_health_checks
        display_service_info
        success "Deployment completed successfully! 🎉"
    else
        error "Deployment failed during health checks"
        exit 1
    fi
}

# Handle script arguments
case "${1:-}" in
    "build")
        log "Building custom image only..."
        check_docker
        build_image
        ;;
    "deploy")
        log "Deploying services only..."
        check_env_vars
        check_docker
        validate_docker_compose
        deploy_services
        ;;
    "health")
        log "Running health checks only..."
        run_health_checks
        ;;
    *)
        main
        ;;
esac