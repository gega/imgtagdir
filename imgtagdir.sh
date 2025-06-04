#!/bin/bash
#
# imgtagdir.sh
#
# Compatible with Aves Libre Gallery tag format (XMP:Subject)
#
# start from cron, incron or start the loop from ~/.profile


### Config area

WATCH_DIR="$HOME/Pictures/Camera/"
TAG_DIR="$HOME/Pictures/Tagged"

###############


INOTIFY_BIN=$(command -v inotifywait)
EXIFTOOL_BIN=$(command -v exiftool)


function get_tags()
{
  local mime=$(file -b --mime-type "$1")
  if [ x"image/jpeg" == x"$mime" ]; then
    "$EXIFTOOL_BIN" -s3 -XMP:Subject "$1" 2>/dev/null | tr ',' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | grep -v '^$'
  fi
}

function process_file()
{
  local img="$1"
  local tags
  tags=$(get_tags "$img") || return

  for tag in $tags;
  do
    mkdir -p "$TAG_DIR/$tag"
    ln -sf "$img" "$TAG_DIR/$tag/$(basename "$img")"
  done
}

function catchup()
{
  newest=$(find "$TAG_DIR" -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -d' ' -f2-)
  find "$WATCH_DIR" -type f -newer "$newest" -exec file --mime-type {} \; | grep "image/jpeg" | cut -d: -f1 | while read -r file; do
    process_file "$file"
  done
}

function watch_loop()
{
  "$INOTIFY_BIN" -m -e close_write --format "%w%f" "$WATCH_DIR" | while read -r file; do
    process_file "$file"
  done
}

function rebuild()
{
  find $WATCH_DIR -type f -exec file --mime-type {}  \; | fgrep image/jpeg | cut -d: -f1 | while read -r file; do
    process_file "$file"
  done
}

function show_help()
{
  cat <<-EOM
	Usage: $0 [command]

	Commands:
	  watch     Watch \$WATCH_DIR for new files and tag them
	  catchup   Process all images newer than the latest in \$TAG_DIR
	  rebuild   Re-process all images in \$WATCH_DIR
	  link      Process one file
	  help      Show this help message

	Make sure 'exiftool' is installed.
EOM
}


case "$1" in
watch)
  catchup
  watch_loop
  ;;
catchup)
  catchup
  ;;
rebuild)
  rebuild
  ;;
link)
  process_file $2
  ;;
help | -h | --help | "")
  show_help
  ;;
*)
  echo "Unknown command: $1" >&2
  show_help
  exit 1
  ;;
esac
