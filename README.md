
# Video Chat A Pro



### Local Project Setup



Create an `config/application.yml` by using the template:



```

cp config/application{.example,}.yml

```


Create Database based on the SQL structure
```

rake db:setup

```
Run migrations
```

rake db:migrate

```
Seed initial data
```

rake db:seed

```
Run Server
```

rails s

```






### Testing



Run the tests:



```

rake

```



### Populate Staging



Capture a backup:



```

mina pg:backup to=production

scp production:db/backups/production.dump .

```



Then sanitize it locally:



```

createdb prod_sanitizer

pg_restore --verbose --clean --no-acl --no-owner -d prod_sanitizer production.dump

psql -d prod_sanitizer < lib/tasks/scrub_production.sql

pg_dump -Fc --no-acl --no-owner prod_sanitizer > sanitized.dump

```



Then restore the sanitized dump into staging:



```

pg_restore --verbose --clean --no-acl --no-owner -d videochatapro_development sanitized.dump

```



### Server Setup

Setup DO from scratch

There is an ansible folder to stand up bare DO machines from scratch.



```

# setup staging server

cd ansible

ansible-playbook main.yml



# setup production server

cd ansible

ansible-playbook -i inventories/production main.yml

```


### Deploying to server

Apps are hosted on DigitalOcean


1. First do not forget add SSH

https://cloud.digitalocean.com/account/security?i=0eda7f

2. Add your IP address to whitelisted on the DO firewall to "ruby-server"

https://cloud.digitalocean.com/networking/firewalls/1fc08cc9-e00d-46fd-bb86-c099d40e1b3c/rules?i=0eda7f


3. Add your public ssh key on the droplets

Open droplet console and add ssh key

https://cloud.digitalocean.com/droplets?i=0eda7f



After that you can deploy.

```

mina deploy to=staging

```



```

mina deploy to=production

```





### DigilatOcean Console

Production Droplet
```
ssh videochatapro@138.68.253.118
```

Staging Droplet
```
 ssh videochatapro@142.93.83.197
```

You need to have pass for staging and production console. You can generated it from DO admin panel. Also you should update pass for "videochatapro" user. 


### Sitemap XML refresh

Open console and go to current and run command

```
videochatapro@videochatapro:~/videochatapro$ cd current
videochatapro@videochatapro:~/videochatapro/current$

bundle exec rake sitemap:refresh

```

### Site Admin

https://staging.videochatapro.com/
login: admin
pass: 123


