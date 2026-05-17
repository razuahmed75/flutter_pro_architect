# Pro Architect Playroom Example App

This folder contains a fully working, premium-designed Flutter workbench application designed to showcase and interactively test **every single public API** of the `flutter_pro_architect` package.

Instead of outputting boring text to terminal streams or simple print statements, this example provides a gorgeous, interactive GUI that lets you experiment with scaffolding and templates in real time!

---

## 🚀 How to Run the Example

### Prerequisites
Make sure you have the [Flutter SDK installed](https://docs.flutter.dev/get-started/install) and a device/simulator connected.

### Steps
1. Navigate to the `example` directory:
   ```bash
   cd example
   ```
2. Get the packages and resolve dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   - **Android:**
     ```bash
     flutter run -d android
     ```
   - **iOS:**
     ```bash
     flutter run -d ios
     ```
   - **macOS / Windows / Linux (Desktop):**
     ```bash
     flutter run -d macos # or windows / linux
     ```
   - **Web:**
     ```bash
     flutter run -d chrome
     ```

---

## 🛠️ Public APIs Demonstrated

This workbench application is a complete sandbox showing all parts of the package:

1. **`toSnakeCase(String input)`**
   - *Tab:* **Names**
   - *Description:* Demonstrates how raw names are normalized to standard directory & file names (e.g. `UserAuth` -> `user_auth`).

2. **`toPascalCase(String input)`**
   - *Tab:* **Names**
   - *Description:* Demonstrates how raw names are translated into standard class/widget name formats (e.g. `user_profile` -> `UserProfile`).

3. **`Templates` Static Generators**
   - *Tab:* **Templates**
   - *Description:* Displays live rendering of all 18+ Clean Architecture & BLoC boilerplate files based on your input name. You can copy the code with a single tap!

4. **`FeatureGenerator` & `GenerationSummary`**
   - *Tab:* **Generator**
   - *Description:* Safely instantiates `FeatureGenerator` programmatically and generates the files within a sandbox temp workspace (`Directory.systemTemp`). You can browse the files and inspect code in the **Generated File Explorer**!

5. **`FlutterProArchitectCli`**
   - *Tab:* **CLI Runner**
   - *Description:* Simulates a terminal command execution of `flutter_pro_architect create_bloc_<feature>` with custom command line arguments. Returns real-time terminal stdout stream logs and exit codes.

---

## 💡 Safe Sandboxing on Mobile Devices
Because iOS and Android devices run in sandboxed environments with read-only root directories, running filesystem code relative to `/` would throw permissions errors. 

To solve this, this playroom dynamically sets `Directory.current` to a safe, writable system temp directory (`Directory.systemTemp`), writes a mock `pubspec.yaml` to it, and runs the generator perfectly on iOS/Android simulators without any issues!
