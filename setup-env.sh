#!/bin/bash

# Interactive script to set up .env file

echo "🔧 ChatKit Examples - Environment Setup"
echo "========================================"
echo ""

# Check if .env already exists
if [ -f .env ]; then
    echo "⚠️  .env file already exists!"
    echo ""
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Setup cancelled. Your existing .env file was not modified."
        exit 0
    fi
    echo ""
fi

echo "Let's set up your environment variables."
echo ""
echo "📝 You'll need:"
echo "  1. OpenAI API Key (required)"
echo "     Get it from: https://platform.openai.com/api-keys"
echo ""
echo "  2. ChatKit Domain Key (optional, for production)"
echo "     Get it from: https://platform.openai.com/settings/organization/security/domain-allowlist"
echo ""

# Get OpenAI API Key
while true; do
    read -p "Enter your OpenAI API Key (starts with sk-proj-): " OPENAI_KEY
    
    if [ -z "$OPENAI_KEY" ]; then
        echo "❌ API key cannot be empty!"
        echo ""
        read -p "Do you want to skip this and set it later? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            OPENAI_KEY=""
            break
        fi
    elif [[ ! $OPENAI_KEY =~ ^sk- ]]; then
        echo "⚠️  Warning: API key should start with 'sk-'"
        echo ""
        read -p "Use this key anyway? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            break
        fi
    else
        break
    fi
done

echo ""

# Get ChatKit Domain Key (optional)
read -p "Enter ChatKit Domain Key (press Enter to use default 'domain_pk_local_dev'): " DOMAIN_KEY

if [ -z "$DOMAIN_KEY" ]; then
    DOMAIN_KEY="domain_pk_local_dev"
fi

echo ""
echo "📄 Creating .env file..."

# Create .env file
cat > .env << EOF
# OpenAI API Key
# Get your API key from: https://platform.openai.com/api-keys
OPENAI_API_KEY=$OPENAI_KEY

# Optional: ChatKit Domain Key (for production)
# Get from: https://platform.openai.com/settings/organization/security/domain-allowlist
VITE_CHATKIT_API_DOMAIN_KEY=$DOMAIN_KEY
EOF

echo "✅ .env file created successfully!"
echo ""

if [ -z "$OPENAI_KEY" ]; then
    echo "⚠️  Remember to add your OpenAI API key to the .env file before running the container!"
    echo ""
    echo "Edit .env and add your key:"
    echo "  OPENAI_API_KEY=sk-proj-your-key-here"
else
    echo "🎉 All set! You can now run the Docker container:"
    echo ""
    echo "  ./run-docker.sh"
fi

echo ""
echo "📚 For more information, see ENV_SETUP.md"
echo ""

