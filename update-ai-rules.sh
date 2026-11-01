#!/usr/bin/env bash
set -e

echo "🔄 Pulling latest AI rules from RapiderAI/rapider-ai-rules..."

# Create a temporary directory
TEMP_DIR=$(mktemp -d)

# Clone only the latest commit to save time
git clone --depth 1 git@github.com:RapiderAI/rapider-ai-rules.git "$TEMP_DIR"

echo "📦 Applying rules to the current application..."

# Remove old AI configuration files
rm -rf .agents
rm -f AGENTS.md .cursorrules .windsurfrules

# Copy the updated files from the rapider-app template
cp -R "$TEMP_DIR/rapider-app/.agents" ./
cp "$TEMP_DIR/rapider-app/AGENTS.md" ./
cp "$TEMP_DIR/rapider-app/.cursorrules" ./
cp "$TEMP_DIR/rapider-app/.windsurfrules" ./

# Clean up
rm -rf "$TEMP_DIR"

echo "✅ AI rules updated successfully!"
