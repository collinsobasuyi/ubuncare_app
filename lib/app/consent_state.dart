import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConsentState extends ChangeNotifier {
  bool accepted = false;
  String? selectedAvatar;

  /// Load saved consent and avatar
  Future<void> loadConsent() async {
    final prefs = await SharedPreferences.getInstance();
    accepted = prefs.getBool('consentAccepted') ?? false;
    selectedAvatar = prefs.getString('selectedAvatar');
    notifyListeners();
  }

  /// Accept consent (silent save)
  Future<void> acceptConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('consentAccepted', true);
    accepted = true;
  }

  /// Save selected avatar
  Future<void> selectAvatar(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedAvatar', name);
    selectedAvatar = name;
    notifyListeners();
  }

  /// Notify router once loaded
  void syncAfterStartup() => notifyListeners();

  /// Reset everything
  Future<void> resetApp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    accepted = false;
    selectedAvatar = null;
    notifyListeners();
  }
}
