#!/bin/bash
echo "⚠️  Make sure apt-file is installed and updated before running this script."
echo "   If not, run: sudo apt install apt-file && sudo apt-file update"
echo

read -rp "🛠️  Enter the path to your daemon (e.g. ./griffiond): " DAEMON

# Check if file exists and is executable
if [[ ! -x "$DAEMON" ]]; then
  echo "❌ Error: '$DAEMON' not found or not executable."
  exit 1
fi

MAX_ATTEMPTS=10
ATTEMPT=0

echo "🔍 Scanning for missing libraries required by $DAEMON..."

# Ensure apt-file is ready
if ! command -v apt-file &> /dev/null; then
  echo "📦 Installing apt-file..."
  sudo apt update
  sudo apt install -y apt-file
  sudo apt-file update
fi

while [[ $ATTEMPT -lt $MAX_ATTEMPTS ]]; do
  MISSING_LIBS=($(ldd "$DAEMON" | grep "not found" | awk '{print $1}'))
  
  if [[ ${#MISSING_LIBS[@]} -eq 0 ]]; then
    echo "✅ All dependencies resolved. Launching $DAEMON..."
    exec "$DAEMON"
    exit 0
  fi

  echo "⚠️  Found ${#MISSING_LIBS[@]} missing libraries..."

  for LIB in "${MISSING_LIBS[@]}"; do
    echo "🔍 Searching for package providing: $LIB"
    PACKAGE=$(apt-file search "$LIB" | head -n1 | cut -d: -f1)

    if [[ -n "$PACKAGE" ]]; then
      echo "📦 Installing: $PACKAGE"
      sudo apt install -y "$PACKAGE"
    else
      echo "❌ Could not find a package for: $LIB"
    fi
  done

  ((ATTEMPT++))
  echo "♻️  Rechecking dependencies... (attempt $ATTEMPT)"
done

echo "🚫 Max attempts reached. Some dependencies may still be missing."
exit 1
