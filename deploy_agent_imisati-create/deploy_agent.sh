#!/bin/bash

deploy_app() {
    echo "Deploy feature selected"
}

run_app() {
    echo "Run feature selected"
}

archive_logs() {
    echo "Archive feature selected"
}

echo "===== Deployment Agent ====="
echo "1. Deploy Application"
echo "2. Run Application"
echo "3. Archive Logs"

read -p "Choose an option: " choice

case $choice in
    1) deploy_app ;;
    2) run_app ;;
    3) archive_logs ;;
    *) echo "Invalid option" ;;
esac

