# NATS Production Cluster Deployment

Production-ready NATS 3-node cluster deployment using Ansible.

## Prerequisites

- Ansible >= 2.9
- Three Linux servers (Ubuntu 20.04+ or RHEL/CentOS 8+)
- SSH access to all servers
- Sudo privileges
- Python 3.x on target servers

## Quick Start

1. Clone this repository
2. Configure your inventory:
   ```bash
   cp inventory/hosts.yml.example inventory/hosts.yml
   # Edit inventory/hosts.yml with your server IPs
   ```

3. Set up SSL certificates:
   ```bash
   # Place your certificates in the following structure:
   /etc/nats/certs/
   ├── ca.pem
   ├── server-cert.pem
   └── server-key.pem
   ```

4. Create secure credentials:
   ```bash
   ansible-vault create group_vars/vault.yml
   # Add required secrets:
   vault_nats_auth_token: "your-secure-token"
   ```

5. Deploy:
   ```bash
   ansible-playbook -i inventory/hosts.yml site.yml --ask-vault-pass
   ```

## Verification

Test cluster health:
```bash
# Check cluster status
nats-server --server-check <server-ip>:4222

# Monitor cluster
curl http://<server-ip>:8222/varz
```

## Configuration

Key configurations in `group_vars/all.yml`:

- `nats_version`: NATS server version
- `nats_cluster_name`: Cluster identifier
- `nats_*_port`: Various port configurations
- `nats_monitoring_enabled`: Enable/disable monitoring

## Security

- TLS enabled by default
- Token-based authentication
- Dedicated system user
- Restricted file permissions
- Monitoring interface protected

## Maintenance

### Updating NATS Version

1. Update `nats_version` in `group_vars/all.yml`
2. Run playbook:
   ```bash
   ansible-playbook -i inventory/hosts.yml site.yml --ask-vault-pass --tags update
   ```
2. Run playbook:
   ```bash
   ansible-playbook -i inventory/hosts.yml site.yml --ask-vault-pass --ask-become-pass -vv
   ```


### Logs

- Location: `/var/log/nats/nats-server.log`
- Rotation: Handled by logrotate

## Troubleshooting

1. Check service status:
   ```bash
   systemctl status nats
   ```

2. View logs:
   ```bash
   journalctl -u nats -f
   ```

3. Common issues:
   - Port conflicts: Check if ports 4222, 6222, 8222 are available
   - Certificate issues: Verify cert permissions and paths
   - Connection refused: Check firewall rules

## Support

For issues:
1. Check `journalctl -u nats`
2. Verify network connectivity
3. Ensure all certificates are valid
4. Check disk space and system resources

## License

MIT

## Contributing

1. Fork repository
2. Create feature branch
3. Submit pull request with tests