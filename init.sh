#!/bin/bash
git lfs fetch --all

mkdir tempdl
cd tempdl

wget --output-document gs-logger.zip https://gitlab.com/godot-stuff/gs-logger/-/archive/master/gs-logger-master.zip
wget --output-document shaker.zip https://github.com/Eneskp3441/Shaker/archive/refs/heads/main.zip
wget --output-document rhythm-notifier.zip https://github.com/michaelgundlach/rhythm_notifier/archive/refs/heads/main.zip
wget --output-document gut.zip https://github.com/bitwes/Gut/archive/refs/tags/v9.7.1.zip
wget --output-document beehave.zip https://github.com/bitbrain/beehave/archive/refs/tags/v2.9.3.zip
wget --output-document event_audio.zip https://github.com/bbbscarter/event-audio-godot/archive/refs/heads/main.zip

unzip gs-logger.zip -d gs-logger
unzip shaker.zip -d shaker
unzip rhythm-notifier.zip -d rhythm-notifier
unzip gut.zip -d gut
unzip beehave.zip -d beehave
unzip event_audio.zip -d event_audio

cd ..

if [ -d "addons" ]; then
  rm -rf addons
fi
mkdir addons

cp -r tempdl/gs-logger/gs-logger-master/addons/gs_logger ./addons/gs_logger
cp -r tempdl/shaker/Shaker-main/addons/shaker ./addons/shaker
cp -r tempdl/rhythm-notifier/rhythm_notifier-main/addons/rhythm_notifier ./addons/rhythm_notifier
cp -r tempdl/gut/Gut-9.7.1/addons/gut ./addons/gut
cp -r tempdl/beehave/beehave-2.9.3/addons/beehave ./addons/beehave
cp -r tempdl/event_audio/event-audio-godot-main/addons/event_audio ./addons/event_audio

rm -rf tempdl
