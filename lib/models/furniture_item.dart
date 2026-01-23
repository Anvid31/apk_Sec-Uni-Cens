class FurnitureItem {
  final String id;
  final String category; // Segmento (Mobiliario Escolar)
  final String type;     // Articulo (AMBIENTE, CONJUNTO, PRODUCTO)
  final String code;     // El número (ej: 100)
  final String name;     // El nombre (ej: Aulas de Preescolar)
  String description; // Detalle (Ahora mutable para AMBIENTE)
  
  // Variables de estado (para el formulario)
  int quantity;
  String observations;
  
  // Para manejar los sub-items de AMBIENTE en memoria
  List<FurnitureSubItem>? subItems;

  FurnitureItem({
    required this.id,
    required this.category,
    required this.type,
    required this.code,
    required this.name,
    required this.description,
    this.quantity = 0,
    this.observations = '',
    this.subItems,
  });

  Map<String, dynamic> toJson() {
     // Si hay subItems editados, actualizamos la descripción antes de serializar
     if (subItems != null && subItems!.isNotEmpty) {
       description = subItems!.map((i) => '${i.quantity} ${i.name}').join(', ');
     }
     
     return {
      'code': code,
      'name': name,
      'type': type,
      'description': description,
      'quantity': quantity,
      'observations': observations,
    };
  }
}

class FurnitureSubItem {
  String name;
  int quantity;
  FurnitureSubItem({required this.name, required this.quantity});
}
