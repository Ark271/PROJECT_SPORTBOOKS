import '../../domain/entities/user.dart';
import '../datasources/auth_remote_ds.dart';

class UserMapper {
  const UserMapper();

  UserEntity fromRemote(RemoteUser ru) {
    return UserEntity(
      id: ru.uid,
      email: ru.email, // RemoteUser.email là non-nullable
      name: ru.displayName, // RemoteUser.displayName là non-nullable
    );
  }
}
