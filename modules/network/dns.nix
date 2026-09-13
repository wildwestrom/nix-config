# Encrypted DNS via dnscrypt-proxy on localhost. NetworkManager still hands out
# the resolver, so this only takes effect for whatever points at 127.0.0.1.
{
  flake.modules.nixos.dns = {
    services.dnscrypt-proxy = {
      enable = true;
      settings = {
        ipv6_servers = true;
        # require_dnssec = true;
        require_dnssec = false; # temporary testing
        sources.public-resolvers = {
          urls = [
            "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
            "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
          ];
          cache_file = "/var/lib/dnscrypt-proxy/public-resolvers.md";
          minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
        };
        server_names = [
          "quad9"
          "cloudflare"
          "nextdns"
          "mullvad-doh"
        ];
        listen_addresses = [
          "127.0.0.1:53"
          "[::1]:53"
        ];
        odoh_servers = true;
        timeout = 10000;
        lb_strategy = "p2";
        cache = true;
        cache_size = 4092;
        log_file = "/tmp/dnscrypt-proxy.log";
        use_syslog = false; # will make syslog messy otherwise
      };
    };
  };
}
