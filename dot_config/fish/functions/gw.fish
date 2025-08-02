function gw --description "Git worktree management tool"
    # Default patterns for ignored files to copy
    set -g GW_DEFAULT_COPY_PATTERNS ".env" ".env.*"

    # Get current repository info first
    set -l repo_root (git rev-parse --show-toplevel 2>/dev/null)
    if test -z "$repo_root"
        echo "Error: Not in a git repository" >&2
        return 1
    end

    # Setup worktrees base directory
    set -l worktrees_base "$HOME/worktrees"
    if not test -d $worktrees_base
        mkdir -p $worktrees_base
    end

    set -l project_name (basename $repo_root)
    set -l project_worktrees_dir "$worktrees_base/$project_name"

    # Parse arguments
    if test (count $argv) -eq 0
        # No arguments: show fzf selector to choose worktree
        __gw_select_worktree
    else
        switch $argv[1]
            case main
                # Go to main branch worktree
                __gw_go_to_main $project_worktrees_dir
            case new
                # Create new worktree
                __gw_create_new $project_worktrees_dir $argv[2..-1]
            case add
                # Add worktree from existing branch
                __gw_add_existing $project_worktrees_dir $argv[2..-1]
            case rm
                # Remove worktree with fzf
                __gw_remove_worktree
            case clean
                # Clean up merged/deleted worktrees
                __gw_clean_worktrees
            case '*'
                echo "Usage: gw [command] [options]"
                echo "Commands:"
                echo "  gw                  - Select and switch to a worktree"
                echo "  gw main             - Switch to main branch worktree"
                echo "  gw new <name>       - Create new worktree from main branch"
                echo "  gw new -c <name>    - Create new worktree from current branch"
                echo "  gw add              - Create worktree from existing branch"
                echo "  gw rm               - Remove a worktree"
                echo "  gw clean            - Remove merged/deleted worktrees"
                echo ""
                echo "Options for 'new' and 'add' commands:"
                echo "  --copy-ignored <patterns>  - Copy specific ignored files (comma-separated)"
                echo "  --no-copy-ignored         - Don't copy any ignored files"
                echo ""
                echo "Default copy patterns: $GW_DEFAULT_COPY_PATTERNS"
                return 1
        end
    end
end

# Determine main branch
function __gw_get_main_branch
    if git show-ref --verify --quiet refs/heads/main
        echo main
    else if git show-ref --verify --quiet refs/heads/master
        echo master
    else
        echo "Error: No main/master branch found" >&2
        return 1
    end
end

# Helper function: Select and switch to worktree
function __gw_select_worktree
    set -l worktrees (git worktree list --porcelain | grep "^worktree" | sed 's/^worktree //')
    if test -z "$worktrees"
        echo "No worktrees found" >&2
        return 1
    end

    set -l selected (printf '%s\n' $worktrees | fzf --height=40% --reverse --prompt="Select worktree: ")
    if test -n "$selected"
        cd $selected
    end
end

# Helper function: Go to main branch
function __gw_go_to_main
    set -l project_worktrees_dir $argv[1]
    set -l main_branch (__gw_get_main_branch)
    if test $status -ne 0
        return 1
    end

    set -l main_worktree "$project_worktrees_dir/$main_branch"

    # Create main worktree if it doesn't exist
    if not test -d $main_worktree
        echo "Creating main branch worktree..."
        mkdir -p $project_worktrees_dir
        git worktree add $main_worktree $main_branch
    end

    cd $main_worktree
end

