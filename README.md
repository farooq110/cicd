# APP09759 Cloud Deployment Module State Machine

- App ID: [APP09759](https://nordstrom.service-now.com/nerds?s=&spa=1&appid=APP09759&t=1)
- Last Reviewed Date: 03/26/2025
- Contact Information:
  - [#publiccloud](https://nordstrom.slack.com/archives/C13RCA4RH)
  - [techpubcloud@nordstrom.com](mailto:techpubcloud@nordstrom.com)
- Telemetry: N/A

This repo contains the IaC for the Cloud Deployment Module state machine. Individual lambdas found in other repos in this folder. See [Github Component Layer 5-pager](https://git.jwn.app/TM00231/github-component-layer/cloud-component-design/-/blob/main/5-pager.md) for more details.

The event it recieves is in the format:
`
{
    "cloud": "AWS",
    "cloud_acct_id": "012345678901",
    "app_id": "APP01234",
    "invoker": "ServiceNow"
}
`
  
## Contributing

To contribute to this script, `git pull` to get the most up to date version of the code. Then make changes and submit an MR for Cloud Engineering to review. Be sure the team is aware of changes so that engineers who run the script can `pull` to get the updates so they are not using outdated code.

## Branching Strategy

feature_branch > moon_branch > main_branch

    ```BASH
    git checkout main
    git pull origin main

    git checkout moon
    git pull origin moon
    git merge main moon
    
    git checkout -b <feature_branch>
    ```