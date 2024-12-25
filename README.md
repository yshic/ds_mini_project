# smart_home

A new Flutter project.

## Prerequisite

1. **Flutter SDK**: Install the Flutter SDK from the [official Flutter website](https://flutter.dev/docs/get-started/install).
2. **Android Studio**: Install Android Studio, which includes the Android SDK and an Android emulator.
3. **Android Device**: An Android device with Developer Options and USB Debugging enabled.

## Steps to Set Up

1. **Install Flutter SDK**:
   - Download the Flutter SDK from the [official Flutter website](https://flutter.dev/docs/get-started/install).
   - Extract the downloaded file and add the Flutter `bin` directory to your system's PATH.

2. **Install Android Studio**:
   - Download and install Android Studio from the [official website](https://developer.android.com/studio).
   - During installation, ensure that the Android SDK, Android SDK Platform-Tools, and Android SDK Build-Tools are installed.
   - Open Android Studio and go to `File > Settings > Plugins`. Search for and install the Flutter and Dart plugins.

3. **Set Up an Android Device**:
   - Enable Developer Options on your Android device. Go to `Settings > About phone` and tap `Build number` seven times.
   - Enable USB Debugging. Go to `Settings > Developer options` and enable `USB debugging`.
   - Connect your Android device to your computer via USB.

4. **Verify Flutter Installation**:
   - Open a terminal or command prompt.
   - Run `flutter doctor` to verify that Flutter is installed correctly and to check for any missing dependencies. Follow the instructions provided by `flutter doctor` to resolve any issues.

5. **Run the Flutter Project**:
   - Open your Flutter project in your preferred IDE (e.g., Android Studio or Visual Studio Code).
   - Ensure that your Android device is connected and recognized by running `flutter devices` in the terminal.
   - Run the project using the IDE's run button or by executing `flutter run` in the terminal.