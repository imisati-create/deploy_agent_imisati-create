#!/bin/bash

deploy_app() {
    trap cleanup_on_interrupt SIGINT SIGTSTP

    echo "Checking requirements..."

    if ! command -v python3 >/dev/null 2>&1; then
        echo "Error: python3 is not installed."
        exit 1
    fi

    if ! command -v zip >/dev/null 2>&1; then
        echo "Error: zip is not installed."
        exit 1
    fi

    echo "Requirements verified."



read -p "Enter project name: " project_name

PROJECT_DIR="attendance_tracker_${project_name}"

if [ -d "$PROJECT_DIR" ]; then
    read -p "Directory already exists. Overwrite? (y/n): " answer

    if [ "$answer" = "y" ]; then
        rm -rf "$PROJECT_DIR"
    else
        echo "Deployment cancelled."
        exit 1
    fi
fi
mkdir -p "$PROJECT_DIR"
mkdir -p "$PROJECT_DIR/Helpers"
mkdir -p "$PROJECT_DIR/reports"
mkdir -p "$PROJECT_DIR/archives"

echo "Project structure created."
cp templates/attendance_checker.py "$PROJECT_DIR"

cp templates/config.json \
"$PROJECT_DIR/Helpers/config.json"

echo "Template files copied."
echo "Choose roster option"
echo "1. Copy Template Roster"
echo "2. Generate New Roster"
read -p "Select option: " roster_option

if [ "$roster_option" = "1" ]; then

    read -p "How many students to copy? " num_students

    head -n $((num_students + 1)) \
    templates/assets.csv \
    > "$PROJECT_DIR/Helpers/assets.csv"

    echo "Roster copied."

fi
}

cleanup_on_interrupt() {
    echo ""
    echo "Deployment interrupted! Archiving what was created so far..."
    if [ -n "$PROJECT_DIR" ] && [ -d "$PROJECT_DIR" ]; then
        zip -rq "${PROJECT_DIR}_archive.zip" "$PROJECT_DIR"
        rm -rf "$PROJECT_DIR"
        echo "Archive saved as ${PROJECT_DIR}_archive.zip"
    fi
    exit 1
}

run_app() {
    echo "Run feature selected"
}
archive_logs() {
    echo "Archive feature selected"
}

while true; do
echo "===== Deployment Agent ====="
echo "1. Deploy Application"
echo "2. Run Application"
echo "3. Archive Logs"
echo "4. Exit"
read -p "Choose an option: " choice

case $choice in
    1) deploy_app ;;
    2) run_app ;;
    3) archive_logs ;;
    4) exit 0 ;;
    *) echo "Invalid option" ;;


esac
done
