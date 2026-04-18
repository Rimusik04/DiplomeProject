import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'package:firebase_auth/firebase_auth.dart';

import '../services/oreder_service.dart';
import '../models/order_model.dart';

class CreateOrderPage extends StatefulWidget {
  final String serviceType;

  const CreateOrderPage({super.key, required this.serviceType});

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  // Основные поля
  final petController = TextEditingController();
  final addressController = TextEditingController();
  final commentController = TextEditingController();
  double? lat;
  double? lng;
  final ageController = TextEditingController();
  final colorController = TextEditingController();
  
  // Выбор услуг 
  String selectedSpecificService = "walking";
  String selectedServiceType = ""; 
  
  // часы для выгулов
  int selectedWalkingHours = 1;
  final List<int> walkingHours = [1, 2, 3, 4, 5];
  
  // и дни
  int selectedBoardingDays = 1;
  final List<int> boardingDays = [1, 2, 3, 4, 5, 6, 7];
  
  // Для гурминга
  String selectedGroomingService = "Стандарт";
  final List<String> groomingServices = [
    "Стандарт (мытье, стрижка)",
    "Полный (мытье, стрижка, когти, уши)",
    "VIP (все процедуры + спа)"
  ];
  
  // Для ветврачов
  String selectedVetService = "Осмотр";
  final List<String> vetServices = [
    "Осмотр",
    "Вакцинация",
    "Анализы",
    "Лечение",
    "Экстренная помощь"
  ];
  
  // Для дрессировки кого то 
  String selectedTrainingType = "Индивидуальная";
  final List<String> trainingTypes = [
    "Индивидуальная",
    "Групповая",
    "Коррекция поведения",
    "ОКД"
  ];
  
  // Для зоотакси (даже я использую только автобус...)
  String selectedTaxiType = "Стандарт";
  final List<String> taxiTypes = [
    "Стандарт",
    "С клеткой",
    "С ветеринаром",
    "Срочный"
  ];
  
  String selectedGender = "Мальчик";
  
  final dateController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  
  XFile? pickedImage;
  bool isLoading = false;
  
  //  номер телефона
  final phoneController = TextEditingController();
  
  final picker = ImagePicker();
  final OrderService service = OrderService();
  
  // облока
  final String cloudName = "dbyfybai7";
  final String uploadPreset = "socpet_upload";
  
  // стоимост
  int calculatePrice() {
    int basePrice = 0;
    
    switch (selectedSpecificService) {
      case "walking":
        basePrice = 1500 * selectedWalkingHours;
        break;
      case "boarding":
        basePrice = 3000 * selectedBoardingDays;
        break;
      case "grooming":
        switch (selectedGroomingService) {
          case "Стандарт (мытье, стрижка)":
            basePrice = 4000;
            break;
          case "Полный (мытье, стрижка, когти, уши)":
            basePrice = 6000;
            break;
          case "VIP (все процедуры + спа)":
            basePrice = 10000;
            break;
          default:
            basePrice = 4000;
        }
        break;
      case "vet":
        switch (selectedVetService) {
          case "Осмотр":
            basePrice = 5000;
            break;
          case "Вакцинация":
            basePrice = 8000;
            break;
          case "Анализы":
            basePrice = 7000;
            break;
          case "Лечение":
            basePrice = 10000;
            break;
          case "Экстренная помощь":
            basePrice = 15000;
            break;
          default:
            basePrice = 5000;
        }
        break;
      case "training":
        switch (selectedTrainingType) {
          case "Индивидуальная":
            basePrice = 5000;
            break;
          case "Групповая":
            basePrice = 3000;
            break;
          case "Коррекция поведения":
            basePrice = 7000;
            break;
          case "ОКД":
            basePrice = 6000;
            break;
          default:
            basePrice = 5000;
        }
        break;
      case "taxi":
        switch (selectedTaxiType) {
          case "Стандарт":
            basePrice = 2000;
            break;
          case "С клеткой":
            basePrice = 3000;
            break;
          case "С ветеринаром":
            basePrice = 5000;
            break;
          case "Срочный":
            basePrice = 4000;
            break;
          default:
            basePrice = 2000;
        }
        break;
      default:
        basePrice = 2500;
    }
    
    return basePrice;
  }
  
