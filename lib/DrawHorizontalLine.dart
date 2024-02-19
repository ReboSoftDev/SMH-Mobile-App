import 'package:flutter/material.dart';

class DrawHorizontalLines extends CustomPainter
{
  final BuildContext context;
  final double lineGap;
  final double strokeWidth;
  final double startingPoint;
  final double reduceFromWidth;
  final Color strokeColor;
  DrawHorizontalLines( this.context, this.lineGap, this.strokeWidth, this.startingPoint, this.reduceFromWidth, this.strokeColor );

  @override
  void paint( Canvas canvas, Size size )
  {
    var paintLine = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    for ( double i = lineGap; i < ( size.height ); i = i + lineGap )
    {
      Offset hzStartingPoint = Offset( startingPoint, i );
      Offset hzEndingPoint = Offset( size.width - reduceFromWidth, i );
      canvas.drawLine( hzStartingPoint, hzEndingPoint, paintLine );
    }
  }

  @override
  bool shouldRepaint( CustomPainter painter )
  {
    return false;
  }
}