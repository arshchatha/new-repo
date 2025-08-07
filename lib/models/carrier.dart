class Carrier {
  String name;
  String id;
  String email;
  String phone;
  String address;
  String city;
  String state;
  String zip;
  String mc;
  String dot;
  String ein;
  String insurance;
  String insuranceExpiration;
  String w9;
  String w9Expiration;
  String coa;
  String coaExpiration;
  String notes;

  Carrier({
    required this.name,
    required this.id,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.zip,
    required this.mc,
    required this.dot,
    required this.ein,
    required this.insurance,
    required this.insuranceExpiration,
    required this.w9,
    required this.w9Expiration,
    required this.coa,
    required this.coaExpiration,
    required this.notes,
  });

  factory Carrier.fromJson(Map<String, dynamic> json) {
    return Carrier(
      name: json['name'],
      id: json['id'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      zip: json['zip'],
      mc: json['mc'],
      dot: json['dot'],
      ein: json['ein'],
      insurance: json['insurance'],
      insuranceExpiration: json['insuranceExpiration'],
      w9: json['w9'],
      w9Expiration: json['w9Expiration'],
      coa: json['coa'],
      coaExpiration: json['coaExpiration'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'zip': zip,
      'mc': mc,
      'dot': dot,
      'ein': ein,
      'insurance': insurance,
      'insuranceExpiration': insuranceExpiration,
      'w9': w9,
      'w9Expiration': w9Expiration,
      'coa': coa,
      'coaExpiration': coaExpiration,
      'notes': notes,
    };
  }
  @override
  String toString() {
    return 'Carrier{name: $name, id: $id, email: $email, phone: $phone, address: $address, city: $city, state: $state, zip: $zip, mc: $mc, dot: $dot, ein: $ein, insurance: $insurance, insuranceExpiration: $insuranceExpiration, w9: $w9, w9Expiration: $w9Expiration, coa: $coa, coaExpiration: $coaExpiration, notes: $notes}';
  }
}