import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:subscriptions/data/entities/payment.dart';

import 'indicator.dart';

class PieChartThisMonth extends StatefulWidget {
  PieChartThisMonth({Key key, List<Payment> paymentsThisMonth})
      : _paymentsThisMonth = paymentsThisMonth,
        super(key: key);

  List<Payment> _paymentsThisMonth;

  @override
  State<StatefulWidget> createState() => PieChart2State();
}

class PieChart2State extends State<PieChartThisMonth> {
  StreamController<PieTouchResponse> pieTouchedResultStreamController;

  int touchedIndex;
  var _indicatorsWidgets = List<Widget>();

  @override
  void initState() {
    super.initState();

    _buildLegendIndicator();
    pieTouchedResultStreamController = StreamController();
    pieTouchedResultStreamController.stream.distinct().listen((details) {
      if (details == null) {
        return;
      }

      setState(() {
        if (details.touchInput is FlLongPressEnd) {
          touchedIndex = -1;
        } else {
          touchedIndex = details.touchedSectionPosition;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          height: 200,
          width: 200,
          child: FlChart(
            chart: PieChart(
              PieChartData(
                  pieTouchData: PieTouchData(
                      touchResponseStreamSink:
                          pieTouchedResultStreamController.sink),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  sectionsSpace: 5,
                  centerSpaceRadius: 30,
                  sections: showingSections()),
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _indicatorsWidgets,
        ),
      ],
    );
  }

  void _buildLegendIndicator() {
    for (var payment in widget._paymentsThisMonth) {
      _indicatorsWidgets.add(Indicator(
        color: payment.subscription.color,
        text: payment.subscription.name,
        isSquare: true,
      ));
    }
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(widget._paymentsThisMonth.length, (i) {
      final isTouched = i == touchedIndex;
      final double fontSize = isTouched ? 25 : 14;
      final double radius = isTouched ? 60 : 50;
      final payment = widget._paymentsThisMonth[i];

      return PieChartSectionData(
        color: payment.subscription.color,
        value: payment.subscription.price,
        title: "€ ${payment.subscription.price}",
        radius: radius,
        titleStyle: TextStyle(fontSize: fontSize, color: Colors.white),
      );
    });
  }
}
