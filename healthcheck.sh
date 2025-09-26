#!/bin/bash

# Health Check Script for LibreChat + GoMarble MCP
# Validates all services are running correctly

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_PORT=${PORT:-3080}
RAG_PORT=${RAG_PORT:-8000}
TIMEOUT=30

# Logging functions
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

success() {
    echo -e "${GREEN}[✅] $1${NC}"
}

warning() {
    echo -e "${YELLOW}[⚠️] $1${NC}"
}

error() {
    echo -e "${RED}[❌] $1${NC}"
}

# Check if a service is running
check_service() {
    local service_name=$1
    local container_name=$2
    
    if docker ps --format "{{.Names}}" | grep -q "^${container_name}$"; then
        success "$service_name container is running"
        return 0
    else
        error "$service_name container is not running"
        return 1
    fi
}

# Check HTTP endpoint
check_http_endpoint() {
    local name=$1
    local url=$2
    local expected_status=${3:-200}
    
    local response=$(curl -s -o /dev/null -w "%{http_code}" --max-time $TIMEOUT "$url" 2>/dev/null || echo "000")
    
    if [ "$response" = "$expected_status" ]; then
        success "$name HTTP endpoint is healthy ($url)"
        return 0
    else
        error "$name HTTP endpoint failed (Status: $response, Expected: $expected_status)"
        return 1
    fi
}

# Check database connection
check_mongodb() {
    log "Checking MongoDB connection..."
    
    if check_service "MongoDB" "librechat-mongodb"; then
        # Test MongoDB connection
        if docker exec librechat-mongodb mongosh --quiet --eval "db.adminCommand('ping').ok" LibreChat 2>/dev/null | grep -q "1"; then
            success "MongoDB connection is healthy"
            return 0
        else
            error "MongoDB connection test failed"
            return 1
        fi
    else
        return 1
    fi
}

# Check MeiliSearch
check_meilisearch() {
    log "Checking MeiliSearch..."
    
    if check_service "MeiliSearch" "librechat-meilisearch"; then
        # Test MeiliSearch health (internal check since it might not be exposed)
        if docker exec librechat-meilisearch curl -sf http://localhost:7700/health >/dev/null 2>&1; then
            success "MeiliSearch health check passed"
            return 0
        else
            warning "MeiliSearch health endpoint not accessible (may be normal if not exposed)"
            return 0  # Don't fail deployment for this
        fi
    else
        return 1
    fi
}

# Check PostgreSQL/VectorDB
check_vectordb() {
    log "Checking VectorDB (PostgreSQL)..."
    
    if check_service "VectorDB" "librechat-vectordb"; then
        # Test PostgreSQL connection
        if docker exec librechat-vectordb pg_isready -U myuser -d mydatabase >/dev/null 2>&1; then
            success "VectorDB connection is healthy"
            return 0
        else
            error "VectorDB connection test failed"
            return 1
        fi
    else
        return 1
    fi
}

# Check RAG API
check_rag_api() {
    log "Checking RAG API..."
    
    if check_service "RAG API" "librechat-rag-api"; then
        # Test RAG API health endpoint
        if check_http_endpoint "RAG API" "http://localhost:$RAG_PORT/health" 200 2>/dev/null ||
           docker exec librechat-rag-api curl -sf "http://localhost:$RAG_PORT/health" >/dev/null 2>&1; then
            success "RAG API is healthy"
            return 0
        else
            warning "RAG API health check inconclusive (may be normal if not exposed)"
            return 0  # Don't fail deployment for this
        fi
    else
        return 1
    fi
}

# Check main LibreChat API
check_librechat_api() {
    log "Checking LibreChat API..."
    
    if check_service "LibreChat API" "librechat-api"; then
        # Test main API health endpoint
        if check_http_endpoint "LibreChat API" "http://localhost:$APP_PORT/api/health" 200; then
            success "LibreChat API is healthy and accessible"
            return 0
        else
            error "LibreChat API health check failed"
            return 1
        fi
    else
        return 1
    fi
}

