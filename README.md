# SkinLogic AI: On-Device Skin Condition Analyzer

## Overview

SkinLogic AI is a mobile application built with Flutter that provides immediate, on-device analysis of various skin conditions using a trained Machine Learning model. This project demonstrates the capability of integrating deep learning models directly into mobile applications for real-time inference, offering quick insights into potential skin issues.

**Disclaimer:** This application is for informational and educational purposes only and is not intended to be a substitute for professional medical advice, diagnosis, or treatment. Always consult with a qualified healthcare professional for any health concerns.

## Features

* **On-Device ML Inference:** Utilizes a lightweight TensorFlow Lite (TFLite) model for fast, offline skin condition analysis.
* **Image Input:** Users can capture photos using their device's camera or select images from their gallery.
* **Prediction Results:** Displays the primary predicted skin condition along with a confidence indicator (High, Moderate, Low).
* **Detailed Probabilities:** Offers an option to view the full list of probabilities for all detected classes.
* **User-Friendly Interface:** Clean and intuitive design for ease of use.
* **Cross-Platform:** Built with Flutter, supporting both Android and iOS (tested primarily on Android).

## Supported Skin Conditions

The current model is trained to identify 9 common skin conditions:
* Actinic Keratosis
* Atopic Dermatitis
* Basal Cell Carcinoma
* Benign Keratosis
* Dermatofibroma
* Melanocytic Nevus
* Melanoma
* Squamous Cell Carcinoma
* Tinea Ringworm Candidiasis
* Vascular Lesion

*(Note: Accuracy may vary. The model's performance can be significantly improved with larger and more diverse training datasets.)*

## Technologies Used

* **Flutter:** Mobile application development framework.
* **Dart:** Programming language for Flutter.
* **TensorFlow Lite (TFLite):** For deploying and running the machine learning model on device.
* **`tflite_flutter`:** Flutter plugin for TFLite integration.
* **`image_picker`:** For selecting images from gallery or camera.
* **`image`:** Dart package for image processing (resizing, pixel manipulation).
* **`permission_handler`:** For managing camera and storage permissions.
* **Python (for Model Training):**
    * TensorFlow / Keras: For building and training the deep learning model (MobileNetV2 Transfer Learning).
    * Google Colaboratory: For cloud-based GPU training.
    * Dataset: [Skin Disease Classification Image Dataset from Kaggle](https://www.kaggle.com/datasets/riyaelizashaju/skin-disease-classification-image-dataset)

## Getting Started

Follow these instructions to set up and run the project locally.

### Prerequisites

* [Flutter SDK](https://flutter.dev/docs/get-started/install) installed (stable channel recommended).
* Android Studio / VS Code with Flutter and Dart plugins.
* An Android or iOS device/emulator.

### Setup Steps

1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/MarsadMaqsood/skinlogic.git
    cd skinlogic
    ```
2.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Run the Application:**
    ```bash
    flutter run
    ```
    (Ensure a device/emulator is connected.)

## Model Details

The pre-trained `.tflite` model and `labels.txt` are included in the `assets/model/` directory.

* **Model Architecture:** MobileNetV2 (fine-tuned using transfer learning).
* **Input Image Size:** 224x224 pixels.
* **Normalization:** Pixel values scaled from 0-255 to 0-1.
* **Training Dataset:** [Skin Disease Classification Image Dataset from Kaggle](https://www.kaggle.com/datasets/riyaelizashaju/skin-disease-classification-image-dataset)

## Future Enhancements (Ideas for Portfolio Discussion)

* Train on significantly larger and more diverse datasets (e.g., ISIC, HAM10000) for improved accuracy and robustness.
* Implement advanced preprocessing techniques.
* Explore more sophisticated model architectures or ensemble methods.
* Add features like user history, information about diseases, or integration with external APIs for consulting.
* Improve UI/UX, especially for handling uncertain predictions.

## Contributing

Feel free to fork this repository, open issues, or submit pull requests.

## License

This project is licensed under the [MIT License](https://github.com/MarsadMaqsood/skinlogic/blob/master/LICENSE). See the `LICENSE` file for details.

## Acknowledgments

* The Flutter and TensorFlow communities for their invaluable resources and tools.
* [Riya Eliza Shaju](https://www.kaggle.com/riyaelizashaju) for providing the [Skin Disease Classification Image Dataset](https://www.kaggle.com/datasets/riyaelizashaju/skin-disease-classification-image-dataset) on Kaggle.