#!/bin/bash
cd /home/ec2-user/app
npm install
pm2 stop all || true
pm2 start server.js