set -g GW_DEFAULT_COPY_PATTERNS ".env" ".env.*" "**/.env" "**/.env.*"
set -g GW_BASE_METADATA_FILE ".gw-base"

function gw --description "Git worktree management tool"
    # Default patterns for ignored files to copy

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
                __gw_remove_worktree $argv[2..-1]
            case clean
                # Clean up merged/deleted worktrees
                __gw_clean_worktrees $argv[2..-1]
            case exp experiment
                # Create experimental worktrees in zellij panes
                __gw_create_experiment $project_worktrees_dir $argv[2..-1]
            case apply
                # Apply current worktree changes to its base branch worktree
                __gw_apply_to_base $project_worktrees_dir $argv[2..-1]
            case prompt-gen
                if test (count $argv) -lt 2
                    echo "Usage: gw prompt-gen compare" >&2
                    return 1
                end
                switch $argv[2]
                    case compare
                        __gw_prompt_gen_compare $project_worktrees_dir $repo_root
                    case '*'
                        echo "Usage: gw prompt-gen compare" >&2
                        return 1
                end
            case '*'
                echo "Usage: gw [command] [options]"
                echo "Commands:"
                echo "  gw                  - Select and switch to a worktree"
                echo "  gw main             - Switch to main branch worktree"
                echo "  gw new <name>       - Create new worktree from main branch"
                echo "  gw new -c <name>    - Create new worktree from current branch"
                echo "  gw add              - Create worktree from existing branch"
                echo "  gw rm [--force]     - Remove a worktree (force ignores local changes)"
                echo "  gw clean [--force]  - Remove merged/deleted worktrees (force ignores local changes)"
                echo "  gw exp              - Create experimental worktrees in zellij panes (3 columns)"
                echo "  gw experiment       - Alias for 'gw exp'"
                echo "  gw apply [target]   - Apply current worktree changes onto its base worktree"
                echo "  gw prompt-gen compare - Generate an AI比較用プロンプト for experiment worktrees"
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

function __gw_metadata_file_for
    set -l worktree_path $argv[1]
    if test -z "$worktree_path"
        return 1
    end
    echo "$worktree_path/$GW_BASE_METADATA_FILE"
end

function __gw_write_base_metadata
    set -l worktree_path $argv[1]
    set -l repo_name $argv[2]
    set -l base_branch $argv[3]
    set -l base_worktree $argv[4]

    if test -z "$worktree_path" -o -z "$base_branch" -o -z "$base_worktree"
        return 1
    end

    set -l resolved_base (cd $base_worktree 2>/dev/null; and pwd)
    if test -n "$resolved_base"
        set base_worktree $resolved_base
    end

    set -l meta_file (__gw_metadata_file_for $worktree_path)
    printf 'repo=%s\nbase_branch=%s\nbase_worktree=%s\n' "$repo_name" "$base_branch" "$base_worktree" > "$meta_file"
end

function __gw_read_base_metadata
    set -l worktree_path $argv[1]
    set -l meta_file (__gw_metadata_file_for $worktree_path)

    if not test -f "$meta_file"
        return 1
    end

    set -l base_branch ""
    set -l base_worktree ""
    set -l repo_name ""

    while read -l line
        set line (string trim $line)
        if test -z "$line"
            continue
        end
        if string match -q '#*' "$line"
            continue
        end

        set -l parts (string split -m 1 '=' $line)
        if test (count $parts) -lt 2
            continue
        end

        set -l key (string trim $parts[1])
        set -l value (string trim $parts[2])

        switch $key
            case repo
                set repo_name $value
            case base_branch
                set base_branch $value
            case base_worktree
                set base_worktree $value
        end
    end < "$meta_file"

    if test -z "$base_branch" -o -z "$base_worktree"
        return 1
    end

    echo $base_branch
    echo $base_worktree
    echo $repo_name
    return 0
end

