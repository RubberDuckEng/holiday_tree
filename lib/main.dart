import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TreeWidgetOfAwesome(),
    );
  }
}

class TreeWidgetOfAwesome extends StatelessWidget {
  const TreeWidgetOfAwesome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
        child: CustomPaint(
      painter: TreePainter(),
    ));
  }
}

void addStar(Path path, Offset center, double radius) {
  // incribe a circle with 5 points
  const angleStep = 2 * math.pi / 5;
  const startAngle = -math.pi / 2;
  final p = List.generate(
      5,
      (i) => Offset(
            radius * math.cos(angleStep * i + startAngle) + center.dx,
            radius * math.sin(angleStep * i + startAngle) + center.dy,
          ));

  // 0 -> 2 > 4 -> 1 -> 3 -> 0
  path.moveTo(p[0].dx, p[0].dy);
  path.lineTo(p[2].dx, p[2].dy);
  path.lineTo(p[4].dx, p[4].dy);
  path.lineTo(p[1].dx, p[1].dy);
  path.lineTo(p[3].dx, p[3].dy);
  path.lineTo(p[0].dx, p[0].dy);
}

void addTree(Path path, Offset topOfTree, double height, double halfWidth) {
  path.addPolygon([
    topOfTree,
    topOfTree + Offset(halfWidth, height),
    topOfTree + Offset(-halfWidth, height)
  ], true);
}

class TreePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = Colors.green.shade200;
    canvas.drawRect(Offset.zero & size, paint);

    final unit = size.shortestSide / 8;
    final heightOfTree = unit * 7;
    final halfWidthOfTree = unit * 2;
    final topOfTree = size.center(Offset(0, -unit) * 4);
    final bottomOfTree = topOfTree + Offset(0, heightOfTree);
    final stumpWidth = unit;
    final stumpHeight = unit;
    final stumpRect = Rect.fromCenter(
        center: bottomOfTree + Offset(0, stumpHeight / 2.0),
        width: stumpWidth,
        height: stumpHeight);

    paint.color = Colors.brown.shade600;
    canvas.drawRect(stumpRect, paint);

    final treePath = Path();
    addTree(
      treePath,
      topOfTree,
      heightOfTree,
      halfWidthOfTree,
    );
    paint.color = Colors.green.shade600;
    canvas.drawPath(treePath, paint);

    paint.color = Colors.white;
    paint.strokeCap = StrokeCap.round;
    paint.strokeWidth = unit / 8;
    final colors = [Colors.blue.shade200, Colors.white, Colors.pink.shade100];
    final yStep = unit / 2;
    final xStep = unit / 8;
    final lights = <Offset>[];
    final rows = heightOfTree ~/ yStep;
    final slope = heightOfTree / halfWidthOfTree;
    int k = 0;
    for (int i = 0; i < rows; ++i) {
      final bottom = i * yStep;
      final top = bottom + yStep * 0.5;
      final treeRadiusAtBottom = (heightOfTree - bottom) / slope;
      final treeRadiusAtTop = (heightOfTree - top) / slope;
      final cols = math.max(3, treeRadiusAtBottom ~/ xStep);
      for (int j = 0; j < cols; ++j) {
        final t = j / (cols - 1);
        final dy = lerpDouble(bottom, top, Curves.easeIn.transform(t))!;
        final dx = lerpDouble(-treeRadiusAtBottom, treeRadiusAtTop, t)!;
        paint.color = colors[k];
        k = (k + 1) % colors.length;
        canvas.drawPoints(
            PointMode.points, [bottomOfTree - Offset(dx, dy)], paint);
      }
    }

    // canvas.drawPoints(PointMode.points, lights, paint);

    final starPath = Path();
    addStar(starPath, topOfTree, unit);
    paint.color = Colors.yellow.shade600;
    canvas.drawPath(starPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
