#!/opt/homebrew/bin/bash
# detect-budget-violations.sh
# Scans AGENTS.md files for token budget violations

set -euo pipefail

# Token budgets (characters)
GLOBAL_MAX=12000
PROFILE_MAX=8000
PROJECT_MAX=6000
AGENT_MAX=6000

find_agents_files() {
    find "$1" -name "AGENTS.md" -type f
}

check_budget() {
    local file="$1"
    local max_chars="$2"
    local char_count
    char_count=$(wc -c < "$file")

    if [ "$char_count" -gt "$max_chars" ]; then
        local over=$((char_count - max_chars))
        echo "VIOLATION:$file:$char_count:$max_chars:$over"
        return 0
    fi
    return 1
}

detect_level() {
    local file="$1"
    local dir
    dir=$(dirname "$file")

    if [[ "$dir" == */agents/* ]]; then
        echo "agent:$AGENT_MAX"
    elif [[ "$dir" =~ Projects/[^/]+/[^/]+ ]]; then
        echo "project:$PROJECT_MAX"
    elif [[ "$dir" =~ Projects/[^/]+$ ]]; then
        echo "profile:$PROFILE_MAX"
    else
        echo "global:$GLOBAL_MAX"
    fi
}

main() {
    local search_dir="${1:-.}"
    local violations=()

    while IFS= read -r agents_file; do
        local level_info
        level_info=$(detect_level "$agents_file")
        local level="${level_info%:*}"
        local max_chars="${level_info#*:}"

        if check_budget "$agents_file" "$max_chars"; then
            violations+=("$agents_file")
        fi
    done < <(find_agents_files "$search_dir")

    if [ ${#violations[@]} -gt 0 ]; then
        echo "BUDGET_VIOLATIONS_DETECTED:${#violations[@]}"
        for violation in "${violations[@]}"; do
            echo "$violation"
        done
        return 0
    else
        echo "NO_VIOLATIONS"
        return 1
    fi
}

main "$@"
