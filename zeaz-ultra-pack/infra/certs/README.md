Place TLS certs in this directory:

- `fullchain.pem`
- `privkey.pem`

Example self-signed cert for wildcard + cme:

```bash
openssl req -x509 -nodes -newkey rsa:2048 \
  -keyout privkey.pem \
  -out fullchain.pem \
  -days 365 \
  -subj "/CN=*.zeaz.dev" \
  -addext "subjectAltName=DNS:*.zeaz.dev,DNS:cme.zeaz.dev"
```
