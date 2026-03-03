import 'package:flutter/material.dart';

class HowToUseScreen extends StatelessWidget {
  const HowToUseScreen({super.key});

  // Updated primary color (CYAN)
  static const Color primaryBrandColor = Color(0xFF33D3FF);
  
  // Dark theme background colors (unchanged)
  static const Color backgroundColor = Color(0xFF121212);
  static const Color surfaceColor = Color(0xFF1E1E1E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "How to Connect",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), 
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Follow these steps to start using your remote:",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Step 1
                    _buildStep(
                      stepNumber: "1",
                      icon: Icons.power_settings_new,
                      title: "Turn on TV",
                      description: "Make sure your TV is turned ON before proceeding.",
                    ),

                    // Step 2
                    _buildStep(
                      stepNumber: "2",
                      icon: Icons.bluetooth_searching,
                      title: "Pair Manually",
                      description: "Go to your system Bluetooth settings. Pair the TV manually, then return here.",
                    ),

                    // Step 3
                    _buildStep(
                      stepNumber: "3",
                      icon: Icons.playlist_add_check,
                      title: "Select TV",
                      description: "You will see your TV in the paired list. Click on your TV name to connect.",
                    ),

                    // Step 4
                    _buildStep(
                      stepNumber: "4",
                      icon: Icons.stay_current_portrait_outlined,
                      title: "Ready to Control",
                      description: "After selecting the TV, the app will proceed to the next screen where you can use and control your TV.",
                    ),

                    // Troubleshooting
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: primaryBrandColor.withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline, color: primaryBrandColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  "Troubleshooting",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: primaryBrandColor,
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "If you are unable to connect, close the application completely and restart your Bluetooth. It should then connect correctly.",
                                  style: TextStyle(
                                    fontSize: 14, 
                                    height: 1.4,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom Button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBrandColor,
                    foregroundColor: Colors.white,
                    surfaceTintColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "I Understand",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep({
    required String stepNumber,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Box
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Center(
              child: Icon(
                icon,
                color: primaryBrandColor,
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white60,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}