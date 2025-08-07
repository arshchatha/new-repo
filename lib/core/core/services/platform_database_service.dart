import 'package:flutter/foundation.dart';
import 'package:lboard/core/services/database_interface.dart';
import 'package:lboard/core/core/database/database_helper.dart';
import 'package:lboard/core/services/sembast_service.dart';
import 'package:lboard/models/broker.dart';
import 'package:lboard/models/load_post.dart';
import 'package:lboard/models/user.dart';
import 'package:lboard/models/chat_message.dart';
import 'file_picker_windows_dummy.dart';
import 'file_picker_linux_dummy.dart';
import 'file_picker_macos_dummy.dart';

class PlatformDatabaseService implements DatabaseInterface {
  static final PlatformDatabaseService instance = PlatformDatabaseService._privateConstructor();
  PlatformDatabaseService._privateConstructor();

  late final DatabaseInterface _implementation;
  bool _isInitialized = false;

  @override
  Future<void> init() async {
    if (!_isInitialized) {
      if (kIsWeb) {
        _implementation = SembastService.instance as DatabaseInterface;
      } else if (defaultTargetPlatform == TargetPlatform.windows) {
        // Use dummy implementation to avoid file_picker pluginClass error on Windows
        _implementation = FilePickerWindowsDummy() as DatabaseInterface;
      } else if (defaultTargetPlatform == TargetPlatform.linux) {
        // Use dummy implementation to avoid file_picker pluginClass error on Linux
        _implementation = FilePickerLinuxDummy() as DatabaseInterface;
      } else if (defaultTargetPlatform == TargetPlatform.macOS) {
        // Use dummy implementation to avoid file_picker pluginClass error on MacOS
        _implementation = FilePickerMacosDummy() as DatabaseInterface;
      } else {
        _implementation = DatabaseHelper.instance as DatabaseInterface;
      }
      await _implementation.init();
      _isInitialized = true;
    }
  }

  // Chat message related methods
  Future<void> insertMessage(ChatMessage message) async {
    if (_implementation is DatabaseHelper) {
      return await (_implementation).insertMessage(message);
    } else {
      throw UnimplementedError('insertMessage is not implemented for this platform');
    }
  }

  Future<List<ChatMessage>> getMessagesBetweenUsers(String userId1, String userId2) async {
    if (_implementation is DatabaseHelper) {
      return await (_implementation).getMessagesBetweenUsers(userId1, userId2);
    } else {
      throw UnimplementedError('getMessagesBetweenUsers is not implemented for this platform');
    }
  }

  @override
  Future<void> insertLoad(LoadPost load) async {
    return await _implementation.insertLoad(load);
  }

  @override
  Future<List<LoadPost>> getLoads() async {
    return await _implementation.getLoads();
  }

  @override
  Future<void> updateLoadBids(String loadId, List<LoadPostQuote> bids) async {
    return await _implementation.updateLoadBids(loadId, bids);
  }

  @override
  Future<void> deleteLoad(String id) async {
    return await _implementation.deleteLoad(id);
  }

  @override
  Future<void> updateLoad(LoadPost load) async {
    return await _implementation.updateLoad(load);
  }

  @override
  Future<List<Broker>> getAllBrokers() async {
    return await _implementation.getAllBrokers();
  }

  @override
  Future<List<Map<String, dynamic>>> getAllBrokersRaw() async {
    return await _implementation.getAllBrokersRaw();
  }

  @override
  Future<void> insertBroker(Broker broker) async {
    return await _implementation.insertBroker(broker);
  }

  @override
  Future<void> updateBroker(Broker broker) async {
    return await _implementation.updateBroker(broker);
  }

  @override
  Future<void> deleteBroker(String brokerId) async {
    return await _implementation.deleteBroker(brokerId);
  }

  @override
  Future<void> insertUser(User user) async {
    return await _implementation.insertUser(user);
  }

  @override
  Future<User?> getUser(String username) async {
    return await _implementation.getUser(username);
  }

  @override
  Future<void> updateUser(User user) async {
    return await _implementation.updateUser(user);
  }

  @override
  Future<List<User>> getUsersByUsdotNumber(String usdotNumber) async {
    return await _implementation.getUsersByUsdotNumber(usdotNumber);
  }
}
