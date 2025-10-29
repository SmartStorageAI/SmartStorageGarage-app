class ContainerModel {
  final String id;
  final String nombre;
  final String cliente;
  final String size;
  final bool status;

  ContainerModel({
    required this.id,
    required this.nombre,
    required this.cliente,
    required this.size,
    required this.status,
  });

  factory ContainerModel.fromMap(String id, Map<String, dynamic> data) {
    return ContainerModel(
      id: id,
      nombre: data['nombre'] ?? '',
      cliente: data['cliente'] ?? '',
      size: data['size'] ?? '',
      status: data['status'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'cliente': cliente,
      'size': size,
      'status': status,
    };
  }
}
