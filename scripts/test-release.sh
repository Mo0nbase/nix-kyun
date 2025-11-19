#!/usr/bin/env bash
# Retrigger test release workflow
# This script deletes the existing test release and tag, then recreates them
# to trigger a fresh release workflow run.

set -e

TAG_NAME="v0.1.0-test"
RELEASE_TITLE="Test Release v0.1.0"

echo "================================================"
echo "Retriggering Test Release Workflow"
echo "================================================"
echo ""
echo "Tag: $TAG_NAME"
echo "Release: $RELEASE_TITLE"
echo ""

# Check if gh CLI is available
if ! command -v gh &> /dev/null; then
    echo "ERROR: GitHub CLI (gh) is not installed"
    echo "Install it with: https://cli.github.com/"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "ERROR: Not authenticated with GitHub CLI"
    echo "Run: gh auth login"
    exit 1
fi

echo "Step 1: Deleting existing release..."
if gh release view "$TAG_NAME" &> /dev/null; then
    gh release delete "$TAG_NAME" --yes
    echo "✓ Release deleted"
else
    echo "→ Release does not exist (skipping)"
fi

echo ""
echo "Step 2: Deleting remote tag..."
if git ls-remote --tags origin | grep -q "refs/tags/$TAG_NAME"; then
    git push --delete origin "$TAG_NAME"
    echo "✓ Remote tag deleted"
else
    echo "→ Remote tag does not exist (skipping)"
fi

echo ""
echo "Step 3: Deleting local tag..."
if git tag -l | grep -q "^$TAG_NAME$"; then
    git tag -d "$TAG_NAME"
    echo "✓ Local tag deleted"
else
    echo "→ Local tag does not exist (skipping)"
fi

echo ""
echo "Step 4: Creating new tag on latest commit..."
LATEST_COMMIT=$(git rev-parse HEAD)
COMMIT_SHORT=$(git rev-parse --short HEAD)
echo "Latest commit: $COMMIT_SHORT"
git tag -a "$TAG_NAME" -m "$RELEASE_TITLE"
echo "✓ Local tag created"

echo ""
echo "Step 5: Pushing tag to remote..."
git push origin "$TAG_NAME"
echo "✓ Tag pushed"

echo ""
echo "Step 6: Creating release..."
gh release create "$TAG_NAME" \
    --title "$RELEASE_TITLE" \
    --notes "Test release for workflow validation.

This is an automated test release. The release workflow will build and attach the NixOS image artifacts.

**Commit:** $COMMIT_SHORT
**Purpose:** Testing release workflow and image build process" \
    --prerelease

echo "✓ Release created"

echo ""
echo "================================================"
echo "✓ Test release retriggered successfully!"
echo "================================================"
echo ""
echo "The release workflow should now be running."
echo "Check status at: https://github.com/$(gh repo view --json nameWithOwner -q .nameWithOwner)/actions"
echo ""
echo "View release at: https://github.com/$(gh repo view --json nameWithOwner -q .nameWithOwner)/releases/tag/$TAG_NAME"
