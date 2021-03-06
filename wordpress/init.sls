{% from "wordpress/map.jinja" import map with context %}

include:
  - wordpress.cli

{% for id, site in salt['pillar.get']('wordpress:sites', {}).items() %}
{{ map.docroot }}/{{ id }}/web:
  file.directory:
    - user: {{ map.www_user }}
    - group: {{ map.www_group }}
    - mode: 755
    - makedirs: True

# This command tells wp-cli to download wordpress
download_wordpress_{{ id }}:
 cmd.run:
  - cwd: {{ map.docroot }}/{{ id }}/web
  - name: '/usr/local/bin/wp core download --path="{{ map.docroot }}/{{ id }}/web/"'
  - runas: {{ map.www_user }}
  - unless: test -f {{ map.docroot }}/{{ id }}/web/wp-config.php

# This command tells wp-cli to create our wp-config.php, DB info needs to be the same as above
configure_{{ id }}:
 cmd.run:
  - name: '/usr/local/bin/wp core config --dbname="{{ site.get('database') }}" --dbuser="{{ site.get('dbuser') }}" --dbpass="{{ site.get('dbpass') }}" --dbhost="{{ site.get('dbhost') }}" --path="{{ map.docroot }}/{{ id }}/web"'
  - cwd: {{ map.docroot }}/{{ id }}/web
  - runas: {{ map.www_user }}
  - unless: test -f {{ map.docroot }}/{{ id }}/web/wp-config.php  

# This command tells wp-cli to install wordpress
install_{{ id }}:
 cmd.run:
  - cwd: {{ map.docroot }}/{{ id }}/web
  - name: '/usr/local/bin/wp core install --url="{{ site.get('url') }}" --title="{{ site.get('title') }}" --admin_user="{{ site.get('username') }}" --admin_password="{{ site.get('password') }}" --admin_email="{{ site.get('email') }}" --path="{{ map.docroot }}/{{ id }}/web/"'
  - runas: {{ map.www_user }}
  - unless: /usr/local/bin/wp core is-installed --path="{{ map.docroot }}/{{ id }}/web"
{% endfor %}