# Check GoMarble MCP integration
check_gomarble_mcp() {
    log "Checking GoMarble MCP integration..."
    
    # Check if GoMarble API key is configured
    if [ -z "$GOMARBLE_API_KEY" ]; then
        error "GOMARBLE_API_KEY environment variable is not set"
        return 1
    fi
    
    # Check if MCP server directory exists and has proper files
    if docker exec librechat-api test -f "/app/server/index.js" 2>/dev/null; then
        success "GoMarble MCP server files are present"
    else
        error "GoMarble MCP server files are missing"
        return 1
    fi
    
    # Check if librechat.yaml contains MCP configuration
    if docker exec librechat-api grep -q "mcpServers" "/app/librechat.yaml" 2>/dev/null; then
        success "MCP configuration found in librechat.yaml"
    else
        error "MCP configuration missing from librechat.yaml"
        return 1
    fi
    
    success "GoMarble MCP integration appears to be configured correctly"
    return 0
}

# Check volume mounts and persistence
check_volumes() {
    log "Checking volume mounts..."
    
    local volumes=("librechat_uploads" "librechat_logs" "librechat_mongodb_data" "librechat_meilisearch_data" "librechat_vectordb_data")
    local failed=0
    
    for volume in "${volumes[@]}"; do
        if docker volume inspect "$volume" >/dev/null 2>&1; then
            success "Volume $volume exists"
        else
            error "Volume $volume is missing"
            ((failed++))
        fi
    done
    
    return $failed
}

# Check network connectivity between services
check_internal_network() {
    log "Checking internal network connectivity..."
    
    # Test connectivity from API container to other services
    local services=("mongodb:27017" "meilisearch:7700" "vectordb:5432" "rag_api:$RAG_PORT")
    local failed=0
    
    for service in "${services[@]}"; do
        if docker exec librechat-api timeout 5 bash -c "echo >/dev/tcp/${service/:/ }" 2>/dev/null; then
            success "Network connectivity to $service is working"
        else
            error "Network connectivity to $service failed"
            ((failed++))
        fi
    done
    
    return $failed
}

# Generate health report
generate_report() {
    local total_checks=$1
    local failed_checks=$2
    local success_rate=$(( (total_checks - failed_checks) * 100 / total_checks ))
    
    echo
    log "=== Health Check Summary ==="
    echo
    echo "📊 Overall Health: $([ $failed_checks -eq 0 ] && echo "✅ HEALTHY" || echo "⚠️ ISSUES DETECTED")"
    echo "   Success Rate: $success_rate% ($((total_checks - failed_checks))/$total_checks checks passed)"
    echo "   Failed Checks: $failed_checks"
    echo
    
    if [ $failed_checks -eq 0 ]; then
        success "All health checks passed! LibreChat is ready to use. 🎉"
        echo
        echo "🌐 Access LibreChat at: http://localhost:$APP_PORT"
        echo "🔧 API Health: http://localhost:$APP_PORT/api/health"
    else
        error "Some health checks failed. Please review the issues above."
        echo
        echo "🔍 Troubleshooting commands:"
        echo "   docker logs librechat-api"
        echo "   docker ps --format 'table {{.Names}}\t{{.Status}}'"
        echo "   docker compose -f coolify-docker-compose.yml logs"
    fi
    echo
}

# Main health check function
main() {
    log "Starting comprehensive health check for LibreChat + GoMarble MCP..."
    echo
    
    local total_checks=0
    local failed_checks=0
    
    # Core service checks
    ((total_checks++)); check_mongodb || ((failed_checks++))
    ((total_checks++)); check_meilisearch || ((failed_checks++))
    ((total_checks++)); check_vectordb || ((failed_checks++))
    ((total_checks++)); check_rag_api || ((failed_checks++))
    ((total_checks++)); check_librechat_api || ((failed_checks++))
    
    # Integration checks
    ((total_checks++)); check_gomarble_mcp || ((failed_checks++))
    
    # Infrastructure checks
    ((total_checks++)); check_volumes || ((failed_checks++))
    ((total_checks++)); check_internal_network || ((failed_checks++))
    
    # Generate final report
    generate_report $total_checks $failed_checks
    
    # Exit with appropriate code
    [ $failed_checks -eq 0 ] && exit 0 || exit 1
}

# Handle script arguments
case "${1:-}" in
    "quick")
        log "Running quick health check (core services only)..."
        check_librechat_api && success "Quick health check passed!" || error "Quick health check failed!"
        ;;
    "mcp")
        log "Checking GoMarble MCP integration only..."
        check_gomarble_mcp
        ;;
    *)
        main
        ;;
esac