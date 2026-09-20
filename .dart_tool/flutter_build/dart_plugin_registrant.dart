//
// Generated file. Do not edit.
// This file is generated from template in file `flutter_tools/lib/src/flutter_plugins.dart`.
//

// @dart = 3.12

import 'dart:io'; // flutter_ignore: dart_io_import.
import 'package:android_file_picker/android_file_picker.dart' as android_file_picker;
import 'package:geocoding_android/geocoding_android.dart' as geocoding_android;
import 'package:geolocator_android/geolocator_android.dart' as geolocator_android;
import 'package:image_picker_android/image_picker_android.dart' as image_picker_android;
import 'package:file_picker_darwin/file_picker_darwin.dart' as file_picker_darwin;
import 'package:geocoding_darwin/geocoding_darwin.dart' as geocoding_darwin;
import 'package:geolocator_apple/geolocator_apple.dart' as geolocator_apple;
import 'package:image_picker_ios/image_picker_ios.dart' as image_picker_ios;
import 'package:file_picker_linux/file_picker_linux.dart' as file_picker_linux;
import 'package:file_selector_linux/file_selector_linux.dart' as file_selector_linux;
import 'package:geolocator_linux/geolocator_linux.dart' as geolocator_linux;
import 'package:image_picker_linux/image_picker_linux.dart' as image_picker_linux;
import 'package:package_info_plus/package_info_plus.dart' as package_info_plus;
import 'package:file_picker_darwin/file_picker_darwin.dart' as file_picker_darwin;
import 'package:file_selector_macos/file_selector_macos.dart' as file_selector_macos;
import 'package:geocoding_darwin/geocoding_darwin.dart' as geocoding_darwin;
import 'package:geolocator_apple/geolocator_apple.dart' as geolocator_apple;
import 'package:image_picker_macos/image_picker_macos.dart' as image_picker_macos;
import 'package:file_selector_windows/file_selector_windows.dart' as file_selector_windows;
import 'package:image_picker_windows/image_picker_windows.dart' as image_picker_windows;
import 'package:package_info_plus/package_info_plus.dart' as package_info_plus;
import 'package:speech_to_text_windows/speech_to_text_windows.dart' as speech_to_text_windows;
import 'package:windows_file_picker/windows_file_picker.dart' as windows_file_picker;

@pragma('vm:entry-point')
class _PluginRegistrant {

