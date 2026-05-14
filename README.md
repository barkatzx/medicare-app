# MediCare PLC - Healthcare & Pharmacy App

![MediCare Logo](assets/images/MediCarePLC.png)

MediCare PLC is a premium, modern healthcare and pharmacy application designed for seamless medical shopping. Built with Flutter, it provides an industry-standard experience for accessing essential healthcare products with a focus on performance, security, and aesthetics.

## 🚀 Features

### **Premium Shopping Experience**
*   **Modern Search engine**: Optimized search with debouncing and query sanitization for precise product discovery.
*   **Dynamic Product Feed**: Categorized and trending products with high-fidelity UI and Hero transitions.
*   **Smart Cart Management**: Optimistic UI updates with real-time price and discount calculations.
*   **Optimized Image Loading**: Uses `cached_network_image` for blazing-fast visual performance and reduced data usage.

### **Reliability & Performance**
*   **Background Notifications**: Automated polling system using `Workmanager` to deliver status bar alerts even when the app is closed.
*   **Production-Ready Network Layer**: Managed HTTP client logic designed for high-latency mobile networks (3G/4G).
*   **Global State Management**: Powered by `Riverpod` for a reactive and scalable architecture.

### **Architecture & Safety**
*   **Domain-Driven Design (DDD)**: Clear separation of Concerns (Entities, Repositories, Providers, and Screens).
*   **Global Error Handling**: Integrated error boundaries to capture and handle crashes gracefully.
*   **Production Logging**: Custom logger utility to ensure data privacy and performance in release builds.

## 🛠️ Technology Stack

*   **Framework**: [Flutter](https://flutter.dev/)
*   **State Management**: [Riverpod](https://riverpod.dev/)
*   **Networking**: [HTTP](https://pub.dev/packages/http)
*   **Notifications**: [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
*   **Background Tasks**: [Workmanager](https://pub.dev/packages/workmanager)
*   **UI Assets**: Custom Google Fonts (Outfit), SVGs, and Shimmer effects.

## 📦 Getting Started

### Prerequisites
*   Flutter SDK (3.11.4 or higher)
*   Android SDK (API 21+) / iOS SDK (12.0+)

### Installation
1.  Clone the repository:
    ```bash
    git clone https://github.com/barkatzx/medicare-app.git
    ```
2.  Install dependencies:
    ```bash
    flutter pub get
    ```
3.  Run the application:
    ```bash
    flutter run
    ```

## 📄 License
This project is proprietary and for internal use by MediCare PLC.

---
Built with ❤️ for MediCare PLC.
