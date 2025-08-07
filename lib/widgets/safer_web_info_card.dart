import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/safer_web_snapshot.dart';
import '../providers/safer_web_provider.dart';

enum SaferWebDisplayMode { compact, detailed, analytics }

class SaferWebInfoCard extends StatefulWidget {
  final String identifier;
  final bool showFullDetails;
  final VoidCallback? onRefresh;
  final SaferWebDisplayMode displayMode;
  final bool showComparisons;

  const SaferWebInfoCard({
    super.key,
    required this.identifier,
    this.showFullDetails = false,
    this.onRefresh,
    this.displayMode = SaferWebDisplayMode.detailed,
    this.showComparisons = false,
  });

  @override
  State<SaferWebInfoCard> createState() => _SaferWebInfoCardState();
}

class _SaferWebInfoCardState extends State<SaferWebInfoCard> {
  late Future<SaferWebSnapshot?> _snapshotFuture;
  late bool _showFullDetails;

  @override
  void initState() {
    super.initState();
    _showFullDetails = widget.showFullDetails;
    _fetchData();
  }

  void _fetchData() {
    final provider = Provider.of<SaferWebProvider>(context, listen: false);
    _snapshotFuture = provider.fetchSnapshot(widget.identifier);
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toUpperCase()) {
      case 'ACTIVE':
      case 'AUTHORIZED':
        color = Colors.green;
        break;
      case 'INACTIVE':
      case 'PENDING':
        color = Colors.orange;
        break;
      case 'REVOKED':
      case 'SUSPENDED':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        status,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }

