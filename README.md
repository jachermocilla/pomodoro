# Pomodoro Timer

I just want a simple Pomodoro timer for my Ubuntu box so here it is. 

`gnome-pomodoro` takes up too much desktop space and is too 'complex' for my needs :)

## Use
Download the latest release from `https://github.com/jachermocilla/pomodoro/releases/latest/`
and install it with `sudo apt install ./pomodoro-timer_<version>_all.deb`.

Search for the app in the app list after.

Settings and the window position are saved in `~/.config/pomodoro-timer/config.json`.

Upgrading from 1.0.7 or earlier: older packages copied a shortcut onto each user's
Desktop. Newer packages don't, so you can delete `~/Desktop/pomodoro-timer.desktop` by hand.

## Run from source
```
sudo apt install python3-tk
python3 pomodoro.py
```

## Release
1. Commit your changes and tag the release: `git tag vX.Y.Z && git push --tags`
2. Build the package: `./build-deb.sh` (the version is taken from the latest tag)
3. Upload `debian_package/pomodoro-timer_X.Y.Z_all.deb` to a new GitHub release for the tag.
