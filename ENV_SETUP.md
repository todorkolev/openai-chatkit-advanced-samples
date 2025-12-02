# Environment Variables Setup

This guide explains how to configure your environment variables for the ChatKit Examples Docker container.

## Quick Start

1. **Copy the example file:**
   ```bash
   cp .env.example .env
   ```

2. **Edit the `.env` file and add your OpenAI API key:**
   ```bash
   # Open in your favorite editor
   nano .env
   # or
   vim .env
   # or
   code .env
   ```

3. **Add your API key:**
   ```env
   OPENAI_API_KEY=sk-proj-your-actual-key-here
   ```

4. **Run the container:**
   ```bash
   ./run-docker.sh
   ```

## Getting Your OpenAI API Key

1. Go to [OpenAI Platform](https://platform.openai.com/api-keys)
2. Sign in or create an account
3. Click "Create new secret key"
4. Copy the key (it starts with `sk-proj-...`)
5. Paste it into your `.env` file

## Environment Variables

### Required

- **`OPENAI_API_KEY`** - Your OpenAI API key for making API calls
  - Format: `sk-proj-...`
  - Get it from: https://platform.openai.com/api-keys

### Optional

- **`VITE_CHATKIT_API_DOMAIN_KEY`** - ChatKit domain allowlist key (for production)
  - Default: `domain_pk_local_dev` (works for local development)
  - For production, get from: https://platform.openai.com/settings/organization/security/domain-allowlist

## Alternative Methods

### Method 1: Using .env file (Recommended)

```bash
# Edit .env file
echo "OPENAI_API_KEY=sk-proj-your-key-here" > .env

# Run the script (it will automatically load .env)
./run-docker.sh
```

### Method 2: Export in terminal

```bash
# Export the key
export OPENAI_API_KEY=sk-proj-your-key-here

# Run the script
./run-docker.sh
```

### Method 3: Pass directly to docker

```bash
# Build the image first
docker build -t chatkit-examples .

# Run with the key
docker run -p 80:80 -e OPENAI_API_KEY=sk-proj-your-key-here chatkit-examples
```

## Security Notes

⚠️ **Important Security Practices:**

1. **Never commit `.env` to git** - It's already in `.gitignore`
2. **Don't share your API key** - Keep it private
3. **Rotate keys regularly** - Generate new keys periodically
4. **Use different keys** - Use separate keys for dev/staging/production
5. **Set usage limits** - Configure spending limits in OpenAI dashboard

## Troubleshooting

### "OPENAI_API_KEY not set" error

**Solution:** Make sure you've added your key to the `.env` file or exported it:
```bash
# Check if it's set
echo $OPENAI_API_KEY

# If empty, add it to .env or export it
export OPENAI_API_KEY=sk-proj-your-key-here
```

### API calls failing with 401 Unauthorized

**Possible causes:**
1. Invalid API key - Check if you copied it correctly
2. Expired key - Generate a new one
3. Insufficient credits - Check your OpenAI account balance

### .env file not being loaded

**Solution:** Make sure:
1. The file is named exactly `.env` (not `.env.txt`)
2. It's in the root directory of the project
3. You're running `./run-docker.sh` from the project root

## Example .env File

```env
# OpenAI API Key (Required)
OPENAI_API_KEY=sk-proj-abc123def456ghi789jkl012mno345pqr678stu901vwx234yz

# ChatKit Domain Key (Optional - for production)
VITE_CHATKIT_API_DOMAIN_KEY=domain_pk_local_dev
```

## Need Help?

- OpenAI API Documentation: https://platform.openai.com/docs
- OpenAI API Keys: https://platform.openai.com/api-keys
- OpenAI Usage Dashboard: https://platform.openai.com/usage

