#!/bin/bash
set -euo pipefail

# Preserve Docker's internal DNS NAT rules before flushing
DOCKER_DNS_RULES=$(iptables-save -t nat | grep "127.0.0.11" || true)

iptables -F
iptables -X
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# Loopback + established connections
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# DNS
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT

# Restore Docker's DNS NAT rules
if [ -n "$DOCKER_DNS_RULES" ]; then
  echo "$DOCKER_DNS_RULES" | iptables-restore -t nat --noflush
fi

ipset create allowed-domains hash:ip 2>/dev/null || ipset flush allowed-domains

whitelist() {
  local domain=$1
  local ips
  ips=$(dig +short "$domain" A | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' || true)
  if [ -z "$ips" ]; then
    echo "WARN: no A record for $domain, skipping" >&2
  fi
  for ip in $ips; do
    ipset add allowed-domains "$ip" 2>/dev/null || true
  done
}

whitelist "google.com"

iptables -A OUTPUT -m set --match-set allowed-domains dst -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -m set --match-set allowed-domains dst -j ACCEPT

iptables -A OUTPUT -j REJECT --reject-with icmp-admin-prohibited

# Sanity check
echo "Testing firewall..."
if curl -s --max-time 3 https://example.com >/dev/null 2>&1; then
  echo "FAIL: example.com reachable, firewall not working"
  exit 1
fi
if ! curl -s --max-time 5 https://api.anthropic.com >/dev/null 2>&1; then
  echo "WARN: api.anthropic.com not reachable, check whitelist"
fi
echo "Firewall active."
