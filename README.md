message2
========

[![Build Status](https://travis-ci.org/qnn/message2.png?branch=master)](https://travis-ci.org/qnn/message2)

Message system in Rails.

Features:

* Any one can create a message.
* Admin can create new admin, moderator or user.
* Admins have all privileges, moderators can make message visible only to some users while users are only accessible to list and details page of messages.
* 2-second rate limit on POST/PUT/DELETE action.
* You can switch languages between English and Simplified Chinese.

Please note that this repository is not being actively maintained.

![message2](https://f.cloud.github.com/assets/1284703/2059858/726c56e4-8bde-11e3-8b46-9d614259b21c.png)

How to use
----------

Nginx configuration:

    upstream app_server {
        server unix:/tmp/unicorn.sock fail_timeout=0;
    }
    server {
        client_max_body_size 1m;
        server_name <YOUR_SERVER_NAME>;
        keepalive_timeout 5;
        root /srv/qnn/message2/public;
        try_files $uri/index.html $uri.html $uri @app;
        location @app {
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Host $http_host;
            proxy_redirect off;
            proxy_pass http://app_server;
        }
        error_page 500 502 503 504 /500.html;
        location = /500.html {
            root /srv/qnn/message2/public;
        }
    }

Deploy:

    cd /srv/qnn
    git clone https://github.com/qnn/message2.git
    cd message2
    export RAILS_ENV=production
    bundle
    bundle exec rake db:migrate
    bundle exec rake db:seed
    bundle exec rake assets:precompile
    start_unicorn

Reference: [Running Multiple Rails Apps on Nginx](https://github.com/Hack56/Rails-Template/wiki/Running-Multiple-Rails-Apps-on-Nginx)

Developer
---------

* caiguanhao
