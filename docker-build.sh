#!/bin/bash

DIR="logs"
# if dir does not exists create it
if
  [ ! -d "$DIR" ]
then
  mkdir -p "$DIR" && chmod -R 755 "$DIR"
fi

URL=$"http://localhost:8890"
process_id=$!
DATE=$(date +"%Y-%m-%dT%H:%M:%S")

# output all console info to file
exec > >(tee -i logs/"$DATE"-image-build.log)
exec 2>&1

docker stop vulcanored_app
echo "container stopped"
wait $process_id

docker rm vulcanored_app
wait $process_id
echo "container removed"

docker rmi alpine
wait $process_id

docker rmi vulcanored
wait $process_id
echo "alpine images removed"

docker build -t vulcanored:latest -f Dockerfile .
echo "new alpine image build"
wait $process_id

docker run -dt --name vulcanored_app -p 8890:80 vulcanored:latest
echo "running new container now"
wait $process_id

echo "Exit status: $?"
echo "all processes finished"

[[ -x $BROWSER ]] && exec "$BROWSER" "$URL"
path=$(which xdg-open || which gnome-open) && exec "$path" "$URL"
if open -Ra "Google Chrome" --args --incognito "$URL"; then
  echo "opening application now"
  open -na "Google Chrome" --args --incognito "$URL"
else
  echo "no system browser installed"
fi

# exit script after 10 seconds
sleep 10
kill -15 $PPID
