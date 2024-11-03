#!/bin/bash

# Prompt the user for each mining parameter
read -p "Enter the algorithm (e.g., kawpow, ethash): " algorithm
read -p "Enter the pool address (e.g., pool.example.com): " pool_address
read -p "Enter the port (e.g., 3333): " port
read -p "Enter the wallet address: " wallet
read -p "Enter the password (optional, defaults to 'x'): " password

# Set default password to 'x' if none was provided
password=${password:-x}

# Display the information entered for verification
echo ""
echo "Configuration Summary:"
echo "----------------------"
echo "Algorithm: $algorithm"
echo "Pool Address: $pool_address"
echo "Port: $port"
echo "Wallet Address: $wallet"
echo "Password: $password"
echo ""

# Create the 'readytomine.sh' file with the command
config_file="readytomine.sh"
echo "#!/bin/bash" > "$config_file"
echo "./t-rex --algo $algorithm --url $pool_address:$port --user $wallet --pass $password" >> "$config_file"

# Make the file executable
chmod +x "$config_file"
