class District {
  final String id;
  final String name;
  final String nameKn; // Kannada name
  final List<Taluk> taluks;

  const District({
    required this.id,
    required this.name,
    required this.nameKn,
    required this.taluks,
  });

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'] as String,
      name: json['name'] as String,
      nameKn: json['name_kn'] as String? ?? json['name'] as String,
      taluks: (json['taluks'] as List?)
          ?.map((t) => Taluk.fromJson(t as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class Taluk {
  final String id;
  final String name;
  final String nameKn;
  final String districtId;
  final List<Hobli> hoblis;

  const Taluk({
    required this.id,
    required this.name,
    required this.nameKn,
    required this.districtId,
    required this.hoblis,
  });

  factory Taluk.fromJson(Map<String, dynamic> json) {
    return Taluk(
      id: json['id'] as String,
      name: json['name'] as String,
      nameKn: json['name_kn'] as String? ?? json['name'] as String,
      districtId: json['district_id'] as String,
      hoblis: (json['hoblis'] as List?)
          ?.map((h) => Hobli.fromJson(h as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class Hobli {
  final String id;
  final String name;
  final String nameKn;
  final String talukId;
  final List<Village> villages;

  const Hobli({
    required this.id,
    required this.name,
    required this.nameKn,
    required this.talukId,
    required this.villages,
  });

  factory Hobli.fromJson(Map<String, dynamic> json) {
    return Hobli(
      id: json['id'] as String,
      name: json['name'] as String,
      nameKn: json['name_kn'] as String? ?? json['name'] as String,
      talukId: json['taluk_id'] as String,
      villages: (json['villages'] as List?)
          ?.map((v) => Village.fromJson(v as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class Village {
  final String id;
  final String name;
  final String nameKn;
  final String hobliId;
  final String pincode;
  final List<String> surveyNumbers;

  const Village({
    required this.id,
    required this.name,
    required this.nameKn,
    required this.hobliId,
    required this.pincode,
    required this.surveyNumbers,
  });

  factory Village.fromJson(Map<String, dynamic> json) {
    return Village(
      id: json['id'] as String,
      name: json['name'] as String,
      nameKn: json['name_kn'] as String? ?? json['name'] as String,
      hobliId: json['hobli_id'] as String,
      pincode: json['pincode'] as String? ?? '',
      surveyNumbers: (json['survey_numbers'] as List?)
          ?.map((s) => s.toString())
          .toList() ?? [],
    );
  }
}
