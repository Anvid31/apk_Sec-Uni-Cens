class ElectricityInfo {
  bool? hasElectricService;
  String? electricServiceType;
  String? otherElectricServiceDescription;
  String? observations; // Campo para observaciones y comentarios
  bool? interestedInSolarPanels;
  
  ElectricityInfo({
    this.hasElectricService,
    this.electricServiceType,
    this.otherElectricServiceDescription,
    this.observations,
    this.interestedInSolarPanels,
  });
  
  Map<String, dynamic> toJson() => {
    'hasElectricService': hasElectricService,
    'electricServiceType': electricServiceType,
    'otherElectricServiceDescription': otherElectricServiceDescription,
    'observations': observations,
    'interestedInSolarPanels': interestedInSolarPanels,
  };
  
  factory ElectricityInfo.fromJson(Map<String, dynamic> json) {
    return ElectricityInfo(
      hasElectricService: json['hasElectricService'],
      electricServiceType: json['electricServiceType'],
      otherElectricServiceDescription: json['otherElectricServiceDescription'],
      observations: json['observations'],
      interestedInSolarPanels: json['interestedInSolarPanels'],
    );
  }

  ElectricityInfo copyWith({
    bool? hasElectricService,
    String? electricServiceType,
    String? otherElectricServiceDescription,
    String? observations,
    bool? interestedInSolarPanels,
  }) {
    return ElectricityInfo(
      hasElectricService: hasElectricService ?? this.hasElectricService,
      electricServiceType: electricServiceType ?? this.electricServiceType,
      otherElectricServiceDescription: otherElectricServiceDescription ?? this.otherElectricServiceDescription,
      observations: observations ?? this.observations,
      interestedInSolarPanels: interestedInSolarPanels ?? this.interestedInSolarPanels,
    );
  }
}
