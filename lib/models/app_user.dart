/// Usuario autenticado. Hoy lo produce MockAuthService; cuando conectemos
/// Firebase Auth de verdad, se construye a partir del User de Firebase
/// pero el resto de la app sigue usando este mismo tipo.
class AppUser {
  final String id;
  final String email;
  final String location;

  // Falso para cuentas recién creadas (signUp) hasta que pasan por
  // CreateProfileScreen — así AuthGate sabe cuándo mandar a alguien ahí
  // antes de dejarlo entrar a la app. Las cuentas que inician sesión
  // (signIn) ya tienen perfil, así que empiezan en true.
  final bool hasCompletedProfile;

  const AppUser({required this.id, required this.email, this.location = '', this.hasCompletedProfile = true});

  AppUser copyWith({bool? hasCompletedProfile}) {
    return AppUser(
      id: id,
      email: email,
      location: location,
      hasCompletedProfile: hasCompletedProfile ?? this.hasCompletedProfile,
    );
  }
}
