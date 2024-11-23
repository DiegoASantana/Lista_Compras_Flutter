import 'package:flutter/services.dart';

class PremiumService {
  static const platform = MethodChannel('com.Lista_Compras_Flutter/premium');

  static Future<bool> isPremiumUser() async {
    try {
      final bool result = await platform.invokeMethod('isPremiumUser');
      return result;
    } catch (e) {
      print("Erro ao verificar status premium: $e");
      return false;
    }
  }

  static Future<bool> purchasePremiumAccess() async {
    try {
      final bool result = await platform.invokeMethod('purchasePremiumAccess');
      return result;
    } catch (e) {
      print("Erro ao realizar compra premium: $e");
      return false;
    }
  }
}