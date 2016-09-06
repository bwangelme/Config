#!/bin/bash
#History:
#   Michael	Sep,06,2016
#Program:
#

REPO_DIR="/var/www/blog"
echo "build at $(date)"
git -C "${REPO_DIR}" pull origin master && echo "Build Successfully"
