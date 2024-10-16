#!/bin/bash

# Improved Bash Script to Combine Text Files into a Markdown for LLM Analysis
# with Directory Exclusion, File Extension Inclusion, and File Pattern Exclusion Support

# Function to print usage
print_usage() {
    echo "Usage: $0 <root_directory> <output_file> [--exclude-dir dir1 dir2...] [--include ext1 ext2...] [--exclude pattern1 pattern2...]"
    echo "Example: $0 ./project output.md --exclude-dir ./project/node_modules ./project/venv --include py js --exclude '*.test.js' '*.spec.py'"
}

# Check if the correct number of arguments are provided
if [ "$#" -lt 2 ]; then
    print_usage
    exit 1
fi

root_dir="$1"        # Root directory passed as the first argument
output_file="$2"     # Output file passed as the second argument
shift 2              # Shift the positional arguments to handle the options

excluded_dirs=()
included_extensions=()
excluded_patterns=()

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --exclude-dir)
            shift
            while [[ $# -gt 0 && ! $1 == --* ]]; do
                excluded_dirs+=("$1")
                shift
            done
            ;;
        --include)
            shift
            while [[ $# -gt 0 && ! $1 == --* ]]; do
                included_extensions+=("$1")
                shift
            done
            ;;
        --exclude)
            shift
            while [[ $# -gt 0 && ! $1 == --* ]]; do
                excluded_patterns+=("$1")
                shift
            done
            ;;
        *)
            echo "Unknown option: $1"
            print_usage
            exit 1
            ;;
    esac
done

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
> "$output_file"

# Define supported source code file extensions with their corresponding language tags
declare -A file_extensions=(
    ["py"]="python"
    ["js"]="javascript"
    ["java"]="java"
    ["cpp"]="cpp"
    ["html"]="html"
    ["css"]="css"
    ["sh"]="bash"
    ["dart"]="dart"
    ["md"]="markdown"
    ["json"]="json"
    ["yaml"]="yaml"
    ["txt"]=""
)

# Construct the exclusion arguments for the find command
exclude_dir_args=()
for dir in "${excluded_dirs[@]}"; do
    exclude_dir_args+=("-not" "-path" "$dir/*")
done

# Function to check if a file matches any of the excluded patterns
matches_excluded_pattern() {
    local file="$1"
    local filename=$(basename "$file")
    local relative_path="${file#$root_dir/}"
    for pattern in "${excluded_patterns[@]}"; do
        if [[ "$filename" == $pattern || "$relative_path" == $pattern ]]; then
            return 0  # Match found
        fi
    done
    return 1  # No match found
}

# Function to recursively find and combine text files
combine_text_files() {
    local current_dir="$1"
    
    # If no specific extensions are included, use all supported extensions
    if [ ${#included_extensions[@]} -eq 0 ]; then
        included_extensions=("${!file_extensions[@]}")
    fi
    
    # Loop through each included file extension
    for ext in "${included_extensions[@]}"; do
        if [[ -v "file_extensions[$ext]" ]]; then
            lang="${file_extensions[$ext]}"
            find "$current_dir" -type f -name "*.$ext" "${exclude_dir_args[@]}" 2>/dev/null | while read -r file; do
                # Check if the file exists (in case of race conditions or permission issues)
                if [ ! -f "$file" ]; then
                    echo "Warning: Skipping '$file', file does not exist."
                    continue
                fi

                # Check if the file matches any of the excluded patterns
                if matches_excluded_pattern "$file"; then
                    continue
                fi

                # Include the full path
                full_path="$file"

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
        else
            echo "Warning: Unsupported file extension '$ext' specified."
        fi
    done
}

# Call the function to combine text files
combine_text_files "$root_dir"

echo "Markdown file created at: $output_file"