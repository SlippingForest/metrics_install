### install exporter; port 48620
```bash
wget -O - https://raw.githubusercontent.com/SlippingForest/metrics_install/master/install_exporter_linux.sh | bash <(cat) </dev/tty
```
### Check if exporter is running
```bash
sudo service metrics-exporter status
```

### install agent
```bash
wget -O - https://raw.githubusercontent.com/SlippingForest/metrics_install/master/install_agent_linux.sh | bash <(cat) </dev/tty
```
### Check if agent is running
```bash
sudo service metrics-agent status
```

### uninstall
```bash
wget -O - https://raw.githubusercontent.com/SlippingForest/metrics_install/master/uninstall.sh | bash <(cat) </dev/tty
```