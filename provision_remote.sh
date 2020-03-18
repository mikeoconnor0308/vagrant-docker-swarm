# Configures docker to expose it's API on the provide port. 
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo bash -c 'cat > /etc/systemd/system/docker.service.d/startup_options.conf' << EOF
# /etc/systemd/system/docker.service.d/override.conf
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:${DOCKER_PORT}
...
EOF

echo "Restarting docker"
sudo systemctl daemon-reload
sudo systemctl restart docker.service