import 'package:elbe/elbe.dart';
import 'package:newsy/service/s_outlets.dart';

class OutletAudienceChart extends StatelessWidget {
  final List<NewsOutlet> outlets;
  final Color color1;
  final Color color2;
  final double? size;

  const OutletAudienceChart(
      {super.key,
      required this.outlets,
      this.size,
      required this.color1,
      required this.color2});

  Widget _chart({required BuildContext context}) => CustomPaint(
      size: size != null ? Size.square(context.rem(size!)) : Size.zero,
      painter: MyCustomPainter(
          outlets.map((e) => e.audience).toList(), color1, color2));

  void showToast(BuildContext context, String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message, color: Colors.white)));

  Widget _label(
          {required Alignment align,
          required String text,
          required IconData icon}) =>
      Builder(builder: (context) {
        return Align(
          alignment: align,
          child: InkWell(
            onTap: () => showToast(context, text),
            child: Tooltip(
                message: text,
                child: Icon(
                  icon,
                )),
          ),
        );
      });

  @override
  Widget build(BuildContext context) {
    return size != null
        ? _chart(context: context)
        : Card(
            border: Border.none,
            padding: const RemInsets.all(0.6),
            child: SizedBox.square(
              dimension: context.rem(14),
              child: Stack(
                children: [
                  _label(
                      align: Alignment.topCenter,
                      text: "Leserschaft: ⌀ Einkommen",
                      icon: Icons.euro),
                  _label(
                      align: Alignment.centerRight,
                      text: "Leserschaft: ⌀ Bildungsgrad",
                      icon: Icons.graduationCap),
                  _label(
                      align: Alignment.bottomCenter,
                      text: "Leserschaft: ⌀ Alter",
                      icon: Icons.cake),
                  _label(
                      align: Alignment.centerLeft,
                      text: "Leserschaft: ⌀ Wohnortgröße",
                      icon: Icons.building),
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox.square(
                      dimension: context.rem(10),
                      child: _chart(context: context),
                    ),
                  ),
                ],
              ),
            ));
  }
}

class MyCustomPainter extends CustomPainter {
  final Color color;
  final Color secondaryColor;
  final List<NewsOutletAudience> audiences;
  MyCustomPainter(this.audiences, this.color, this.secondaryColor);

  void paintAudience(Canvas canvas, Size size, NewsOutletAudience audience,
      Color color, bool fill) {
    final paint = Paint()
      ..color = fill ? color : color.withOpacity(1)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = fill ? 5 : 3;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final center = Offset(centerX, centerY);

    double mapPointY(double a) => (centerY * (a + 0.2) * 0.8);
    double mapPointX(double a) => (centerX * (a + 0.2) * 0.8);

    final top = center.translate(0, -mapPointY(audience.incomeNorm));
    final right = center.translate(mapPointX(audience.educationNorm), 0);
    final bottom = center.translate(0, mapPointY(audience.ageNorm));
    final left = center.translate(-mapPointX(audience.citySizeNorm), 0);

    Path path = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(right.dx, right.dy)
      ..lineTo(bottom.dx, bottom.dy)
      ..lineTo(left.dx, left.dy)
      ..close();

    canvas.drawPath(path, paint);
    paint.style = PaintingStyle.fill;
    if (!fill) paint.color = color.withOpacity(0);
    canvas.drawPath(path, paint);

    if (!fill) {
      for (final point in [top, right, bottom, left]) {
        canvas.drawCircle(point, 5, paint..color = color);
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // axis paint
    final paint = Paint()
      ..color = const Color(0xffb0b0b0)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 1;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    canvas.drawLine(Offset(0, centerY), Offset(size.width, centerY), paint);
    canvas.drawLine(Offset(centerX, 0), Offset(centerX, size.height), paint);

    if (audiences.isEmpty) return;
    if (audiences.length > 1) {
      paintAudience(canvas, size, audiences[0], secondaryColor, true);
    }

    paintAudience(canvas, size, audiences.last, color, false);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
