class AddressRequest {
  final String address;
  final String locality;
  final String? googleMapLink;
  final String? landmark;
  final String? floor;
  final double? lattitude;
  final double? longitude;
  AddressRequest({
    required this.address,
    required this.locality,
    this.googleMapLink,
    this.landmark,
    this.floor,
    this.lattitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() {
    final data = {'address': address, 'locality': locality};

    if (googleMapLink != null && googleMapLink!.isNotEmpty) {
      data['mapUrl'] = googleMapLink!;
    }
    if (landmark != null && landmark!.isNotEmpty) {
      data['landmark'] = landmark!;
    }
    if (floor != null && floor!.isNotEmpty) {
      data['floor'] = floor!;
    }
    if (lattitude != null) {
      data['lat'] = lattitude!.toString();
    }
    if (longitude != null) {
      data['lng'] = longitude!.toString();
    }

    return data;
  }
}
//fetch address

class Address {
  final String id;
  final String address;
  final String locality;
  final double? lat;
  final double? lng;
  final String? floor;
  final String? landmark;

  Address({
    required this.id,
    required this.address,
    required this.locality,
    this.lat,
    this.lng,
    this.floor,
    this.landmark,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['_id'] ?? '',
      address: json['address'] ?? '',
      locality: json['locality'] ?? '',
      lat: json['lat'] != null ? json['lat'].toDouble() : null,
      lng: json['lng'] != null ? json['lng'].toDouble() : null,
      floor: json['floor'],
      landmark: json['landmark'],
    );
  }
}
