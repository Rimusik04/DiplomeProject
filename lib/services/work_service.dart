import 'package:flutter/material.dart';
import '../screens/worker_page.dart';
// import '../screens/boarding_page.dart'; 

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  final List<ServiceData> services = const [
    ServiceData(
      name: "Выгул собак",
      priceFrom: 1500,
      priceTo: 3000,
      rating: 4.85,
      reviewsCount: 234,
      description: "Профессиональный выгул с активными играми, тренировками и социализацией вашего питомца",
      fullDescription: "Индивидуальный подход к каждой собаке. Прогулка длительностью от 30 минут до 2 часов. Включает активные игры, дрессировку по желанию, фотоотчет и уход после прогулки.",
      icon: Icons.directions_walk,
      serviceType: "walking",
      imageUrl: "https://images.unsplash.com/photo-1548199973-03cce0bbc87b?w=500",
      features: ["🐕 Индивидуальный подход", "🎾 Активные игры", "📸 Фотоотчет", "🏃 Разные маршруты"],
      workersCount: 48,
      popularity: "🔥 Популярная услуга",
    ),
    ServiceData(
      name: "Передержка",
      priceFrom: 4000,
      priceTo: 8000,
      rating: 4.93,
      reviewsCount: 567,
      description: "Комфортное пребывание в домашних условиях с полным уходом",
      fullDescription: "Ваш питомец будет жить в комфортной домашней обстановке. Обеспечиваем полноценное питание, регулярные прогулки, медицинский уход при необходимости и ежедневные видеоотчеты.",
      icon: Icons.home,
      serviceType: "boarding",
      imageUrl: "https://images.unsplash.com/photo-1548767797-d8c844163c4c?w=500",
      features: ["🏡 Домашние условия", "🍖 Питание включено", "🚶 Прогулки 3 раза в день", "📹 Видеоотчеты"],
      workersCount: 32,
      popularity: "⭐ Рекомендуемая услуга",
    ),
    ServiceData(
      name: "Груминг",
      priceFrom: 3000,
      priceTo: 15000,
      rating: 4.78,
      reviewsCount: 189,
      description: "Профессиональный уход за шерстью, когтями и гигиеной",
      fullDescription: "Полный спектр услуг: стрижка, мытье, чистка ушей, стрижка когтей, гигиенический уход. Используем только профессиональную косметику и безопасные инструменты.",
      icon: Icons.content_cut,
      serviceType: "grooming",
      imageUrl: "https://images.unsplash.com/photo-1516734212186-a967f81ad0d7?w=500",
      features: ["✂️ Профессиональная стрижка", "🧴 Гипоаллергенная косметика", "🐾 Гигиенический уход", "💅 Стрижка когтей"],
      workersCount: 27,
      popularity: "✨ Новая услуга",
    ),
    ServiceData(
      name: "Ветпомощь на дому",
      priceFrom: 5000,
      priceTo: 20000,
      rating: 4.95,
      reviewsCount: 123,
      description: "Выезд ветеринара для осмотра, вакцинации и лечения",
      fullDescription: "Квалифицированная ветеринарная помощь на дому. Вакцинация, чипирование, осмотр, назначение лечения, забор анализов. Без стресса для питомца.",
      icon: Icons.medical_services,
      serviceType: "vet",
      imageUrl: "https://images.unsplash.com/photo-1576201836106-db1758fd1c97?w=500",
      features: ["💉 Вакцинация", "🩺 Профессиональный осмотр", "📋 Электронная карта", "🚗 Быстрый выезд"],
      workersCount: 15,
      popularity: "🏆 Топ-услуга",
    ),
    ServiceData(
      name: "Дрессировка",
      priceFrom: 2000,
      priceTo: 5000,
      rating: 4.88,
      reviewsCount: 312,
      description: "Индивидуальные занятия по послушанию и коррекции поведения",
      fullDescription: "Профессиональная дрессировка с учетом особенностей характера. Базовый курс послушания, коррекция поведения, подготовка к выставкам, обучение трюкам.",
      icon: Icons.psychology,
      serviceType: "training",
      imageUrl: "https://images.unsplash.com/photo-1588943211346-0908a1fb0b01?w=500",
      features: ["🐕 Базовое послушание", "🎯 Коррекция поведения", "🎪 Трюки и команды", "📜 Сертификат об обучении"],
      workersCount: 22,
      popularity: "🎓 Опытные кинологи",
    ),
    ServiceData(
      name: "Зоотакси",
      priceFrom: 1000,
      priceTo: 3000,
      rating: 4.82,
      reviewsCount: 445,
      description: "Безопасная перевозка питомцев по городу и области",
      fullDescription: "Специализированный транспорт с клетками и фиксаторами. Кондиционер, чистота, безопасность. Перевозка к ветеринару, грумеру, в аэропорт или на передержку.",
      icon: Icons.local_taxi,
      serviceType: "taxi",
      imageUrl: "https://images.unsplash.com/photo-1551326844-4df70f78d0e9?w=500",
      features: ["🚐 Специализированный транспорт", "🔒 Безопасная фиксация", "🌡️ Комфортный климат", "📞 Онлайн-отслеживание"],
      workersCount: 19,
      popularity: "🚀 Быстрая подача",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Услуги для питомцев",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: services.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ServiceCard(service: services[index]),
          );
        },
      ),
    );
  }
}

