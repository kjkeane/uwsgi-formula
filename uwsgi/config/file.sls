# -*- coding: utf-8 -*-
# vim: ft=sls

{# Get the 'tplroot' from tpldir' #}
{% set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- from tplroot ~ "/map.jinja" import uwsgi with context %}
{%- from tplroot ~ "/macros.jinja" import files_switch with context %}

uwsgi-run-directory:
  file.directory:
    - name: /run/uwsgi
    - user: {{ uwsgi.user }}
    - group: {{ uwsgi.group }}
    - mode: 755
    - require:
      - sls: {{ sls_package_install }}

uwsgi-log-directory:
  file.directory:
    - name: /var/log/uwsgi
    - user: {{ uwsgi.user }}
    - group: {{ uwsgi.group }}
    - mode: 755
    - require:
      - sls: {{ sls_package_install }}

uwsgi-ini:
  file.managed:
    - name: /etc/uwsgi.ini
    - user: {{ uwsgi.user }}
    - group: {{ uwsgi.group }}
    - mode: 644
    - source: {{ files_switch(
                    salt['config.get'](
                        tplroot ~ ':tofs:files:uwsgi-config',
                        ['uwsgi.tmpl', 'uwsgi.jinja']
                    )
              ) }}
    - template: jinja
    - context:
        uwsgi: {{ uwsgi|json }}
    - require:
      - sls: {{ sls_package_install }}

{% if 'apps' in uwsgi %}
{% for app, app_items in uwsgi.apps.items() %}
uwsgi-{{ app }}-config:
  file.managed:
    - name: {{ uwsgi.includes_dir }}/{{ app }}.ini
    - mode: 644
    - user: {{ uwsgi.user }}
    - group: {{ uwsgi.group }}
    - source: {{ files_switch(
                    salt['config.get'](
                        tplroot ~ ':tofs:files:uwsgi-config',
                        ['uwsgi-app.tmpl', 'uwsgi-app.jinja']
                    )
              ) }}
    - template: jinja
    - context:
        app: {{ app|json }}
        app_items: {{ app_items|json }}
    - require:
      - sls: {{ sls_package_install }}
{% endfor %}
{% endif %}
