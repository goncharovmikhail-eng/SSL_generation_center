# Unified Center for Generating Test SSL Certificates

This center provides:

- Isolation: Mkcert runs inside a Docker container.

- Compact and Convenient Certificate Storage: The root certificate is only generated if not found in the target directory.

- Automation: Minimizes manual steps.

- Automatic image build: If the Docker image is not found, it will be built automatically.

- Automatically generates a certificate chain, changes file extensions, sets permissions to 777 for integration with Ansible.

- Domain Name Standardization: By default, domains follow the [lastname].stage pattern.

- Git-Friendly Storage: Designed to be stored in Git, since test stand certificate keys are assumed to be compromise-tolerant.

# Requirements
- Docker
- Bash (to run gen_cert.sh)

# Installation
```bash
git clone git@github.com:goncharovmikhail-eng/CA.git
cd cert-generation```

# Synopsis
```bash
./gen_cert.sh [LastName] [--name domain] [--path cert_output_path] [--ip ip_address]```

- LastName — If --name is not specified, the domain will be auto-generated as [lastname].stage.
- --name — Explicitly set the domain name.
- --path — Path to save certificates (default: certs/).
- --ip — Add an IP address to the certificate (can be used multiple times). Note: 127.0.0.1 and localhost are included by default.
- --help — Show this help message.