class ServiceData {
  final String name;
  final int priceFrom;
  final int priceTo;
  final double rating;
  final int reviewsCount;
  final String description;
  final String fullDescription;
  final IconData icon;
  final String serviceType;
  final String imageUrl;
  final List<String> features;
  final int workersCount;
  final String popularity;

  const ServiceData({
    required this.name,
    required this.priceFrom,
    required this.priceTo,
    required this.rating,
    required this.reviewsCount,
    required this.description,
    required this.fullDescription,
    required this.icon,
    required this.serviceType,
    required this.imageUrl,
    required this.features,
    required this.workersCount,
    required this.popularity,
  });

  String get priceRange => "$priceFrom - $priceTo ₸";
}
class ServiceCard extends StatelessWidget {
  final ServiceData service;

  const ServiceCard({super.key, required this.service});

  Widget _getServicePage() {
    switch (service.serviceType) {
      case "walking":
        return WorkersPage(serviceType: "walking");
      case "boarding":
        // return const BoardingPage();
        return WorkersPage(serviceType: "boarding");
      case "grooming":
        return WorkersPage(serviceType: "grooming");
      case "vet":
        return WorkersPage(serviceType: "vet");
      case "training":
        return WorkersPage(serviceType: "training");
      case "taxi":
        return WorkersPage(serviceType: "taxi");
      default:
        return WorkersPage(serviceType: service.serviceType);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _getServicePage(),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              child: Stack(
                children: [
                  Image.network(
                    service.imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        color: Colors.grey[200],
                        child: Icon(
                          service.icon,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                      );
                    },
                  ),
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Text(
                        service.popularity,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.pink,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          service.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              service.rating.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              " (${service.reviewsCount})",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service.description,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: service.features.map((feature) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.pink.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.pink.shade100,
                          ),
                        ),
                        child: Text(
                          feature,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.pink.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Цена за услугу",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              service.priceRange,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.pink,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Container(
                      //   padding: const EdgeInsets.symmetric(
                      //     horizontal: 12,
                      //     vertical: 8,
                      //   ),
                      //   decoration: BoxDecoration(
                      //     color: Colors.blue.shade50,
                      //     borderRadius: BorderRadius.circular(12),
                      //   ),
                        // child: Column(
                        //   children: [
                        //     Text(
                        //       "${service.workersCount}",
                        //       style: TextStyle(
                        //         fontSize: 18,
                        //         fontWeight: FontWeight.bold,
                        //         color: Colors.blue.shade700,
                        //       ),
                        //     ),
                        //     Text(
                        //       "исполнителей",
                        //       style: TextStyle(
                        //         fontSize: 11,
                        //         color: Colors.blue.shade600,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    // padding: const EdgeInsets.all(12),
                    // decoration: BoxDecoration(
                    //   color: Colors.grey.shade50,
                    //   borderRadius: BorderRadius.circular(12),
                    // ),
                    child: Row(
                      children: [
                        // Icon(
                        //   Icons.info_outline,
                        //   size: 18,
                        //   color: Colors.pink.shade400,
                        // ),
                        // const SizedBox(width: 8),
                        // Expanded(
                        //   child: Text(
                        //      service.fullDescription,
                        //     style: TextStyle(
                        //       fontSize: 12,
                        //       color: Colors.grey[700],
                        //       height: 1.4,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  // const SizedBox(height: 16),
                  // Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => _getServicePage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Выбрать исполнителя",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            size: 18,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}