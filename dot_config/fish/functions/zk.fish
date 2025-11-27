function zk --description "Kill all detached Zellij sessions"
    set -l detached_sessions (zellij list-sessions --no-formatting 2>/dev/null | grep "EXITED" | awk '{print $1}')

    if test -z "$detached_sessions"
        echo "No detached sessions found"
        return 0
    end

    set -l count 0
    for session in $detached_sessions
        zellij delete-session $session 2>/dev/null
        and set count (math $count + 1)
    end

    echo "Deleted $count detached session(s)"
end
