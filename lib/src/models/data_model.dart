import 'dart:developer' show log;

import 'package:covid19cuba/src/models/models.dart';

class DataModel {
  CasesModel cases;
  DiagnosticCentersModel diagnosticCenters;
  IsolationCentersModel isolationCenters;
  String note;

  DataModel({
    this.cases,
    this.diagnosticCenters,
    this.isolationCenters,
    this.note,
  });

  int get numberOfDiagnosed => cases.days.values
      .where((x) => x.diagnosed != null)
      .map((x) => x.diagnosed.length)
      .reduce((v, e) => v + e);

  int get numberOfDeaths => cases.days.values
      .where((x) => x.deathsNumber != null)
      .map((x) => x.deathsNumber)
      .reduce((v, e) => v + e);

  int get numberOfEvacuees => cases.days.values
      .where((x) => x.evacueesNumber != null)
      .map((x) => x.evacueesNumber)
      .reduce((v, e) => v + e);

  int get numberOfRecovered => cases.days.values
      .where((x) => x.recoveredNumber != null)
      .map((x) => x.recoveredNumber)
      .reduce((v, e) => v + e);

  int get numberOfActive =>
      numberOfDiagnosed - numberOfDeaths - numberOfEvacuees - numberOfRecovered;

  List<DayModel> get days {
    var result = cases.days.values.toList();
    result.sort((a, b) => a.date.compareTo(b.date));
    return result;
  }

  DateTime get update => days.last.date;

  List<DiagnosedModel> get diagnosed {
    var result = List<DiagnosedModel>();
    days.where((x) => x.diagnosed != null).forEach((x) {
      result.addAll(x.diagnosed);
    });
    return result;
  }

  List<String> get ageGroupsNames => [
        '0-18',
        '19-40',
        '41-60',
        '>=61',
        'Desconocido',
      ];

  Map<String, String> get contagionsPretty {
    return <String, String>{
      'importado': 'Importados',
      'introducido': 'Introducidos',
      'autoctono': 'Autóctonos',
      'desconocido': 'Desconocidos',
    };
  }

  Map<String, int> get contagions {
    var result = <String, int>{
      'importado': 0,
      'introducido': 0,
      'autoctono': 0,
      'desconocido': 0,
    };
    days
        .where((x) => x.diagnosed != null)
        .map((x) => x.diagnosed)
        .forEach((diagnosed) {
      diagnosed.forEach((item) {
        if (item.contagion == null) {
          ++result['desconocido'];
        } else if (result.containsKey(item.contagion)) {
          ++result[item.contagion];
        } else {
          result[item.contagion] = 0;
        }
      });
    });
    return result;
  }

  Map<String, String> get gendersPretty {
    return <String, String>{
      'hombre': 'Hombres',
      'mujer': 'Mujeres',
      'no reportado': 'No Reportados',
    };
  }

  Map<String, int> get genders {
    var result = <String, int>{
      'hombre': 0,
      'mujer': 0,
      'no reportado': 0,
    };
    days
        .where((x) => x.diagnosed != null)
        .map((x) => x.diagnosed)
        .forEach((diagnosed) {
      diagnosed.forEach((item) {
        if (item.sex == null) {
          ++result['desconocido'];
        } else if (result.containsKey(item.sex)) {
          ++result[item.sex];
        } else {
          result[item.sex] = 0;
        }
      });
    });
    return result;
  }

  List<int> get ageGroups {
    var result = [0, 0, 0, 0, 0];
    days
        .where((x) => x.diagnosed != null)
        .map((x) => x.diagnosed)
        .forEach((diagnosed) {
      diagnosed.forEach((item) {
        var age = item.age;
        if (age == null) {
          ++result[4];
        } else if (0 <= age && age <= 18) {
          ++result[0];
        } else if (19 <= age && age <= 40) {
          ++result[1];
        } else if (41 <= age && age <= 60) {
          ++result[2];
        } else {
          ++result[3];
        }
      });
    });
    return result;
  }

  Map<String, String> get countriesPretty {
    return <String, String>{
      'cu': 'Cuba',
      'it': 'Italia',
      'be': 'Bélgica',
      'us': 'USA',
      'fr': 'Francia',
      'ca': 'Canadá',
      'es': 'España',
      'cn': 'China',
      'ru': 'Rusia',
      'uy': 'Uruguay',
      'do': 'R.Dominicana',
    };
  }

  Map<String, int> get countries {
    var result = Map<String, int>();
    days
        .where((x) => x.diagnosed != null)
        .map((x) => x.diagnosed)
        .forEach((diagnosed) {
      diagnosed.forEach((item) {
        if (result.containsKey(item.country)) {
          ++result[item.country];
        } else {
          result[item.country] = 0;
        }
      });
    });
    return result;
  }

  List<int> get accumulated {
    var result = List<int>();
    for (var item
        in days.map((x) => x.diagnosed != null ? x.diagnosed.length : 0)) {
      if (result.length == 0) {
        result.add(item);
      } else {
        result.add(item + result.last);
      }
    }
    return result;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'casos': cases.toJson(),
      'centros_diagnostico': diagnosticCenters.toJson(),
      'centros_aislamiento': isolationCenters.toJson(),
      'note-text': note,
    };
  }

  static DataModel fromJson(Map<String, dynamic> json) {
    CasesModel cases;
    DiagnosticCentersModel diagnosticCenter;
    IsolationCentersModel isolationCenters;
    try {
      cases = CasesModel.fromJson(json['casos']);
    } catch (e) {
      log('cases->' + e.toString());
      throw e;
    }
    try {
      diagnosticCenter = DiagnosticCentersModel.fromJson(
        json['centros_diagnostico'],
      );
    } catch (e) {
      log('diagnostic->' + e.toString());
      throw e;
    }
    try {
      isolationCenters = IsolationCentersModel.fromJson(
        json['centros_aislamiento'],
      );
    } catch (e) {
      log('isolation->' + e.toString());
      throw e;
    }
    return DataModel(
      cases: cases,
      diagnosticCenters: diagnosticCenter,
      isolationCenters: isolationCenters,
      note: json.containsKey('json') ? json['note-text'] : null,
    );
  }
}
