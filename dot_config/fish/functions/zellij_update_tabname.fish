function zellij_update_tabname
    if set -q ZELLIJ
        set current_dir $PWD
        if test $current_dir = $HOME
            set current_dir "~"
        else
            set current_dir (basename $current_dir)
        end
        nohup zellij action rename-tab $current_dir >/dev/null 2>&1
    end
end