import 'package:flutter/material.dart';

class ExplorationPopup extends StatefulWidget {
  const ExplorationPopup({super.key});

  @override
  State<ExplorationPopup> createState() => _ExplorationPopupState();
}

class _ExplorationPopupState extends State<ExplorationPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final double boxWidth = 300;
  final double boxHeight = 300;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Offset _calculatePosition(double t) {
    final double halfW = boxWidth / 2;
    final double halfH = boxHeight / 2;

    if (t < 0.25) {
      double progress = (t / 0.25);
      return Offset(-halfW + progress * boxWidth, -halfH);
    } else if (t < 0.5) {
      double progress = ((t - 0.25) / 0.25);
      return Offset(halfW, -halfH + progress * boxHeight);
    } else if (t < 0.75) {
      double progress = ((t - 0.5) / 0.25);
      return Offset(halfW - progress * boxWidth, halfH);
    } else {
      double progress = ((t - 0.75) / 0.25);
      return Offset(-halfW, halfH - progress * boxHeight);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Stack(
        children: [
          // 🔹 Same background image as HomePage
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg1.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 🔹 Same dark glassy gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color.fromARGB(255, 53, 53, 53).withOpacity(0.3),
                  const Color.fromARGB(255, 65, 65, 65).withOpacity(0.1),
                ],
              ),
            ),
          ),

          // 🔹 Center QR + animated close button
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glassy QR Container
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    width: boxWidth,
                    height: boxHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      // 🔹 Replace with your QR widget
                      child: Image.asset(
                        "assets/qr.jpg",
                        width: 270,
                        height: 270,

                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                // Moving Close Button
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final t = _controller.value;
                    final pos = _calculatePosition(t);

                    return Transform.translate(offset: pos, child: child);
                  },
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            const Color.fromARGB(
                              255,
                              53,
                              53,
                              53,
                            ).withOpacity(0.3),
                            const Color.fromARGB(
                              255,
                              65,
                              65,
                              65,
                            ).withOpacity(0.1),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(
                              255,
                              100,
                              100,
                              100,
                            ).withOpacity(0.6),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
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
