#!/bin/bash
set -e

# ------------------------------
# MiniCloud Deployment Script v25
# -------------------------------


# -------------------------------
# Creating the stack templates
# -------------------------------
WORKING_DIR="$(pwd)"
VOLUMES_DIR="$WORKING_DIR/volumes"
TEMPLATES_DIR="library/stack-templates"
DEPLOY_DIR="stacks"
mkdir -p "$DEPLOY_DIR"
mkdir -p "$VOLUMES_DIR"

for STACK_PATH in "$TEMPLATES_DIR"/*; do
    STACK_NAME=$(basename "$STACK_PATH")
    template_file="$STACK_PATH/docker-compose.yml.tpl"
    target_file="$DEPLOY_DIR/$STACK_NAME/docker-compose.yml"

    mkdir -p "$DEPLOY_DIR/$STACK_NAME"

    if [ ! -f "$template_file" ]; then
        echo "❌ $template_file not found!"
        continue
    else
        # Escape WORKING_DIR for sed (handles slashes, spaces, &)
        escaped_dir=$(printf '%s\n' "$VOLUMES_DIR" | sed 's/[&/\]/\\&/g')

        sed "s|{\$VOLUMES_DIR}|$escaped_dir|g" "$template_file" > "$target_file"
        echo "✅ Processed $template_file → $target_file"
    fi
done

echo "🎉 All templates processed."


# -------------------------------
# Setting up portainer and stacks
# -------------------------------

PORTAINER_NAME="portainer"
PORTAINER_PORT=9000
PORTAINER_URL="http://localhost:$PORTAINER_PORT"
ADMIN_USER="admin"
ADMIN_PASS="${PORTAINER_ADMIN_PASSWORD:-minicloud2024!}"  # ✅ 12+ chars required
STACKS_DIR="$PWD/stacks"
NETWORK_NAME="minicloud"

echo "🚀 Starting MiniCloud deployment..."

# --- 1️⃣ Check Docker ---
if ! command -v docker &> /dev/null; then
  echo "❌ Docker not found. Please install Docker Desktop first."
  exit 1
fi

# Check if Docker is actually running
if ! docker info &> /dev/null; then
  echo "❌ Docker is not running. Please install and start Docker Desktop."
  exit 1
fi

# --- 2️⃣ Create Docker network if missing ---
if ! docker network ls | grep -q "$NETWORK_NAME"; then
  echo "🌐 Creating Docker network '$NETWORK_NAME'..."
  docker network create "$NETWORK_NAME"
fi

# --- 3️⃣ Remove old Portainer container ---
if docker ps -a --format '{{.Names}}' | grep -q "^$PORTAINER_NAME$"; then
  echo "🧹 Removing old Portainer container..."
  docker rm -f "$PORTAINER_NAME" >/dev/null 2>&1 || true
fi

# --- 3b️⃣ Remove old Portainer volume to ensure clean start ---
echo "🧹 Removing old Portainer data volume..."
docker volume rm portainer_data >/dev/null 2>&1 || true

# --- 4️⃣ Start Portainer ---
echo "🛠️  Starting Portainer..."
docker run -d \
  -p $PORTAINER_PORT:9000 \
  -p 8000:8000 \
  --name $PORTAINER_NAME \
  --network $NETWORK_NAME \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest >/dev/null

# --- 5️⃣ Wait for Portainer API ---
echo "⏳ Waiting for Portainer API to be ready..."
MAX_WAIT=90
COUNT=0

until curl -sf "$PORTAINER_URL/api/status" >/dev/null 2>&1; do
    sleep 3
    COUNT=$((COUNT+3))
    if [ $COUNT -ge $MAX_WAIT ]; then
        echo "❌ Portainer API did not become ready after $MAX_WAIT seconds."
        echo "Check logs: docker logs $PORTAINER_NAME"
        exit 1
    fi
    echo "  Waiting... ($COUNT/$MAX_WAIT seconds)"
done

echo "✅ Portainer API is ready."

# --- 6️⃣ Create admin user ---
echo "🔑 Creating admin user..."
sleep 2  # Give Portainer a moment to fully initialize

INIT_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$PORTAINER_URL/api/users/admin/init" \
  -H "Content-Type: application/json" \
  -d "{\"Username\":\"$ADMIN_USER\",\"Password\":\"$ADMIN_PASS\"}")

HTTP_CODE=$(echo "$INIT_RESPONSE" | tail -n1)
BODY=$(echo "$INIT_RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Admin user created successfully"
elif [ "$HTTP_CODE" = "409" ]; then
    echo "⚠️  Admin user already exists (this is okay)"
else
    echo "⚠️  Init returned HTTP $HTTP_CODE: $BODY"
    echo "   Attempting to continue..."
fi

# --- 7️⃣ Login to verify ---
echo "🔐 Verifying admin login..."
sleep 2

LOGIN_RESPONSE=$(curl -s -X POST "$PORTAINER_URL/api/auth" \
  -H "Content-Type: application/json" \
  -d "{\"Username\":\"$ADMIN_USER\",\"Password\":\"$ADMIN_PASS\"}")

TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.jwt // empty')

if [ -z "$TOKEN" ]; then
    echo "❌ Failed to login. Response: $LOGIN_RESPONSE"
    echo ""
    echo "💡 Troubleshooting:"
    echo "   1. Check Portainer logs: docker logs $PORTAINER_NAME"
    echo "   2. Visit $PORTAINER_URL in your browser"
    echo "   3. Password must be 12+ characters (current: ${#ADMIN_PASS} chars)"
    exit 1
fi

echo "✅ Successfully logged in to Portainer"

# --- 8️⃣ Create/Get Docker environment ---
echo "🔍 Checking for Docker environment..."

ENVIRONMENTS=$(curl -s "$PORTAINER_URL/api/endpoints" \
  -H "Authorization: Bearer $TOKEN")

ENDPOINT_ID=$(echo "$ENVIRONMENTS" | jq -r '.[0].Id // empty')

if [ -z "$ENDPOINT_ID" ]; then
    echo "📍 Creating local Docker environment..."
    
    # Portainer API requires form data, not JSON!
    CREATE_ENV=$(curl -s -w "\n%{http_code}" -X POST "$PORTAINER_URL/api/endpoints" \
      -H "Authorization: Bearer $TOKEN" \
      -F "Name=local" \
      -F "EndpointCreationType=1")
    
    HTTP_CODE=$(echo "$CREATE_ENV" | tail -n1)
    BODY=$(echo "$CREATE_ENV" | sed '$d')
    
    ENDPOINT_ID=$(echo "$BODY" | jq -r '.Id // empty')
    
    if [ -z "$ENDPOINT_ID" ]; then
        echo "❌ Failed to create environment (HTTP $HTTP_CODE)"
        echo "   Response: $BODY"
        exit 1
    fi
    
    echo "✅ Created Docker environment with ID: $ENDPOINT_ID"
else
    echo "✅ Found existing environment ID: $ENDPOINT_ID"
fi

# --- 9️⃣ Prepare directories ---
mkdir -p "$STACKS_DIR"
mkdir -p "$PWD/caddy"

echo "📁 Stacks directory ready at $STACKS_DIR"

# --- 🔟 Deploy stacks from stacks directory ---
echo ""
echo "📦 Scanning for stacks in $STACKS_DIR..."

DEPLOYED_COUNT=0
FAILED_COUNT=0

# Look for docker-compose files in subdirectories
for STACK_PATH in "$STACKS_DIR"/*; do
    if [ -d "$STACK_PATH" ]; then
        STACK_NAME=$(basename "$STACK_PATH")
        COMPOSE_FILE="$STACK_PATH/docker-compose.yml"
        
        if [ ! -f "$COMPOSE_FILE" ]; then
            COMPOSE_FILE="$STACK_PATH/compose.yml"
        fi
        
        if [ -f "$COMPOSE_FILE" ]; then
            echo "📋 Deploying stack: $STACK_NAME"
            
            # Read the compose file content
            COMPOSE_CONTENT=$(cat "$COMPOSE_FILE")
            
            # Check if stack already exists
            EXISTING_STACK=$(curl -s "$PORTAINER_URL/api/stacks" \
              -H "Authorization: Bearer $TOKEN" | \
              jq -r ".[] | select(.Name==\"$STACK_NAME\") | .Id")
            
            if [ -n "$EXISTING_STACK" ]; then
                echo "   ⚠️  Stack '$STACK_NAME' already exists (ID: $EXISTING_STACK), skipping..."
                continue
            fi
            
            # Create the stack
            STACK_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$PORTAINER_URL/api/stacks/create/standalone/string?endpointId=$ENDPOINT_ID" \
              -H "Authorization: Bearer $TOKEN" \
              -H "Content-Type: application/json" \
              -d @- <<EOF
{
  "name": "$STACK_NAME",
  "stackFileContent": $(echo "$COMPOSE_CONTENT" | jq -Rs .),
  "env": []
}
EOF
)
            
            STACK_HTTP_CODE=$(echo "$STACK_RESPONSE" | tail -n1)
            STACK_BODY=$(echo "$STACK_RESPONSE" | sed '$d')
            
            if [ "$STACK_HTTP_CODE" = "200" ]; then
                echo "   ✅ Successfully deployed '$STACK_NAME'"
                DEPLOYED_COUNT=$((DEPLOYED_COUNT + 1))
            else
                echo "   ❌ Failed to deploy '$STACK_NAME' (HTTP $STACK_HTTP_CODE)"
                echo "   Response: $STACK_BODY"
                FAILED_COUNT=$((FAILED_COUNT + 1))
            fi
            
            sleep 1
        else
            echo "   ⏭️  Skipping '$STACK_NAME' (no docker-compose.yml found)"
        fi
    fi
done

if [ $DEPLOYED_COUNT -eq 0 ] && [ $FAILED_COUNT -eq 0 ]; then
    echo "   ℹ️  No stacks found to deploy"
    echo "   💡 Create subdirectories in $STACKS_DIR with docker-compose.yml files"
    echo "   Example structure:"
    echo "      $STACKS_DIR/nextcloud/docker-compose.yml"
    echo "      $STACKS_DIR/photoprism/docker-compose.yml"
fi

echo ""
echo "📊 Deployment summary: $DEPLOYED_COUNT deployed, $FAILED_COUNT failed"

# --- 1️⃣1️⃣ Summary ---
echo ""
echo "========================================="
echo "✨ MiniCloud base setup complete!"
echo "========================================="
echo "Portainer URL:     $PORTAINER_URL"
echo "Admin username:    $ADMIN_USER"
echo "Admin password:    $ADMIN_PASS"
echo "Stacks folder:     $STACKS_DIR"
echo "Network:           $NETWORK_NAME"
echo "Endpoint ID:       $ENDPOINT_ID"
echo "========================================="
echo ""
echo "📝 Next steps:"
echo "   1. Open $PORTAINER_URL in your browser"
echo "   2. Login with the credentials above"
echo "   3. Check your deployed stacks in Portainer"
echo "   4. Add more stacks: create folders in $STACKS_DIR with docker-compose.yml"
echo "   ⚠️  Attention for filebrowser, see container logs for user name and first password."
echo ""
echo "🔧 Useful commands:"
echo "   - View logs:       docker logs $PORTAINER_NAME"
echo "   - Restart:         docker restart $PORTAINER_NAME"
echo "   - Stop:            docker stop $PORTAINER_NAME"
echo "========================================="