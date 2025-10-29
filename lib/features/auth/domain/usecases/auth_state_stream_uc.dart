import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user.dart';

class AuthStateStreamUc {
  final AuthRepository repo;
  AuthStateStreamUc(this.repo);

  /// Trả về stream trạng thái đăng nhập (null = chưa đăng nhập)
  Stream<UserEntity?> call() => repo.authState$; // KHÔNG gọi như hàm
}
