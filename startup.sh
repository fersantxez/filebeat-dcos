tee /dcos-journalctl-filebeat.sh<-EOF 
#!/bin/bash
/usr/bin/journalctl --no-tail -f \
  -u dcos-3dt.service 				 \
  -u dcos-3dt.socket				 \
  -u dcos-adminrouter-reload.service \
  -u dcos-adminrouter-reload.timer   \
  -u dcos-adminrouter.service        \
  -u dcos-bouncer.service            \
  -u dcos-ca.service                 \
  -u dcos-cfn-signal.service         \
  -u dcos-cosmos.service             \
  -u dcos-download.service           \
  -u dcos-epmd.service               \
  -u dcos-exhibitor.service          \
  -u dcos-gen-resolvconf.service     \
  -u dcos-gen-resolvconf.timer       \
  -u dcos-history.service            \
  -u dcos-link-env.service           \
  -u dcos-logrotate-master.timer     \
  -u dcos-marathon.service           \
  -u dcos-mesos-dns.service          \
  -u dcos-mesos-master.service       \
  -u dcos-metronome.service          \
  -u dcos-minuteman.service          \
  -u dcos-navstar.service            \
  -u dcos-networking_api.service     \
  -u dcos-secrets.service            \
  -u dcos-setup.service              \
  -u dcos-signal.service             \
  -u dcos-signal.timer               \
  -u dcos-spartan-watchdog.service   \
  -u dcos-spartan-watchdog.timer     \
  -u dcos-spartan.service            \
  -u dcos-vault.service              \
  -u dcos-logrotate-master.service   \
  -u dcos-logrotate-agent.timer            \
  -u dcos-mesos-slave.service              \
  -u dcos-adminrouter-agent.service        \
  -u dcos-adminrouter-reload.service       \
  -u dcos-adminrouter-reload.timer         \
  -u dcos-rexray.service                   \
  -u dcos-vol-discovery-priv-agent.service \
  -u dcos-logrotate-agent.service          \
  > /var/log/dcos/dcos.log 2>&1
EOF

mkdir -p /var/log/dcos

tee /etc/filebeat/filebeat.yml <<-EOF 
filebeat.prospectors:
- input_type: log
  paths:
    - /var/lib/mesos/slave/slaves/*/frameworks/*/executors/*/runs/latest/stdout
    - /var/lib/mesos/slave/slaves/*/frameworks/*/executors/*/runs/latest/stderr
    - /var/log/mesos/*.log
    - /var/log/dcos/dcos.log
tail_files: true
output.elasticsearch:
  hosts: ["$ELASTIC_HOST:$ELASTIC_PORT"]
EOF

chmod 0755 /dcos-journalctl-filebeat.sh
/bin/dcos-journalctl-filebeat.sh