function __gw_resolve_base_info
    set -l worktree_path $argv[1]
    set -l base_branch ""
    set -l base_worktree ""

    set -l meta (__gw_read_base_metadata $worktree_path)
    if test $status -eq 0
        set base_branch $meta[1]
        set base_worktree $meta[2]
    end

    if test -z "$base_branch" -o -z "$base_worktree"
        if string match -q "$HOME/worktrees/*" "$worktree_path"
            set -l parent (dirname $worktree_path)
            if test -z "$base_branch"
                set base_branch (basename $parent)
            end
            if test -z "$base_worktree"
                set base_worktree $parent
            end
        end
    end

    if test -z "$base_branch" -o -z "$base_worktree"
        echo "Error: Unable to resolve base worktree for '$worktree_path'." >&2
        echo "Hint: recreate this worktree via 'gw new' or 'gw exp' to regenerate metadata." >&2
        return 1
    end

    set -l resolved (cd "$base_worktree" 2>/dev/null; and pwd)
    if test -n "$resolved"
        set base_worktree $resolved
    end

    echo $base_branch
    echo $base_worktree
end

# Find a worktree path for the provided branch name
function __gw_find_worktree_by_branch
    set -l target_branch $argv[1]
    if test -z "$target_branch"
        return 1
    end

    set -l target_ref "refs/heads/$target_branch"
    set -l worktree_path ""
    set -l current_path ""

    for line in (git worktree list --porcelain)
        if string match -q -r '^worktree ' $line
            set current_path (string replace -r '^worktree ' '' $line)
        else if string match -q -r '^branch ' $line
            set -l branch_ref (string replace -r '^branch ' '' $line)
            if test "$branch_ref" = "$target_ref"
                set worktree_path $current_path
                break
            end
        end
    end

    if test -n "$worktree_path"
        echo $worktree_path
        return 0
    end

    return 1
end

# Apply current worktree changes onto its base worktree

