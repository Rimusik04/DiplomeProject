import 'dart:convert';
import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';

class GroqService {
  // не смотри это мой API КЛЮЧ 
  static const String apiKey = 'const apiKey = "YOUR_API_KEY";';
  
  static const String model = 'llama-3.3-70b-versatile';
  
  Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': model,
          'messages': [
            {
              'role': 'system', 
              'content': 'Ты полезный ассистент для приложения SocPet. Отвечай кратко и по делу и конечно же только то что касается самого приложения или касаемо животных'
            },
            {'role': 'user', 'content': message}
          ],
          'temperature': 0.7,
          'max_tokens': 1000,
          'stream': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        print('Ошибка ${response.statusCode}: ${response.body}');
        return '❌ Ошибка: ${response.statusCode}';
      }
    } catch (e) {
      print('Исключение: $e');
      return '❌ Ошибка соединения. Проверь интернет.';
    }
  }
  
  Stream<String> sendMessageStream(String message) async* {
    final request = http.Request(
      'POST',
      Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
    );
    
    request.headers.addAll({
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    });
    
    request.body = jsonEncode({
      'model': model,
      'messages': [
        {'role': 'system', 'content': 'Ты полезный ассистент.'},
        {'role': 'user', 'content': message}
      ],
      'temperature': 0.7,
      'max_tokens': 1000,
      'stream': true,  
    });
    
    final response = await request.send();
    
    await for (var chunk in response.stream.transform(utf8.decoder).transform(const LineSplitter())) {
      if (chunk.startsWith('data: ') && chunk != 'data: [DONE]') {
        try {
          final jsonStr = chunk.substring(6);
          final data = jsonDecode(jsonStr);
          final content = data['choices'][0]['delta']['content'];
          if (content != null) {
            yield content;
          }
        } catch (e) {
          // Игнорируем ошибки парсинга
        }
      }
    }
  }
}