1. `echo "=== Phase 3: Complete Package Removal ===" && echo "Identifying Docker packages:" && ssh prtr "dpkg -l | grep -i docker | awk '{print \$2}'" && echo "=== Removing Docker packages ===" && ssh prtr "sudo apt remove --purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin && sudo apt autoremove -y"`

2. `echo "=== Removing actual Docker packages ===" && ssh prtr "sudo apt remove --purge -y docker-buildx docker-cli docker-compose docker-desktop docker.io && sudo apt autoremove -y"`

3. `echo "=== Identifying NVIDIA packages ===" && ssh prtr "dpkg -l | grep -i nvidia | awk '{print \$2}'" && echo "=== Removing NVIDIA packages ===" && ssh prtr "sudo apt remove --purge -y \$(dpkg -l | grep -i nvidia | awk '{print \$2}') && sudo apt autoremove -y"`

4. `echo "=== System Configuration Cleanup ===" && ssh prtr "sudo rm -rf /etc/docker /var/lib/docker ~/.docker /etc/nvidia /usr/local/cuda* /opt/nvidia* && echo 'Configuration directories cleaned' && sudo apt clean && sudo apt autoclean && echo 'Package cache cleaned'"`

5. `ssh prtr "sudo rm -rf /etc/docker /var/lib/docker ~/.docker /etc/nvidia && find /usr/local -name 'cuda*' -type d 2>/dev/null | xargs sudo rm -rf && find /opt -name 'nvidia*' -type d 2>/dev/null | xargs sudo rm -rf && echo 'Configuration directories cleaned' && sudo apt clean && sudo apt autoclean && echo 'Package cache cleaned'"`

6. `echo "=== Final Verification ===" && ssh prtr "echo 'Checking for remaining packages:' && dpkg -l | grep -E '(docker|nvidia)' || echo 'No Docker/NVIDIA packages found' && echo 'Checking for running processes:' && ps aux | grep -E '(docker|nvidia)' | grep -v grep || echo 'No Docker/NVIDIA processes found' && echo 'System ready for reboot'"`

7. `echo "=== Initiating System Reboot ===" && echo "NVIDIA kernel threads detected - reboot required for complete cleanup" && ssh prtr "echo 'Rebooting prtr for complete cleanup...' && sudo reboot" && echo "=== prtr reboot initiated ==="`

8. `echo "=== Waiting for prtr to reboot ===" && sleep 30 && echo "=== Testing prtr connectivity ===" && ssh prtr "hostname && echo 'prtr is back online' && echo 'Verifying clean state:' && dpkg -l | grep -E '(docker|nvidia)' || echo 'SUCCESS: No Docker/NVIDIA packages found' && ps aux | grep -E '(docker|nvidia)' | grep -v grep || echo 'SUCCESS: No Docker/NVIDIA processes found'"`

9. `ssh prtr "echo '=== All Containers (including stopped) ===' && docker ps -a --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}' 2>/dev/null && echo '=== Docker Images ===' && docker images --format 'table {{.Repository}}\t{{.Tag}}\t{{.Size}}' 2>/dev/null"`

10. `BACKUP_DIR="containerization/archon-backup/20250917-185528" && echo "Working in: $BACKUP_DIR" && echo "=== Exporting Archon Container Images from prtr ===" && ssh prtr "docker save -o /tmp/archon-images.tar archon-frontend:latest archon-archon-mcp:latest archon-archon-server:latest archon-archon-agents:latest pgvector/pgvector:pg16 postgrest/postgrest:v12.2.0 adminer:4.8.1 && ls -lh /tmp/archon-images.tar"`

11. `echo "=== Copying Archon Images to Backup Directory ===" && scp prtr:/tmp/archon-images.tar containerization/archon-backup/20250917-185528/ && echo "=== Preserving Systemd Service Configuration ===" && ssh prtr "systemctl cat archon.service > /tmp/archon.service.backup && systemctl cat ollama.service > /tmp/ollama.service.backup" && scp prtr:/tmp/archon.service.backup prtr:/tmp/ollama.service.backup .archive/stage1-prtr-preservation/20250917-185528/`

12. `echo "=== Documenting Current System State ===" && ssh prtr "docker info > /tmp/docker-info.txt && docker version > /tmp/docker-version.txt && nvidia-smi > /tmp/nvidia-status.txt 2>/dev/null || echo 'NVIDIA status captured' > /tmp/nvidia-status.txt && systemctl list-units --type=service | grep -E '(docker|nvidia|archon|ollama)' > /tmp/services-status.txt" && scp prtr:/tmp/{docker-info.txt,docker-version.txt,nvidia-status.txt,services-status.txt} .archive/stage1-prtr-preservation/20250917-185528/`

13. `echo "=== Phase 2: Graceful Service Shutdown on prtr ===" && echo "Current service status:" && ssh prtr "systemctl is-active archon.service ollama.service docker.service docker.socket" && echo "=== Stopping services in correct order ===" && ssh prtr "sudo systemctl stop archon.service && echo 'archon.service stopped' && sudo systemctl stop ollama.service && echo 'ollama.service stopped' && sudo systemctl stop docker.service docker.socket && echo 'Docker services stopped'"`
