# 
Luti is a Flutter application designed for exploring and booking vacation homes. The app integrates Firebase for backend services, offering features such as location details, booking management, and more.

## Table of Contents

- [Features](#features)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Firebase Setup](#firebase-setup)
- [Running the App](#running-the-app)
- [License](#license)
- [Contributing](#contributing)
- [Contact](#contact)

## Features

- Explore vacation homes with detailed information and images.
- Book homes and manage your bookings.
- Integrated Firebase for backend services.
- Clean and user-friendly interface.
- Responsive design for both Android and iOS devices.

## Getting Started

Follow these steps to get the project up and running on your local machine.

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Firebase Account](https://firebase.google.com/)
- An Android or iOS device/emulator

### Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/your-username/Luti.git
   cd Luti
   ```

2. **Install Flutter dependencies:**

   ```bash
   flutter pub get
   ```

### Firebase Setup

1. **Create a Firebase Project:**

   - Go to the [Firebase Console](https://console.firebase.google.com/).
   - Click on "Add project" and follow the prompts to create a new Firebase project.

2. **Add Android App:**

   - In the Firebase console, click on the Android icon to add an Android app.
   - Register your app with the package name `com.example.luti`.
   - Download the `google-services.json` file and place it in the `android/app` directory.

3. **Add iOS App:**

   - In the Firebase console, click on the iOS icon to add an iOS app.
   - Register your app with the iOS bundle ID.
   - Download the `GoogleService-Info.plist` file and place it in the `ios/Runner` directory.

4. **Configure Android Project:**

   - Add the `google-services.json` file to `android/app`.
   - Modify `android/build.gradle`:

     ```groovy
     buildscript {
         dependencies {
             classpath 'com.google.gms:google-services:4.3.10'
         }
     }
     ```

   - Modify `android/app/build.gradle`:

     ```groovy
     apply plugin: 'com.android.application'
     apply plugin: 'com.google.gms.google-services'

     dependencies {
         implementation platform('com.google.firebase:firebase-bom:31.1.1')
         implementation 'com.google.firebase:firebase-analytics'
     }
     ```

5. **Configure iOS Project:**

   - Add the `GoogleService-Info.plist` file to `ios/Runner`.
   - Modify `ios/Runner/Info.plist`:

     ```xml
     <key>CFBundleURLTypes</key>
     <array>
         <dict>
             <key>CFBundleTypeRole</key>
             <string>Editor</string>
             <key>CFBundleURLSchemes</key>
             <array>
                 <string>YOUR_REVERSED_CLIENT_ID</string>
             </array>
         </dict>
     </array>
     ```

   - Modify `ios/Podfile`:

     ```ruby
     platform :ios, '10.0'

     target 'Runner' do
       use_frameworks!
       use_modular_headers!

       pod 'Firebase/Core'
       pod 'Firebase/Analytics'

       flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
     end

     post_install do |installer|
       installer.pods_project.targets.each do |target|
         target.build_configurations.each do |config|
           config.build_settings['ENABLE_BITCODE'] = 'NO'
         end
       end
     end
     ```

   - Run `pod install` in the `ios` directory:

     ```bash
     cd ios
     pod install
     cd ..
     ```

## Running the App

1. **Run on Android:**

   ```bash
   flutter run
   ```

2. **Run on iOS:**

   ```bash
   flutter run
   ```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project.
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`).
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the Branch (`git push origin feature/AmazingFeature`).
5. Open a Pull Request.

## Contact

1.  Azeez Damilare Gbenga - [d.azeez@alustudent.com](mailto:d.azeez@alustudent.com)
2.  Marvelous Nelson - [m.nelson@alustudent.com](mailto:m.nelson@alustudent.com)
3.  Nana Koramah Abeasi - [n.abeasi@alustudent.com](mailto:n.abeasi@alustudent.com)
4.  Jeremiah Agbaje - [j.agbaje@alustudent.com](mailto:j.agbaje@alustudent.com)
5.  Lenine Ngenzi - [l.ngenzi@alustudent.com](mailto:l.ngenzi@alustudent.com)

Project Link: [https://github.com/dazeez1/Luti.git](https://github.com/dazeez1/Luti.git)

## Link to the video demonstration of the project implementation

[Click here]()

## Link to the video demonstration of the project Authentication, App/Business Logic, and Backend.

[Click here]()
