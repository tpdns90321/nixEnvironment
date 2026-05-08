{pkgs}: ''{
  "enabled": true,
  "network": {
    "allowLocalBinding": true,
    "allowAllUnixSockets": true,
    "allowedDomains": ["github.com", "*.github.com", "raw.githubusercontent.com", "npmjs.com", "npmjs.org", "*.npmjs.org", "*.npmjs.com", "pypi.org", "*.pypi.org", "nixos.org", "*.nixos.org"],
    "deniedDomains": []
  },
  "filesystem": {
    "denyRead": ["/Users", "/home", ".env", ".env.*"],
    "allowRead": [".", "~/.pi", "~/.codex", "~/.config", "/tmp", "/private/tmp", "${pkgs.pi-coding-agent}"],
    "allowWrite": [".", "/tmp", "/private/tmp"],
    "denyWrite": [".env", ".env.*"]
  }
}''

