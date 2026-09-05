# run fastfetch when logging in
fastfetch

# custom command to abbreviate rsync file moving using screen for background prrocessing
movefiles() {
    # Check if the user passed --status
    if [ "$1" == "--status" ]; then
        if screen -list | grep -q "movefiles_job"; then
            echo "--- Active File Transfer Jobs Found ---"
            screen -list | grep "movefiles_job"
            echo ""
            echo "To view live progress, run: screen -r movefiles_job"
            echo "To detach again without killing it, press: Ctrl+A then D"
        else
            echo "No active file transfers running in the background."
        fi
        return 0
    fi

    if [ "$#" -lt 2 ]; then
        echo "Usage:"
        echo "  movefiles <source1> [source2 ...] <destination>   (Runs in background via screen)"
        echo "  movefiles --status                                (Checks running transfers)"
        return 1
    fi

    # Create a unique timestamped screen session name
    SESSION_NAME="movefiles_job"

    # Save command string safely handling paths with spaces
    echo "Starting transfer in background screen session: $SESSION_NAME..."

    # Launch inside a detached screen session
    screen -dmS "$SESSION_NAME" bash -c '
        rsync -ahP --remove-source-files "$@"
        for var in "${@:1:$#-1}"; do
            if [ -d "$var" ]; then
                find "$var" -type d -empty -delete 2>/dev/null
            fi
        done
        echo ""
        echo "Done! Press Enter to exit."
        read
    ' _ "$@"

    echo "Transfer started in a background screen session"
    echo "Run 'movefiles --status' to check status, or 'screen -r $SESSION_NAME' to monitor real-time progress."
}

#movefiles() {
#    # less than 2 arguments: display usage help
#    if [ "$#" -lt 2 ]; then
#        echo "Usage: movefiles <source1> [source2 ...] <destination>"
#        return 1
#    fi
#
#    # Extract the last argument as the destination
#    eval DEST=\$\{"$#"\}
#
#    # Pass all arguments to rsync
#    rsync -ahP --remove-source-files "$@"
#
#    # Clean up empty source directories after files are transferred
#    for var in "${@:1:$#-1}"; do
#        if [ -d "$var" ]; then
#            find "$var" -type d -empty -delete 2>/dev/null
#        fi
#    done
#}
