# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_file = tplroot ~ '.config.file' %}
{%- from tplroot ~ "/map.jinja" import uwsgi with context %}
{%- from tplroot ~ "/macros.jinja" import files_switch with context %}

uwsgi-app-socket-file-absent:
  file.absent:
    - name: /etc/systemd/system/uwsgi-app@.socket

uwsgi-app-service-file-absent:
  file.absent:
    - name: /etc/systemd/system/uwsgi-app@.service

uwsgi-systemd-daemon-reload:
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: uwsgi-app-socket-file
      - file: uwsgi-app-service-file

{% for app in uwsgi.apps %}
uwsgi-socket-{{ app }}-stopped:
  service.dead:
    - name: uwsgi-app@{{ app }}.socket

uwsgi-service-{{ app }}-stopped:
  service.dead:
    - name: uwsgi-app@{{ app }}.service
{% endfor %}
