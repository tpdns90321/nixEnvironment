{pkgs}: ''{
  "enabled": true,
  "network": {
    "allowLocalBinding": true,
    "allowAllUnixSockets": true,
    "allowedDomains": ["github.com", "*.github.com", "raw.githubusercontent.com", "npmjs.com", "npmjs.org", "*.npmjs.org", "*.npmjs.com", "pypi.org", "*.pypi.org", "nixos.org", "*.nixos.org", "openai.com", "*.openai.com", "chatgpt.com", "*.chatgpt.com"],
    "deniedDomains": []
  },
  "filesystem": {
    "denyRead": [".env", ".env.*"],
    "allowRead": [".", "~/.pi", "~/.codex", "~/.config", "/tmp", "/private/tmp", "${pkgs.pi-coding-agent}"],
    "allowWrite": [".", "/tmp", "/private/tmp"],
    "denyWrite": [".env.*"]
  }
}''

