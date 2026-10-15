#!/bin/bash

names=("Your Name 1" "Your Name 2" "Your Name 3" "Your Name 4" "Your Name 5" "Your Name 6" "Your Name 7" "Your Name 8" "Your Name 9" "Your Name 10")
emails=("name1@example.com" "name2@example.com" "name3@example.com" "name4@example.com" "name5@example.com" "name6@example.com" "name7@example.com" "name8@example.com" "name9@example.com" "name10@example.com")

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

elif [ "$roster_option" = "2" ]; then
    read -r -p "How many students to generate (1-10)? " num_students
    if ! [[ "$num_students" =~ ^[0-9]+$ ]] || [ "$num_students" -lt 1 ] || [ "$num_students" -gt 10 ]; then
        echo "Error: enter a number from 1 to 10."
        return 1
    fi
    echo "Email,Names,Attendance Count,Absence Count" > "$PROJECT_DIR/Helpers/assets.csv"
    for ((i=0; i<num_students; i++)); do
        echo "${emails[$i]},${names[$i]},0,0" >> "$PROJECT_DIR/Helpers/assets.csv"
    done
    sed -i 's/"total_sessions": [0-9]*/"total_sessions": 1/' "$PROJECT_DIR/Helpers/config.json"
    echo "Roster generated."
fi

    chmod +x "$PROJECT_DIR/attendance_checker.py"
    chmod 600 "$PROJECT_DIR/Helpers/config.json"
    echo "Permissions set: attendance_checker.py is executable (+x), config.json is owner read/write only (600)"

    read -r -p "Update attendance alert thresholds? (y/n): " upd
    if [[ "$upd" =~ ^[Yy]$ ]]; then
        read -r -p "New warning threshold [75]: " warn
        warn=${warn:-75}
        read -r -p "New failure threshold [50]: " fail
        fail=${fail:-50}
        if ! [[ "$warn" =~ ^[0-9]+$ ]] || ! [[ "$fail" =~ ^[0-9]+$ ]] || [ "$warn" -gt 100 ] || [ "$fail" -ge "$warn" ]; then
            echo "Invalid input: use numbers, warning <= 100, failure lower than warning. Thresholds unchanged."
        else
            sed -i "s/\"warning\": [0-9]*/\"warning\": $warn/" "$PROJECT_DIR/Helpers/config.json"
            sed -i "s/\"failure\": [0-9]*/\"failure\": $fail/" "$PROJECT_DIR/Helpers/config.json"
            echo "Thresholds updated: warning=$warn, failure=$fail"
        fi
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
