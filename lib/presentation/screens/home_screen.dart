import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // Import provider
import 'package:ecotrack/presentation/viewmodels/dashboard_viewmodel.dart'; // Import DashboardViewModel
// No longer need AppViewModel import here as we don't listen to its index directly.
// import 'package:ecotrack/presentation/viewmodels/app_viewmodel.dart';
import 'package:ecotrack/domain/entities/footprint_entry.dart'; // Import FootprintEntry for type hinting
import 'package:fl_chart/fl_chart.dart'; // Import fl_chart

// HomeScreen is the View for the Dashboard.
// It is a StatelessWidget that consumes the DashboardViewModel,
// which now reacts to changes in the ActivityRepository stream and provides historical data for charting.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Removed initState and didChangeDependencies as the ViewModel is reactive.

  @override
  Widget build(BuildContext context) {
    print('HomeScreen: build called'); // Debug log
    // Watch the DashboardViewModel to react to state changes (isLoading, messages, data).
    // This widget will rebuild when the ViewModel notifies listeners.
    final dashboardViewModel = context.watch<DashboardViewModel>();
    print(
      'HomeScreen: ViewModel state - isLoading: ${dashboardViewModel.isLoading}, errorMessage: ${dashboardViewModel.errorMessage}, latestFootprint: ${dashboardViewModel.latestFootprint != null}, history count: ${dashboardViewModel.footprintHistory.length}',
    ); // Debug log

    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoTrack Dashboard'), // App bar title
        backgroundColor:
            Theme.of(context).primaryColor, // Use primary color from theme
      ),
      body: _buildBody(
        context,
        dashboardViewModel,
      ), // Delegate building the body based on state
    );
  }

  // Helper method to build the body content based on ViewModel state.
  Widget _buildBody(BuildContext context, DashboardViewModel viewModel) {
    print(
      'HomeScreen:_buildBody called. Checking ViewModel state...',
    ); // Debug log
    print(
      'HomeScreen:_buildBody: isLoading: ${viewModel.isLoading}, errorMessage: ${viewModel.errorMessage}, latestFootprint: ${viewModel.latestFootprint != null}, history count: ${viewModel.footprintHistory.length}',
    ); // Debug log

    if (viewModel.isLoading) {
      // Show a loading indicator
      return const Center(child: CircularProgressIndicator());
    } else if (viewModel.errorMessage != null) {
      // Show an error message
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Error: ${viewModel.errorMessage}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    } else if (viewModel.latestFootprint != null ||
        viewModel.footprintHistory.isNotEmpty) {
      // Display the latest footprint and the chart if data is available.
      // Even if latestFootprint is null, we might have history for the chart.

      // Prepare data points for the chart
      final List<FlSpot> spots =
          viewModel.footprintHistory.asMap().entries.map((entry) {
              // Convert timestamp to a double for the X axis.
              // Use millisecondsSinceEpoch.
              final double xValue =
                  entry.value.timestamp.millisecondsSinceEpoch.toDouble();
              final double yValue = entry.value.totalCo2e;
              return FlSpot(xValue, yValue);
            }).toList()
            ..sort((a, b) => a.x.compareTo(b.x)); // Sort by timestamp ascending

      // Calculate min/max for chart axes if data exists
      double minX = 0;
      double maxX = 1;
      double minY = 0;
      double maxY = 1;

      if (spots.isNotEmpty) {
        minX = spots.first.x;
        maxX = spots.last.x;
        minY = spots.map((spot) => spot.y).reduce(min); // Find minimum Y
        maxY = spots.map((spot) => spot.y).reduce(max); // Find maximum Y

        // Add some padding to the Y axis
        minY = (minY * 0.9).clamp(
          0.0,
          double.infinity,
        ); // 10% less, but not below 0
        maxY = maxY * 1.1; // 10% more
      }

      // Determine if Y values are constant
      final bool yValuesAreConstant = spots.isNotEmpty && minY == maxY;

      return SingleChildScrollView(
        // Use SingleChildScrollView for vertical scrolling
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch, // Stretch chart horizontally
            children: <Widget>[
              // Display latest footprint if available
              if (viewModel.latestFootprint != null) ...[
                const Text(
                  'Your Latest Footprint Estimate:',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  // Display total CO2e, formatted (formatting can be added later)
                  '${viewModel.latestFootprint!.totalCo2e.toStringAsFixed(2)} kg CO2e',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  // Display timestamp, formatted
                  'as of ${viewModel.latestFootprint!.timestamp.toLocal().toString().split('.')[0]}', // Basic formatting
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 32), // Space before the chart
              ],

              // Display the chart if historical data is available (at least one point)
              if (spots.isNotEmpty) ...[
                // Use spots.isNotEmpty
                const Text(
                  'Footprint History:',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                // --- Chart Widget ---\
                SizedBox(
                  // Give the chart a defined size
                  height: 200, // Example height
                  child: LineChart(
                    LineChartData(
                      minX: minX, // Set minX
                      maxX: maxX, // Set maxX
                      minY: minY, // Set minY
                      maxY: maxY, // Set maxY
                      // // Define chart data points
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots, // Use the prepared spots
                          isCurved: true,
                          color:
                              Theme.of(
                                context,
                              ).primaryColor, // Use primary color
                          dotData: const FlDotData(
                            show: false,
                          ), // Hide data points
                          belowBarData: BarAreaData(
                            show: true,
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.3),
                          ), // Add shaded area below the line
                        ),
                      ],

                      // Define chart titles and axes
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          // X-axis titles (timestamps)
                          sideTitles: SideTitles(
                            showTitles:
                                spots.length >
                                0, // Show titles if at least one point
                            getTitlesWidget: (value, meta) {
                              // Convert the double xValue (timestamp) back to DateTime for display
                              final dateTime =
                                  DateTime.fromMillisecondsSinceEpoch(
                                    value.toInt(),
                                  ).toLocal(); // Convert to local time for display
                              // Display date (e.g., 'MM-dd')
                              return SideTitleWidget(
                                meta: meta, // Use meta as you indicated worked
                                space: 8.0,
                                child: Text(
                                  DateFormat('MM-dd').format(dateTime),
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            },
                            // Let fl_chart determine the interval automatically based on data points
                            // We don't need an explicit interval here for auto-spacing
                            reservedSize:
                                30, // Increased reserved size slightly
                          ),
                        ),
                        leftTitles: AxisTitles(
                          // Y-axis titles (CO2e)
                          sideTitles: SideTitles(
                            showTitles:
                                !yValuesAreConstant, // Only show Y titles if Y values are not constant
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 10),
                              ); // Display CO2e values
                            },
                            reservedSize: 40, // Space for titles
                          ),
                        ),
                      ),
                      // // Define grid lines
                      gridData: FlGridData(
                        show:
                            spots.length >
                            1, // Only show grid lines if more than one point
                        drawVerticalLine: true,
                        drawHorizontalLine:
                            !yValuesAreConstant, // Only show horizontal grid lines if Y values are not constant
                        // Provide a default horizontal interval if Y values are constant to avoid division by zero.
                        horizontalInterval:
                            yValuesAreConstant
                                ? 1.0
                                : (maxY - minY) /
                                    5, // Fix: Provide default interval if constant
                        // Let fl_chart determine vertical interval automatically
                        // verticalInterval: oneDayInMilliseconds, // Removed explicit vertical interval
                        getDrawingVerticalLine:
                            (value) => const FlLine(
                              color: Colors.grey,
                              strokeWidth: 0.5,
                            ),
                        getDrawingHorizontalLine:
                            (value) => const FlLine(
                              color: Colors.grey,
                              strokeWidth: 0.5,
                            ),
                      ),
                      // Define borders
                      // Define tooltips (optional)
                      borderData: FlBorderData(
                        show: true,

                        border: Border.all(color: Colors.grey, width: 1),
                      ),
                    ),
                  ),
                ),
                // --- End Chart Widget ---
              ],
            ],
          ),
        ),
      );
    } else {
      // No data available (e.g., first time user)
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'No footprint data available yet. Log some activities to see your impact!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }
  }
}
