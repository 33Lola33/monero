#!/bin/bash

# Usage information
echo "Usage: $0 [NEW_COIN_NAME] [NEW_COIN_TICKER]"
NEW_COIN_NAME=${1:-"MyNewCoin"}
NEW_COIN_TICKER=${2:-"MNC"}

# Change to correct directory
if ! cd ~/monero; then
    echo "Failed to change to monero directory"
    exit 1
fi

# Function to replace text in files
replace_text() {
    local old_text="$1"
    local new_text="$2"
    git grep -l "$old_text" | xargs sed -i "s/$old_text/$new_text/g"
}

# Replace [OptionalNewCoinName] with the new coin name
echo "Replacing [OptionalNewCoinName] with $NEW_COIN_NAME..."
replace_text "[OptionalNewCoinName]" "$NEW_COIN_NAME"

# Replace [OptionalNewCoinTicker] with the new coin ticker
echo "Replacing [OptionalNewCoinTicker] with $NEW_COIN_TICKER..."
replace_text "[OptionalNewCoinTicker]" "$NEW_COIN_TICKER"

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
git commit -m "Forked [OptionalNewCoinName] to $NEW_COIN_NAME with basic changes"

# Build the project
echo "Building the project..."
make

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "Build successful. Starting node in testnet mode..."
    # Use the correct path for monerod
    /home/gypsy/monero/build/Linux/master/release/bin/monerod --testnet --p2p-bind-ip 127.0.0.1 --add-exclusive-node 127.0.0.1 &
    
    echo "Generating a new wallet..."
    # Use the correct path for monero-wallet-cli
    if /home/gypsy/monero/build/Linux/master/release/bin/monero-wallet-cli --testnet --generate-new-wallet "${NEW_COIN_NAME,,}_wallet"; then
        echo "Wallet creation successful."
    else
        echo "Wallet creation failed."
    fi

    echo "Remember to mine some test coins if you want to test transactions!"
else
    echo "Build failed. Please check your changes and try again."
fi

# Push changes to your fork on GitHub
echo "Pushing changes to GitHub..."
git push origin master

echo "Script completed. Check your setup and test your new coin!"

# Exit script successfully
exit 0