function __gw_apply_to_base_impl
    set -l project_worktrees_dir $argv[1]
    set -l target_override ""
    if test (count $argv) -ge 2
        set target_override $argv[2]
    end

    set -l repo_root (git rev-parse --show-toplevel 2>/dev/null)
    if test -z "$repo_root"
        echo "Error: Not inside a git worktree" >&2
        return 1
    end

    set -l current_branch (git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if test -z "$current_branch"
        echo "Error: Unable to determine current branch" >&2
        return 1
    end

    set -l base_branch ""
    set -l base_worktree ""

    if test -n "$target_override"
        if test -d "$target_override"
            set base_worktree (cd "$target_override" 2>/dev/null; and pwd)
            if test -z "$base_worktree"
                echo "Error: Unable to resolve target path '$target_override'" >&2
                return 1
            end
            set base_branch (git -C "$base_worktree" rev-parse --abbrev-ref HEAD 2>/dev/null)
        else
            set base_branch $target_override
            set base_worktree (__gw_find_worktree_by_branch $base_branch)
        end
    else
        set -l resolved (__gw_resolve_base_info $repo_root)
        if test $status -ne 0
            return 1
        end
        set base_branch $resolved[1]
        set base_worktree $resolved[2]
    end

    if test -z "$base_worktree"
        echo "Error: Could not resolve target worktree" >&2
        return 1
    end

    if not test -d "$base_worktree"
        echo "Error: Base worktree path '$base_worktree' does not exist" >&2
        return 1
    end

    if test -z "$base_branch"
        set base_branch (git -C "$base_worktree" rev-parse --abbrev-ref HEAD 2>/dev/null)
    end

    if test -z "$base_branch"
        set base_branch (basename $base_worktree)
    end

    if test -z "$base_branch"
        echo "Error: Could not determine base branch name" >&2
        return 1
    end

    if test "$base_branch" = "$current_branch"
        echo "Error: Base branch resolved to current branch ($current_branch)" >&2
        return 1
    end

    if test "$base_worktree" = "$repo_root"
        echo "Error: Already on base worktree '$base_branch'" >&2
        return 1
    end

    set -l dirty_status (git -C "$base_worktree" status --porcelain)
    if test -n "$dirty_status"
        echo "Base worktree '$base_worktree' has uncommitted changes:" >&2
        git -C "$base_worktree" status --short >&2
        read -l response -P "Discard base worktree changes before applying? [y/N] "
        set response (string lower (string trim $response))
        if not string match -q -r '^(y|yes)$' $response
            echo "Aborted." >&2
            return 1
        end
        git -C "$base_worktree" reset --hard >/dev/null
        git -C "$base_worktree" clean -fd >/dev/null
    end

    set -l temp_dir (mktemp -d /tmp/gw-apply.XXXXXX)
    if test $status -ne 0 -o -z "$temp_dir"
        echo "Error: Failed to create temporary directory" >&2
        return 1
    end

    set -l commit_patch "$temp_dir/commits.patch"
    set -l worktree_patch "$temp_dir/worktree.patch"

    git -C "$repo_root" diff --binary "$base_branch...$current_branch" > $commit_patch
    if test $status -ne 0
        rm -rf $temp_dir
        echo "Error: Failed to create diff between '$base_branch' and '$current_branch'" >&2
        return 1
    end

    git -C "$repo_root" diff --binary HEAD > $worktree_patch
    if test $status -ne 0
        rm -rf $temp_dir
        echo "Error: Failed to capture working tree changes" >&2
        return 1
    end

    set -l applied_commits 0
    if test -s $commit_patch
        if git -C "$base_worktree" apply --3way --allow-empty --whitespace=nowarn $commit_patch
            set applied_commits 1
        else
            rm -rf $temp_dir
            echo "Error: Failed to apply committed changes to base worktree" >&2
            return 1
        end
    end

    set -l applied_worktree 0
    if test -s $worktree_patch
        if git -C "$base_worktree" apply --allow-empty --whitespace=nowarn $worktree_patch
            set applied_worktree 1
        else
            rm -rf $temp_dir
            echo "Error: Failed to apply uncommitted changes to base worktree" >&2
            return 1
        end
    end

    set -l copied_untracked 0
    set -l untracked_files (git -C "$repo_root" ls-files --others --exclude-standard)
    for file in $untracked_files
        set -l source_path "$repo_root/$file"
        if not test -e $source_path
            continue
        end
        set -l target_path "$base_worktree/$file"
        set -l target_dir (dirname $target_path)
        if test "$target_dir" != "."
            mkdir -p $target_dir
        end
        cp -p $source_path $target_path
        set copied_untracked 1
    end

    rm -rf $temp_dir

    if test $applied_commits -eq 0 -a $applied_worktree -eq 0 -a $copied_untracked -eq 0
        echo "No changes to apply to base worktree." >&2
        return 0
    end

    echo "Applied changes from '$current_branch' to base '$base_branch' worktree: $base_worktree"
    if test $applied_commits -eq 1
        echo "  - committed changes applied"
    end
    if test $applied_worktree -eq 1
        echo "  - uncommitted tracked changes applied"
    end
    if test $copied_untracked -eq 1
        echo "  - untracked files copied"
    end

    return 0
end

function __gw_apply_to_base
    set -l original_pwd (pwd)
    __gw_apply_to_base_impl $argv
    set -l apply_status $status
    if test -n "$original_pwd" -a -d "$original_pwd"
        cd "$original_pwd"
    end
    return $apply_status
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

# Resolve upstream (e.g. origin/main) for the provided branch
function __gw_get_upstream_for_branch
    set -l branch $argv[1]
    if test -z "$branch"
        return 1
    end

    set -l upstream (git for-each-ref --format='%(upstream:short)' "refs/heads/$branch")
    if test -n "$upstream"
        echo $upstream
        return 0
    end

    if git remote | grep -q '^origin$'
        echo "origin/$branch"
        return 0
    end

    echo "Error: No upstream remote configured for branch '$branch'" >&2
    return 1
end

# Fast-forward the local branch to match its upstream remote reference
function __gw_fast_forward_branch_from_remote
    set -l branch $argv[1]
    if test -z "$branch"
        return 1
    end

    set -l upstream (__gw_get_upstream_for_branch $branch)
    if test $status -ne 0
        return 1
    end

    set -l upstream_parts (string split -m 1 '/' $upstream)
    if test (count $upstream_parts) -lt 2
        echo "Error: Invalid upstream format '$upstream'" >&2
        return 1
    end

    set -l remote $upstream_parts[1]
    set -l remote_branch $upstream_parts[2]

    echo "Fetching latest '$remote_branch' from '$remote'..." >&2
    git fetch --quiet $remote $remote_branch
    if test $status -ne 0
        echo "Error: Failed to fetch '$remote/$remote_branch'" >&2
        return 1
    end

    set -l remote_ref "refs/remotes/$remote/$remote_branch"
    set -l remote_sha (git rev-parse --verify $remote_ref 2>/dev/null)
    if test -z "$remote_sha"
        echo "Error: Remote ref '$remote_ref' not found after fetch" >&2
        return 1
    end

    set -l local_ref "refs/heads/$branch"
    set -l local_sha (git rev-parse --verify $local_ref 2>/dev/null)

    if test -z "$local_sha"
        git update-ref $local_ref $remote_sha
        return $status
    end

    git merge-base --is-ancestor $local_sha $remote_sha >/dev/null
    if test $status -eq 0
        git update-ref $local_ref $remote_sha
    else
        echo "Warning: '$branch' has diverged from '$remote/$remote_branch'; skipped auto fast-forward." >&2
        return 1
    end
end

# Helper function: Create new worktree
function __gw_create_new
    set -l project_worktrees_dir $argv[1]
    set -l from_current 0
    set -l branch_name ""
    set -l copy_patterns $GW_DEFAULT_COPY_PATTERNS
    set -l no_copy_ignored 0
    set -l source_dir (pwd)
    set -l repo_root (git rev-parse --show-toplevel 2>/dev/null)
    if test -z "$repo_root"
        echo "Error: Not inside a git repository" >&2
        return 1
    end
    set -l repo_name (basename $repo_root)

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

    set -l base_branch ""
    set -l base_worktree ""

    if test $from_current -eq 1
        set base_branch (git branch --show-current)
        if test -z "$base_branch"
            echo "Error: Unable to determine current branch" >&2
            return 1
        end
        set base_worktree $repo_root
    else
        set base_branch (__gw_get_main_branch)
        if test $status -ne 0
            return 1
        end

        __gw_fast_forward_branch_from_remote $base_branch
        if test $status -ne 0
            echo "Continuing with local '$base_branch' state." >&2
        end

        set base_worktree (__gw_find_worktree_by_branch $base_branch)
        if test -z "$base_worktree"
            set -l root_branch (git -C $repo_root rev-parse --abbrev-ref HEAD 2>/dev/null)
            if test "$root_branch" = "$base_branch"
                set base_worktree $repo_root
            end
        end

        if test -z "$base_worktree"
            echo "Error: Unable to locate worktree for base branch '$base_branch'. Run 'gw main' first." >&2
            return 1
        end
    end

    set -l base_container "$project_worktrees_dir/$base_branch"
    set -l worktree_path "$base_container/$branch_name"

    if test -d "$worktree_path"
        echo "Error: Worktree already exists: $worktree_path" >&2
        return 1
    end

    mkdir -p "$base_container"
    set -l worktree_parent (dirname "$worktree_path")
    if not test -d "$worktree_parent"
        mkdir -p "$worktree_parent"
    end

    if test $from_current -eq 1
        echo "Creating worktree '$branch_name' from current branch '$base_branch'..."
        git worktree add -b $branch_name "$worktree_path" HEAD
    else
        echo "Creating worktree '$branch_name' from '$base_branch'..."
        git worktree add -b $branch_name "$worktree_path" $base_branch
    end

    if test $status -eq 0
        # Copy ignored files if not disabled
        if test $no_copy_ignored -eq 0
            __gw_copy_ignored_files $source_dir "$worktree_path" $copy_patterns
        end

        __gw_write_base_metadata "$worktree_path" $repo_name $base_branch $base_worktree

        cd "$worktree_path"
    end
end

# Helper function: Add worktree from existing branch
function __gw_add_existing
    set -l project_worktrees_dir $argv[1]
    set -l copy_patterns $GW_DEFAULT_COPY_PATTERNS
    set -l no_copy_ignored 0
    set -l base_override ""
    set -l source_dir (pwd)
    set -l repo_root (git rev-parse --show-toplevel 2>/dev/null)
    if test -z "$repo_root"
        echo "Error: Not inside a git repository" >&2
        return 1
    end
    set -l repo_name (basename $repo_root)

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
            case --base
                set i (math $i + 1)
                if test $i -le (count $argv)
                    set base_override $argv[$i]
                else
                    echo "Error: --base requires a value" >&2
                    return 1
                end
            case '*'
                echo "Error: Unknown option: $argv[$i]" >&2
                echo "Usage: gw add [--copy-ignored <patterns>] [--no-copy-ignored] [--base <branch>]" >&2
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

    set -l full_branch_name $selected

    set -l base_branch $base_override
    if test -z "$base_branch"
        set base_branch (__gw_get_main_branch)
        if test $status -ne 0
            return 1
        end
    end

    set -l base_worktree (__gw_find_worktree_by_branch $base_branch)
    if test -z "$base_worktree"
        set -l root_branch (git -C $repo_root rev-parse --abbrev-ref HEAD 2>/dev/null)
        if test "$root_branch" = "$base_branch"
            set base_worktree $repo_root
        end
    end

    if test -z "$base_worktree"
        echo "Error: Unable to locate worktree for base branch '$base_branch'. Run 'gw main' first." >&2
        return 1
    end

    set -l base_container "$project_worktrees_dir/$base_branch"
    set -l worktree_path "$base_container/$full_branch_name"

    # Check if worktree already exists
    if test -d "$worktree_path"
        echo "Error: Worktree already exists: $worktree_path" >&2
        return 1
    end

    mkdir -p "$base_container"

    # Check if it's a remote branch
    if git show-ref --verify --quiet "refs/remotes/origin/$full_branch_name"
        echo "Creating worktree from remote branch 'origin/$full_branch_name'..."
        git worktree add --track -b $full_branch_name "$worktree_path" origin/$full_branch_name
    else
        echo "Creating worktree from local branch '$full_branch_name'..."
        git worktree add "$worktree_path" $full_branch_name
    end

    if test $status -eq 0
        # Copy ignored files if not disabled
        if test $no_copy_ignored -eq 0
            __gw_copy_ignored_files $source_dir "$worktree_path" $copy_patterns
        end

        __gw_write_base_metadata "$worktree_path" $repo_name $base_branch $base_worktree

        cd "$worktree_path"
    end
end

# Helper function: Remove worktree
function __gw_remove_worktree
    set -l force 0
    for arg in $argv
        switch $arg
            case -f --force
                set force 1
            case ''
                continue
            case '*'
                echo "Usage: gw rm [--force]" >&2
                return 1
        end
    end

    set -l worktrees (git worktree list --porcelain | grep "^worktree" | sed 's/^worktree //' | grep -v (git rev-parse --show-toplevel))

    if test -z "$worktrees"
        echo "No worktrees to remove" >&2
        return 1
    end

    set -l selected (printf '%s\n' $worktrees | fzf --height=40% --reverse --prompt="Select worktree to remove: ")

    if test -n "$selected"
        set -l branch_name (git -C $selected branch --show-current)
        echo "Removing worktree: $selected (branch: $branch_name)"
        set -l remove_args remove
        if test $force -eq 1
            set remove_args $remove_args --force
        end
        git worktree $remove_args $selected

        # Also delete the branch
        if test -n "$branch_name"
            echo "Deleting branch: $branch_name"
            git branch -D $branch_name
        end
    end
end

# Helper function: Clean merged/deleted worktrees
function __gw_clean_worktrees
    set -l force 0
    for arg in $argv
        switch $arg
            case -f --force
                set force 1
            case ''
                continue
            case '*'
                echo "Usage: gw clean [--force]" >&2
                return 1
        end
    end

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
                set -l remove_args remove
                if test $force -eq 1
                    set remove_args $remove_args --force
                end
                git worktree $remove_args $worktree

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

    set -l matched_files

    # Use find to search for files matching each pattern
    for pattern in $patterns
        # Handle different pattern types - check more specific patterns first
        if string match -q "**/.*" $pattern
            # Pattern like **/.env or **/.env.*
            set -l base_pattern (string replace "**/" "" $pattern)
            # Find files matching the pattern in any subdirectory
            set -l found_files (find . -name "$base_pattern" -type f 2>/dev/null | sed 's|^\./||')
            set matched_files $matched_files $found_files
        else if string match -q "*/*" $pattern
            # Pattern with directory like .serena/*
            # Split the pattern into directory and file parts
            set -l parts (string split -m 1 '/' $pattern)
            set -l dir_pattern $parts[1]
            set -l file_pattern $parts[2]

            # Check if the directory exists first
            if test -d "./$dir_pattern"
                if test "$file_pattern" = "*"
                    # If pattern is like .serena/*, include the directory itself
                    # Add the directory as a special entry to copy the whole directory
                    set matched_files $matched_files $dir_pattern
                end
            end
        else
            # Simple pattern like .env or .env.*
            # Search in all directories
            set -l found_files (find . -name "$pattern" -type f 2>/dev/null | sed 's|^\./||')
            set matched_files $matched_files $found_files
        end
    end

    # Remove duplicates and output
    printf '%s\n' $matched_files | sort -u
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

        # Check if it's a directory
        if test -d "$source_file"
            # Copy directory recursively
            if cp -r "$source_file" "$target_file"
                echo "  Copied directory: $file"
            else
                echo "  Error copying directory: $file" >&2
            end
        else
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
end

# Helper function: Create experimental worktrees in zellij panes
function __gw_create_experiment
    set -l project_worktrees_dir $argv[1]
    set -l pane_count 3

    # Check if we're in a zellij session
    if not set -q ZELLIJ
        echo "Error: Must be run inside a zellij session" >&2
        return 1
    end

    # Get current branch as base
    set -l base_branch (git branch --show-current)
    if test -z "$base_branch"
        echo "Error: Not on a branch" >&2
        return 1
    end

    # Store current directory for copying ignored files
    set -l source_dir (pwd)
    set -l repo_root (git rev-parse --show-toplevel 2>/dev/null)
    if test -z "$repo_root"
        echo "Error: Not inside a git repository" >&2
        return 1
    end
    set -l repo_name (basename $repo_root)
    set -l base_container "$project_worktrees_dir/$base_branch"
    mkdir -p "$base_container"

    # Create worktrees first and collect paths
    set -l worktree_paths
    for i in (seq 1 $pane_count)
        set -l branch_name "$base_branch-exp-$i"
        set -l worktree_path "$base_container/$branch_name"

        # Check if worktree/branch already exists
        if test -d "$worktree_path"
            echo "Warning: Worktree already exists: $worktree_path, skipping..." >&2
            set worktree_paths $worktree_paths ""
            continue
        end

        if git show-ref --verify --quiet "refs/heads/$branch_name"
            echo "Warning: Branch already exists: $branch_name, skipping..." >&2
            set worktree_paths $worktree_paths ""
            continue
        end

        # Create worktree from current branch
        echo "Creating worktree '$branch_name' from '$base_branch'..."
        git worktree add -b $branch_name "$worktree_path" HEAD

        if test $status -ne 0
            echo "Error: Failed to create worktree for $branch_name" >&2
            set worktree_paths $worktree_paths ""
            continue
        end

        # Copy ignored files
        __gw_copy_ignored_files $source_dir "$worktree_path" $GW_DEFAULT_COPY_PATTERNS

        __gw_write_base_metadata "$worktree_path" $repo_name $base_branch $source_dir

        set worktree_paths $worktree_paths $worktree_path
    end

    # Generate dynamic layout with worktree paths using cwd
    set -l tab_name "exp-$base_branch"
    set -l layout_dir "$HOME/.config/zellij/layouts"
    mkdir -p $layout_dir
    set -l temp_layout "$layout_dir/exp-dynamic.kdl"

    set -l layout_content "layout {
  default_tab_template {
      pane size=1 borderless=true {
          plugin location=\"zellij:tab-bar\"
      }
      children
      pane size=2 borderless=true {
          plugin location=\"zellij:status-bar\"
      }
  }
    pane split_direction=\"vertical\" {"

    for i in (seq 1 $pane_count)
        set -l size "33%"
        if test $i -eq $pane_count
            set size "34%"
        end

        set -l worktree_path $worktree_paths[$i]
        if test -n "$worktree_path"
            set layout_content "$layout_content
        pane size=\"$size\" cwd=\"$worktree_path\""
        else
            set layout_content "$layout_content
        pane size=\"$size\""
        end
    end

    set layout_content "$layout_content
    }
}"

    # Write layout to config directory
    echo "$layout_content" > $temp_layout

    # Create new tab with dynamic layout
    zellij action new-tab --layout "exp-dynamic" --name "$tab_name"

    echo "Created $pane_count experimental worktrees in tab '$tab_name'"
