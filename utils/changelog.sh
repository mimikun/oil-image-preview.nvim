#!/bin/bash

GIT_LOG=$(git log "origin/master..HEAD" --pretty=format:"%B")
HOSTNAME=$(hostname)

changelog() {
    echo "## run"
    echo ""
    echo "> Run commit"
    echo ""
    echo '```bash'
    echo 'git commit -m "WIP:--------------------------------------------------------------------------" --allow-empty --no-verify'
    echo "$GIT_LOG" |
        # Remove blank line
        sed -e '/^$/d' |
        # Remove DROP commit msg
        sed -e 's/.*DROP.*//g' |
        # Remove blank line
        sed -e '/^$/d' |
        sed -e 's/^/git commit -m "WIP:/g' |
        sed -e 's/$/" --allow-empty --no-verify/g'
    echo 'git commit -m "WIP:--------------------------------------------------------------------------" --allow-empty --no-verify'
    echo '```'
}

if [[ "$HOSTNAME" = "TanakaPC" ]]; then
    changelog >>"maskfile.md"
fi
