import '../../data/services/auth_service.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService authService = AuthService();

  @override
  Future<String?> login(String email, String password) async {
    try {
      await authService.login(email, password);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Future<String?> register(String email, String password) async {
    try {
      await authService.register(email, password);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Future<void> logout() async {
    await authService.logout();
  }
}
