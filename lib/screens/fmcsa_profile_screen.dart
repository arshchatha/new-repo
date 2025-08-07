import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../providers/safer_web_provider.dart';
import '../services/fmcsa_verification_service.dart';
import '../core/config/app_routes.dart';

class FmcsaProfileScreen extends StatefulWidget {
  const FmcsaProfileScreen({super.key});

  @override
  State<FmcsaProfileScreen> createState() => _FmcsaProfileScreenState();
}

class _FmcsaProfileScreenState extends State<FmcsaProfileScreen> {
  final FmcsaVerificationService _verificationService = FmcsaVerificationService();
  bool _isVerifying = false;
  VerificationResult? _verificationResult;

  @override
  void initState() {
    super.initState();
    _checkVerificationStatus();
  }

  Future<void> _checkVerificationStatus() async {
    if (!mounted) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    if (user != null && user.usDotMcNumber.isNotEmpty) {
      if (!mounted) return;
      
      setState(() {
        _isVerifying = true;
      });

      try {
        final result = await _verificationService.verifyAndUpdateUser(user);
        
        if (mounted) {
          setState(() {
            _verificationResult = result;
          });
        }
      } catch (e) {
        // Handle error silently for now
      } finally {
        if (mounted) {
          setState(() {
            _isVerifying = false;
          });
        }
      }
    }
  }

  Future<void> _refreshVerification() async {
    await _checkVerificationStatus();
  }

