// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:skinlogic/service/tflite.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  XFile? selectedImage;
  bool _isLoading = false;
  TfLiteService tfLiteService = TfLiteService();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        selectedImage = pickedFile;
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await tfLiteService.runInference(selectedImage: selectedImage);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    tfLiteService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('SkinLogic AI'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 20,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Analyze your skin conditions with AI',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.grey[700]),
            ),

            if (selectedImage != null)
              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(File(selectedImage!.path)),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.image, size: 100, color: Colors.grey[400]),
              ),

            Row(
              spacing: 12,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      bool isGranted = await Permission.camera
                          .request()
                          .isGranted;
                      if (isGranted) {
                        _pickImage(ImageSource.camera);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Camera permission denied. Cannot take photo.',
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            FilledButton.icon(
              onPressed: _isLoading ? null : _analyzeImage,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.medical_services),
              label: Text(_isLoading ? 'Analyzing...' : 'Analyze Image'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),

            if (tfLiteService.predictionResults.isNotEmpty) displayDisease(),
          ],
        ),
      ),
    );
  }

  Widget displayDisease() {
    var (diseaseName, confidence, confidenceMessage, confidenceColor) =
        tfLiteService.formatPrediction();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Primary Prediction:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 10, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  diseaseName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${(confidence * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: confidenceColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Confidence: $confidenceMessage',
              style: TextStyle(
                fontSize: 15,
                fontStyle: FontStyle.italic,
                color: confidenceColor,
              ),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                _showAllProbabilitiesDialog();
              },
              child: const Text('Show Details'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllProbabilitiesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('All Prediction Probabilities'),
          content: SingleChildScrollView(
            child: ListBody(
              children: tfLiteService.predictionResults.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key),
                      Text('${(entry.value * 100).toStringAsFixed(2)}%'),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
