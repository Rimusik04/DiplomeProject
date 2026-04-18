import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String userId;
  final String serviceType;
  final String specificService; 
  final String petName;
  final String location;
  final String date;
  final String time;
  final int price;
  final String status; 
  final String notes;
  final String petAge;
  final String petGender;
  final String petColor;
  final String? petImageUrl;
  final double minRating;
  final String serviceCategory;
  final double? lat;
  final double? lng;
  final int? walkingHours;
  final int? boardingDays;
  final String? groomingService;
  final String? vetService;     
  final String? trainingType;   
  final String? taxiType;       
  final String phoneNumber;
  final DateTime? createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.serviceType,
    required this.specificService,
    required this.petName,
    required this.location,
    required this.date,
    required this.time,
    required this.price,
    required this.status,
    required this.notes,
    required this.petAge,
    required this.petGender,
    required this.petColor,
    this.petImageUrl,
    required this.minRating,
    required this.serviceCategory,
    this.lat,
    this.lng,
    this.walkingHours,
    this.boardingDays,
    this.groomingService,
    this.vetService,
    this.trainingType,
    this.taxiType,
    required this.phoneNumber,
    this.createdAt,
  });

  factory OrderModel.fromMap(String id, Map<String, dynamic> data) {
    return OrderModel(
      id: id,
      userId: data['userId'] ?? '',
      serviceType: data['serviceType'] ?? '',
      specificService: data['specificService'] ?? '',
      petName: data['petName'] ?? '',
      location: data['location'] ?? '',
      date: data['date'] ?? '',
      time: data['time'] ?? '',
      price: (data['price'] ?? 0).toInt(),
      status: data['status'] ?? 'active',
      notes: data['notes'] ?? '',
      petAge: data['petAge'] ?? '',
      petGender: data['petGender'] ?? '',
      petColor: data['petColor'] ?? '',
      petImageUrl: data['petImageUrl'],
      minRating: (data['minRating'] ?? 0).toDouble(),
      serviceCategory: data['serviceCategory'] ?? '',
      lat: data['lat'] != null ? (data['lat']).toDouble() : null,
      lng: data['lng'] != null ? (data['lng']).toDouble() : null,
      walkingHours: data['walkingHours'],
      boardingDays: data['boardingDays'],
      groomingService: data['groomingService'],
      vetService: data['vetService'],
      trainingType: data['trainingType'],
      taxiType: data['taxiType'],
      phoneNumber: data['phoneNumber'] ?? '',
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'serviceType': serviceType,
      'specificService': specificService,
      'petName': petName,
      'location': location,
      'date': date,
      'time': time,
      'price': price,
      'status': status,
      'notes': notes,
      'petAge': petAge,
      'petGender': petGender,
      'petColor': petColor,
      'petImageUrl': petImageUrl,
      'minRating': minRating,
      'serviceCategory': serviceCategory,
      'lat': lat,
      'lng': lng,
      'walkingHours': walkingHours,
      'boardingDays': boardingDays,
      'groomingService': groomingService,
      'vetService': vetService,
      'trainingType': trainingType,
      'taxiType': taxiType,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt != null 
          ? Timestamp.fromDate(createdAt!) 
          : FieldValue.serverTimestamp(),
    };
  }
  
  String getServiceDetails() {
    switch (specificService) {
      case "walking":
        return "Выгул: $walkingHours ч";
      case "boarding":
        return "Передержка: $boardingDays дн";
      case "grooming":
        return "Груминг: $groomingService";
      case "vet":
        return "Ветпомощь: $vetService";
      case "training":
        return "Дрессировка: $trainingType";
      case "taxi":
        return "Зоотакси: $taxiType";
      default:
        return "";
    }
  }
  
  String getFormattedPrice() {
    return "$price ₸";
  }
  
  bool isActive() {
    return status == "active" || status == "in_progress";
  }
  
  // //  Получить цвет статуса допольнительная фунция которую можно добаить позже (в обновлениях)
  // Color getStatusColor() {
  //   switch (status) {
  //     case "completed":
  //       return Colors.green;
  //     case "cancelled":
  //       return Colors.red;
  //     case "in_progress":
  //       return Colors.orange;
  //     default:
  //       return Colors.blue;
  //   }
  // }
  
  String getStatusText() {
    switch (status) {
      case "completed":
        return "Выполнен";
      case "cancelled":
        return "Отменен";
      case "in_progress":
        return "В процессе";
      default:
        return "Активен";
    }
  }
  
  // // Получить иконку статуса пока не реализован и не нужен пока что 
  // IconData getStatusIcon() {
  //   switch (status) {
  //     case "completed":
  //       return Icons.check_circle;
  //     case "cancelled":
  //       return Icons.cancel;
  //     case "in_progress":
  //       return Icons.play_circle;
  //     default:
  //       return Icons.pending;
  //   }
  // }
}