# Set your Git user identity
git config user.email "devi.priya@microsoft.com"
git config user.name "devi-priya_avl"

# Navigate to the desired directory
Set-Location environment/devbox

# Generate a unique tag name based on the current timestamp
$TAG_NAME = "trigger-workflow-$(Get-Date -Format yyyyMMddHHmmss)"

# Check if the tag or branch exists in the repository
if (git show-ref --tags --quiet --verify "refs/tags/$TAG_NAME") {
    Write-Output "Tag '$TAG_NAME' already exists. Aborting."
    exit 1
}

# Create and push the tag
git tag -a $TAG_NAME -m "Trigger GitHub Actions workflow"
git push origin $TAG_NAME
