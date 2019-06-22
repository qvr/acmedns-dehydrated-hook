# acmedns-hook

[Dehydrated](https://github.com/lukas2511/dehydrated) hook for [acme-dns](https://github.com/joohoi/acme-dns).

# Usage
## Configuration
Add the hook settings to Dehydrated's `config`:
```sh
ACMEDNS_UPDATE_URL="https://auth.acme-dns.io/update"
ACMEDNS_CONFIG="/etc/dehydrated/config.acmedns"
```

Add acme-dns's domain specific account info to `config.acmedns` (`ACMEDNS_CONFIG` above):
```sh
ACMEDNS_USERNAME["example.com"]="username"
ACMEDNS_PASSWORD["example.com"]="password"
ACMEDNS_SUBDOMAIN["example.com"]="subdomain"

ACMEDNS_USERNAME["second.example.com"]="username2"
ACMEDNS_PASSWORD["second.example.com"]="password2"
ACMEDNS_SUBDOMAIN["second.example.com"]="subdomain2"
```
You need to register these manually by calling the acme-dns `/register` endpoint.

(There's also the option of using `ACMEDNS_*_DEFAULT` settings in main dehydrated `config` file
if you want to use a single account for all your domains.)

Finally, configure the DNS hook by adding the following to your Dehydrated config:

```sh
CHALLENGETYPE="dns-01"
HOOK="./acmedns-hook.sh"
```
