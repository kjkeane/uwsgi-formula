# -*- coding: utf-8 -*-
# vim: ft=sls

{# Get the 'tplroot' from tpldir' #}
{% set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- from tplroot ~ "/map.jinja" import uwsgi with context %}
{%- from tplroot ~ "/macros.jinja" import files_switch with context %}

uwsgi-run-directory-absent:
  file.absent:
    - name: /run/uwsgi

uwsgi-log-directory-absent:
  file.absent:
    - name: /var/log/uwsgi

uwsgi-ini-absent:
  file.absent:
    - name: /etc/uwsgi.ini

{% if 'apps' in uwsgi %}
{% for app, app_items in uwsgi.apps.items() %}
uwsgi-{{ app }}-config-absent:
  file.absent:
    - name: {{ uwsgi.includes_dir }}/{{ app }}.ini
{% endfor %}
{% endif %}
