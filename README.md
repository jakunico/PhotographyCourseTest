# Photography Course Test

Demo video: https://share.icloud.com/photos/0tw8W28zErsg8KypCALpQjECg

### Features

- View the video list and select any video to check details.
- Download the video to the device for offline viewing.
- Video list is cached so that you can still use the app while offline.
- In-app media player.
- Support for light and dark appereances.
- Requires iOS 13.1 (or later)

### Tech

- UI built with SwiftUI.
- No external dependencies.

### Missing

The following were not included due to time constraints (6 hours project):

- Refresh video list feature
- Tests

### Notes

- All videos are linked to the same video file in the current json response, that file is huge so testing the download feature might be hard.
- You can use this test video here that is much smaller: `https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8`.
- Once the download is initiated you can use other apps and the download will continue. Do not force-quit the app as this will kill any ongoing download.
- If the OS force-quits the app while the download is taking place (due to memeory outage) the download will still continue in the background.
