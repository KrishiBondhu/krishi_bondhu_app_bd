import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_tts/flutter_tts.dart';
// NEW IMPORT FOR LISTENING
import 'package:speech_to_text/speech_to_text.dart' as stt;

class WeatherForecastScreen extends StatefulWidget {
  const WeatherForecastScreen({Key? key}) : super(key: key);

  @override
  State<WeatherForecastScreen> createState() => _WeatherForecastScreenState();
}

class _WeatherForecastScreenState extends State<WeatherForecastScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FlutterTts _flutterTts = FlutterTts();
  // NEW VARIABLES FOR SPEECH RECOGNITION
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _weatherData;
  String _currentCity = "Dhaka";

  @override
  void initState() {
    super.initState();
    _initTts();
    _fetchWeatherForCity("Dhaka"); 
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("bn-BD");
    await _flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  // --- NEW: VOICE ASSISTANT FUNCTION ---
  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) => print('Speech Status: $status'),
        onError: (errorNotification) => print('Speech Error: $errorNotification'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            if (val.hasConfidenceRating && val.confidence > 0) {
              String command = val.recognizedWords.toLowerCase();
              // Simple keyword matching for demo purposes
              if (command.contains("bristi") || command.contains("বৃষ্টি")) {
                _replyAboutRain();
              }
            }
          },
          localeId: "bn_BD", // Try to listen in Bangla
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _replyAboutRain() {
    if (_weatherData == null) return;
    double rain = (_weatherData!['daily']['precipitation_sum'][0] as num).toDouble();
    if (rain > 1.0) {
      _speak("হ্যাঁ, আজ বৃষ্টির সম্ভাবনা আছে।"); // "Yes, chance of rain today."
    } else {
      _speak("না, আজ বৃষ্টির সম্ভাবনা নেই।"); // "No, no chance of rain today."
    }
  }
  // ------------------------------------

  @override
  void dispose() {
    _flutterTts.stop();
    _speech.stop();
    super.dispose();
  }

  // ... (Keep _getCoordinatesForCity and _fetchWeather same as before) ...
  Future<Map<String, double>> _getCoordinatesForCity(String city) async {
      // (Use the same code as before for brevity in this response, standard API call)
       try {
      final geoUrl = "https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeComponent(city)}&count=1";
      final response = await http.get(Uri.parse(geoUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          return {
            'latitude': data['results'][0]['latitude'] as double,
            'longitude': data['results'][0]['longitude'] as double,
          };
        } else {
          throw Exception("শহর খুঁজে পাওয়া যায়নি।");
        }
      } else {
        throw Exception("অবস্থান তথ্য পেতে ব্যর্থ হয়েছে।");
      }
    } catch (e) {
      throw Exception("ত্রুটি: ${e.toString()}");
    }
  }

  Future<void> _fetchWeather(double latitude, double longitude) async {
      // (Use the same code as before)
       try {
      final weatherUrl = 
          "https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current_weather=true&hourly=temperature_2m,weathercode,relativehumidity_2m,windspeed_10m&daily=weathercode,temperature_2m_max,temperature_2m_min,sunrise,sunset,precipitation_sum,windspeed_10m_max&timezone=auto";
      final response = await http.get(Uri.parse(weatherUrl));
      if (response.statusCode == 200) {
        setState(() {
          _weatherData = json.decode(response.body);
          _isLoading = false;
          _errorMessage = null;
        });
      } else {
        throw Exception("আবহাওয়া তথ্য লোড করতে ব্যর্থ হয়েছে।");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _fetchWeatherForCity(String city) async {
    if (city.isEmpty) return;
    setState(() { _isLoading = true; _errorMessage = null; _currentCity = city; });
    try {
      final coords = await _getCoordinatesForCity(city);
      await _fetchWeather(coords['latitude']!, coords['longitude']!);
    } catch (e) {
      setState(() { _isLoading = false; _errorMessage = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("আবহাওয়ার পূর্বাভাস"),
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
      ),
      // FLOATING MIC BUTTON FOR VOICE ASSISTANT
      floatingActionButton: FloatingActionButton(
        onPressed: _listen,
        backgroundColor: _isListening ? Colors.red : const Color(0xFF4CAF50),
        child: Icon(_isListening ? Icons.mic : Icons.mic_none, size: 30),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : _errorMessage != null 
              ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchCard(),
          const SizedBox(height: 20),
          _buildKrishiAlertBox(),
          const SizedBox(height: 20),
          _buildCurrentWeather(),
          const SizedBox(height: 30),
          
          // --- AJER KRISHI KAJ IS BACK HERE ---
          _buildSectionHeader("আজকের কৃষি কাজ", Icons.agriculture),
          _buildFarmingActivityGuide(),
          // ------------------------------------

          const SizedBox(height: 30),
          _buildSectionHeader("আজকের কৃষি তথ্য", Icons.analytics),
          _buildVitalAgriDataGrid(),
          const SizedBox(height: 30),
          _buildSectionHeader("ঘণ্টা অনুযায়ী পূর্বাভাস", Icons.access_time),
          _buildHourlyForecast(),
          const SizedBox(height: 30),
          _buildSectionHeader("আগামী ৭ দিন", Icons.calendar_today),
          _buildDailyForecast(),
          const SizedBox(height: 80), // Extra space for FAB
        ],
      ),
    );
  }

  // ... (Keep _buildSearchCard, _buildKrishiAlertBox, _buildCurrentWeather, _buildSectionHeader same as before) ...
   Widget _buildSearchCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "আপনার উপজেলার নাম লিখুন...",
          prefixIcon: const Icon(Icons.search, color: Colors.green),
          suffixIcon: IconButton(icon: const Icon(Icons.clear, color: Colors.grey), onPressed: _searchController.clear),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        onSubmitted: (value) => _fetchWeatherForCity(value),
      ),
    );
  }

  Widget _buildKrishiAlertBox() {
    final daily = _weatherData!['daily'];
    double rain = (daily['precipitation_sum'][0] as num).toDouble();
    double wind = (daily['windspeed_10m_max'][0] as num).toDouble();

    String text = "আজ আবহাওয়া কৃষি কাজের জন্য নিরাপদ।";
    Color color = Colors.green[700]!;
    Color bg = Colors.green[50]!;
    IconData icon = Icons.verified_user;

    if (rain > 10) {
      text = "সতর্কতা: আজ ভারী বৃষ্টির সম্ভাবনা! জমিতে সেচ বা সার দেবেন না।";
      color = Colors.red[700]!;
      bg = Colors.red[50]!;
      icon = Icons.warning;
    } else if (wind > 20) {
      text = "সতর্কতা: আজ বাতাসের গতি বেশি। কীটনাশক স্প্রে করা থেকে বিরত থাকুন।";
      color = Colors.orange[800]!;
      bg = Colors.orange[50]!;
      icon = Icons.flag;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.3))),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color))),
          IconButton(
            icon: const Icon(Icons.volume_up, size: 30),
            color: color,
            onPressed: () => _speak(text),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentWeather() {
    final current = _weatherData!['current_weather'];
    final daily = _weatherData!['daily'];
    int code = current['weathercode'].round();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_currentCity, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              Text("এখন", style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8))),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_getWeatherIcon(code), size: 90, color: Colors.white),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${current['temperature'].round()}°", style: const TextStyle(fontSize: 70, fontWeight: FontWeight.bold, color: Colors.white, height: 1)),
                  Text(_getWeatherDescriptionBangla(code), style: const TextStyle(fontSize: 20, color: Colors.white70)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text("সর্বোচ্চ: ${daily['temperature_2m_max'][0].round()}°", style: const TextStyle(color: Colors.white, fontSize: 16)),
              Text("সর্বনিম্ন: ${daily['temperature_2m_min'][0].round()}°", style: const TextStyle(color: Colors.white70, fontSize: 16)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2E7D32), size: 24),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
        ],
      ),
    );
  }


  // === REDESIGNED FARMING ACTIVITY GUIDE ===
  Widget _buildFarmingActivityGuide() {
    final daily = _weatherData!['daily'];
    double todayRain = (daily['precipitation_sum'][0] as num).toDouble();
    double maxWind = (daily['windspeed_10m_max'][0] as num).toDouble();

    bool canFertilize = todayRain < 2.0;
    bool canSpray = maxWind < 15.0 && todayRain < 1.0;
    bool needIrrigation = todayRain < 5.0;

    return Row(
      children: [
        _buildActivityCard("সার", canFertilize, Icons.eco),
        const SizedBox(width: 12),
        _buildActivityCard("কীটনাশক", canSpray, Icons.pest_control),
        const SizedBox(width: 12),
        _buildActivityCard("সেচ", needIrrigation, Icons.water_drop),
      ],
    );
  }

  Widget _buildActivityCard(String title, bool isRecommended, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: isRecommended ? Colors.green[50] : Colors.red[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isRecommended ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.black87, size: 30),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Icon(
              isRecommended ? Icons.check_circle : Icons.cancel,
              color: isRecommended ? Colors.green : Colors.red,
              size: 40,
            ),
          ],
        ),
      ),
    );
  }
  // =========================================

  // ... (Keep all other build functions: _buildVitalAgriDataGrid, _buildHourlyForecast, _buildDailyForecast, and helpers SAME as before) ...
   // === নতুন ডিজাইন: কৃষি তথ্য (Agri Data) ===
  Widget _buildVitalAgriDataGrid() {
    final daily = _weatherData!['daily'];
    final currentHour = DateTime.now().hour;
    double rain = (daily['precipitation_sum'][0] as num).toDouble();
    double wind = (_weatherData!['hourly']['windspeed_10m'][currentHour] as num).toDouble();
    int humidity = (_weatherData!['hourly']['relativehumidity_2m'][currentHour] as num).round();

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5, // কার্ডগুলো একটু চওড়া হবে
      children: [
        _buildAgriCard("বৃষ্টিপাত", "${rain} মিমি", Icons.water_drop_rounded, Colors.blue, rain > 5 ? Colors.red[50] : Colors.blue[50]),
        _buildAgriCard("বাতাসের গতি", "${wind} কিমি/ঘ", Icons.air_rounded, Colors.teal, wind > 15 ? Colors.orange[50] : Colors.teal[50]),
        _buildAgriCard("আর্দ্রতা", "${humidity}%", Icons.water_rounded, Colors.indigo, humidity > 85 ? Colors.red[50] : Colors.indigo[50]),
        _buildAgriCard("সূর্যাস্ত", DateFormat('jm').format(DateTime.parse(daily['sunset'][0])), Icons.wb_twilight_rounded, Colors.orange, Colors.orange[50]),
      ],
    );
  }

  Widget _buildAgriCard(String title, String value, IconData icon, Color iconColor, Color? bgColor) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor ?? Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: iconColor.withOpacity(0.1), width: 1.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(backgroundColor: iconColor.withOpacity(0.2), child: Icon(icon, color: iconColor)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
              Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
            ],
          )
        ],
      ),
    );
  }

  // === নতুন ডিজাইন: ঘণ্টা অনুযায়ী পূর্বাভাস (Hourly Forecast) ===
  Widget _buildHourlyForecast() {
    final hourly = _weatherData!['hourly'];
    final currentHour = DateTime.now().hour;

    return SizedBox(
      height: 140, // উচ্চতা একটু বাড়ানো হয়েছে
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: 24,
        itemBuilder: (context, index) {
          final hourIndex = currentHour + index;
          if (hourIndex >= hourly['time'].length) return const SizedBox.shrink();
          
          final time = DateTime.parse(hourly['time'][hourIndex]);
          final temp = hourly['temperature_2m'][hourIndex].round();
          final code = hourly['weathercode'][hourIndex].round();
          bool isRainy = [51,53,55,61,63,65,80,81,82,95].contains(code);

          return Container(
            width: 80,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              // বৃষ্টির সম্ভাবনা থাকলে কার্ডের রং নীলচে হবে
              color: index == 0 ? const Color(0xFF4CAF50) : (isRainy ? Colors.blue[50] : Colors.white),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: isRainy ? Colors.blue.withOpacity(0.3) : Colors.grey.shade200),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(DateFormat('ha').format(time), style: TextStyle(fontWeight: FontWeight.bold, color: index == 0 ? Colors.white : Colors.black87)),
                Icon(_getWeatherIcon(code), size: 32, color: index == 0 ? Colors.white : (isRainy ? Colors.blue : Colors.orange)),
                Text("$temp°", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: index == 0 ? Colors.white : Colors.black87)),
              ],
            ),
          );
        },
      ),
    );
  }

  // === নতুন ডিজাইন: আগামী ৭ দিন (Daily Forecast) ===
  Widget _buildDailyForecast() {
    final daily = _weatherData!['daily'];
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 7,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final date = DateTime.parse(daily['time'][index]);
        final min = daily['temperature_2m_min'][index].round();
        final max = daily['temperature_2m_max'][index].round();
        final code = daily['weathercode'][index].round();
        final rain = (daily['precipitation_sum'][index] as num).toDouble();
        bool isRainy = rain > 1.0;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            // বৃষ্টির দিন হলে বর্ডার নীল হবে, নাহলে সাধারণ
            border: Border.all(color: isRainy ? Colors.blue.withOpacity(0.5) : Colors.transparent, width: 1.5),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(DateFormat('EEEE').format(date), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), // বারের নাম (e.g., Monday)
                    Text(DateFormat('d MMM').format(date), style: TextStyle(color: Colors.grey[600], fontSize: 13)), // তারিখ
                  ],
                ),
              ),
              // আইকন এবং বৃষ্টির পরিমাণ
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Icon(_getWeatherIcon(code), color: isRainy ? Colors.blue : Colors.orange, size: 30),
                    if (isRainy) 
                      Text("${rain.toStringAsFixed(1)} মিমি", style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold))
                  ],
                ),
              ),
              // তাপমাত্রা
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("$max°", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Text("$min°", style: TextStyle(fontSize: 16, color: Colors.grey[500])),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getWeatherIcon(int code) {
    switch (code) {
      case 0: return Icons.wb_sunny_rounded;
      case 1: case 2: return Icons.wb_cloudy_rounded;
      case 3: return Icons.cloud_rounded;
      case 45: case 48: return Icons.foggy;
      case 51: case 53: case 55: return Icons.grain_rounded;
      case 61: case 63: case 65: return Icons.water_drop_rounded;
      case 80: case 81: case 82: return Icons.shower_rounded;
      case 95: case 96: case 99: return Icons.thunderstorm_rounded;
      default: return Icons.cloud_outlined;
    }
  }

  String _getWeatherDescriptionBangla(int code) {
    switch (code) {
      case 0: return "রৌদ্রোজ্জ্বল";
      case 1: case 2: return "আংশিক মেঘলা";
      case 3: return "মেঘলা";
      case 45: case 48: return "কুয়াশা";
      case 51: case 53: case 55: return "গুঁড়ি গুঁড়ি বৃষ্টি";
      case 61: case 63: case 65: return "বৃষ্টি";
      case 80: case 81: case 82: return "ভারী বর্ষণ";
      case 95: case 96: case 99: return "বজ্রসহ বৃষ্টি";
      default: return "মেঘলা";
    }
  }
}