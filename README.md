![Caffeguard](docs/banner.png)

# Caffeguard

You leave your Mac on with `caffeinate` so it does not go to sleep. You walk away. Someone
sits down at it.

Caffeguard catches them. It lives in your menu bar as a little shield. When your Mac is
caffeinated and nobody has touched it for a few minutes, Caffeguard starts watching through
your webcam. If someone looks at the camera, it takes their photo, saves it, and turns every
screen bright red.

That's it.

## How to install

1. Download the `.dmg` file from the [latest release](../../releases/latest).
2. Open it and drag Caffeguard into Applications.
3. Open Caffeguard. macOS will say it can't check the app, because it is not signed by a
   paid Apple developer account. Go to **System Settings → Privacy & Security**, scroll
   down, and click **Open Anyway**. You only do this once.
4. Pick the camera you want it to use and allow camera access. iPhone cameras are never
   offered.

## How to use it

1. Start `caffeinate` in Terminal, like you normally would.
2. Walk away.
3. After 5 minutes of nobody touching the Mac, the shield in the menu bar fills in. It is
   watching now.
4. If someone sits down and looks at the screen, they get a red screen and you get their
   photo in `~/Pictures/Caffeguard`.
5. The red screen only goes away with your fingerprint (Touch ID) or your Mac password.
   Until then it keeps watching: if that person runs off and someone else sits down later,
   you get a photo of them too.

Things to know:

- Typing does not turn it off, because an intruder would type too. Stopping `caffeinate`
  turns it off, and so does unchecking **Enabled** in the menu.
- It will catch you too when you come back. Uncheck **Enabled** first, or stop `caffeinate`.
- One person sitting there is one photo. A new photo needs the seat to be empty for 30
  seconds first.
- After you unlock the red screen, it waits another quiet period before it watches again.
- Change the camera or the waiting time in **Settings…** from the menu bar shield.
- The camera is off unless it is watching. It never records video.

## Email alerts

Caffeguard can email you each photo the moment it takes it, so you see who it was even if
they delete the file.

1. Turn on 2-Step Verification for your Google account, then
   [create an app password](https://myaccount.google.com/apppasswords). It is 16 letters.
2. Open **Settings…** from the menu bar shield, turn on **Email me a photo of each
   intrusion**, and type your Gmail address and the app password.
3. Click **Send Test Email** to check it works.

The email goes from your Gmail address to itself. The app password is kept in your Mac's
keychain. Nothing is sent anywhere unless you turn this on.

## Build it yourself

You need macOS 15 or newer and Xcode.

```sh
swift test               # run the tests
scripts/install.sh       # build and install into /Applications
scripts/dmg.sh           # build build/Caffeguard-<version>.dmg
scripts/release.sh       # tag and publish a GitHub release with the DMG
```

The version number lives in `Support/Info.plist`.
