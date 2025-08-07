import 'package:lboard/models/load_post.dart';
import 'package:lboard/models/user.dart';
import 'package:lboard/models/broker.dart';

abstract class DatabaseInterface {
  Future<void> init();
  
  // Load related methods
  Future<void> insertLoad(LoadPost load);
  Future<List<LoadPost>> getLoads();
  Future<void> updateLoadBids(String loadId, List<LoadPostQuote> bids);
  Future<void> deleteLoad(String id);
  Future<void> updateLoad(LoadPost load);

  // User related methods
  Future<void> insertUser(User user);
  Future<User?> getUser(String username);
  Future<void> updateUser(User user);

  // Broker related methods
  Future<List<Map<String, dynamic>>> getAllBrokersRaw();
  Future<List<Broker>> getAllBrokers();
  Future<void> insertBroker(Broker broker);
  Future<void> updateBroker(Broker broker);
  Future<void> deleteBroker(String brokerId);
  
  // Additional methods
  Future<List<User>> getUsersByUsdotNumber(String usdotNumber);
}
