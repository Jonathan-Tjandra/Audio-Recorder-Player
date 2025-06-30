# Audio Recorder & Player App

A feature-rich audio recording and playback application for iOS, built with modern Apple technologies.

This project is a comprehensive audio utility that demonstrates core and advanced audio handling in an iOS environment. The interface is built primarily with **SwiftUI** for a modern, declarative UI, while all audio processing is powered by the robust **AVFoundation** framework.

## Features

### Core Functionality
- **Audio Recording:** Record high-quality audio with the ability to pause and resume sessions.
- **Audio Playback:** A full-featured player for all recorded and included audio files.
- **File Management:**
    - **Rename:** Easily rename your recordings.
    - **Reorder:** Change the order of recordings in your list.
    - **Delete:** Permanently delete unwanted recordings with a confirmation step.
    - **Duplicate:** Make a copy of an existing recording.

### Advanced Playback
- **Playback Speed:** Adjust the playback speed from slower to faster rates.
- **Auto-Repeat:** Set a single audio file to loop continuously.
- **Auto-Continue:** Automatically play the next track in the list once the current one finishes.

## Technology Stack

- **SwiftUI:** The user interface is built almost entirely with SwiftUI, ensuring a modern and responsive design.
- **AVFoundation:** Leveraged for all core audio functionalities, including recording (`AVAudioRecorder`) and playback (`AVAudioPlayer`).
- **UIKit:** Used where necessary for interoperability or specific lifecycle components.
- **Language:** **Swift** (Latest Version)

## Getting Started

Follow these instructions to get the project running on your local machine for development and testing purposes.

### Prerequisites
- macOS with the latest version of Xcode installed.
- An Apple Developer account is required for testing on a physical iOS device.

### Build Instructions

⚠️ **Important:** This project is configured to run without a `Main.storyboard`. If you encounter a build error upon first opening the project, please follow these steps exactly:

1.  In the Project Navigator, find and delete the `Main.storyboard` file (if it exists).
2.  Find and delete the `LaunchScreen.storyboard` file (if it exists).
3.  Go to your Project's Target settings and select the **Info** tab.
4.  Find and delete the key:
    - `` `Main storyboard file base name` ``
5.  Expand the `Application Scene Manifest` section and navigate through the hierarchy:
    - `Scene Configuration` -> `Application Session Role` -> `Item 0 (Default Configuration)`
6.  Within `Item 0`, find and delete the key:
    - `` `Storyboard Name` ``

After performing these steps, clean the build folder (**Product -> Clean Build Folder**) and run the build again. It should now succeed.

### Testing Configuration

To run the app for testing without the default, bundled audio files:

1.  Open the `HearView.swift` file.
2.  Comment out or remove the "Song Section" (around line 57) to hide the default audio from the list.