  Widget _buildVerificationStatusCard(User user) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _verificationResult?.success == true 
                      ? Icons.verified_user 
                      : user.usDotMcNumber.isEmpty
                          ? Icons.error_outline
                          : Icons.warning,
                  color: _verificationResult?.success == true 
                      ? Colors.green 
                      : user.usDotMcNumber.isEmpty
                          ? Colors.red
                          : Colors.orange,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'FMCSA Verification Status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (_isVerifying)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _refreshVerification,
                    tooltip: 'Refresh Verification',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (user.usDotMcNumber.isEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No USDOT/MC number provided. Please update your profile to enable FMCSA verification.',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _verificationResult?.success == true 
                      ? Colors.green.shade50 
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _verificationResult?.success == true 
                        ? Colors.green.shade200 
                        : Colors.orange.shade200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _verificationResult?.success == true 
                              ? Icons.check_circle 
                              : Icons.info,
                          color: _verificationResult?.success == true 
                              ? Colors.green 
                              : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _verificationResult?.success == true 
                                ? 'Verified Company' 
                                : 'Verification Status',
                            style: TextStyle(
                              color: _verificationResult?.success == true 
                                  ? Colors.green.shade800 
                                  : Colors.orange.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow('USDOT/MC Number', user.usDotMcNumber),
                    if (_verificationResult != null) ...[
                      const SizedBox(height: 4),
                      _buildInfoRow('Status', _verificationResult!.message),
                      if (_verificationResult!.snapshot != null) ...[
                        const SizedBox(height: 4),
                        _buildInfoRow('Legal Name', _verificationResult!.snapshot!.legalName),
                        _buildInfoRow('Operating Status', _verificationResult!.snapshot!.status),
                      ],
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Verification helps build trust with other platform users',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScreenshotReminderCard(User user) {
    // Calculate next screenshot date (biweekly)
    final now = DateTime.now();
    final nextScreenshot = _verificationService.calculateNextScreenshotDate();
    final daysUntilScreenshot = nextScreenshot.difference(now).inDays;
    final isOverdue = daysUntilScreenshot < 0;
    final isDueSoon = daysUntilScreenshot <= 3 && daysUntilScreenshot >= 0;

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      color: isOverdue 
          ? Colors.red.shade50 
          : isDueSoon 
              ? Colors.orange.shade50 
              : Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isOverdue 
                      ? Icons.error 
                      : isDueSoon 
                          ? Icons.warning 
                          : Icons.schedule,
                  color: isOverdue 
                      ? Colors.red 
                      : isDueSoon 
                          ? Colors.orange 
                          : Colors.blue,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Biweekly Screenshot Reminder',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  Icons.info_outline,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isOverdue 
                    ? Colors.red.shade100 
                    : isDueSoon 
                        ? Colors.orange.shade100 
                        : Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isOverdue 
                      ? Colors.red.shade300 
                      : isDueSoon 
                          ? Colors.orange.shade300 
                          : Colors.blue.shade300,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isOverdue 
                            ? Icons.priority_high 
                            : isDueSoon 
                                ? Icons.access_time 
                                : Icons.check_circle_outline,
                        color: isOverdue 
                            ? Colors.red.shade700 
                            : isDueSoon 
                                ? Colors.orange.shade700 
                                : Colors.blue.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isOverdue
                              ? 'OVERDUE - Action Required!'
                              : isDueSoon
                                  ? 'Due Soon - Please Take Action'
                                  : 'On Track - Next Reminder',
                          style: TextStyle(
                            color: isOverdue 
                                ? Colors.red.shade800 
                                : isDueSoon 
                                    ? Colors.orange.shade800 
                                    : Colors.blue.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Status', 
                    isOverdue
                        ? 'Overdue by ${-daysUntilScreenshot} days'
                        : isDueSoon
                            ? 'Due in $daysUntilScreenshot days'
                            : 'Due in $daysUntilScreenshot days'),
                  _buildInfoRow('Due Date', 
                    '${nextScreenshot.day}/${nextScreenshot.month}/${nextScreenshot.year}'),
                  _buildInfoRow('Frequency', 'Every 14 days (Biweekly)'),
                  _buildInfoRow('Purpose', 'FMCSA Compliance Documentation'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Colors.grey.shade600,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Screenshots help maintain FMCSA compliance and build trust with shippers',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to SaferWeb search to take screenshot
                      Navigator.pushNamed(context, AppRoutes.saferWebSearch);
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Screenshot'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isOverdue 
                          ? Colors.red 
                          : isDueSoon 
                              ? Colors.orange 
                              : Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    // Show help dialog about screenshot requirements
                    _showScreenshotHelpDialog();
                  },
                  icon: const Icon(Icons.help_outline),
                  label: const Text('Help'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showScreenshotHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.help_outline, color: Colors.blue),
              SizedBox(width: 8),
              Text('Screenshot Requirements'),
            ],
          ),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Why are screenshots required?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  '• FMCSA compliance documentation\n'
                  '• Verify current operating status\n'
                  '• Build trust with platform users\n'
                  '• Maintain accurate company information',
                ),
                SizedBox(height: 16),
                Text(
                  'What to screenshot:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  '• Your company\'s SaferWeb profile page\n'
                  '• Include company name and USDOT number\n'
                  '• Ensure operating status is visible\n'
                  '• Capture the full page with timestamp',
                ),
                SizedBox(height: 16),
                Text(
                  'Frequency: Every 14 days (Biweekly)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, AppRoutes.saferWebSearch);
              },
              child: const Text('Take Screenshot'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFmcsaInfoCard(User user) {
    if (user.usDotMcNumber.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.business, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'FMCSA Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer<SaferWebProvider>(
              builder: (context, provider, child) {
                final snapshot = provider.getSnapshot(user.usDotMcNumber);
                final isLoading = provider.isLoading(user.usDotMcNumber);
                final error = provider.getError(user.usDotMcNumber);

                if (isLoading) {
                  return const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text('Fetching FMCSA data...'),
                      ],
                    ),
                  );
                }

                if (error != null) {
                  return Column(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 8),
                      Text(
                        'Error loading FMCSA data: $error',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          provider.fetchSnapshot(user.usDotMcNumber);
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  );
                }

                if (snapshot == null) {
                  return Column(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue, size: 48),
                      const SizedBox(height: 8),
                      const Text(
                        'No FMCSA data available',
                        style: TextStyle(color: Colors.blue),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          provider.fetchSnapshot(user.usDotMcNumber);
                        },
                        icon: const Icon(Icons.cloud_download),
                        label: const Text('Load Data'),
                      ),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoSection('Company Information', [
                      _buildInfoRow('Legal Name', snapshot.legalName),
                      _buildInfoRow('Entity Type', snapshot.entityType),
                      _buildInfoRow('Operating Status', snapshot.status),
                      _buildInfoRow('Physical Address', snapshot.address),
                    ]),
                    const Divider(),
                    _buildInfoSection('Registration Details', [
                      _buildInfoRow('USDOT Number', snapshot.usdotNumber ?? 'N/A'),
                      _buildInfoRow('MC Number', snapshot.mcNumber ?? 'N/A'),
                    ]),
                    const Divider(),
                    _buildInfoSection('Fleet Information', [
                      _buildInfoRow('Power Units', snapshot.powerUnits?.toString() ?? 'N/A'),
                      _buildInfoRow('Drivers', snapshot.drivers?.toString() ?? 'N/A'),
                    ]),
                    if (snapshot.inspectionSummary != null) ...[
                      const Divider(),
                      _buildInfoSection('Inspection Summary', [
                        _buildInfoRow('Total Inspections', 
                          snapshot.inspectionSummary!['total']?.toString() ?? 'N/A'),
                        _buildInfoRow('Out of Service Rate', 
                          '${snapshot.inspectionSummary!['oos_rate']?.toString() ?? 'N/A'}%'),
                      ]),
                    ],
                    if (snapshot.crashSummary != null) ...[
                      const Divider(),
                      _buildInfoSection('Crash Summary', [
                        _buildInfoRow('Total Crashes', 
                          snapshot.crashSummary!['total']?.toString() ?? 'N/A'),
                        _buildInfoRow('Fatal Crashes', 
                          snapshot.crashSummary!['fatal']?.toString() ?? 'N/A'),
                      ]),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Last Updated: ${DateTime.now().toString().split('.')[0]}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () {
                            provider.fetchSnapshot(user.usDotMcNumber);
                          },
                          tooltip: 'Refresh Data',
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
        const SizedBox(height: 8),
      ],
    );
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
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FMCSA Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.saferWebSearch);
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          
          if (user == null) {
            return const Center(
              child: Text('Please log in to view your profile'),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildVerificationStatusCard(user),
                _buildScreenshotReminderCard(user),
                _buildFmcsaInfoCard(user),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
