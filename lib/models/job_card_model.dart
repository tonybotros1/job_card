class JobCardModel {
  String? customerName;
  String? carBrand;
  String? carModel;
  String? plateNumber;
  String? carMileage;
  String? chassisNumber;
  String? phoneNumber;
  String? emailAddress;
  String? color;
  String? date;
  double? fuelAmount;

  JobCardModel(
      {this.customerName,
      this.carBrand,
      this.carModel,
      this.plateNumber,
      this.carMileage,
      this.chassisNumber,
      this.phoneNumber,
      this.emailAddress,
      this.color,
      this.date,
      this.fuelAmount});

  JobCardModel.fromJson(Map<String, dynamic> json) {
    customerName = json['customer_name'];
    carBrand = json['car_brand'];
    carModel = json['car_model'];
    plateNumber = json['plate_number'];
    carMileage = json['car_mileage'];
    chassisNumber = json['chassis_number'];
    phoneNumber = json['phone_number'];
    emailAddress = json['email_address'];
    color = json['color'];
    date = json['date'];
    fuelAmount = json['fuel_amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['customer_name'] = customerName;
    data['car_brand'] = carBrand;
    data['car_model'] = carModel;
    data['plate_number'] = plateNumber;
    data['car_mileage'] = carMileage;
    data['chassis_number'] = chassisNumber;
    data['phone_number'] = phoneNumber;
    data['email_address'] = emailAddress;
    data['color'] = color;
    data['date'] = date;
    data['fuel_amount'] = fuelAmount;
    return data;
  }
}
