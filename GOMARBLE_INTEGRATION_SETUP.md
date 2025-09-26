# GoMarble MCP + LibreChat Integration Setup

## ✅ Completed Steps

### 1. LibreChat Configuration
- ✅ Cloned LibreChat repository
- ✅ Created `.env` configuration file
- ✅ Created `librechat.yaml` with GoMarble MCP settings
- ✅ Created `docker-compose.override.yml` for MCP integration
- ✅ Added GoMarble API key placeholder in environment variables

### 2. GoMarble MCP Configuration
The following MCP server configuration has been added to `librechat.yaml`:

```yaml
mcpServers:
  gomarble:
    type: sse
    url: "https://apps.gomarble.ai/mcp-api/sse"
    timeout: 30000
    headers:
      Authorization: "Bearer ${GOMARBLE_API_KEY}"
    instructions: |
      GoMarble MCP provides access to marketing data from Facebook Ads, Google Ads, and Google Analytics.
      Use it to analyze ad performance, generate reports, and optimize marketing campaigns.
    userContext: true
```

## 🔄 Next Steps Required

### 3. Install Docker (Manual Step Required)
Docker installation requires sudo privileges. Please run these commands:

```bash
# Update package index
sudo apt update

# Install dependencies
sudo apt install apt-transport-https ca-certificates curl gnupg lsb-release

# Add Docker GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add current user to docker group (optional, to run without sudo)
sudo usermod -aG docker $USER

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker
```

### 4. Set up GoMarble Account
1. Go to [apps.gomarble.ai](https://apps.gomarble.ai)
2. Login with Google Account or Email ID
3. Click on profile picture (top right) → Copy API Key
4. Connect your marketing accounts:
   - Facebook/Meta Ads Manager
   - Google Ads
   - Google Analytics

### 5. Configure API Key
Replace the placeholder in `.env` file:
```bash
# Edit .env file
nano .env

# Find and replace:
GOMARBLE_API_KEY=your_gomarble_api_key_here
# With your actual API key from GoMarble
```

### 6. Set UID/GID for Docker
Set your user ID and group ID for Docker:
```bash
echo "UID=$(id -u)" >> .env
echo "GID=$(id -g)" >> .env
```

### 7. Launch LibreChat
```bash
# Build and start all services
docker compose up -d

# Check logs
docker compose logs -f api

# Access LibreChat at http://localhost:3080
```

## 🧪 Testing GoMarble Integration

Once everything is running, test the integration with these prompts in LibreChat:

1. **"Give me the ROAS of my Facebook Ad Accounts in the past week"**
2. **"Analyze which audience segments have the highest ROAS across Facebook Ads and Google Ads"**
3. **"Generate a weekly performance report comparing my Google Ads and Facebook Ads campaigns"**

## 📁 File Structure
```
LibreChat/
├── .env                           # Environment variables (with GoMarble API key)
├── librechat.yaml                 # LibreChat config (with GoMarble MCP)
├── docker-compose.yml             # Main Docker configuration
├── docker-compose.override.yml    # Custom overrides for MCP
└── GOMARBLE_INTEGRATION_SETUP.md  # This setup guide
```

## 🔧 Troubleshooting

### MCP Connection Issues
- Verify GoMarble API key is correct
- Check network connectivity to `https://apps.gomarble.ai/mcp-api/sse`
- Review Docker logs: `docker compose logs gomarble`

### Marketing Data Access Issues
- Ensure marketing accounts are properly connected in GoMarble dashboard
- Verify account permissions for Facebook/Google integrations
- Check GoMarble account status and API limits

### Docker Issues
- Ensure Docker is running: `sudo systemctl status docker`
- Check Docker Compose version: `docker compose version`
- Restart services: `docker compose restart`

## 📚 Documentation Links
- [LibreChat MCP Documentation](https://www.librechat.ai/docs/features/mcp)
- [GoMarble MCP Setup Guide](https://www.gomarble.ai/mcp-thankyou)
- [LibreChat Docker Guide](https://www.librechat.ai/docs/installation/docker)