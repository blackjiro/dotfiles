function zellij_update_tabname
    if set -q ZELLIJ
        set tab_name ""

        set repo_name (git remote get-url origin 2>/dev/null | sed -E 's#.*/([^/]+)(\.git)?$#\1#' | sed 's/\.git$//')

        if test -z "$repo_name"
            set repo_name (basename (git rev-parse --show-toplevel 2>/dev/null))
        end

        set branch_name (git branch --show-current 2>/dev/null)

        if test -n "$repo_name" -a -n "$branch_name"
            set tab_name "$repo_name:$branch_name"
        else
            if test $PWD = $HOME
                set tab_name "~"
            else
                set tab_name (basename $PWD)
            end
        end

        nohup zellij action rename-tab $tab_name >/dev/null 2>&1
    end
end
