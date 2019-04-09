# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import uwsgi with context %}

uwsgi-package-install-pip-installed:
  pkg.installed:
    - pkgs: 
      - uwsgi
      - uwsgi-logger-file
      - uwsgi-logger-syslog
      - uwsgi-logger-rsyslog
      - uwsgi-plugin-python36
      - uwsgi-plugin-python2
