# GoDaddy hook for `dehydrated`

This is a **`bash`-only** hook for the [Let's Encrypt](https://letsencrypt.org/) ACME client [dehydrated](https://github.com/dehydrated-io/dehydrated), using [GoDaddy](https://www.GoDaddy.com/)'s [APIs](https://developer.godaddy.com/) to automatically manage DNS records to respond to `dns-01` challenges.

## Requirements

  * command line utilities (both already required by `dehydrated`):
    - `bash` (>= v4.0 for pattern matching)
    - `curl`
  * GoDaddy API Key and Secret - see [Configuration](#Configuration) below.

## Installation

```bash
mkdir le
cd le
git clone https://github.com/dehydrated-io/dehydrated.git dehydrated
mkdir hooks
git clone https://github.com/eengstrom/letsencrypt-hook-dns-01-godaddy.git hooks/dns-01-godaddy
```

## Configuration

If you do not have an account-specific GoDaddy API Key and Secret, visit ["GoDaddy APIs - getting started"](https://developer.godaddy.com/getstarted) to obtain them.

The hook requires that they be in your environment.  You can manually set them via:
```bash
export GODADDY_KEY='example-key'
export GODADDY_SECRET='example-secret'
```

You may also put those lines into a `dehydrated` `config` file.

## Usage

```bash
dehydrated/dehydrated --cron -d foo.example.com -t dns-01 -k 'hooks/dns-01-godaddy/hook.sh'
```
# Alternatives

Although I prefer a `bash`-only version, there are other GoDaddy-compatible, `dehydrated` hooks:

* https://github.com/josteink/le-godaddy-dns - requires python and some python libraries

# Acknowledgements

With thanks to:
  * Lukas Schauer, the original author of `dehydrated`.
  * Yashar F. and the hints provided by his notional, bash-only [GoDaddy hook](https://github.com/walcony/letsencrypt-GoDaddy-hook).
