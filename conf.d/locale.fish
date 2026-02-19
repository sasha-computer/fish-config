# Prevent locale warnings when SSHing into NAS via tailscale ssh
set -gx LC_ALL en_US.UTF-8
set -gx LANG en_US.UTF-8
