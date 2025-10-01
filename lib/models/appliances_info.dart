class ApplianceItem {
  String name;
  int quantity;
  bool isInUse;

  ApplianceItem({
    required this.name,
    this.quantity = 0,
    this.isInUse = false,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'quantity': quantity,
    'isInUse': isInUse,
  };

  factory ApplianceItem.fromJson(Map<String, dynamic> json) {
    return ApplianceItem(
      name: json['name'] as String,
      quantity: json['quantity'] as int? ?? 0,
      isInUse: json['isInUse'] as bool? ?? false,
    );
  }
}

class AppliancesInfo {
  List<ApplianceItem> appliances;
  String? otherAppliances; // Añadida esta propiedad

  AppliancesInfo({
    List<ApplianceItem>? appliances,
    this.otherAppliances,  }) : appliances = appliances ?? [
    ApplianceItem(name: 'Bombillos'),
    ApplianceItem(name: 'Nevera'),
    ApplianceItem(name: 'Ventilador'),
    ApplianceItem(name: 'Computador'),
    ApplianceItem(name: 'Tablet'),
    ApplianceItem(name: 'Celular'),
    ApplianceItem(name: 'Televisor'),
    ApplianceItem(name: 'Licuadora'),
    ApplianceItem(name: 'Equipo de Sonido'),
    ApplianceItem(name: 'Lavadora'),
    ApplianceItem(name: 'Impresora'),
  ];

  Map<String, dynamic> toJson() => {
    'appliances': appliances.map((item) => item.toJson()).toList(),
    'otherAppliances': otherAppliances, // Añadido al toJson
  };

  factory AppliancesInfo.fromJson(Map<String, dynamic> json) {
    return AppliancesInfo(
      appliances: (json['appliances'] as List?)
          ?.map((item) => ApplianceItem.fromJson(item))
          .toList(),
      otherAppliances: json['otherAppliances'] as String?,
    );
  }
}
