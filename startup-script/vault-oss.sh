#!/bin/sh -x

install_unzip() {
    sudo apt-get update -y
    sudo apt-get install -y unzip
}

process_exit_code_analyser() {
    EXITVAL=${1}
    debug_message=${2}

    if [ ${1} -eq 0 ]
    then
        echo "SUCCESS: $2"
    else 
        echo "FAILURE: $2 ; script exiting with exit code: ${1}"
        exit ${1}
    fi
}

create_directories() {
    sudo mkdir -p /opt/vault/{logs,bin,data}
    EXITVAL=$?
    process_exit_code_analyser $EXITVAL "directory creation process"
    
    sudo mkdir -p /etc/vault
    EXITVAL2=$?
    process_exit_code_analyser $EXITVAL2 "/etc/vault directory creation"
}

download_binary() {
    wget https://releases.hashicorp.com/vault/1.10.3/vault_1.10.3_linux_amd64.zip
    EXITVAL=$?
    process_exit_code_analyser ${EXITVAL} "vault binary download process"
    sudo unzip vault_1.10.3_linux_amd64.zip -d /opt/vault/bin
    EXITVAL2=$?
    process_exit_code_analyser ${EXITVAL} "vault binary unzipping process"
}

vault_configuration() {
    #[ -f /etc/vault/config.json ] ? echo "config file created" : echo "config file creation failed"
    sudo cat <<'EOF' > /tmp/config.json.tmp 
    {
	    "listener": [{
		    "tcp": {
		    	"address": "0.0.0.0:8200",
	    		"tls_disable": 1
    		}
	    }],
	    "api_addr": "http://127.0.0.1:8200",
	    "storage": {
		    "file": {
			    "path": "/opt/vault/data"
		    }
	    },
	    "max_lease_ttl": "10h",
	    "default_lease_ttl": "10h",
	    "ui": true
    }
EOF
cp /tmp/config.json.tmp ~/config.json
sudo chmod 755 ~/config.json
}

create_user_service_for_vault() {
    sudo useradd -r vault
    sudo chown -R vault:vault /opt/vault

    
    sudo cat <<'EOF' >> /tmp/vault.service.tmp
    [Unit]
    Description=vault service
    Requires=network-online.target
    After=network-online.target
    ConditionFileNotEmpty=~/config.json

    [Service]
    User=vault
    Group=vault
    EnvironmentFile=-/etc/sysconfig/vault
    Environment=GOMAXPROCS=2
    Restart=on-failure
    ExecStart=/opt/vault/vault server -config=~/config.json
    StandardOutput=/opt/vault/logs/output.log
    StandardError=/opt/vault/logs/error.log
    LimitMEMLOCK=infinity
    ExecReload=/bin/kill -HUP $MAINPID/
    KillSignal=SIGTERM

    [Install]
    WantedBy=multi-user.target
EOF
sudo cp /tmp/vault.service.tmp /etc/systemd/system/vault.service
sudo chmod 755 /etc/systemd/system/vault.service
}

enable_vault() {
    sudo systemctl enable vault.service 
    EXITVAL=$?
    process_exit_code_analyser ${EXITVAL} "vault service enable"

    sudo systemctl start vault.service
    EXITVAL2=$?
    process_exit_code_analyser ${EXITVAL2} "vault service start"
}

prep_vault() {
    export PATH=$PATH:/opt/vault/bin
    echo "export PATH=$PATH:/opt/vault/bin" >> ~/.bashrc
}


install_unzip
create_directories
download_binary
vault_configuration
create_user_service_for_vault
#enable_vault
prep_vault