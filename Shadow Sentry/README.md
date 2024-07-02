A SOC project to detect and analyse malicious activity on the network, with a self-written pentest script to attack the system and monitor the alerts.

Summary:
- A SIEM server and honeypot server were configured separately on DigitalOcean.
- Elastic Cloud was installed on the SIEM server and established connectivity and secure communication between the Elastic Stack components (Elasticsearch, Logstash, Kibana).
- Installed Filebeat on the honeypot server to collect and send desired logs to the SIEM server.
- Simulated common services on the honeypot server such as a fake corporate webpage run on Apache2, an FTP service using VSFTPD, and SSH and Telnet routed to the Cowrie honeypot.
- Hardened both servers by setting firewall rules, disabling unnecessary ports and services, implementing strong credentials and security updates, and installing Fail2ban.
- Configured Kibana indices and dashboards to visualise real-time security events and capture attacks.
- Defined alerting rules to detect attacks when they occur.

The pentest script was written to scan a network and simulate the following attacks against the honeypot server:
  1) A brute force attack and netcat reverse shell connection cronjob to gain persistence in the target server.
  2) A TCP SYN flood DDoS attack using Hping3.
  3) Harvesting credentials via remote command execution using Metasploit.