  Widget _buildSummarySection(String title, Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...data.entries.map((entry) => _buildInfoRow(
          entry.key.replaceAll('_', ' ').toUpperCase(),
          entry.value.toString(),
        )),
        const Divider(),
      ],
    );
  }

  Widget _buildUsInspectionsSection(UsInspectionSummary? usInspections) {
    if (usInspections == null) return const SizedBox.shrink();

    Widget buildCategoryRow(String label, UsInspectionCategory category) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          _buildInfoRow('Out of Service', category.outOfService.toString()),
          _buildInfoRow('Out of Service Percent', category.outOfServicePercent),
          _buildInfoRow('National Average', category.nationalAverage),
          _buildInfoRow('Inspections', category.inspections.toString()),
          const SizedBox(height: 8),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 24),
        const Text(
          'US Inspections',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        buildCategoryRow('Driver', usInspections.driver),
        buildCategoryRow('Vehicle', usInspections.vehicle),
        buildCategoryRow('Hazmat', usInspections.hazmat),
        buildCategoryRow('IEP', usInspections.iep),
        const Divider(),
      ],
    );
  }

  Widget _buildAnalyticsView(SaferWebSnapshot data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAnalyticsHeader(data),
        const SizedBox(height: 16),
        _buildSafetyMetricsDashboard(data),
        const SizedBox(height: 16),
        _buildInspectionAnalytics(data),
        if (data.crashSummary != null) ...[
          const SizedBox(height: 16),
          _buildCrashAnalytics(data),
        ],
        const SizedBox(height: 16),
        _buildComplianceOverview(data),
      ],
    );
  }

  Widget _buildAnalyticsHeader(SaferWebSnapshot data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getSafetyRatingColorWithAlpha(data.safetyRatingDisplay, 0.1),
            _getSafetyRatingColorWithAlpha(data.safetyRatingDisplay, 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getSafetyRatingColorWithAlpha(data.safetyRatingDisplay, 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.legalName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${data.entityType} - ${widget.identifier}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              _buildSafetyRatingChip(data.safetyRatingDisplay),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Power Units',
                  data.displayPowerUnits,
                  Icons.local_shipping,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Drivers',
                  data.displayDrivers,
                  Icons.person,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Status',
                  data.displayStatus,
                  Icons.info,
                  _getStatusColor(data.status),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyMetricsDashboard(SaferWebSnapshot data) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Safety Metrics Overview',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (data.usInspections != null)
              _buildInspectionMetricsGrid(data.usInspections!),
          ],
        ),
      ),
    );
  }

  Widget _buildInspectionMetricsGrid(UsInspectionSummary inspections) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildInspectionMetricTile('Driver', inspections.driver),
        _buildInspectionMetricTile('Vehicle', inspections.vehicle),
        _buildInspectionMetricTile('Hazmat', inspections.hazmat),
        _buildInspectionMetricTile('IEP', inspections.iep),
      ],
    );
  }

  Widget _buildInspectionMetricTile(String title, UsInspectionCategory category) {
    final outOfServiceRate = _parsePercentage(category.outOfServicePercent);
    final nationalAverage = _parsePercentage(category.nationalAverage);
    final isAboveAverage = outOfServiceRate > nationalAverage;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isAboveAverage ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isAboveAverage ? Colors.red.shade200 : Colors.green.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Icon(
                isAboveAverage ? Icons.trending_up : Icons.trending_down,
                size: 16,
                color: isAboveAverage ? Colors.red : Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${category.inspections} inspections',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 2),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 11, color: Colors.black87),
              children: [
                TextSpan(
                  text: '${category.outOfServicePercent} OOS',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isAboveAverage ? Colors.red : Colors.green,
                  ),
                ),
                TextSpan(
                  text: ' (Avg: ${category.nationalAverage})',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInspectionAnalytics(SaferWebSnapshot data) {
    if (data.usInspections == null) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assessment, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Detailed Inspection Analysis',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailedInspectionTable(data.usInspections!),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedInspectionTable(UsInspectionSummary inspections) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1.5),
        2: FlexColumnWidth(1.5),
        3: FlexColumnWidth(1.5),
        4: FlexColumnWidth(1),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(4),
          ),
          children: const [
            Padding(
              padding: EdgeInsets.all(8),
              child: Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text('Inspections', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text('OOS Rate', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text('National Avg', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        _buildInspectionTableRow('Driver', inspections.driver),
        _buildInspectionTableRow('Vehicle', inspections.vehicle),
        _buildInspectionTableRow('Hazmat', inspections.hazmat),
        _buildInspectionTableRow('IEP', inspections.iep),
      ],
    );
  }

  TableRow _buildInspectionTableRow(String category, UsInspectionCategory data) {
    final outOfServiceRate = _parsePercentage(data.outOfServicePercent);
    final nationalAverage = _parsePercentage(data.nationalAverage);
    final isAboveAverage = outOfServiceRate > nationalAverage;
    
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(category),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(data.inspections.toString()),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            data.outOfServicePercent,
            style: TextStyle(
              color: isAboveAverage ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(data.nationalAverage),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            isAboveAverage ? Icons.warning : Icons.check_circle,
            size: 16,
            color: isAboveAverage ? Colors.red : Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildCrashAnalytics(SaferWebSnapshot data) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.car_crash, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Crash Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (data.crashSummary != null)
              _buildCrashSummaryGrid(data.crashSummary!),
          ],
        ),
      ),
    );
  }

  Widget _buildCrashSummaryGrid(Map<String, dynamic> crashSummary) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: crashSummary.entries.map((entry) {
        return _buildCrashMetricCard(
          entry.key.replaceAll('_', ' ').toUpperCase(),
          entry.value.toString(),
        );
      }).toList(),
    );
  }

  Widget _buildCrashMetricCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceOverview(SaferWebSnapshot data) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.verified, color: Colors.purple, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Compliance Overview',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildComplianceMetrics(data),
          ],
        ),
      ),
    );
  }

  Widget _buildComplianceMetrics(SaferWebSnapshot data) {
    return Column(
      children: [
        if (data.usdotNumber != null)
          _buildComplianceRow('USDOT Number', data.usdotNumber!, Icons.confirmation_number),
        if (data.mcNumber != null)
          _buildComplianceRow('MC Number', data.mcNumber!, Icons.local_shipping),
        if (data.usdotStatus != null)
          _buildComplianceRow('USDOT Status', data.usdotStatus!, Icons.verified_user),
        _buildComplianceRow('Operating Status', data.displayStatus, Icons.business),
        if (data.mcs150Date != null)
          _buildComplianceRow(
            'MCS-150 Updated',
            _formatDate(data.mcs150Date!),
            Icons.update,
          ),
      ],
    );
  }

  Widget _buildComplianceRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyRatingChip(String rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getSafetyRatingColor(rating),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        rating,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color.fromRGBO((color.r * 255.0).round() & 0xff, (color.g * 255.0).round() & 0xff, (color.b * 255.0).round() & 0xff, 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color.fromRGBO((color.r * 255.0).round() & 0xff, (color.g * 255.0).round() & 0xff, (color.b * 255.0).round() & 0xff, 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Color _getSafetyRatingColor(String rating) {
    switch (rating.toUpperCase()) {
      case 'SATISFACTORY':
        return Colors.green;
      case 'CONDITIONAL':
        return Colors.orange;
      case 'UNSATISFACTORY':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getSafetyRatingColorWithAlpha(String rating, double alpha) {
    final baseColor = _getSafetyRatingColor(rating);
    return Color.fromRGBO(
      (baseColor.r * 255.0).round() & 0xff,
      (baseColor.g * 255.0).round() & 0xff,
      (baseColor.b * 255.0).round() & 0xff,
      alpha,
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
      case 'AUTHORIZED':
        return Colors.green;
      case 'INACTIVE':
      case 'PENDING':
        return Colors.orange;
      case 'REVOKED':
      case 'SUSPENDED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  double _parsePercentage(String percentage) {
    final cleanPercentage = percentage.replaceAll('%', '').trim();
    return double.tryParse(cleanPercentage) ?? 0.0;
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: FutureBuilder<SaferWebSnapshot?>(
        future: _snapshotFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading data: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _fetchData();
                      });
                      widget.onRefresh?.call();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data;
          if (data == null) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.info_outline, color: Colors.grey, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'No data found for ${widget.identifier}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: widget.displayMode == SaferWebDisplayMode.analytics
                ? _buildAnalyticsView(data)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data.legalName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${data.entityType} - ${widget.identifier}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                if (data.usdotNumber != null)
                                  _buildInfoRow('USDOT Number', data.usdotNumber!),
                                if (data.mcNumber != null)
                                  _buildInfoRow('MC Number', data.mcNumber!),
                                if (data.usdotStatus != null)
                                  _buildInfoRow('USDOT Status', data.usdotStatus!),
                              ],
                            ),
                          ),
                          _buildStatusChip(data.status),
                        ],
                      ),
                      const Divider(height: 24),
                      _buildInfoRow('Address', data.address),
                      if (data.powerUnits != null)
                        _buildInfoRow('Power Units', data.powerUnits.toString()),
                      if (data.drivers != null)
                        _buildInfoRow('Drivers', data.drivers.toString()),
                      if (_showFullDetails) ...[
                        const Divider(height: 24),
                        if (data.inspectionSummary != null)
                          _buildSummarySection('Inspection Summary', data.inspectionSummary),
                        if (data.crashSummary != null)
                          _buildSummarySection('Crash Summary', data.crashSummary),
                        _buildUsInspectionsSection(data.usInspections),
                      ],

                      const SizedBox(height: 16),
                      if (!_showFullDetails)
                        Center(
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _showFullDetails = true;
                              });
                            },
                            child: const Text('View Full Details'),
                          ),
                        ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}
