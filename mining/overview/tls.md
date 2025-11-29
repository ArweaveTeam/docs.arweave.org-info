# Operating a node with TLS enabled

Using TLS/HTTPS protocol is not necessary to have when operating a node, in fact most nodes don't use it.
If you are considering to enable TLS support for your node you are most likely concerned with end-to-end encryption of HTTP requests. This makes sense if your node is publicly accessible and you are expecting to communicate with it using private secrets (example: you have metrics enabled for mining statistics protected by an Authentication).

This article handles the limited (but usable) support that arweaev has for TLS via the erlang library cowboy. But we do encourage node operators to consider more stable approaches, like nginx proxy with certbot, or cloud provided solutions like AWS's ELB load-balancer or Cloudfront. Operating TLS certificates on top of the Erlang runtime, is rather "bare-metal" and can be difficult, but if that's the only solution for your infrastructure, then read on.

## Generating TLS certificates using certbot

Using the certbot command line tool to generate certificates is a nice free way to get browser compatible certificates. Self-signed TLS certificates via `openssl` or `mkcert` are also viable options.

Seen in the screenshot below, it's not necessary to use nginx as certbot can start a python http server to perform the verification procedure. But whatever works for you, please use.

 <img src="../.gitbook/assets/certbot_example.png" alt="Certbot certificates example" />

The cerbot on ubuntu systems (your operating system may vary) will generate a folder with pem file extensions in `/etc/letsencrypt/live/{your-domain-name}/`, two files will be important for us, `cert.pem` and `privkey.pem`.

By default these files are going to be symlinks to files stored under `/etc/letsencrypt/archive/...` it's important to be aware of, that the user that is going to run arweave is allowed read-access to these files. If you run arweave under root user (not-recommended!) then this isn't going to be a problem, otherwise you must perform the appropriate chmod operations on these symlink files as well as their target files to allow your current user to read these files and use them. Erlang doesn't provide good enough error messages if this isn't the case.

## Starting arweave with TLS certs

Here's an example of starting arweave with tls support.

```sh
./bin/start port 8443 tls_key_file /etc/letsencrypt/live/{your-domain-name}/privkey.pem tls_cert_file /etc/letsencrypt/live/{your-domain-name}/cert.pem # rest of your arweave cli arguments
```

the key here is to pass the arg tls_key_file with the value of the filepath to privkey.pem as well as passing tls_cert_file to the path of cert.pem.
