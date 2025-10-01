class CoverageInfo {
  bool? preescolar;
  bool? primaria;
  bool? segundaria;
  int? totalStudents;
  List<String>? educationalLevels; // Agregando propiedad faltante
  int? boysCount; // Agregando propiedad faltante
  int? girlsCount; // Agregando propiedad faltante
  int? teachersCount; // Agregando propiedad faltante

  CoverageInfo({
    this.preescolar,
    this.primaria,
    this.segundaria,
    this.totalStudents,
    this.educationalLevels, // Agregando al constructor
    this.boysCount, // Agregando al constructor
    this.girlsCount, // Agregando al constructor
    this.teachersCount, // Agregando al constructor
  });

  Map<String, dynamic> toJson() => {
    'preescolar': preescolar,
    'primaria': primaria,
    'segundaria': segundaria,
    'totalStudents': totalStudents,
    'educationalLevels': educationalLevels, // Agregando al toJson
    'boysCount': boysCount, // Agregando al toJson
    'girlsCount': girlsCount, // Agregando al toJson
    'teachersCount': teachersCount, // Agregando al toJson
  };

  factory CoverageInfo.fromJson(Map<String, dynamic> json) {
    return CoverageInfo(
      preescolar: json['preescolar'],
      primaria: json['primaria'],
      segundaria: json['segundaria'],
      totalStudents: json['totalStudents'],
      educationalLevels: json['educationalLevels'] != null ? List<String>.from(json['educationalLevels']) : null, // Agregando fromJson
      boysCount: json['boysCount'],
      girlsCount: json['girlsCount'],
      teachersCount: json['teachersCount'],
    );
  }

  CoverageInfo copyWith({
    bool? preescolar,
    bool? primaria,
    bool? segundaria,
    int? totalStudents,
    List<String>? educationalLevels, // Agregando a copyWith
    int? boysCount, // Agregando a copyWith
    int? girlsCount, // Agregando a copyWith
    int? teachersCount, // Agregando a copyWith
  }) {
    return CoverageInfo(
      preescolar: preescolar ?? this.preescolar,
      primaria: primaria ?? this.primaria,
      segundaria: segundaria ?? this.segundaria,
      totalStudents: totalStudents ?? this.totalStudents,
      educationalLevels: educationalLevels ?? this.educationalLevels, // Agregando a copyWith
      boysCount: boysCount ?? this.boysCount, // Agregando a copyWith
      girlsCount: girlsCount ?? this.girlsCount, // Agregando a copyWith
      teachersCount: teachersCount ?? this.teachersCount, // Agregando a copyWith
    );
  }
}
