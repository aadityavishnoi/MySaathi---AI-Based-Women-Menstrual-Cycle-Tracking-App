import 'package:flutter/material.dart';
import '../../domain/repositories/auth_repository_impl.dart';

class LoginController with ChangeNotifier {
  final AuthRepositoryImpl repository = AuthRepositoryImpl();

  bool loading = false;

  Future<String?> login(String email, String password) async {
    loading = true;
    notifyListeners();

    final error = await repository.login(email, password);

    loading = false;
    notifyListeners();

    return error;
  }
}
