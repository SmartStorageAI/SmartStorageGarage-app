class ContainerModel {
  final String id;
  final String nombre;
  final String cliente;
  final String size;
  final bool status;
  final String ubicacion;

  ContainerModel({
    required this.id,
    required this.nombre,
    required this.cliente,
    required this.size,
    required this.status,
    required this.ubicacion,
  });

  factory ContainerModel.fromMap(String id, Map<String, dynamic> data) {
    // Si tiene cliente, el estado debe ser ocupado
    final hasCliente = data['cliente'] != null && 
                       (data['cliente'] as String).isNotEmpty;
    final status = hasCliente ? true : (data['status'] ?? false);
    
    return ContainerModel(
      id: id,
      nombre: data['nombre'] ?? '',
      cliente: data['cliente'] ?? '',
      size: data['size'] ?? '',
      status: status,
      ubicacion: data['ubicacion'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'cliente': cliente,
      'size': size,
      'status': status,
      'ubicacion': ubicacion,
    };
  }
}
