#!/bin/bash
echo "here i am"
echo $1 $2 $3 $4
cd /app/application/commands/ && /usr/bin/php console.php install $1 $2 $3 $4
