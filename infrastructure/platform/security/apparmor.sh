#!/bin/bash

systemctl enable apparmor
systemctl start apparmor

aa-enforce /etc/apparmor.d/*
