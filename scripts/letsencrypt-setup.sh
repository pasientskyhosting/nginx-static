#!/bin/bash

# Lets Encrypt
/opt/letsencrypt/letsencrypt-auto certonly -a webroot --webroot-path=$WEBROOT -d example.com -d www.example.com
