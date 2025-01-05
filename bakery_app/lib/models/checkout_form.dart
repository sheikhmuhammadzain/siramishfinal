class CheckoutForm {
  String name;
  String email;
  String address;
  String city;
  String zipCode;

  CheckoutForm({
    this.name = '',
    this.email = '',
    this.address = '',
    this.city = '',
    this.zipCode = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'address': address,
      'city': city,
      'zipCode': zipCode,
    };
  }

  bool isValid() {
    return name.isNotEmpty &&
        email.isNotEmpty &&
        email.contains('@') &&
        address.isNotEmpty &&
        city.isNotEmpty &&
        zipCode.isNotEmpty;
  }
}
