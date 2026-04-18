import 'package:flutter/material.dart';
import 'worker_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Worker {
  final String id;
  final String name;
  final int age;
  final String experience;
  final int price;
  final String priceUnit;
  final double rating;
  final int reviews;
  final bool isOnline;
  final String avatarUrl;
  final String bio;
  final int completedOrders;
  final String responseTime;
  final String location;
  final List<String> languages;
  final bool verified;
  final List<String> skills;
  final List<String> serviceTypes;

  const Worker({
    required this.id,
    required this.name,
    required this.age,
    required this.experience,
    required this.price,
    required this.priceUnit,
    required this.rating,
    required this.reviews,
    required this.isOnline,
    required this.avatarUrl,
    required this.bio,
    required this.completedOrders,
    required this.responseTime,
    required this.location,
    required this.languages,
    required this.verified,
    required this.skills,
    required this.serviceTypes,
  });

  String get formattedPrice => "$price ₸";
}

class WorkerCard extends StatelessWidget {
  final Worker worker;

  const WorkerCard({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WorkerProfilePage(
              name: worker.name,
              workerId: worker.id,
              workerData: {
                'experience': worker.experience,
                'bio': worker.bio,
                'rating': worker.rating,
                'reviews': worker.reviews,
                'isOnline': worker.isOnline,
                'avatarUrl': worker.avatarUrl,
                'location': worker.location,
                'completedOrders': worker.completedOrders,
                'responseTime': worker.responseTime,
                'languages': worker.languages,
                'skillsList': worker.skills,
              },
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundImage: NetworkImage(worker.avatarUrl),
                        child: worker.avatarUrl.isEmpty
                            ? const Icon(Icons.person, size: 40)
                            : null,
                      ),
                      if (worker.verified)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.verified,
                              size: 14,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      if (worker.isOnline)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                worker.name,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (worker.verified)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "Проверен",
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 12, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              worker.location,
                              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              worker.responseTime,
                              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: worker.skills.take(2).map((skill) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.pink.shade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                skill,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.pink.shade700,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatChip(
                        Icons.star,
                        "${worker.rating}",
                        "(${worker.reviews})",
                        Colors.orange,
                      ),
                      _buildStatChip(
                        Icons.work,
                        worker.experience,
                        "опыта",
                        Colors.blue,
                      ),
                      _buildStatChip(
                        Icons.check_circle,
                        "${worker.completedOrders}",
                        "заказов",
                        Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.format_quote, size: 14, color: Colors.pink.shade300),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            worker.bio,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "от ${worker.formattedPrice}",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.pink,
                              ),
                            ),
                            Text(
                              "/ ${worker.priceUnit}",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 110,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => WorkerProfilePage(
                                  name: worker.name,
                                  workerId: worker.id,
                                  workerData: {
                                    'experience': worker.experience,
                                    'bio': worker.bio,
                                    'rating': worker.rating,
                                    'reviews': worker.reviews,
                                    'isOnline': worker.isOnline,
                                    'avatarUrl': worker.avatarUrl,
                                    'location': worker.location,
                                    'completedOrders': worker.completedOrders,
                                    'responseTime': worker.responseTime,
                                    'languages': worker.languages,
                                    'skillsList': worker.skills,
                                  },
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Выбрать",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String mainText, String subText, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            mainText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            " $subText",
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class OrderDetailPage extends StatefulWidget {
  final String orderId;
  final Map<String, dynamic> orderData;
  final String userName;

  const OrderDetailPage({
    super.key,
    required this.orderId,
    required this.orderData,
    required this.userName,
  });

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  
  @override
  void initState() {
    super.initState();
    _setupMarkers();
  }
  
  void _setupMarkers() {
    final lat = widget.orderData['lat'];
    final lng = widget.orderData['lng'];
    
    if (lat != null && lng != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId("order_location"),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: widget.orderData['petName'] ?? "Питомец",
            snippet: widget.orderData['location'] ?? "Адрес",
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.orderData;
    final petImageUrl = order['petImageUrl'];
    final lat = order['lat'];
    final lng = order['lng'];
    final phoneNumber = order['phoneNumber'];
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Детали заказа"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                image: petImageUrl != null && petImageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(petImageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: petImageUrl == null || petImageUrl.isEmpty
                  ? const Center(
                      child: Icon(Icons.pets, size: 80, color: Colors.grey),
                    )
                  : null,
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          order['petName'] ?? "Без имени",
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.pink.shade50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          "${order['price'] ?? 0} ₸",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Инфо питомца
                  _buildDetailSection(
                    "О питомце",
                    Icons.pets,
                    [
                      _buildDetailRow(Icons.category, "Вид", order['petType'] ?? "Собака"),
                      _buildDetailRow(Icons.cake, "Возраст", order['petAge'] ?? "Не указан"),
                      _buildDetailRow(
                        order['petGender'] == "Мальчик" ? Icons.male : Icons.female,
                        "Пол",
                        order['petGender'] ?? "Не указан",
                      ),
                      _buildDetailRow(Icons.color_lens, "Цвет", order['petColor'] ?? "Не указан"),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Инфо о заказе
                  _buildDetailSection(
                    "Детали заказа",
                    Icons.receipt,
                    [
                      _buildDetailRow(Icons.person, "Заказчик", widget.userName),
                      _buildDetailRow(Icons.calendar_today, "Дата", order['date'] ?? "Не указана"),
                      _buildDetailRow(Icons.location_on, "Адрес", order['location'] ?? "Не указан"),
                      if (phoneNumber != null && phoneNumber.isNotEmpty)
                        _buildDetailRow(Icons.phone, "Телефон", phoneNumber),
                    ],
                  ),
                  
                  if (order['notes'] != null && order['notes'].toString().isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildDetailSection(
                      "Комментарий",
                      Icons.notes,
                      [
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            order['notes'],
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[800],
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  // Карта сокровищ но пока выдает оооочень большие ошибки
                  // if (lat != null && lng != null) ...[
                  //   const SizedBox(height: 24),
                  //   _buildDetailSection(
                  //     "Местоположение",
                  //     Icons.map,
                  //     [
                  //       Container(
                  //         height: 250,
                  //         margin: const EdgeInsets.only(top: 12),
                  //         decoration: BoxDecoration(
                  //           borderRadius: BorderRadius.circular(16),
                  //           boxShadow: [
                  //             BoxShadow(
                  //               color: Colors.black.withOpacity(0.1),
                  //               blurRadius: 8,
                  //               offset: const Offset(0, 2),
                  //             ),
                  //           ],
                  //         ),
                  //         child: ClipRRect(
                  //           borderRadius: BorderRadius.circular(16),
                  //           child: GoogleMap(
                  //             initialCameraPosition: CameraPosition(
                  //               target: LatLng(lat, lng),
                  //               zoom: 15,
                  //             ),
                  //             markers: _markers,
                  //             onMapCreated: (controller) {
                  //               _mapController = controller;
                  //             },
                  //             myLocationEnabled: true,
                  //             myLocationButtonEnabled: true,
                  //             zoomControlsEnabled: true,
                  //           ),
                  //         ),
                  //       ),
                  //       const SizedBox(height: 12),
                  //       TextButton.icon(
                  //         onPressed: () {
                  //           final url = "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
                  //         },
                  //         icon: const Icon(Icons.open_in_new),
                  //         label: const Text("Открыть в картах"),
                  //         style: TextButton.styleFrom(
                  //           foregroundColor: Colors.pink,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ],
                  
                  const SizedBox(height: 32),
                  
                  if (order['status'] == "active") ...[
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await _updateStatus("in_progress");
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.check_circle),
                            label: const Text("Принять заказ"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _showCancelDialog();
                            },
                            icon: const Icon(Icons.cancel),
                            label: const Text("Отклонить"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  if (order['status'] == "in_progress") ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await _updateStatus("completed");
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.check_circle),
                        label: const Text("Завершить заказ"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.pink.shade700, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
  
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _updateStatus(String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .update({'status': status});
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == "completed" 
                ? "Заказ завершен! 🎉" 
                : status == "in_progress"
                ? "Заказ принят! 📞"
                : "Статус обновлен",
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Ошибка: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Отклонить заказ"),
          content: const Text("Вы уверены, что хотите отклонить этот заказ?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Отмена"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _updateStatus("cancelled");
                Navigator.pop(context);
              },
              child: const Text(
                "Отклонить",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}

class WorkersPage extends StatefulWidget {
  final String serviceType;

  const WorkersPage({super.key, required this.serviceType});

  @override
  State<WorkersPage> createState() => _WorkersPageState();
}

class _WorkersPageState extends State<WorkersPage> {
  int selectedTab = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String getServiceTitle() {
    switch (widget.serviceType) {
      case "walking":
        return "Выгул собак";
      case "boarding":
        return "Передержка";
      case "grooming":
        return "Груминг";
      case "vet":
        return "Ветпомощь на дому";
      case "training":
        return "Дрессировка";
      case "taxi":
        return "Зоотакси";
      default:
        return widget.serviceType;
    }
  }

  String _getSpecificService() {
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

  Future<String> getUserName(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      
      if (userDoc.exists) {
        final data = userDoc.data();
        return data?['name'] ?? data?['username'] ?? userId.substring(0, 8);
      }
      return userId.substring(0, 8);
    } catch (e) {
      return userId.substring(0, 8);
    }
  }

  Widget _ordersList() {
    final String specificService = _getSpecificService();
    
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('specificService', isEqualTo: specificService)
          // .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  "Нет заказов",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                Text(
                  "Здесь будут отображаться ваши заказы",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index];
            final order = data.data() as Map<String, dynamic>;
            
            return FutureBuilder<String>(
              future: getUserName(order['userId']),
              builder: (context, userSnapshot) {
                final userName = userSnapshot.data ?? "Пользователь";
                return _buildOrderCard(context, data.id, order, userName);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, String orderId, Map<String, dynamic> order, String userName) {
    final petName = order['petName'] ?? "Без имени";
    final location = order['location'] ?? "Не указано";
    final date = order['date'] ?? "Не указана";
    final price = order['price'] ?? 0;
    final status = order['status'] ?? "active";
    final petType = order['petType'] ?? "Собака";
    final description = order['notes'] ?? order['description'] ?? "";
    final petImageUrl = order['petImageUrl'];
    final petAge = order['petAge'] ?? "Не указан";
    final petGender = order['petGender'] ?? "Не указан";
    final petColor = order['petColor'] ?? "Не указан";
    final lat = order['lat'];
    final lng = order['lng'];
    final phoneNumber = order['phoneNumber'] ?? "Не указан";
    final currentUser = FirebaseAuth.instance.currentUser;
    final isOwner = currentUser?.uid == order['userId'];
    
    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    switch (status) {
      case "completed":
        statusColor = Colors.green;
        statusText = "Выполнен";
        statusIcon = Icons.check_circle;
        break;
      case "cancelled":
        statusColor = Colors.red;
        statusText = "Отменен";
        statusIcon = Icons.cancel;
        break;
      case "in_progress":
        statusColor = Colors.orange;
        statusText = "В процессе";
        statusIcon = Icons.play_circle;
        break;
      default:
        statusColor = Colors.blue;
        statusText = "Активен";
        statusIcon = Icons.pending;
    }
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderDetailPage(
              orderId: orderId,
              orderData: order,
              userName: userName,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: petImageUrl != null && petImageUrl.isNotEmpty
                      ? Image.network(
                          petImageUrl,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 180,
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(Icons.pets, size: 60, color: Colors.grey),
                              ),
                            );
                          },
                        )
                      : Container(
                          height: 180,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.pets, size: 60, color: Colors.grey),
                          ),
                        ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          petName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.pink.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.attach_money, size: 16, color: Colors.pink.shade700),
                            const SizedBox(width: 4),
                            Text(
                              "$price ₸",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.pink.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(Icons.category, petType),
                      _buildInfoChip(Icons.cake, petAge),
                      _buildInfoChip(
                        petGender == "Мальчик" ? Icons.male : Icons.female,
                        petGender,
                      ),
                      _buildInfoChip(Icons.color_lens, petColor),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        userName,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        phoneNumber,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.notes, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              description,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (status == "active" && !isOwner) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await _updateOrderStatus(orderId, "in_progress");
                            },
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text("Принять заказ"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _showCancelDialog(context, orderId);
                            },
                            icon: const Icon(Icons.close, size: 18),
                            label: const Text("Отклонить"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (status == "in_progress" && !isOwner) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await _updateOrderStatus(orderId, "completed");
                        },
                        icon: const Icon(Icons.check_circle, size: 18),
                        label: const Text("Завершить заказ"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateOrderStatus(String orderId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({'status': status});
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == "completed" 
                ? "Заказ завершен! Спасибо за работу " 
                : status == "in_progress"
                ? "Заказ принят! Свяжитесь с клиентом для уточнения деталей "
                : "Статус заказа обновлен",
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Ошибка: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCancelDialog(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Отклонить заказ"),
          content: const Text("Вы уверены, что хотите отклонить этот заказ?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Отмена"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _updateOrderStatus(orderId, "cancelled");
              },
              child: const Text(
                "Отклонить",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Worker> allWorkers = [
      Worker(
        id: "1",
        name: "Алексей",
        age: 28,
        experience: "3 года",
        price: 2000,
        priceUnit: "прогулка",
        rating: 4.7,
        reviews: 24,
        isOnline: true,
        avatarUrl: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150",
        bio: "Люблю животных и активный отдых. Работаю с собаками любых пород.",
        completedOrders: 156,
        responseTime: "5-10 мин",
        location: "м. Алатау",
        languages: ["Русский", "Казахский"],
        verified: true,
        skills: ["Активные игры", "Дрессировка", "Фотоотчет"],
        serviceTypes: ["walking", "boarding"],
      ),
      Worker(
        id: "2",
        name: "Мария",
        age: 32,
        experience: "5 лет",
        price: 3000,
        priceUnit: "прогулка",
        rating: 4.9,
        reviews: 58,
        isOnline: false,
        avatarUrl: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150",
        bio: "Профессиональный кинолог с высшим образованием. Индивидуальный подход.",
        completedOrders: 342,
        responseTime: "15-20 мин",
        location: "м. Байконур",
        languages: ["Русский", "Английский"],
        verified: true,
        skills: ["Кинология", "Дрессировка", "Ветпомощь"],
        serviceTypes: ["walking", "training"],
      ),
      Worker(
        id: "3",
        name: "Дмитрий",
        age: 24,
        experience: "2 года",
        price: 1800,
        priceUnit: "прогулка",
        rating: 4.5,
        reviews: 12,
        isOnline: true,
        avatarUrl: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150",
        bio: "Энергичный и ответственный. Гарантирую безопасность и хорошее настроение.",
        completedOrders: 89,
        responseTime: "3-5 мин",
        location: "м. Абая",
        languages: ["Русский"],
        verified: false,
        skills: ["Активные игры", "Выгул в парке"],
        serviceTypes: ["walking"],
      ),
      Worker(
        id: "4",
        name: "Екатерина",
        age: 35,
        experience: "7 лет",
        price: 3500,
        priceUnit: "день",
        rating: 5.0,
        reviews: 124,
        isOnline: true,
        avatarUrl: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150",
        bio: "Ветеринар с опытом. Особый уход за пожилыми собаками и щенками.",
        completedOrders: 567,
        responseTime: "1-3 мин",
        location: "м. Жибек Жолы",
        languages: ["Русский", "Казахский", "Английский"],
        verified: true,
        skills: ["Ветпомощь", "Пожилые собаки", "Щенки"],
        serviceTypes: ["boarding", "vet"],
      ),
      Worker(
        id: "5",
        name: "Сергей",
        age: 29,
        experience: "4 года",
        price: 2500,
        priceUnit: "прогулка",
        rating: 4.8,
        reviews: 45,
        isOnline: false,
        avatarUrl: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150",
        bio: "Спортсмен, люблю длительные прогулки и активные игры. Есть свой транспорт.",
        completedOrders: 234,
        responseTime: "10-15 мин",
        location: "м. Саина",
        languages: ["Русский"],
        verified: true,
        skills: ["Длительные прогулки", "Бег с собакой", "Трансфер"],
        serviceTypes: ["walking", "taxi"],
      ),
    ];

    final filteredWorkers = allWorkers.where((worker) {
      return worker.serviceTypes.contains(_getSpecificService());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              getServiceTitle(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "${filteredWorkers.length} исполнителей",
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.filter_list),
          //   onPressed: () {
          //     _showFilterDialog(context);
          //   },
          // ),
          // IconButton(
          //   icon: const Icon(Icons.sort),
          //   onPressed: () {
          //     _showSortDialog(context);
          //   },
          // ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedTab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selectedTab == 0 ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(child: Text("Исполнители")),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedTab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selectedTab == 1 ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(child: Text("Заказы")),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: selectedTab == 0
                ? ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredWorkers.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: WorkerCard(worker: filteredWorkers[index]),
                      );
                    },
                  )
                : _ordersList(),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Фильтры",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text("Цена за услугу"),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildFilterChip("До 2000 ₸"),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFilterChip("2000-3000 ₸"),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFilterChip("От 3000 ₸"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text("Рейтинг"),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildFilterChip("4.5+"),
                  _buildFilterChip("4.7+"),
                  _buildFilterChip("4.9+"),
                ],
              ),
              const SizedBox(height: 20),
              const Text("Статус"),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildFilterChip("Онлайн"),
                  _buildFilterChip("Проверенные"),
                  _buildFilterChip("С отзывами"),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("Применить"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label) {
    return FilterChip(
      label: Text(label),
      onSelected: (bool selected) {},
      selected: false,
      backgroundColor: Colors.grey[100],
      selectedColor: Colors.pink[100],
      checkmarkColor: Colors.pink,
    );
  }

  void _showSortDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Сортировка",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildSortOption(context, "По рейтингу", true),
              _buildSortOption(context, "По цене (возрастание)", false),
              _buildSortOption(context, "По цене (убывание)", false),
              _buildSortOption(context, "По опыту", false),
              _buildSortOption(context, "По отзывам", false),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(BuildContext context, String title, bool isSelected) {
    return ListTile(
      title: Text(title),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.pink) : null,
      onTap: () => Navigator.pop(context),
    );
  }
}