# Helper function: Create new worktree
function __gw_create_new
    set -l project_worktrees_dir $argv[1]
    set -l from_current 0
    set -l branch_name ""
    set -l copy_patterns $GW_DEFAULT_COPY_PATTERNS
    set -l no_copy_ignored 0
    set -l source_dir (pwd)

    # Parse options (skip first arg which is project_worktrees_dir)
    set -l i 2
    while test $i -le (count $argv)
        switch $argv[$i]
            case -c
                set from_current 1
            case --copy-ignored
                set i (math $i + 1)
                if test $i -le (count $argv)
                    # Split comma-separated patterns
                    set copy_patterns (string split ',' $argv[$i])
                else
                    echo "Error: --copy-ignored requires a value" >&2
                    return 1
                end
            case --no-copy-ignored
                set no_copy_ignored 1
            case '*'
                if test -z "$branch_name"
                    set branch_name $argv[$i]
                end
        end
        set i (math $i + 1)
    end

    if test -z "$branch_name"
        echo "Error: Branch name required" >&2
        echo "Usage: gw new [-c] [--copy-ignored <patterns>] [--no-copy-ignored] <branch-name>" >&2
        return 1
    end

    set -l worktree_path "$project_worktrees_dir/$branch_name"

    # Check if worktree already exists
    if test -d $worktree_path
        echo "Error: Worktree already exists: $worktree_path" >&2
        return 1
    end

    # Create directory if needed
    mkdir -p $project_worktrees_dir

    # Create worktree
    if test $from_current -eq 1
        # Create from current branch
        set -l current_branch (git branch --show-current)
        echo "Creating worktree '$branch_name' from current branch '$current_branch'..."
        git worktree add -b $branch_name $worktree_path HEAD
    else
        # Create from main branch
        set -l main_branch (__gw_get_main_branch)
        if test $status -ne 0
            return 1
        end
        echo "Creating worktree '$branch_name' from '$main_branch'..."
        git worktree add -b $branch_name $worktree_path $main_branch
    end

    if test $status -eq 0
        # Copy ignored files if not disabled
        if test $no_copy_ignored -eq 0
            __gw_copy_ignored_files $source_dir $worktree_path $copy_patterns
        end

        cd $worktree_path
    end
end

# Helper function: Add worktree from existing branch
function __gw_add_existing
    set -l project_worktrees_dir $argv[1]
    set -l copy_patterns $GW_DEFAULT_COPY_PATTERNS
    set -l no_copy_ignored 0
    set -l source_dir (pwd)

    # Parse options (skip first arg which is project_worktrees_dir)
    set -l i 2
    while test $i -le (count $argv)
        switch $argv[$i]
            case --copy-ignored
                set i (math $i + 1)
                if test $i -le (count $argv)
                    # Split comma-separated patterns
                    set copy_patterns (string split ',' $argv[$i])
                else
                    echo "Error: --copy-ignored requires a value" >&2
                    return 1
                end
            case --no-copy-ignored
                set no_copy_ignored 1
            case '*'
                echo "Error: Unknown option: $argv[$i]" >&2
                echo "Usage: gw add [--copy-ignored <patterns>] [--no-copy-ignored]" >&2
                return 1
        end
        set i (math $i + 1)
    end

    # Get all branches (local and remote)
    set -l branches (git branch -a --format='%(refname:short)' | sed 's|origin/||' | sort -u)

    if test -z "$branches"
        echo "No branches found" >&2
        return 1
    end

    set -l selected (printf '%s\n' $branches | fzf --height=40% --reverse --prompt="Select branch: ")

    if test -z "$selected"
        return 0
    end

    set -l branch_name (basename $selected)
    set -l worktree_path "$project_worktrees_dir/$branch_name"

    # Check if worktree already exists
    if test -d $worktree_path
        echo "Error: Worktree already exists: $worktree_path" >&2
        return 1
    end

    # Create directory if needed
    mkdir -p $project_worktrees_dir

    # Check if it's a remote branch
    if git show-ref --verify --quiet "refs/remotes/origin/$selected"
        echo "Creating worktree from remote branch 'origin/$selected'..."
        git worktree add --track -b $branch_name $worktree_path origin/$selected
    else
        echo "Creating worktree from local branch '$selected'..."
        git worktree add $worktree_path $selected
    end

    if test $status -eq 0
        # Copy ignored files if not disabled
        if test $no_copy_ignored -eq 0
            __gw_copy_ignored_files $source_dir $worktree_path $copy_patterns
        end

        cd $worktree_path
    end
end

