import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/safer_web_provider.dart';
import '../models/safer_web_snapshot.dart';

class FmcsaInfoWidget extends StatelessWidget {
  final String usdotNumber;
  final bool isCompact;
  final bool showVerificationStatus;

  const FmcsaInfoWidget({
    super.key,
    required this.usdotNumber,
    this.isCompact = false,
    this.showVerificationStatus = false,
  });

  Widget _buildCompactView(BuildContext context, SaferWebSnapshot snapshot) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.verified_user,
            color: Colors.blue.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FMCSA Verified',
                  style: TextStyle(
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'USDOT: ${snapshot.usdotNumber}',
                  style: const TextStyle(fontSize: 12),
                ),
                if (snapshot.mcNumber != null)
                  Text(
                    'MC: ${snapshot.mcNumber}',
                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, size: 20),
            onPressed: () => _showDetailedInfo(context, snapshot),
            tooltip: 'View Details',
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedView(BuildContext context, SaferWebSnapshot snapshot) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.verified_user,
                color: Colors.blue.shade700,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'FMCSA Information',
                  style: TextStyle(
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Legal Name', snapshot.legalName),
          _buildInfoRow('USDOT Number', snapshot.usdotNumber ?? 'N/A'),
          if (snapshot.mcNumber != null)
            _buildInfoRow('MC Number', snapshot.mcNumber!),
          _buildInfoRow('Operating Status', snapshot.status),
          _buildInfoRow('Entity Type', snapshot.entityType),
          if (snapshot.powerUnits != null)
            _buildInfoRow('Power Units', snapshot.powerUnits.toString()),
          if (snapshot.drivers != null)
            _buildInfoRow('Drivers', snapshot.drivers.toString()),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailedInfo(BuildContext context, SaferWebSnapshot snapshot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.verified_user, color: Colors.blue.shade700),
            const SizedBox(width: 8),
            const Text('FMCSA Information'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow('Legal Name', snapshot.legalName),
              _buildInfoRow('USDOT Number', snapshot.usdotNumber ?? 'N/A'),
              if (snapshot.mcNumber != null)
                _buildInfoRow('MC Number', snapshot.mcNumber!),
              _buildInfoRow('Operating Status', snapshot.status),
              _buildInfoRow('Entity Type', snapshot.entityType),
              if (snapshot.powerUnits != null)
                _buildInfoRow('Power Units', snapshot.powerUnits.toString()),
              if (snapshot.drivers != null)
                _buildInfoRow('Drivers', snapshot.drivers.toString()),
              if (snapshot.address.isNotEmpty)
                _buildInfoRow('Address', snapshot.address),
              const Divider(),
              if (snapshot.inspectionSummary != null) ...[
                const Text(
                  'Inspection Summary',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildInfoRow('Total Inspections',
                    snapshot.inspectionSummary!['total']?.toString() ?? 'N/A'),
                _buildInfoRow('Out of Service Rate',
                    '${snapshot.inspectionSummary!['oos_rate']?.toString() ?? 'N/A'}%'),
              ],
              if (snapshot.crashSummary != null) ...[
                const SizedBox(height: 8),
                const Text(
                  'Crash Summary',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildInfoRow('Total Crashes',
                    snapshot.crashSummary!['total']?.toString() ?? 'N/A'),
                _buildInfoRow('Fatal Crashes',
                    snapshot.crashSummary!['fatal']?.toString() ?? 'N/A'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SaferWebProvider>(
      builder: (context, provider, child) {
        final snapshot = provider.getSnapshot(usdotNumber);
        final isLoading = provider.isLoading(usdotNumber);
        final error = provider.getError(usdotNumber);

        if (isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (error != null) {
          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Error loading FMCSA data: $error',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 12,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: () => provider.fetchSnapshot(usdotNumber),
                  tooltip: 'Retry',
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          );
        }

        if (snapshot == null) {
          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey.shade700, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'FMCSA data not available',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: () => provider.fetchSnapshot(usdotNumber),
                  tooltip: 'Load Data',
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          );
        }

        return isCompact
            ? _buildCompactView(context, snapshot)
            : _buildDetailedView(context, snapshot);
      },
    );
  }
}
