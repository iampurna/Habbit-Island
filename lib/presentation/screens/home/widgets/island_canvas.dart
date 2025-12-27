import 'package:flutter/material.dart';

class IslandCanvas extends StatelessWidget {
  const IslandCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: IslandPainter(),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.forest, size: 100, color: Colors.green[700]),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                'Your Island is Growing!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IslandPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green[300]!
      ..style = PaintingStyle.fill;

    // Draw simple island shape
    final path = Path();
    path.moveTo(size.width * 0.3, size.height * 0.6);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.5,
      size.width * 0.7,
      size.height * 0.6,
    );
    path.lineTo(size.width * 0.7, size.height * 0.7);
    path.lineTo(size.width * 0.3, size.height * 0.7);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
