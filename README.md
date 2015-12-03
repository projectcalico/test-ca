# Test Certificate Authority

This repo implements a Certificate Authority for issuing test certificates 
suitable for use with etcd.

*WARNING* this is not for production use!  It does not look after the keys,
the parameters haven't been tuned or audited and it uses hard-coded passwords.

It depends on having openssl installed.

## Usage

To initialise the CA for the first time:
```
$ make ca-cert
```
The CA certificate is stored in ./ca/cacert.pem

To issue a certificate for IP address 1.2.3.4
```
$ make cert-1.2.3.4

...

Certificate in ./ca/certs/1.2.3.4.pem
Private key in ./ca/private/1.2.3.4.pem
```
