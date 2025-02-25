#!/bin/bash
cd /home/ec2-user/app
npm install
pm2 stop all || true
/usr/bin/pm2 start server.js
