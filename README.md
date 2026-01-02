# 🤖 AI Chat - Multi-Model AI Assistant

<div align="center">

![App Demo](assets/screenshots/app_demo.png)

**A beautiful, feature-rich AI chat application built with Flutter, supporting multiple AI models with a stunning bronze & brown themed UI.**

[![Flutter](https://img.shields.io/badge/Flutter-3.4.1+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.4.1+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)

</div>

---

## ✨ Features

### 🎯 Core Features
- **Multi-Model AI Support** - Switch between 7 different AI models on the fly
- **Real-time Streaming** - Live streaming responses from AI models
- **Chat History** - Persistent chat storage with Hive database
- **Image Support** - Send images along with your messages
- **Profile Management** - Customize your name and profile picture
- **Dark/Light Mode** - Elegant glass morphism design in both themes
- **Firebase Authentication** - Google Sign-In integration

### 🚀 Supported AI Models
1. **DeepSeek R1T2 Chimera** - `tngtech/deepseek-r1t2-chimera:free`
2. **NVIDIA Nemotron 3** - `nvidia/nemotron-3-nano-30b-a3b:free`
3. **Google Gemma 3 27B** - `google/gemma-3-27b-it:free`
4. **Google Gemini 2.0 Flash** - `google/gemini-2.0-flash-exp:free`
5. **Mistral Small 3.1** - `mistralai/mistral-small-3.1-24b-instruct:free`
6. **Google Gemma 3 12B** - `google/gemma-3-12b-it:free`
7. **Qwen 2.5 VL** - `qwen/qwen-2.5-vl-7b-instruct:free`

### 🎨 Design Highlights
- **Glass Morphism UI** - Modern frosted glass effects with BackdropFilter
- **Bronze & Brown Theme** - Elegant gradient color scheme
- **Custom Animations** - Smooth fade and slide animations
- **Google Fonts** - Professional typography with Space Grotesk
- **Responsive Design** - Adaptive layouts for different screen sizes

---

## 📸 Screenshots

<div align="center">

### App Demo
<img src="assets/screenshots/app_demo.png" width="700" alt="App Demo">

---

### Application Screens

<table>
  <tr>
    <td align="center">
      <img src="assets/screenshots/screenshot_1.png" width="250" alt="Dashboard"><br>
      <b>Dashboard</b>
    </td>
    <td align="center">
      <img src="assets/screenshots/screenshot_2.png" width="250" alt="Model Selection"><br>
      <b>Model Selection</b>
    </td>
    <td align="center">
      <img src="assets/screenshots/screenshot_3.png" width="250" alt="Chat Screen"><br>
      <b>Chat Interface</b>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="assets/screenshots/screenshot_4.png" width="250" alt="Profile Screen"><br>
      <b>Profile Screen</b>
    </td>
    <td align="center">
      <img src="assets/screenshots/screenshot_5.png" width="250" alt="Settings"><br>
      <b>Settings</b>
    </td>
    <td align="center">
      <!-- Empty cell for symmetry -->
    </td>
  </tr>
</table>

</div>

---

## 🛠️ Tech Stack

### Frontend
- **Flutter** - Cross-platform UI framework
- **Provider** - State management solution
- **Google Fonts** - Custom typography

### Backend & APIs
- **OpenRouter API** - AI model integration
- **Firebase Auth** - Google Sign-In authentication
- **HTTP** - API communication with streaming support

### Database & Storage
- **Hive** - Lightweight NoSQL database
- **Path Provider** - Local file system access
- **Image Picker** - Gallery/camera integration

### UI/UX Libraries
- **Flutter Markdown** - Rich text rendering
- **Flutter SpinKit** - Loading animations
- **Dart UI** - Glass morphism effects (BackdropFilter)

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.4.1 or higher)
- Dart SDK (3.4.1 or higher)
- iOS/Android development environment
- OpenRouter API key
- Firebase project (for authentication)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Priyanshu0520/AI-Chat-With-Several-Ai-Modal.git
   cd AI-Chat-With-Several-Ai-Modal
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up environment variables**
   
   Create a `.env` file in the root directory:
   ```env
   OPENROUTER_API_KEY=your_openrouter_api_key_here
   ```

4. **Configure Firebase**
   - Add your `google-services.json` (Android) to `android/app/`
   - Add your `GoogleService-Info.plist` (iOS) to `ios/Runner/`

5. **Generate Hive adapters**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

6. **Run the app**
   ```bash
   flutter run
   ```

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── apis/
│   └── api_service.dart         # API configuration
├── constants/
│   └── constants.dart           # App constants
├── hive/
│   ├── boxes.dart              # Hive box getters
│   ├── chat_history.dart       # Chat history model
│   ├── settings.dart           # Settings model
│   └── user_model.dart         # User profile model
├── models/
│   └── message.dart            # Message model
├── providers/
│   ├── chat_provider.dart      # Chat state management
│   └── settings_provider.dart  # Settings state management
├── screens/
│   ├── chat_history_screen.dart
│   ├── chat_screen.dart
│   ├── dash_board_screen.dart
│   └── profile_screen.dart
├── themes/                     # Theme configurations
├── utility/
│   └── animated_dialog.dart    # Custom dialogs
└── widgets/                    # Reusable widgets
    ├── bottom_chat_field.dart
    ├── build_display_image.dart
    ├── chat_history_widget.dart
    └── settings_tile.dart
```

---

## 🎨 Color Palette

The app uses a sophisticated bronze & brown color scheme:

```dart
Primary Color:   #AE8048 (RGB: 174, 128, 72)
Secondary Color: #A85D3A (RGB: 168, 93, 58)
Accent Color:    #C69963 (RGB: 198, 153, 99)
```

---

## 🔧 Configuration

### API Setup
The app uses OpenRouter API for AI model access. To set up:

1. Get your API key from [OpenRouter](https://openrouter.ai/)
2. Add it to your `.env` file
3. The API service is configured in `lib/apis/api_service.dart`

### Database
Hive is used for local data persistence:
- **Chat History** - Stores all conversations
- **User Profile** - Name and profile image
- **Settings** - User preferences

---

## 📝 Features in Detail

### 🗨️ Chat Management
- Start new conversations with any AI model
- View and continue previous chats from history
- Delete individual chat sessions
- Persistent message storage

### 🖼️ Image Support
- Pick images from gallery
- Send images with text messages
- Preview images before sending

### 👤 Profile Customization
- Upload custom profile picture
- Edit username with inline editing
- Changes sync across all screens

### ⚙️ Settings
- Toggle AI voice responses
- Switch between dark/light themes
- Model selection with visual feedback

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Developer

**Priyanshu**
- GitHub: [@Priyanshu0520](https://github.com/Priyanshu0520)
- Email: priyanshu052002@gmail.com

---

## 🙏 Acknowledgments

- [OpenRouter](https://openrouter.ai/) for providing AI model access
- [Flutter](https://flutter.dev/) team for the amazing framework
- [Hive](https://docs.hivedb.dev/) for efficient local storage
- All the AI model providers (NVIDIA, Google, Mistral, etc.)

---

<div align="center">

### ⭐ Star this repository if you find it helpful!

Made with ❤️ using Flutter

</div>

