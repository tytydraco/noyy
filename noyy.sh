#!/usr/bin/env bash

CONFIG="$HOME/.config/noyy/paths"
EVENTS="modify,create,delete,move"
TIMEOUT=60

bail() {
    [[ -z "$QUIET" ]] && echo -e "\e[31m ! $*\e[0m"
    exit 1
}

warn() {
    [[ -z "$QUIET" ]] && echo -e "\e[93m - $*\e[0m"
}

log() {
    [[ -z "$QUIET" ]] && echo -e "\e[32m + $*\e[0m"
}

usage() {
	echo "Automatically commit and push git repos upon inode changes
Usage: $0 [-h] [-p PATH][-d DELAY] [-e EVENTS] [-q]
  -h				Show this screen
  -p PATH			Specify a paths file (default: $CONFIG)
  -d DELAY          Minimum time to sleep after each push (default: $TIMEOUT)
  -e EVENTS         Comma-separated inotify events to listen for (default: $EVENTS)
  -q                Quiet mode; no logs"
}

assert_dependencies() {
	for dep in git inotifywait
	do
		if ! command -v "$dep" &>/dev/null
		then
	  		echo "Dependency inaccessible: $dep"
	  		exit 1
		fi
	done
}

parse_options() {
	while getopts ":hp:d:e:q" opt
	do
		case "$opt" in
        h)
			usage
			exit 0
			;;
		d)
			TIMEOUT="$OPTARG"
			;;
		p)
			CONFIG="$OPTARG"
			;;
		e)
            EVENTS="$OPTARG"
            ;;
        q)
            QUIET=true
            ;;
		*)
			usage
			exit 1
			;;
		esac
	done
}

watch() {
    local path="$1"

    inotifywait \
        -e "$EVENTS" \
        -r \
        -q \
        -m \
        --format "%f %e" \
        "$path" | while read -r file action
    do
        cd "$path" || bail "Path not accessible"
        [[ ! -d ".git" ]] && bail "No .git found"

        git add .
        git commit -sam "$file: $action"
        git push || bail "Failed to push"

        sleep "$TIMEOUT"
    done
}

assert_config() {
    [[ ! -f "$CONFIG" ]] && bail "No config at $CONFIG"
}

assert_paths() {
    [[ -z "$PATHS" ]] && bail "PATHS variable is unset"
}

init() {
    for dir in "${PATHS[@]}"
    do
        if [[ ! -d "$dir" ]]
        then
            warn "Not found: $dir"
            continue
        fi

        log "Watching: $dir"
        watch "$dir" &
    done

    wait
}

parse_options "$@"
assert_dependencies
assert_config
source "$CONFIG"
assert_paths
init