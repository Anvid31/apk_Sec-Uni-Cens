import 'package:flutter/foundation.dart';
import 'generalInfo.dart';
import 'institutionalInfo.dart';
import 'coverageInfo.dart';
import 'infrastructureInfo.dart';
import 'observationsInfo.dart';
import 'electricity_info.dart';
import 'appliances_info.dart';
import 'access_route_info.dart';
import 'photographic_record_info.dart';

class SurveyState extends ChangeNotifier {
  GeneralInfo generalInfo = GeneralInfo();
  InstitutionalInfo institutionalInfo = InstitutionalInfo();
  CoverageInfo coverageInfo = CoverageInfo();
  InfrastructureInfo infrastructureInfo = InfrastructureInfo();
  ObservationsInfo observationsInfo = ObservationsInfo();
  ElectricityInfo electricityInfo = ElectricityInfo();
  AppliancesInfo appliancesInfo = AppliancesInfo();
  AccessRouteInfo accessRouteInfo = AccessRouteInfo();
  PhotographicRecordInfo photographicRecordInfo = PhotographicRecordInfo();

  // Nuevas propiedades para el estado de envío
  bool isSubmitted = false;
  DateTime? submissionDate;
  String submissionStatus = 'pending'; // 'pending', 'sent', 'error'
  String? submissionEmail;
  String? errorMessage;

  // Constructor por defecto
  SurveyState();

  void updateGeneralInfo(GeneralInfo info) {
    generalInfo = info;
    notifyListeners();
  }

  void updateInstitutionalInfo(InstitutionalInfo info) {
    institutionalInfo = info;
    notifyListeners();
  }

  void updateCoverageInfo(CoverageInfo info) {
    coverageInfo = info;
    notifyListeners();
  }

  void updateInfrastructureInfo(InfrastructureInfo info) {
    infrastructureInfo = info;
    notifyListeners();
  }

  void updateElectricityInfo(ElectricityInfo info) {
    electricityInfo = info;
    notifyListeners();
  }

  void updateAppliancesInfo(AppliancesInfo info) {
    appliancesInfo = info;
    notifyListeners();
  }
  void updateAccessRouteInfo(AccessRouteInfo info) {
    accessRouteInfo = info;
    notifyListeners();
  }

  void updatePhotographicRecordInfo(PhotographicRecordInfo info) {
    photographicRecordInfo = info;
    notifyListeners();
  }

  void updateObservationsInfo(ObservationsInfo info) {
    observationsInfo = info;
    notifyListeners();
  }

  // Métodos para manejar el estado de envío
  void markAsSubmitted({String? email}) {
    isSubmitted = true;
    submissionDate = DateTime.now();
    submissionStatus = 'pending';
    submissionEmail = email;
    notifyListeners();
  }

  void markAsSent() {
    submissionStatus = 'sent';
    notifyListeners();
  }

  void markAsError(String error) {
    submissionStatus = 'error';
    errorMessage = error;
    notifyListeners();
  }

  void resetSubmissionStatus() {
    isSubmitted = false;
    submissionDate = null;
    submissionStatus = 'pending';
    submissionEmail = null;
    errorMessage = null;
    notifyListeners();
  }

  Map<String, dynamic> toJson() => {
    'generalInfo': generalInfo.toJson(),
    'institutionalInfo': institutionalInfo.toJson(),
    'coverageInfo': coverageInfo.toJson(),
    'infrastructureInfo': infrastructureInfo.toJson(),
    'observationsInfo': observationsInfo.toJson(),
    'electricityInfo': electricityInfo.toJson(),
    'appliancesInfo': appliancesInfo.toJson(),
    'accessRouteInfo': accessRouteInfo.toJson(),
    'photographicRecordInfo': photographicRecordInfo.toJson(),
    // Estados de envío
    'isSubmitted': isSubmitted,
    'submissionDate': submissionDate?.toIso8601String(),
    'submissionStatus': submissionStatus,
    'submissionEmail': submissionEmail,
    'errorMessage': errorMessage,
  };

  // Implementar fromJson para facilitar la conversión desde JSON
  factory SurveyState.fromJson(Map<String, dynamic> json) {
    final state = SurveyState();
    
    if (json['generalInfo'] != null) {
      final generalInfo = json['generalInfo'] as Map<String, dynamic>;
      state.generalInfo.date = generalInfo['date'] != null ? DateTime.parse(generalInfo['date']) : null;
      state.generalInfo.department = generalInfo['department'];
      state.generalInfo.municipality = generalInfo['municipality'];
      state.generalInfo.district = generalInfo['district'];
      state.generalInfo.village = generalInfo['village'];
      state.generalInfo.intervieweeName = generalInfo['intervieweeName'];
      state.generalInfo.contact = generalInfo['contact'];
    }
    
    if (json['institutionalInfo'] != null) {
      final institutionalInfo = json['institutionalInfo'] as Map<String, dynamic>;
      state.institutionalInfo.institutionName = institutionalInfo['institutionName'];
      state.institutionalInfo.dane = institutionalInfo['dane'];
      state.institutionalInfo.institutionType = institutionalInfo['institutionType'];
      state.institutionalInfo.zone = institutionalInfo['zone'];
      state.institutionalInfo.sector = institutionalInfo['sector'];
      state.institutionalInfo.calendar = institutionalInfo['calendar'];
      state.institutionalInfo.category = institutionalInfo['category'];
      state.institutionalInfo.principalName = institutionalInfo['principalName'];
      state.institutionalInfo.location = institutionalInfo['location'];
      state.institutionalInfo.locationCoordinates = institutionalInfo['locationCoordinates'];
      state.institutionalInfo.educationalHeadquarters = institutionalInfo['educationalHeadquarters'];
      state.institutionalInfo.contact = institutionalInfo['contact'];
      state.institutionalInfo.email = institutionalInfo['email'];  
    }
    
    if (json['coverageInfo'] != null) {
      state.coverageInfo = CoverageInfo.fromJson(json['coverageInfo'] as Map<String, dynamic>);
    }
    
    if (json['infrastructureInfo'] != null) {
      state.infrastructureInfo = InfrastructureInfo.fromJson(json['infrastructureInfo'] as Map<String, dynamic>);
    }
    
    if (json['appliancesInfo'] != null) {
      state.appliancesInfo = AppliancesInfo.fromJson(json['appliancesInfo'] as Map<String, dynamic>);
    }
    
    if (json['accessRouteInfo'] != null) {
      state.accessRouteInfo = AccessRouteInfo.fromJson(json['accessRouteInfo'] as Map<String, dynamic>);
    }
    
    if (json['photographicRecordInfo'] != null) {
      state.photographicRecordInfo = PhotographicRecordInfo.fromJson(json['photographicRecordInfo'] as Map<String, dynamic>);
    }
    
    if (json['observationsInfo'] != null) {
      state.observationsInfo = ObservationsInfo.fromJson(json['observationsInfo'] as Map<String, dynamic>);
    }
    
    if (json['electricityInfo'] != null) {
      state.electricityInfo = ElectricityInfo.fromJson(json['electricityInfo'] as Map<String, dynamic>);
    }

    // Estados de envío
    state.isSubmitted = json['isSubmitted'] ?? false;
    if (json['submissionDate'] != null) {
      state.submissionDate = DateTime.parse(json['submissionDate']);
    }
    state.submissionStatus = json['submissionStatus'] ?? 'pending';
    state.submissionEmail = json['submissionEmail'];
    state.errorMessage = json['errorMessage'];

    return state;
  }
}