  String getServiceDetails() {
    switch (selectedSpecificService) {
      case "walking":
        return "Выгул: $selectedWalkingHours ч";
      case "boarding":
        return "Передержка: $selectedBoardingDays дн";
      case "grooming":
        return "Груминг: $selectedGroomingService";
      case "vet":
        return "Ветпомощь: $selectedVetService";
      case "training":
        return "Дрессировка: $selectedTrainingType";
      case "taxi":
        return "Зоотакси: $selectedTaxiType";
      default:
        return "";
    }
  }
  
  //  фото
  Future pickImage() async {
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        pickedImage = image;
      });
    }
  }
  
  // загрузка в Cloudinary облока
  Future<String> uploadImage() async {
    final file = File(pickedImage!.path);
    
    final url = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload");
    
    var request = http.MultipartRequest("POST", url);
    request.fields['upload_preset'] = uploadPreset;
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    
    final response = await request.send();
    
    if (response.statusCode == 200) {
      final res = await response.stream.bytesToString();
      final data = jsonDecode(res);
      return data["secure_url"];
    } else {
      throw Exception("Ошибка загрузки изображения");
    }
  }
  
  // дата
  Future pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateController.text = DateFormat('dd.MM.yyyy').format(picked);
      });
    }
  }
  
  // время
  Future pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }
  
  Future getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Включи геолокацию")),
      );
      return;
    }
    
    permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Нет доступа к геолокации")),
      );
      return;
    }
    
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    
    lat = position.latitude;
    lng = position.longitude;
    
    List<Placemark> placemarks =
        await placemarkFromCoordinates(lat!, lng!);
    
    Placemark place = placemarks[0];
    
    String address =
        "${place.locality}, ${place.street}, ${place.name}";
    
    setState(() {
      lat = position.latitude;
      lng = position.longitude;
      addressController.text = address;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Адрес: $address")),
    );
  }
  
  // создание заказа
  Future createOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) return;
    
    if (petController.text.isEmpty ||
        addressController.text.isEmpty ||
        selectedDate == null ||
        pickedImage == null ||
        phoneController.text.isEmpty) {
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Заполни все обязательные поля")),
      );
      return;
    }
    
    if (selectedTime == null && selectedSpecificService != "boarding") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Выберите время")),
      );
      return;
    }
    
    setState(() => isLoading = true);
    
    try {
      final imageUrl = await uploadImage();
      
      final order = OrderModel(
        id: '',
        userId: user.uid,
        serviceType: widget.serviceType,
        specificService: selectedSpecificService,
        petName: petController.text,
        location: addressController.text,
        date: dateController.text,
        time: selectedTime != null 
            ? selectedTime!.format(context) 
            : "12:00",
        price: calculatePrice(),
        status: "active",
        notes: commentController.text,
        
        petAge: ageController.text,
        petGender: selectedGender,
        petColor: colorController.text,
        petImageUrl: imageUrl,
        
        minRating: 0,
        serviceCategory: selectedSpecificService,
        
        lat: lat,
        lng: lng,
        
        walkingHours: selectedSpecificService == "walking" ? selectedWalkingHours : null,
        boardingDays: selectedSpecificService == "boarding" ? selectedBoardingDays : null,
        groomingService: selectedSpecificService == "grooming" ? selectedGroomingService : null,
        vetService: selectedSpecificService == "vet" ? selectedVetService : null,
        trainingType: selectedSpecificService == "training" ? selectedTrainingType : null,
        taxiType: selectedSpecificService == "taxi" ? selectedTaxiType : null,
        
        //  телефон
        phoneNumber: phoneController.text,
      );
      
      await service.createOrder(order);
      
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Заказ создан")),
      );
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка: $e")),
      );
    }
    
    setState(() => isLoading = false);
  }
  
  @override
  void initState() {
    super.initState();
    selectedSpecificService = _getDefaultService();
  }
  
  String _getDefaultService() {
    switch (widget.serviceType) {
      case "walking":
        return "walking";
      case "boarding":
        return "boarding";
      case "grooming":
        return "grooming";
      case "vet":
        return "vet";
      case "training":
        return "training";
      case "taxi":
        return "taxi";
      default:
        return "walking";
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Новый заказ"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_hasSubServices()) ...[
                  _inputCard(
                    icon: Icons.build,
                    title: "Выберите услугу *",
                    child: _buildModernServiceSelector(),
                    isServiceSelector: true, 
                  ),
                  const SizedBox(height: 16),
                ],
                
                _buildDynamicServiceOptions(),
                
                const SizedBox(height: 16),
                
                _inputCard(
                  icon: Icons.pets,
                  title: "Имя питомца *",
                  child: TextField(
                    controller: petController,
                    decoration: const InputDecoration(
                      hintText: "Например: Бобик",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                _inputCard(
                  icon: Icons.image,
                  title: "Фото питомца *",
                  child: GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: pickedImage == null
                          ? const Center(child: Text("Выбрать фото"))
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(pickedImage!.path),
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                _inputCard(
                  icon: Icons.cake,
                  title: "Возраст",
                  child: TextField(
                    controller: ageController,
                    decoration: const InputDecoration(
                      hintText: "Например: 2 года",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                _inputCard(
                  icon: Icons.pets,
                  title: "Пол",
                  child: DropdownButton<String>(
                    value: selectedGender,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: ["Мальчик", "Девочка"]
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => selectedGender = value!);
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
                
                _inputCard(
                  icon: Icons.color_lens,
                  title: "Цвет",
                  child: TextField(
                    controller: colorController,
                    decoration: const InputDecoration(
                      hintText: "Например: Рыжий",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                _inputCard(
                  icon: Icons.map,
                  title: "Местоположение *",
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: getLocation,
                        icon: const Icon(Icons.my_location),
                        label: const Text("Определить местоположение"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink.shade50,
                          foregroundColor: Colors.pink,
                        ),
                      ),
                      if (addressController.text.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  addressController.text,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                _inputCard(
                  icon: Icons.calendar_today,
                  title: "Дата *",
                  child: TextField(
                    controller: dateController,
                    readOnly: true,
                    onTap: pickDate,
                    decoration: const InputDecoration(
                      hintText: "Выберите дату",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Время (быстрая река)
                if (selectedSpecificService != "boarding") ...[
                  _inputCard(
                    icon: Icons.access_time,
                    title: "Время *",
                    child: GestureDetector(
                      onTap: pickTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          selectedTime != null 
                              ? selectedTime!.format(context) 
                              : "Выберите время",
                          style: TextStyle(
                            color: selectedTime != null ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                _inputCard(
                  icon: Icons.phone,
                  title: "Контактный номер *",
                  child: TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: "+7 705 386 81 71",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                _inputCard(
                  icon: Icons.notes,
                  title: "Комментарий",
                  child: TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: "Особенности питомца, пожелания...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                _priceCard(),
              ],
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : createOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Подтвердить заказ",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          )
        ],
      ),
    );
  }
  
  bool _hasSubServices() {
    return widget.serviceType == "walking" || 
           widget.serviceType == "boarding" ||
           widget.serviceType == "grooming" ||
           widget.serviceType == "vet" ||
           widget.serviceType == "training" ||
           widget.serviceType == "taxi";
  }
  Widget _buildServiceSelector() {
  List<Map<String, String>> services = [];
  
  switch (widget.serviceType) {
    case "walking":
      services = [
        {"value": "walking", "label": "🐕 Выгул собак", "icon": "🐕"},
      ];
      break;
    case "boarding":
      services = [
        {"value": "boarding", "label": "🏠 Передержка", "icon": "🏠"},
      ];
      break;
    case "grooming":
      services = [
        {"value": "grooming", "label": "✂️ Груминг", "icon": "✂️"},
      ];
      break;
    case "vet":
      services = [
        {"value": "vet", "label": "🏥 Ветпомощь на дому", "icon": "🏥"},
      ];
      break;
    case "training":
      services = [
        {"value": "training", "label": "🎓 Дрессировка", "icon": "🎓"},
      ];
      break;
    case "taxi":
      services = [
        {"value": "taxi", "label": "🚕 Зоотакси", "icon": "🚕"},
      ];
      break;
    default:
      services = [
        {"value": "walking", "label": "Выгул", "icon": "🐕"},
      ];
  }
  
  return Container(
    constraints: const BoxConstraints(minHeight: 50),
    child: DropdownButton<String>(
      value: selectedSpecificService,
      isExpanded: true,
      underline: Container(
        height: 1,
        color: Colors.grey[300],
      ),
      items: services.map((service) {
        return DropdownMenuItem(
          value: service["value"],
          child: Row(
            children: [
              Text(
                service["icon"] ?? "📌",
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 12),
              Text(
                service["label"] ?? "",
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedSpecificService = value!;
        });
      },
    ),
  );
}
  Widget _buildDynamicServiceOptions() {
    switch (selectedSpecificService) {
      case "walking":
        return _inputCard(
          icon: Icons.timer,
          title: "Длительность выгула *",
          child: Column(
            children: [
              Wrap(
                spacing: 8,
                children: walkingHours.map((hours) {
                  return FilterChip(
                    label: Text("$hours ч"),
                    selected: selectedWalkingHours == hours,
                    onSelected: (selected) {
                      setState(() {
                        selectedWalkingHours = hours;
                      });
                    },
                    selectedColor: Colors.pink.shade100,
                    checkmarkColor: Colors.pink,
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Text(
                "Максимум 5 часов",
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        );
        
      case "boarding":
        return _inputCard(
          icon: Icons.calendar_today,
          title: "Длительность передержки *",
          child: Column(
            children: [
              Wrap(
                spacing: 8,
                children: boardingDays.map((days) {
                  return FilterChip(
                    label: Text("$days дн"),
                    selected: selectedBoardingDays == days,
                    onSelected: (selected) {
                      setState(() {
                        selectedBoardingDays = days;
                      });
                    },
                    selectedColor: Colors.pink.shade100,
                    checkmarkColor: Colors.pink,
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Text(
                "от 1 дня до 1 недели",
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        );
        
      case "grooming":
        return _inputCard(
          icon: Icons.spa,
          title: "Тип груминга *",
          child: Column(
            children: groomingServices.map((service) {
              return RadioListTile<String>(
                title: Text(service),
                value: service,
                groupValue: selectedGroomingService,
                onChanged: (value) {
                  setState(() {
                    selectedGroomingService = value!;
                  });
                },
                activeColor: Colors.pink,
                contentPadding: EdgeInsets.zero,
              );
            }).toList(),
          ),
        );
        
      case "vet":
        return _inputCard(
          icon: Icons.medical_services,
          title: "Тип помощи *",
          child: Column(
            children: vetServices.map((service) {
              return RadioListTile<String>(
                title: Text(service),
                value: service,
                groupValue: selectedVetService,
                onChanged: (value) {
                  setState(() {
                    selectedVetService = value!;
                  });
                },
                activeColor: Colors.pink,
                contentPadding: EdgeInsets.zero,
              );
            }).toList(),
          ),
        );
        
      case "training":
        return _inputCard(
          icon: Icons.school,
          title: "Тип дрессировки *",
          child: Column(
            children: trainingTypes.map((type) {
              return RadioListTile<String>(
                title: Text(type),
                value: type,
                groupValue: selectedTrainingType,
                onChanged: (value) {
                  setState(() {
                    selectedTrainingType = value!;
                  });
                },
                activeColor: Colors.pink,
                contentPadding: EdgeInsets.zero,
              );
            }).toList(),
          ),
        );
        
      case "taxi":
        return _inputCard(
          icon: Icons.local_taxi,
          title: "Тип такси *",
          child: Column(
            children: taxiTypes.map((type) {
              return RadioListTile<String>(
                title: Text(type),
                value: type,
                groupValue: selectedTaxiType,
                onChanged: (value) {
                  setState(() {
                    selectedTaxiType = value!;
                  });
                },
                activeColor: Colors.pink,
                contentPadding: EdgeInsets.zero,
              );
            }).toList(),
          ),
        );
        
      default:
        return const SizedBox();
    }
  }
  Widget _inputCard({
  required IconData icon,
  required String title,
  required Widget child,
  bool isServiceSelector = false,
}) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 5,
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.pink.shade400, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              isServiceSelector 
                  ? child 
                  : ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 40),
                      child: child,
                    ),
            ],
          ),
        )
      ],
    ),
  );
}
  Widget _buildModernServiceSelector() {
  String getSelectedLabel() {
    switch (selectedSpecificService) {
      case "walking":
        return "🐕 Выгул собак";
      case "boarding":
        return "🏠 Передержка";
      case "grooming":
        return "✂️ Груминг";
      case "vet":
        return "🏥 Ветпомощь на дому";
      case "training":
        return "🎓 Дрессировка";
      case "taxi":
        return "🚕 Зоотакси";
      default:
        return "Выберите услугу";
    }
  }
  
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey[300]!),
      borderRadius: BorderRadius.circular(12),
    ),
    child: PopupMenuButton<String>(
      initialValue: selectedSpecificService,
      onSelected: (value) {
        setState(() {
          selectedSpecificService = value;
        });
      },
      itemBuilder: (context) {
        return [
          const PopupMenuItem(
            value: "walking",
            child: Row(
              children: [
                Text("🐕", style: TextStyle(fontSize: 20)),
                SizedBox(width: 12),
                Text("Выгул собак"),
              ],
            ),
          ),
          const PopupMenuItem(
            value: "boarding",
            child: Row(
              children: [
                Text("🏠", style: TextStyle(fontSize: 20)),
                SizedBox(width: 12),
                Text("Передержка"),
              ],
            ),
          ),
          const PopupMenuItem(
            value: "grooming",
            child: Row(
              children: [
                Text("✂️", style: TextStyle(fontSize: 20)),
                SizedBox(width: 12),
                Text("Груминг"),
              ],
            ),
          ),
          const PopupMenuItem(
            value: "vet",
            child: Row(
              children: [
                Text("🏥", style: TextStyle(fontSize: 20)),
                SizedBox(width: 12),
                Text("Ветпомощь на дому"),
              ],
            ),
          ),
          const PopupMenuItem(
            value: "training",
            child: Row(
              children: [
                Text("🎓", style: TextStyle(fontSize: 20)),
                SizedBox(width: 12),
                Text("Дрессировка"),
              ],
            ),
          ),
          const PopupMenuItem(
            value: "taxi",
            child: Row(
              children: [
                Text("🚕", style: TextStyle(fontSize: 20)),
                SizedBox(width: 12),
                Text("Зоотакси"),
              ],
            ),
          ),
        ];
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            getSelectedLabel(),
            style: const TextStyle(fontSize: 16),
          ),
          Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
        ],
      ),
    ),
  );
}
  Widget _priceCard() {
    int price = calculatePrice();
    String details = getServiceDetails();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Стоимость услуги",
                style: TextStyle(fontSize: 16),
              ),
              Text(
                "$price ₸",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                ),
              ),
            ],
          ),
          if (details.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              details,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Цена может быть скорректирована после обсуждения с исполнителем",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}