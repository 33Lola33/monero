#!/bin/bash

# Ensure we're in the correct directory
cd ~/monero

# Function to replace text in files
replace_text() {
    local old_text="$1"
    local new_text="$2"
    git grep -l "$old_text" | xargs sed -i "s/$old_text/$new_text/g"
}

# Replace Monero with your new coin name
echo "Replacing Monero with MyNewCoin..."
replace_text "Monero" "MyNewCoin"

# Replace XMR with your new coin ticker
echo "Replacing XMR with MNC..."
replace_text "XMR" "MNC"

# Edit cryptonote_config.h manually for network-specific changes
echo "Editing src/cryptonote_config.h for network specifics..."
nano src/cryptonote_config.h

# Wait for user to finish editing
echo "Press Enter when you're done editing..."
read

# Stage all changes
echo "Staging changes..."
git add .

# Commit changes
echo "Committing changes..."
git commit -m "Forked Monero to MyNewCoin with basic changes"

# Build the project
echo "Building the project..."
make

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "Build successful. Starting node in testnet mode..."
    ./build/release/bin/monerod --testnet --p2p-bind-ip 127.0.0.1 --add-exclusive-node 127.0.0.1 &
    
    echo "Generating a new wallet..."
    ./build/release/bin/monero-wallet-cli --testnet --generate-new-wallet mynewcoin_wallet

    echo "Remember to mine some test coins if you want to test transactions!"
else
    echo "Build failed. Please check your changes and try again."
fi

# Push changes to your fork on GitHub
echo "Pushing changes to GitHub..."
git push origin master

echo "Script completed. Check your setup and test your new coin!"