  @pragma('vm:entry-point')
  static void register() {
    if (Platform.isAndroid) {
      try {
        android_file_picker.FilePickerAndroid.registerWith();
      } catch (err) {
        print(
          '`android_file_picker` threw an error: $err. '
          'The app may not function as expected until you remove this plugin from pubspec.yaml'
        );
      }

      try {
        geocoding_android.GeocodingAndroidFactory.registerWith();
      } catch (err) {
        print(
          '`geocoding_android` threw an error: $err. '
          'The app may not function as expected until you remove this plugin from pubspec.yaml'
        );
      }

      try {
        geolocator_android.GeolocatorAndroid.registerWith();
      } catch (err) {
        print(
          '`geolocator_android` threw an error: $err. '
          'The app may not function as expected until you remove this plugin from pubspec.yaml'
        );
      }

      try {
        image_picker_android.ImagePickerAndroid.registerWith();
      } catch (err) {
        print(
          '`image_picker_android` threw an error: $err. '
          'The app may not function as expected until you remove this plugin from pubspec.yaml'
        );
      }

    } else if (Platform.isIOS) {
      try {
        file_picker_darwin.FilePickerDarwin.registerWith();
      } catch (err) {
        print(
          '`file_picker_darwin` threw an error: $err. '
          'The app may not function as expected until you remove this plugin from pubspec.yaml'
        );
      }

      try {
        geocoding_darwin.GeocodingDarwinFactory.registerWith();
      } catch (err) {
        print(
          '`geocoding_darwin` threw an error: $err. '
          'The app may not function as expected until you remove this plugin from pubspec.yaml'
        );
      }

      try {
        geolocator_apple.GeolocatorApple.registerWith();
      } catch (err) {
        print(
          '`geolocator_apple` threw an error: $err. '
          'The app may not function as expected until you remove this plugin from pubspec.yaml'
        );
      }

      try {
        image_picker_ios.ImagePickerIOS.registerWith();
      } catch (err) {
        print(
          '`image_picker_ios` threw an error: $err. '
          'The app may not function as expected until you remove this plugin from pubspec.yaml'
        );
      }

    } else if (Platform.isLinux) {
      try {
        file_picker_linux.FilePickerLinux.registerWith();
      } catch (err) {
        print(
          '`file_picker_linux` threw an error: $err. '
          'The app may not function as expected until you remove this plugin from pubspec.yaml'
        );
      }

      try {
        file_selector_linux.FileSelectorLinux.registerWith();
      } catch (err) {
        print(
          '`file_selector_linux` threw an error: $err. '
          'The app may not function as expected until you remove this plugin from pubspec.yaml'
        );
      }

      try {
        geolocator_linux.GeolocatorLinux.registerWith();
      } catch (err) {
        print(
          '`geolocator_linux` threw an error: $err. '
          'The app may not function as expected until you remove this plugin from pubspec.yaml'
        );
      }

      try {
        image_picker_linux.ImagePickerLinux.registerWith();
      } catch (err) {
        print(
          '`image_picker_linux` threw an error: $err. '
          'The app may not function as expected until you remove this plugin from pubspec.yaml'
        );
      }

      try {
        package_info_plus.PackageInfoPlusLinuxPlugin.registerWith();
      } catch (err) {
        print(
          '`package_info_plus` threw an error: $err. '
          'The app may not function as expected until you remove this plugin from pubspec.yaml'
        );
      }

    } else if (Platform.isMacOS) {
      try {
        file_picker_darwin.FilePickerDarwin.registerWith();
      } catch (err) {
        print(
          '`file_picker_darwin` threw an error: $err. '
          'The app may not function as expected until you remove this plugin from pubspec.yaml'
        );
      }

      try {
        file_selector_macos.FileSelectorMacOS.registerWith();
      } catch (err) {
        print(
          '`file_selector_macos` threw an error: $err. '
          'The app may not function as expected until you remove this plugin from pubspec.yaml'
        );
      }

      try {
        geocoding_darwin.GeocodingDarwinFactory.registerWith();
      } catch (err) {
        print(
          '`geocoding_darwin` threw an error: $err. '
          'The app may not function as expected until you remove this plugin from pubspec.yaml'
        );
      }

      try {
        geolocator_apple.GeolocatorApple.registerWith();
      } catch (err) {
        print(
          '`geolocator_apple` threw an error: $err. '
          'The app may not function as expected until you remove this plugin from pubspec.yaml'
        );
      }

      try {
        image_picker_macos.ImagePickerMacOS.registerWith();
      } catch (err) {
        print(
          '`image_picker_macos` threw an error: $err. '
          'The app may not function as expected until you remove this plugin from pubspec.yaml'
        );
      }

    } else if (Platform.isWindows) {
      try {
        file_selector_windows.FileSelectorWindows.registerWith();
      } catch (err) {
        print(
          '`file_selector_windows` threw an error: $err. '
          'The app may not function as expected until you remove this plugin from pubspec.yaml'
        );
      }

      try {
        image_picker_windows.ImagePickerWindows.registerWith();
      } catch (err) {
        print(
          '`image_picker_windows` threw an error: $err. '
          'The app may not function as expected until you remove this plugin from pubspec.yaml'
        );
      }

      try {
        package_info_plus.PackageInfoPlusWindowsPlugin.registerWith();
      } catch (err) {
        print(
          '`package_info_plus` threw an error: $err. '
          'The app may not function as expected until you remove this plugin from pubspec.yaml'
        );
      }

      try {
        speech_to_text_windows.SpeechToTextWindows.registerWith();
      } catch (err) {
        print(
          '`speech_to_text_windows` threw an error: $err. '
          'The app may not function as expected until you remove this plugin from pubspec.yaml'
        );
      }

      try {
        windows_file_picker.FilePickerWindows.registerWith();
      } catch (err) {
        print(
          '`windows_file_picker` threw an error: $err. '
          'The app may not function as expected until you remove this plugin from pubspec.yaml'
        );
      }

    }
  }
}