# Helper function: Remove worktree
function __gw_remove_worktree
    set -l worktrees (git worktree list --porcelain | grep "^worktree" | sed 's/^worktree //' | grep -v (git rev-parse --show-toplevel))

    if test -z "$worktrees"
        echo "No worktrees to remove" >&2
        return 1
    end

    set -l selected (printf '%s\n' $worktrees | fzf --height=40% --reverse --prompt="Select worktree to remove: ")

    if test -n "$selected"
        set -l branch_name (git -C $selected branch --show-current)
        echo "Removing worktree: $selected (branch: $branch_name)"
        git worktree remove $selected
        
        # Also delete the branch
        if test -n "$branch_name"
            echo "Deleting branch: $branch_name"
            git branch -D $branch_name
        end
    end
end

# Helper function: Clean merged/deleted worktrees
function __gw_clean_worktrees
    set -l main_branch (__gw_get_main_branch)
    if test $status -ne 0
        return 1
    end

    # Get all worktrees except the main repo
    set -l worktrees (git worktree list --porcelain | grep "^worktree" | sed 's/^worktree //' | grep -v (git rev-parse --show-toplevel))

    set -l removed_count 0

    for worktree in $worktrees
        if test -d $worktree
            set -l branch (git -C $worktree branch --show-current)

            # Skip if it's the main branch
            if test "$branch" = "$main_branch"
                continue
            end

            # Check if branch is merged
            set -l is_merged (git branch --merged $main_branch | grep -c "^  $branch\$")

            # Check if remote branch is deleted
            set -l remote_exists (git ls-remote --heads origin $branch | wc -l)

            if test $is_merged -gt 0 -o $remote_exists -eq 0
                echo "Removing worktree: $worktree (branch: $branch)"
                git worktree remove $worktree
                
                # Also delete the branch
                if test -n "$branch"
                    echo "Deleting branch: $branch"
                    git branch -D $branch
                end
                
                set removed_count (math $removed_count + 1)
            end
        end
    end

    if test $removed_count -eq 0
        echo "No worktrees to clean"
    else
        echo "Removed $removed_count worktree(s)"
    end
end

# Helper function: Get ignored files matching patterns
function __gw_get_ignored_files
    set -l patterns $argv
    set -l source_dir (pwd)

    # Get all ignored files
    set -l ignored_files (git ls-files --others --ignored --exclude-standard)

    if test -z "$ignored_files"
        return
    end

    # Filter by patterns
    set -l matched_files
    for file in $ignored_files
        # Skip directories
        if test -d "$source_dir/$file"
            continue
        end

        # Check against each pattern
        for pattern in $patterns
            # Convert glob pattern to regex-like matching
            set -l regex_pattern (string escape --style=regex $pattern | string replace -a '\*' '.*')
            if string match -r "^$regex_pattern\$" $file
                set matched_files $matched_files $file
                break
            end
        end
    end

    printf '%s\n' $matched_files
end

# Helper function: Copy ignored files to new worktree
function __gw_copy_ignored_files
    set -l source_dir $argv[1]
    set -l target_dir $argv[2]
    set -l patterns $argv[3..-1]

    # Get files to copy
    set -l files_to_copy (__gw_get_ignored_files $patterns)

    if test -z "$files_to_copy"
        return
    end

    echo "Copying ignored files:"
    for file in $files_to_copy
        set -l source_file "$source_dir/$file"
        set -l target_file "$target_dir/$file"

        # Check file size (warn if > 1MB)
        set -l file_size (stat -f%z "$source_file" 2>/dev/null; or stat -c%s "$source_file" 2>/dev/null)
        if test -n "$file_size" -a $file_size -gt 1048576
            set -l size_mb (math -s2 $file_size / 1048576)
            echo "  Warning: $file is large ({$size_mb}MB)"
        end

        # Create target directory if needed
        set -l target_file_dir (dirname $target_file)
        if not test -d $target_file_dir
            mkdir -p $target_file_dir
        end

        # Copy file
        if cp "$source_file" "$target_file"
            echo "  Copied: $file"
        else
            echo "  Error copying: $file" >&2
        end
    end
end

