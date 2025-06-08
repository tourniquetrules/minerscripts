#!/bin/bash

# Prompt for the coin name
read -p "Enter the new coin name (e.g., blobfish): " COIN

if [[ -z "$COIN" ]]; then
  echo "❌ Coin name cannot be empty."
  exit 1
fi

COIN_LOWER=$(echo "$COIN" | tr '[:upper:]' '[:lower:]')
COIN_UPPER=$(echo "$COIN" | tr '[:lower:]' '[:upper:]')
COIN_PASCAL="$(tr '[:lower:]' '[:upper:]' <<< ${COIN:0:1})${COIN:1}"

DOCKERFILE="Dockerfile"
COIN_DIR="/data/.${COIN_LOWER}"
CONF_FILE="${COIN_DIR}/${COIN_LOWER}.conf"
RUN_SCRIPT="run_${COIN_LOWER}.sh"
ADDR_SCRIPT="generate_pooladdress_${COIN_LOWER}.sh"

# Generate Dockerfile
cat > "$DOCKERFILE" <<EOF
FROM ubuntu:22.04

# Install core dependencies
RUN apt-get update && \\
    apt-get install -y libboost-all-dev

# Set working directory
WORKDIR /opt/

# Copy local precompiled binaries into image
COPY ${COIN_LOWER}d /usr/bin/${COIN_LOWER}d
COPY ${COIN_LOWER}-cli /usr/bin/${COIN_LOWER}-cli

# Make sure they are executable
RUN chmod +x /usr/bin/${COIN_LOWER}d /usr/bin/${COIN_LOWER}-cli

# Define the data volume for config and blockchain data
VOLUME ["/root/.${COIN_LOWER}"]

# Start the daemon in foreground
CMD ["/usr/bin/${COIN_LOWER}d", "-printtoconsole"]
EOF

echo "✅ Dockerfile for '$COIN_LOWER' created."

# Build Docker image
docker build -t "$COIN_LOWER" .

# Create config directory
mkdir -p "$COIN_DIR"

# Find next available RPC port
START_PORT=9010
RPC_PORT=$START_PORT
while grep -r "rpcport=$RPC_PORT" /data/.*/*.conf 2>/dev/null | grep -q .; do
  ((RPC_PORT++))
done

# Create .conf file
cat > "$CONF_FILE" <<EOF
server=1
listen=1
rpcport=$RPC_PORT
rpcuser=x
rpcpassword=abc123
prune=550
wallet=default
EOF

echo "✅ Created config at $CONF_FILE with rpcport=$RPC_PORT"

# Create run script
cat > "$RUN_SCRIPT" <<EOF
#!/bin/bash
sudo docker run -d \\
  --network host \\
  --restart always \\
  --log-opt max-size=10m \\
  --name ${COIN_LOWER} \\
  -v /data/.${COIN_LOWER}/:/root/.${COIN_LOWER}/ \\
  ${COIN_LOWER}:latest
EOF

chmod +x "$RUN_SCRIPT"
echo "✅ Created launch script: ./$RUN_SCRIPT"

# Create generate_pooladdress script
cat > "$ADDR_SCRIPT" <<EOF
#!/bin/bash
echo "🔐 Generating new address inside '${COIN_LOWER}' container..."
ADDRESS=\$(sudo docker exec ${COIN_LOWER} ${COIN_LOWER}-cli getnewaddress)
echo "📬 Address: \$ADDRESS"
PRIVKEY=\$(sudo docker exec ${COIN_LOWER} ${COIN_LOWER}-cli dumpprivkey \$ADDRESS)
echo "🔑 Private Key: \$PRIVKEY"
EOF

chmod +x "$ADDR_SCRIPT"
echo "✅ Created pool address script: ./$ADDR_SCRIPT"

echo "🚀 All done! Build image, config, and scripts ready for '$COIN_LOWER'."
