import 'package:flutter/foundation.dart';

class RegionProvider with ChangeNotifier {
  String _selectedRegion = "ঢাকা";

  String get selectedRegion => _selectedRegion;

  void updateRegion(String newRegion) {
    if (_selectedRegion != newRegion) {
      _selectedRegion = newRegion;
      notifyListeners();
    }
  }
}
