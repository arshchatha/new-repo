import 'package:flutter/material.dart';
import 'package:lboard/core/config/app_routes.dart';
import 'package:lboard/providers/auth_provider.dart';
import 'tabs/load_tab.dart';
import 'tabs/bidding_tab.dart';
import 'screens/analytics_rate_insights_screen.dart';
import 'tabs/carrierprofile_tab.dart';
import 'widgets/logo_widget.dart';
import 'services/notification_service.dart';
import 'services/chat_service.dart';
import 'screens/notifications_screen.dart';

class CarrierDashboard extends StatefulWidget {
  const CarrierDashboard({super.key});

  @override
  State<CarrierDashboard> createState() => _CarrierDashboardState();
}

class _CarrierDashboardState extends State<CarrierDashboard> {
  int _selectedIndex = 0;
  final NotificationService _notificationService = NotificationService();
  final ChatService _chatService = ChatService();

  final List<Widget> _tabs = [
    const LoadTab(),
    const BiddingTab(),
    Container(), // Placeholder for Add Load button tab
    const AnalyticsRateInsightsScreen(),
    const CarrierProfileTab(),
  ];

  final List<String> _titles = [
    'Available Loads',
    'Bidding',
    'Add Load',
    'Analytics & Rate Insights',
    'Profile',
  ];

  @override
  void initState() {
    super.initState();
    _notificationService.addListener(_onNotificationsChanged);
    _chatService.addListener(_onNotificationsChanged);
  }

  @override
  void dispose() {
    _notificationService.removeListener(_onNotificationsChanged);
    _chatService.removeListener(_onNotificationsChanged);
    super.dispose();
  }

  void _onNotificationsChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onTabSelected(int index) {
    if (index == 2) {
      Navigator.pushNamed(context, AppRoutes.postRequiredLoad);
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 40), // To center the title with leading logo
            Text(_titles[_selectedIndex]),
            const SizedBox(width: 40),
          ],
        ),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: 40,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                LogoWidget(height: 30, width: 30, showProductName: false),
              ],
            ),
          ),
        ),
        actions: [
          Builder(
            builder: (context) {
              final authProvider = AuthProvider.of(context);
              final currentUser = authProvider.user;

              final unreadMessagesCount = currentUser == null ? 0 : _chatService.getUnreadMessageCount(currentUser.id);

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chat),
                    onPressed: () {
                      Navigator.pushNamed(context, '/chat');
                    },
                  ),
                  if (unreadMessagesCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$unreadMessagesCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
              ),
              if (_notificationService.unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${_notificationService.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              AuthProvider.of(context).logout();
              Navigator.of(context).pushReplacementNamed(AppRoutes.login);
            },
          ),
        ],
      ),
      body: _tabs[_selectedIndex],
      // Removed TawkToChatButton as per user request
      // floatingActionButton: const TawkToChatButton(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabSelected,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.black54,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Loads',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.gavel),
            label: 'Bids',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Add Load',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
