#!/bin/bash

# This environment variable should be set in your CI/CD pipeline.
# It should be "SUCCESS" if the build passed or something else if it failed.
if [[ "$BUILD_STATUS" != "SUCCESS" ]]; then
    echo "Build failed. Sending failure email..."
    aws ses send-email \
      --from "nirmalp2632@gmail.com" \
      --destination "ToAddresses=nirmalp2632@gmail.com" \
      --message "Subject={Data='Deployment Failed'},Body={Text={Data='The build or deployment has failed. Please check the logs for details.'}}"
    exit 0
fi

# Assuming the script is triggered by CodeDeploy and we are deploying to the 'TESTING-DEPLOYMENT' environment.
DEPLOYMENT_GROUP_NAME="TESTING-DEPLOYMENT"  # Updated deployment group name.

echo "Deployment group: $DEPLOYMENT_GROUP_NAME"

# Only send success email if this is the 'TESTING-DEPLOYMENT' environment
if [[ "$DEPLOYMENT_GROUP_NAME" == "TESTING-DEPLOYMENT" ]]; then
    echo "Build succeeded and deployment group is 'TESTING-DEPLOYMENT'. Sending success email..."
    aws ses send-email \
      --from "nirmalp2632@gmail.com" \
      --destination "ToAddresses=nirmalp2632@gmail.com" \
      --message "Subject={Data='Deployment Completed'},Body={Text={Data='Your application has been successfully deployed.'}}"
fi
