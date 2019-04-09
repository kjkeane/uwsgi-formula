# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_file = tplroot ~ '.config.file' %}
{%- from tplroot ~ "/map.jinja" import uwsgi with context %}
{%- from tplroot ~ "/macros.jinja" import files_switch with context %}

include:
  - {{ sls_config_file }}

uwsgi-service-dead:
  service.dead:
    - name: {{ uwsgi.service.name }}
    - enable: False
    - require:
      - sls: {{ sls_config_file }}

uwsgi-app-socket-file:
  file.managed:
    - name: /etc/systemd/system/uwsgi-app@.socket
    - user: root
    - group: root
    - mode: 644
    - source: {{ files_switch(
                    salt['config.get'](
                      tplroot ~ ':tofs:files:uwsgi-config',
                      ['uwsgi-app-socket.tmpl', 'uwsgi-app-socket.jinja']
                    )
              ) }}
    - template: jinja

uwsgi-app-service-file:
  file.managed:
    - name: /etc/systemd/system/uwsgi-app@.service
    - user: root
    - group: root
    - mode: 644
    - source: {{ files_switch(
                    salt['config.get'](
                      tplroot ~ ':tofs:files:uwsgi-config',
                      ['uwsgi-app-systemd.tmpl', 'uwsgi-app-systemd.jinja']
                    )
              ) }}
    - template: jinja
    - context:
        uwsgi: {{ uwsgi }}

uwsgi-systemd-daemon-reload:
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: uwsgi-app-socket-file
      - file: uwsgi-app-service-file

{% for app in uwsgi.apps %}
uwsgi-socket-{{ app }}-running:
  service.running:
    - name: uwsgi-app@{{ app }}.socket
    - enable: True
    - require:
      - sls: {{ sls_config_file }}
      - file: uwsgi-app-socket-file

uwsgi-service-{{ app }}-running:
  service.running:
    - name: uwsgi-app@{{ app }}.service
    - enable: True
    - reload: True
    - require:
      - sls: {{ sls_config_file }}
      - file: uwsgi-app-service-file
      - service: uwsgi-socket-{{ app }}-running
    - watch:
      - sls: {{ sls_config_file }}
{% endfor %}
