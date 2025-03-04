#!/bin/bash

# This environment variable should be set in your CI/CD pipeline.
# It should be "SUCCESS" if the build passed or something else if it failed.
if [[ "$BUILD_STATUS" != "SUCCESS" ]]; then
    echo "Build failed. Sending failure email..."
    aws ses send-email \
      --from "nirmalp2632@gmail@gmail.com" \
      --destination "ToAddresses=nirmalp2632@gmail@gmail.com" \
      --message "Subject={Data='Deployment Failed'},Body={Text={Data='The build or deployment has failed. Please check the logs for details.'}}"
    exit 0
fi

# If build passed, get the deployment group name from CodeDeploy
DEPLOYMENT_GROUP_NAME=$(aws deploy get-deployment-group --application-name MyApp --deployment-group-name test --query "deploymentGroupInfo.deploymentGroupName" --output text)
echo "Retrieved deployment group: $DEPLOYMENT_GROUP_NAME"

# Only send success email if this is the test environment
if [[ "$DEPLOYMENT_GROUP_NAME" == "test" ]]; then
    echo "Build succeeded and deployment group is 'test'. Sending success email..."
    aws ses send-email \
      --from "nirmalp2632@gmail.com" \
      --destination "ToAddresses=nirmalp2632@gmail.com" \
      --message "Subject={Data='Deployment Completed'},Body={Text={Data='Your application has been successfully deployed.'}}"
fi