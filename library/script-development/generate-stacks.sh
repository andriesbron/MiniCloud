#!/bin/bash
set -e

WORKING_DIR="$(pwd)"
VOLUMES_DIR="$WORKING_DIR/volumes"
TEMPLATES_DIR="library/stack-templates"
DEPLOY_DIR="stacks"
mkdir -p "$DEPLOY_DIR"
mkdir -p "$VOLUMES_DIR"

for STACK_PATH in "$TEMPLATES_DIR"/*; do
    STACK_NAME=$(basename "$STACK_PATH")
    template_file="$STACK_PATH/docker-compose.yml.template"
    target_file="$DEPLOY_DIR/$STACK_NAME/docker-compose.yml"

    mkdir -p "$DEPLOY_DIR/$STACK_NAME"

    if [ ! -f "$template_file" ]; then
        echo "❌ $template_file not found!"
        continue
    else
        # Escape WORKING_DIR for sed (handles slashes, spaces, &)
        escaped_dir=$(printf '%s\n' "$VOLUMES_DIR" | sed 's/[&/\]/\\&/g')

        sed "s|{\$VOLUMES_DIR}|$escaped_dir|g" "$template_file" > "$target_file"
        echo "✅ Processed $template_file → $target_file"
    fi
done

echo "🎉 All templates processed."
