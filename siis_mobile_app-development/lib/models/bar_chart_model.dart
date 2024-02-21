import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InspectionChart extends StatelessWidget {
  final List<InspectionSeries> data;

  InspectionChart({required this.data});

  @override
  Widget build(BuildContext context) {
    List<charts.Series<InspectionSeries, String>> series = [
      charts.Series(
          id: "Subscribers",
          data: data,
          domainFn: (InspectionSeries series, _) => series.year,
          measureFn: (InspectionSeries series, _) => series.inspections,
          colorFn: (InspectionSeries series, _) => series.barColor,

      )
    ];

    return Container(
      height: 400,
      padding: EdgeInsets.all(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Text(
                "INSPECTION PERCENTAGE FOR SCHOOLS OVER THE PAST 10 YEARS",
                style: Theme.of(context).textTheme.bodyText1,
              ),
              Expanded(
                child: charts.BarChart(series, animate: true),
              )
            ],
          ),
        ),
      ),
    );
  }
}
class InspectionSeries {
  final String year;
  final int inspections;
  final charts.Color barColor;

  InspectionSeries(
      {
        required this.year,
        required this.inspections,
        required this.barColor
      }
      );
}