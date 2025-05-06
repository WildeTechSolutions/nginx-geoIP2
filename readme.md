## Summary

This project will run nginx and certbot in a docker stack.  Change `example.env` to a `.env` file, set the email for certbot and what domains you want to include in the certificates.

Instructions are below for creating a service and timer to both renew SSL/TLS certbot certs and hot reload nginx.  

## Create a Service and Timer

### Certbot renew

Create the certbot renew service

```bash
sudo nano /etc/systemd/system/nginx-certbot-renew.service
```

```properties
[Unit]
Description=Renews ssl certs
[Service]
ExecStart=/usr/bin/docker exec certbot certbot renew --non-interactive --dns-cloudflare --dns-cloudflare-credentials /etc/letsencrypt/cloudflare.ini
```


Create the certbot renew timer

```bash
sudo nano /etc/systemd/system/nginx-certbot-renew.timer
```

```properties
[Unit]
Description=Renews ssl certs
[Timer]
OnCalendar=*-*-* 01:00:00
[Install]
WantedBy=timers.target
```

### Nginx hot reload

Create the reload service 

```bash
sudo nano /etc/systemd/system/nginx-reload.service
```

```properties title="nginx-reload.service"
[Unit]
Description=Hot reload of nginx to get new certs, etc.
[Service]
ExecStart=/usr/bin/docker exec nginx nginx -s reload
```

Create the reload timer
```bash
sudo nano /etc/systemd/system/nginx-reload.timer
```

```properties title="nginx-reload.timer"                                                                  
[Unit]
Description=Hot reload of nginx to get new certs, etc.
[Timer]
OnCalendar=*-*-* 02:00:00
[Install]
WantedBy=timers.target
```

### Enable the timers

Reload the systemd manager configuration

```bash
sudo systemctl daemon-reload
```

Enable the Service (optional: may want to enable it if you want to run the service manually)

```bash
sudo systemctl enable nginx-certbot-renew.service
```

```bash
sudo systemctl enable nginx-reload.service
```

Enable the Timer

```bash
sudo systemctl enable nginx-certbot-renew.timer
```

```bash
sudo systemctl enable nginx-reload.timer
```

Start the timer

```bash
sudo systemctl start nginx-certbot-renew.timer
```

```bash
sudo systemctl start nginx-reload.timer
```

Check the status of the timer

```bash
sudo systemctl status nginx-certbot-renew.timer
```

```bash
sudo systemctl status nginx-reload.timer
```

## Common Commands

Hot reload nginx after changes to configuration

```bash
/usr/bin/docker exec -it nginx nginx -s reload
```

To tail the logs:

```bash
tail -10 /home/thomas/docker/nginx/data/nginx/logs/access.log
```

Manually renew certs

```bash
/usr/bin/docker exec certbot certbot renew --non-interactive --dns-cloudflare --dns-cloudflare-credentials /etc/letsencrypt/cloudflare.ini;
```