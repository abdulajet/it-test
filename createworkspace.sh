#!/bin/bash

# Check if the URL argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <URL>"
    exit 1
fi

URL=$1
CONFIG_FILE="tutorial-config.json"

# Read JSON configuration
FILES=$(jq -r '.files[]' "$CONFIG_FILE")
PANELS=$(jq -r '.panels[]' "$CONFIG_FILE")
OPEN_FILE=$(jq -r '.openFile' "$CONFIG_FILE")

# Create files from the "files" array
for FILE in $FILES; do
    if [ ! -f "$FILE" ]; then
        touch "$FILE"
        echo "Created file: $FILE"
    else
        echo "File already exists: $FILE"
    fi
done

# Determine dependencies based on panels
TASK_DEPENDENCIES=("ExportEnv" "CleanUp")
if echo "$PANELS" | grep -q "browser"; then
    TASK_DEPENDENCIES+=("OpenBrowser")
fi
if echo "$PANELS" | grep -q "terminal"; then
    TASK_DEPENDENCIES+=("OpenTerminal")
fi

# Generate the "dependsOn" array
DEPENDS_ON=$(printf '"%s",' "${TASK_DEPENDENCIES[@]}")
DEPENDS_ON="[${DEPENDS_ON%,}]"

# Update tasks.json using a temporary file
TASKS_FILE=".vscode/tasks.json"
if [ -f "$TASKS_FILE" ]; then
    TEMP_FILE=$(mktemp)
    sed "s|<TASKS>|$DEPENDS_ON|" "$TASKS_FILE" > "$TEMP_FILE" && mv "$TEMP_FILE" "$TASKS_FILE"
    echo "Updated $TASKS_FILE with dependencies: $DEPENDS_ON"
else
    echo "$TASKS_FILE not found."
fi

# Update settings.json using a temporary file
SETTINGS_FILE=".vscode/settings.json"
if [ -f "$SETTINGS_FILE" ]; then
    TEMP_FILE=$(mktemp)
    sed "s|\"vs-browser.url\": \".*\"|\"vs-browser.url\": \"$URL\"|" "$SETTINGS_FILE" > "$TEMP_FILE" && mv "$TEMP_FILE" "$SETTINGS_FILE"
    echo "Updated $SETTINGS_FILE with URL: $URL"
else
    echo "$SETTINGS_FILE not found."
fi

# Update ofos.json using a temporary file
OFOS_FILE=".vscode/ofos.json"
if [ -f "$OFOS_FILE" ]; then
    TEMP_FILE=$(mktemp)
    sed "s|<FILE>|$OPEN_FILE|" "$OFOS_FILE" > "$TEMP_FILE" && mv "$TEMP_FILE" "$OFOS_FILE"
    echo "Updated $OFOS_FILE with openFile: $OPEN_FILE"
else
    echo "$OFOS_FILE not found."
fi