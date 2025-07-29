# SmartWindow App

## First version with LED control

### HC-05

Connect the HC-05 module to Arduino:

## Flutter Application
Make sure to connect the HC-O5 module in the device settings first. In my case, I had to enter 1234 as a pin code.

Add Flutter Bluetooth module in pubspec.yaml:
```
dependencies:
  flutter_bluetooth_serial: ^0.4.0
```
Run ```flutter pub get```

### Permissions
Make sure add permissions to your Android manifest (android/app/src/main/AndroidManifest.xml):

```
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
```

Run app with:
```flutter run```

### Errors
I am not sure if this is due to my old Android device, but if you have build errors, it's probably because some Gradle version changes

#### Step 1:
Add a namespace line inside the android block in the Bluetooth plugin file (~/.pub-cache/hosted/pub.dev/flutter_bluetooth_serial-0.4.0/android/build.gradle):

```
android {
    namespace "io.github.edufolly.flutterbluetoothserial"
    compileSdkVersion 34

    defaultConfig {
        minSdkVersion 19
    }
}
```

#### Step 2:
Update the NDK version in the projects Gradle file (android/app/build.gradle.kts):

```
android {
    ndkVersion "27.0.12077973"
}
```

#### Step 3:
Rerun with ```flutter run```

