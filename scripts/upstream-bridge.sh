#!/usr/bin/env bash

# Upstream Bridge
# This script automatically synchronizes the Redox OS fork with the main upstream repository.
# It fetches the latest changes from upstream master and attempts to rebase or merge
# them into the current fork to keep everything up to date.

set -e

# Configuration
UPSTREAM_URL="https://gitlab.redox-os.org/redox-os/redox.git"
UPSTREAM_REMOTE="upstream"
BRANCH_TO_SYNC="master"

echo "========================================="
echo "        Redox OS Upstream Bridge         "
echo "========================================="

# Ensure we're in the redox checkout directory
if [ ! -d ".git" ]; then
    echo "Error: Not in a git repository. Must run from the root of the redox project."
    exit 1
fi

# Check if upstream remote exists, add if it doesn't
if ! git remote get-url "$UPSTREAM_REMOTE" >/dev/null 2>&1; then
    echo "Adding upstream remote: $UPSTREAM_URL"
    git remote add "$UPSTREAM_REMOTE" "$UPSTREAM_URL"
fi

# Fetch from upstream
echo "Fetching from $UPSTREAM_REMOTE..."
git fetch "$UPSTREAM_REMOTE"

# Ensure we are on the branch to sync
current_branch=$(git rev-parse --abbrev-ref HEAD)
if [ "$current_branch" != "$BRANCH_TO_SYNC" ]; then
    echo "Switching to branch $BRANCH_TO_SYNC..."
    git checkout "$BRANCH_TO_SYNC"
fi

# Sync strategy: Rebase to maintain a clean history
echo "Synchronizing with upstream/$BRANCH_TO_SYNC via rebase..."
if git rebase "$UPSTREAM_REMOTE/$BRANCH_TO_SYNC"; then
    echo "Successfully synchronized with upstream."
    
    # Update submodules if necessary
    echo "Updating submodules..."
    git submodule update --init --recursive
    
    echo "Sync complete!"
else
    echo "Warning: Rebase failed due to conflicts."
    echo "Aborting rebase. Please resolve conflicts manually."
    git rebase --abort
    exit 1
fi
