# run fastfetch when logging in
fastfetch

# custom command to abbreviate rsync file moving 
movefiles() {
    # less than 2 arguments: display usage help
    if [ "$#" -lt 2 ]; then
        echo "Usage: movefiles <source1> [source2 ...] <destination>"
        return 1
    fi

    # Extract the last argument as the destination
    eval DEST=\$\{"$#"\}

    # Pass all arguments to rsync
    rsync -ahP --remove-source-files "$@"

    # Clean up empty source directories after files are transferred
    for var in "${@:1:$#-1}"; do
        if [ -d "$var" ]; then
            find "$var" -type d -empty -delete 2>/dev/null
        fi
    done
}
