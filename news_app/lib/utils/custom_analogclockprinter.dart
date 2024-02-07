import 'package:flutter/material.dart';
import 'dart:math';

import 'package:get/get.dart';

class AnalogClockPainter extends CustomPainter {
  DateTime datetime;
  final bool showDigitalClock;
  final bool showTicks;
  final bool showNumbers;
  final bool showAllNumbers;
  final bool showSecondHand;
  final bool useMilitaryTime;
  final Color hourHandColor;
  final Color minuteHandColor;
  final Color secondHandColor;
  final Color tickColor;
  final Color digitalClockColor;
  final Color numberColor;
  final double textScaleFactor;

  static const double bASESIZE = 320.0;
  static const double mINUTESINHOUR = 60.0;
  static const double sECONDSINMINUTE = 60.0;
  static const double hOURSINCLOCK = 12.0;
  static const double hANDPINHOLESIZE = 8.0;
  static const double sTROKEWIDTH = 3.0;

  AnalogClockPainter(
      {required this.datetime,
      this.showDigitalClock = true,
      this.showTicks = true,
      this.showNumbers = true,
      this.showSecondHand = true,
      this.hourHandColor = Colors.black,
      this.minuteHandColor = Colors.black,
      this.secondHandColor = Colors.redAccent,
      this.tickColor = Colors.grey,
      this.digitalClockColor = Colors.black,
      this.numberColor = Colors.black,
      this.showAllNumbers = false,
      this.textScaleFactor = 1.0,
      this.useMilitaryTime = true});

  @override
  void paint(Canvas canvas, Size size) {
    double scaleFactor = size.shortestSide / bASESIZE;

    if (showTicks) _paintTickMarks(canvas, size, scaleFactor);
    if (showNumbers) {
      _drawIndicators(canvas, size, scaleFactor, showAllNumbers);
    }

    if (showDigitalClock) {
      _paintDigitalClock(canvas, size, scaleFactor, useMilitaryTime);
    }

    _paintClockHands(canvas, size, scaleFactor);
    _paintPinHole(canvas, size, scaleFactor);
  }

  @override
  bool shouldRepaint(AnalogClockPainter oldDelegate) {
    return oldDelegate.datetime.isBefore(datetime);
  }

  _paintPinHole(canvas, size, scaleFactor) {
    Paint midPointStrokePainter = Paint()
      ..color = showSecondHand ? secondHandColor : minuteHandColor
      ..strokeWidth = sTROKEWIDTH * scaleFactor
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(size.center(Offset.zero), hANDPINHOLESIZE * scaleFactor,
        midPointStrokePainter);
  }

  void _drawIndicators(
      Canvas canvas, Size size, double scaleFactor, bool showAllNumbers) {
    TextStyle style = TextStyle(
        color: numberColor,
        fontWeight: FontWeight.bold,
        fontSize: 18.0 * scaleFactor * textScaleFactor);
    double p = 12.0;
    if (showTicks) p += 24.0;

    double r = size.shortestSide / 2;
    double longHandLength = r - (p * scaleFactor);

    for (var h = 1; h <= 12; h++) {
      if (!showAllNumbers && h % 3 != 0) continue;
      double angle = (h * pi / 6) - pi / 2; //+ pi / 2;
      Offset offset =
          Offset(longHandLength * cos(angle), longHandLength * sin(angle));
      TextSpan span = TextSpan(style: style, text: h.toString());
      TextPainter tp = TextPainter(
          text: span,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, size.center(offset - tp.size.center(Offset.zero)));
    }
  }

  Offset _getHandOffset(double percentage, double length) {
    final radians = 2 * pi * percentage;
    final angle = -pi / 2.0 + radians;

    return Offset(length * cos(angle), length * sin(angle));
  }

  void _paintTickMarks(Canvas canvas, Size size, double scaleFactor) {
    double r = size.shortestSide / 2;
    double tick = 5 * scaleFactor,
        mediumTick = 2.5 * tick,
        longTick = 3.0 * tick;
    double p = longTick + 4 * scaleFactor;
    Paint tickPaint = Paint()
      ..color = tickColor
      ..strokeWidth = 2.0 * scaleFactor;

    for (int i = 1; i <= 60; i++) {
      // default tick length is short
      double len = tick;
      if (i % 15 == 0) {
        // Longest tick on quarters (every 15 ticks)
        len = longTick;
      } else if (i % 5 == 0) {
        // Medium ticks on the '5's (every 5 ticks)
        len = mediumTick;
      }
      // Get the angle from 12 O'Clock to this tick (radians)
      double angleFrom12 = i / 60.0 * 2.0 * pi;

      // Get the angle from 3 O'Clock to this tick
      // Note: 3 O'Clock corresponds with zero angle in unit circle
      // Makes it easier to do the math.
      double angleFrom3 = pi / 2.0 - angleFrom12;

      canvas.drawLine(
          size.center(Offset(cos(angleFrom3) * (r + len - p),
              sin(angleFrom3) * (r + len - p))),
          size.center(
              Offset(cos(angleFrom3) * (r - p), sin(angleFrom3) * (r - p))),
          tickPaint);
    }
  }

  void _paintClockHands(Canvas canvas, Size size, double scaleFactor) {
    double r = size.shortestSide / 2;
    double p = 0.0;
    if (showTicks) p += 0.0;
    if (showNumbers) p += 15.0;
    if (showAllNumbers) p += 24.0;
    double longHandLength = r - (p * scaleFactor);
    double shortHandLength = r - (p + 25.0) * scaleFactor;

    Paint handPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.bevel
      ..strokeWidth = sTROKEWIDTH * scaleFactor;
    double seconds = datetime.second / sECONDSINMINUTE;
    double minutes = (datetime.minute + seconds) / mINUTESINHOUR;
    double hour = (datetime.hour + minutes) / hOURSINCLOCK;

    canvas.drawLine(
        size.center(_getHandOffset(hour, hANDPINHOLESIZE * scaleFactor)),
        size.center(_getHandOffset(hour, shortHandLength)),
        handPaint..color = hourHandColor);

    canvas.drawLine(
        size.center(_getHandOffset(minutes, hANDPINHOLESIZE * scaleFactor)),
        size.center(_getHandOffset(minutes, longHandLength)),
        handPaint..color = minuteHandColor);
    if (showSecondHand) {
      canvas.drawLine(
          size.center(_getHandOffset(seconds, hANDPINHOLESIZE * scaleFactor)),
          size.center(_getHandOffset(seconds, longHandLength)),
          handPaint..color = secondHandColor);
    }
  }

  void _paintDigitalClock(
      Canvas canvas, Size size, double scaleFactor, bool useMilitaryTime) {
    int hourInt = datetime.hour;
    String meridiem = '';
    if (!useMilitaryTime) {
      if (hourInt > 12) {
        hourInt = hourInt - 12;
        meridiem = ' PM'.tr;
      } else {
        meridiem = ' AM'.tr;
      }
    }
    String hour = hourInt.toString().padLeft(2, "0");
    String minute = datetime.minute.toString().padLeft(2, "0");
    String second = datetime.second.toString().padLeft(2, "0");
    TextSpan digitalClockSpan = TextSpan(
        style: TextStyle(
            color: digitalClockColor,
            fontSize: 18 * scaleFactor * textScaleFactor),
        text: "$hour:$minute:$second$meridiem");
    TextPainter digitalClockTP = TextPainter(
        text: digitalClockSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
    digitalClockTP.layout();
    digitalClockTP.paint(
        canvas,
        size.center(-digitalClockTP.size
            .center(Offset(0.0, -size.shortestSide / 4.8))));
  }
}
