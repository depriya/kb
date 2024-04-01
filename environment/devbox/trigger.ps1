# Create and push a trigger tag
$TAG_NAME = "trigger-workflow-$(Get-Date -Format yyyyMMddHHmmss)"  # Add a timestamp to make the tag unique
git tag -a $TAG_NAME -m "Trigger GitHub Actions workflow"
git push origin $TAG_NAME
