#!/bin/bash

# Improved Bash Script to Combine Text Files into a Markdown for LLM Analysis with Directory Exclusion Support

# Check if the correct number of arguments are provided
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <root_directory> <output_file> [excluded_dirs...]"
    echo "Example: $0 ./project output.md ./project/node_modules ./project/venv"
    exit 1
fi

root_dir="$1"        # Root directory passed as the first argument
output_file="$2"     # Output file passed as the second argument
shift 2              # Shift the positional arguments to handle the excluded directories

excluded_dirs=("$@") # Collect all the excluded directories

# Check if the root directory exists
if [ ! -d "$root_dir" ]; then
    echo "Error: Directory '$root_dir' does not exist."
    exit 1
fi

# Check if the output file is writable (or can be created)
if ! touch "$output_file" 2>/dev/null; then
    echo "Error: Cannot write to output file '$output_file'."
    exit 1
fi

# Create output file
touch "$output_file"

# Define supported source code file extensions with their corresponding language tags
declare -A file_extensions=(
    ["*.py"]="python"
    ["*.js"]="javascript"
    ["*.java"]="java"
    ["*.cpp"]="cpp"
    ["*.html"]="html"
    ["*.css"]="css"
    ["*.sh"]="bash"
    ["*.dart"]="dart"
    ["*.md"]="markdown"  # Markdown files
    ["*.json"]="json"    # JSON files
    ["*.yaml"]="yaml"    # YAML files
    ["*.txt"]=""         # Plain text files
)

# Construct the exclusion arguments for the find command
exclude_args=()
for dir in "${excluded_dirs[@]}"; do
    exclude_args+=("-not" "-path" "$dir/*")
done

# Function to recursively find and combine text files
combine_text_files() {
    local current_dir="$1"
    
    # Loop through each file extension in the dictionary
    for ext in "${!file_extensions[@]}"; do
        find "$current_dir" -type f -name "$ext" "${exclude_args[@]}" 2>/dev/null | while read -r file; do
            # Check if the file exists (in case of race conditions or permission issues)
            if [ ! -f "$file" ]; then
                echo "Warning: Skipping '$file', file does not exist."
                continue
            fi

            # Include the full path (root_dir + relative path)
            full_path="$file"

            # Get the corresponding language for syntax highlighting
            lang="${file_extensions[$ext]}"

            # Append the file path as plain text (no blank line after)
            echo "$full_path" >> "$output_file"

            # Append the text or source code with proper formatting for markdown
            if [ -n "$lang" ]; then
                echo "\`\`\`$lang" >> "$output_file"  # Start code block with language
            else
                echo "\`\`\`" >> "$output_file"  # Start plain text block
            fi
            
            cat "$file" >> "$output_file"
            echo "\`\`\`" >> "$output_file"  # End code block

            # Add a blank line after each file to separate them
            echo "" >> "$output_file"
        done
    done
}

# Call the function to combine text files
combine_text_files "$root_dir"

echo "Combined text markdown file created at: $output_file"
