import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CattiRadarChart extends StatelessWidget {
  final int socialPercent;
  final int curiosityPercent;
  final int activityPercent;
  final int emotionPercent;

  const CattiRadarChart({
    super.key,
    required this.socialPercent,
    required this.curiosityPercent,
    required this.activityPercent,
    required this.emotionPercent,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.polygon,
          tickCount: 4,
          ticksTextStyle: const TextStyle(
            color: Colors.transparent,
            fontSize: 0,
          ),
          gridBorderData: const BorderSide(color: Color(0xFFEAD3C8), width: 1),
          tickBorderData: const BorderSide(color: Color(0xFFEAD3C8), width: 1),
          radarBorderData: const BorderSide(
            color: Color(0xFFEAD3C8),
            width: 1.2,
          ),
          titleTextStyle: const TextStyle(
            color: Color(0xFF6B4A3A),
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
          getTitle: (index, angle) {
            const titles = ['사교성', '호기심', '활동성', '감정표현'];
            return RadarChartTitle(text: titles[index]);
          },
          dataSets: [
            RadarDataSet(
              fillColor: const Color(0xFFE8A58C).withValues(alpha: 0.28),
              borderColor: const Color(0xFFE8A58C),
              borderWidth: 2,
              entryRadius: 3,
              dataEntries: [
                RadarEntry(value: socialPercent.toDouble()),
                RadarEntry(value: curiosityPercent.toDouble()),
                RadarEntry(value: activityPercent.toDouble()),
                RadarEntry(value: emotionPercent.toDouble()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
