class UserModel {
  final String id;
  final String nombre;
  final String telefono;
  final String email;
  final String membresia;
  final String estadoPago;
  final List<String> contenedores;

  UserModel({
    required this.id,
    required this.nombre,
    required this.telefono,
    required this.email,
    required this.membresia,
    required this.estadoPago,
    required this.contenedores,
  });

  factory UserModel.fromMap(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      nombre: data['nombre'] ?? '',
      telefono: data['telefono'] ?? '',
      email: data['email'] ?? '',
      membresia: data['membresia'] ?? '',
      estadoPago: data['estadoPago'] ?? '',
      contenedores: List<String>.from(data['contenedores'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'telefono': telefono,
      'email': email,
      'membresia': membresia,
      'estadoPago': estadoPago,
      'contenedores': contenedores,
    };
  }
}
