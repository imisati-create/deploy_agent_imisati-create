#!/bin/bash

echo "===== Deployment Agent ====="
echo "1. Deploy Application"
echo "2. Run Application"
echo "3. Archive Logs"

read -p "Choose an option: " choice

case $choice in
    1) echo "Deploy selected" ;;
    2) echo "Run selected" ;;
    3) echo "Archive selected" ;;
    *) echo "Invalid option" ;;
esac