end

# Helper function: Generate comparison prompt for experiment worktrees
function __gw_prompt_gen_compare
    set -l project_worktrees_dir $argv[1]
    set -l repo_root $argv[2]

    set -l base_branch (git branch --show-current)
    if test -z "$base_branch"
        echo "Error: Not on a branch" >&2
        return 1
    end

    set -l repo_name (basename $repo_root)
    set -l base_container "$project_worktrees_dir/$base_branch"
    if not test -d "$base_container"
        echo "Error: No experiment container for branch '$base_branch'. Run 'gw exp' first." >&2
        return 1
    end

    set -l experiment_paths
    set -l experiment_branches
    set -l target_prefix "$base_branch-exp-"
    set -l current_path ""

    for line in (git worktree list --porcelain)
        if string match -q -r '^worktree ' $line
            set current_path (string replace -r '^worktree ' '' $line)
        else if string match -q -r '^branch ' $line
            set -l branch_ref (string replace -r '^branch ' '' $line)
            set -l branch_name (string replace -r '^refs/heads/' '' $branch_ref)
            if string match -q "$target_prefix*" $branch_name
                if test -d "$current_path"
                    set experiment_paths $experiment_paths $current_path
                    set experiment_branches $experiment_branches $branch_name
                end
            end
        end
    end

    if test (count $experiment_paths) -eq 0
        echo "Error: No experiment worktrees found for '$base_branch'. Run 'gw exp' first." >&2
        return 1
    end

    set -l joined_branches (string join ', ' $experiment_branches)
    set -l labels A B C D E F G H I J

    printf "# Prompt\n"
    printf "Goal: Compare the experimental implementations branched from '%s' and select the best candidate. Add any project-specific context if needed.\n\n" $base_branch

    printf "## Common Info\n"
    printf "- Repository: %s\n" $repo_name
    printf "- Base branch: %s\n" $base_branch
    printf "- Worktrees to compare: %s\n" $joined_branches
    printf "- Candidate worktrees:\n"

    set -l count_paths (count $experiment_paths)
    for idx in (seq 1 $count_paths)
        set -l worktree_path $experiment_paths[$idx]
        set -l branch_name $experiment_branches[$idx]
        set -l label $labels[$idx]
        if test -z "$label"
            set label $idx
        end
        if not test -d "$worktree_path"
            printf "  - 候補%s (%s): (worktreeが見つかりません)\n" $label $branch_name
            continue
        end
        printf "  - 候補%s (%s): %s\n" $label $branch_name $worktree_path
    end
    printf "\n"

    printf "## Evaluation Criteria\n"
    printf "- Accuracy: Alignment with requirements and absence of regressions\n"
    printf "- Completeness: Test coverage and missing scope\n"
    printf "- Maintainability: Readability, dependencies, extensibility\n"
    printf "- Simplicity: Smaller implementation footprint and straightforward logic\n"
    printf "- Risk: Blast radius and rollback ease if issues occur\n\n"

    printf "Note: When reviewing each candidate, inspect the entire working tree including staged, unstaged, and uncommitted changes.\n\n"

    printf "## Output Instructions\n"
    printf "1. Score every candidate for each evaluation criterion on a 1-5 scale (1=low, 5=high) and justify each score.\n"
    printf "2. Select exactly one winning candidate and provide three concrete adoption reasons.\n"
    printf "3. Summarize rejection reasons or key risks for the remaining candidates in bullet form.\n"
    printf "4. Propose TODO items (tests/log checks/reviews) required before merging.\n"
    printf "5. Finish with a one-paragraph decision summary under 100 Japanese characters.\n"
    printf "6. Write the entire analysis and final answer in Japanese.\n\n"

    printf "### Output Example\n"
    printf "- 優勝案: 候補A (総合スコア: 18)\n"
    printf "- スコア表:\n"
    printf "  - 候補A: 正確性4 / 完成度5 / 保守性3 / 簡潔性5 / リスク1\n"
    printf "  - 候補B: ...\n"
    printf "- 却下理由: <箇条書き>\n"
    printf "- TODO: <箇条書き>\n"
    printf "- サマリ: <100字以内テキスト>\n"
end
