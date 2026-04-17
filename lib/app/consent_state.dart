import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConsentState extends ChangeNotifier {
  bool accepted = false;
  String? selectedAvatar;
  String? userName;

  /// Load saved consent, avatar, and name on startup.
  Future<void> loadConsent() async {
    final prefs = await SharedPreferences.getInstance();
    accepted       = prefs.getBool('consentAccepted') ?? false;
    selectedAvatar = prefs.getString('selectedAvatar');
    userName       = prefs.getString('userName');
    notifyListeners();
  }

  /// Save user's name for personalisation.
  Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    userName = name;
    notifyListeners();
  }

  /// Accept consent and persist it.
  /// Bug fix: notifyListeners() was missing — router redirect never fired.
  Future<void> acceptConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('consentAccepted', true);
    accepted = true;
    notifyListeners();
  }

  /// Save selected avatar and notify router.
  Future<void> selectAvatar(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedAvatar', name);
    selectedAvatar = name;
    notifyListeners();
  }

  /// Force a router refresh after startup sync.
  void syncAfterStartup() => notifyListeners();

  /// Reset all state (used from settings).
  Future<void> resetApp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    accepted       = false;
    selectedAvatar = null;
    userName       = null;
    notifyListeners();
  }
}
