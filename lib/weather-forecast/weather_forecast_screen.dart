import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'weather_detail_screen.dart'; // Make sure this file exists
// We need this for the daily forecast

class WeatherForecastScreen extends StatefulWidget {
  const WeatherForecastScreen({super.key});

  @override
  State<WeatherForecastScreen> createState() => _WeatherForecastScreenState();
}

class _WeatherForecastScreenState extends State<WeatherForecastScreen> {
  // --- CONTROLLERS & VARIABLES ---
  final TextEditingController _searchController = TextEditingController();
  final String _apiKey = "4fa4e0c1e03c2e989b915bec887f48e1"; // Your key
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isListening = false;
  bool _isLoading = true;
  String? _errorMessage;
  String _currentCity = "Dhaka";
  List<Map<String, dynamic>> _suggestions = [];

  // --- NEW: Separate variables for current and forecast data ---
  Map<String, dynamic>? _currentWeatherData;
  Map<String, dynamic>? _forecastData;
  List<Map<String, dynamic>> _dailyForecast = []; // Processed daily list

  // --- INIT & DISPOSE ---
  @override
  void initState() {
    super.initState();
    _initTts();
    _fetchWeatherForCity("Dhaka");
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _speech.stop();
    _searchController.dispose();
    super.dispose();
  }

  // --- VOICE FEATURES (TTS & STT) ---
  Future<void> _initTts() async {
    await _flutterTts.setLanguage("bn-BD");
    await _flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) => print('Speech Status: $status'),
        onError: (errorNotification) =>
            print('Speech Error: $errorNotification'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            if (val.hasConfidenceRating && val.confidence > 0) {
              String command = val.recognizedWords.toLowerCase();
              if (command.contains("bristi") ||
                  command.contains("বৃষ্টি") ||
                  command.contains("rain")) {
                _replyAboutRain();
              }
            }
          },
          localeId: "bn_BD",
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _replyAboutRain() {
    if (_dailyForecast.isEmpty) return;
    double rain = (_dailyForecast[0]['rain'] ?? 0.0).toDouble();
    if (rain > 1.0) {
      _speak("হ্যাঁ, আজ বৃষ্টির সম্ভাবনা আছে।");
    } else {
      _speak("না, আজ বৃষ্টির সম্ভাবনা নেই।");
    }
    setState(() => _isListening = false);
  }

  // --- API CONNECTION LOGIC (REWRITTEN FOR FREE APIs) ---

  Future<void> _fetchSuggestions(String query) async {
    if (query.length < 3) {
      setState(() {
        _suggestions = [];
      });
      return;
    }
    try {
      final geoUrl = Uri.parse(
          "https://api.openweathermap.org/geo/1.0/direct?q=${Uri.encodeComponent(query)}&limit=5&appid=$_apiKey");
      final geoResponse = await http.get(geoUrl);

      if (geoResponse.statusCode == 200) {
        final geoData = json.decode(geoResponse.body) as List;
        if (geoData.isNotEmpty) {
          setState(() {
            _suggestions = List<Map<String, dynamic>>.from(geoData);
          });
        }
      } else {
        setState(() {
          _suggestions = [];
        });
      }
    } catch (e) {
      setState(() {
        _suggestions = [];
      });
    }
  }

  Future<void> _fetchWeatherForCity(String city) async {
    if (city.isEmpty) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _suggestions = [];
    });

    try {
      // Step 1: Get Coordinates
      final geoUrl = Uri.parse(
          "https://api.openweathermap.org/geo/1.0/direct?q=${Uri.encodeComponent(city)}&limit=1&appid=$_apiKey");
      final geoResponse = await http.get(geoUrl);

      if (geoResponse.statusCode != 200) throw Exception("Geo API Error");
      final geoData = json.decode(geoResponse.body) as List;
      if (geoData.isEmpty) {
        throw Exception("শহর খুঁজে পাওয়া যায়নি।");
      }

      final lat = geoData[0]['lat'];
      final lon = geoData[0]['lon'];
      final cityName = geoData[0]['name'];

      // Step 2: Get Weather Data (TWO separate calls)
      // Call 1: Get CURRENT weather (Free API)
      final currentUrl = Uri.parse(
          "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=bn");
      final currentResponse = await http.get(currentUrl);
      if (currentResponse.statusCode != 200) {
        throw Exception("Current Weather API Error");
      }

      // Call 2: Get 5-DAY / 3-HOUR forecast (Free API)
      final forecastUrl = Uri.parse(
          "https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=bn");
      final forecastResponse = await http.get(forecastUrl);
      if (forecastResponse.statusCode != 200) {
        throw Exception("Forecast API Error");
      }

      // --- Process the 5-day forecast ---
      final forecastList = (json.decode(forecastResponse.body)['list'] as List);
      final processedDaily = _processDailyForecast(forecastList);

      setState(() {
        _currentWeatherData = json.decode(currentResponse.body);
        _forecastData = json.decode(forecastResponse.body);
        _dailyForecast = processedDaily; // Save the processed list
        _currentCity = cityName;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching weather: $e");
      setState(() {
        _isLoading = false;
        _errorMessage = "তথ্য লোড করা যায়নি। ইন্টারনেট সংযোগ পরীক্ষা করুন।";
      });
    }
  }

  // --- NEW HELPER: Processes the 40-item list into a 5-day list ---
  List<Map<String, dynamic>> _processDailyForecast(List forecastList) {
    final dailyData = <String, Map<String, dynamic>>{};

    for (final item in forecastList) {
      final dt = (item['dt'] ?? 0) * 1000;
      final date = DateTime.fromMillisecondsSinceEpoch(dt);
      final dayKey = DateFormat('yyyy-MM-dd').format(date);

      if (!dailyData.containsKey(dayKey)) {
        // This is the first entry for this day
        dailyData[dayKey] = {
          'dt': dt,
          'temp_min': item['main']['temp_min'],
          'temp_max': item['main']['temp_max'],
          'code': item['weather'][0]['id'],
          'description': item['weather'][0]['description'],
          'rain': (item['rain']?['3h'] ?? 0.0).toDouble(), // Rain in last 3h
          'wind': item['wind']['speed'],
          'sunrise': _forecastData?['city']
              ?['sunrise'], // Will be null on first pass, fix later
          'sunset': _forecastData?['city']?['sunset'],
          'hourly_items': [item] // Store all items for this day
        };
      } else {
        // Update existing day's data
        if (item['main']['temp_min'] < dailyData[dayKey]!['temp_min']) {
          dailyData[dayKey]!['temp_min'] = item['main']['temp_min'];
        }
        if (item['main']['temp_max'] > dailyData[dayKey]!['temp_max']) {
          dailyData[dayKey]!['temp_max'] = item['main']['temp_max'];
        }
        dailyData[dayKey]!['rain'] += (item['rain']?['3h'] ?? 0.0).toDouble();
        dailyData[dayKey]!['hourly_items'].add(item);
      }
    }

    // Add sunrise/sunset from forecast data
    final sunrise = _forecastData?['city']?['sunrise'];
    final sunset = _forecastData?['city']?['sunset'];
    if (sunrise != null && sunset != null) {
      for (final day in dailyData.values) {
        day['sunrise'] = sunrise;
        day['sunset'] = sunset;
      }
    }

    return dailyData.values.toList().take(5).toList(); // Return first 5 days
  }

  // --- UI BUILD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("আবহাওয়ার পূর্বাভাস"),
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchWeatherForCity(_currentCity),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _listen,
        backgroundColor: _isListening ? Colors.red : const Color(0xFF4CAF50),
        child: Icon(_isListening ? Icons.mic : Icons.mic_none, size: 30),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.green));
    }
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 50),
            const SizedBox(height: 10),
            Text(_errorMessage!,
                style: const TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _fetchWeatherForCity(_currentCity),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("আবার চেষ্টা করুন"),
            )
          ],
        ),
      );
    }
    if (_currentWeatherData == null ||
        _forecastData == null ||
        _dailyForecast.isEmpty) {
      return const Center(child: Text("কোনো ডেটা পাওয়া যায়নি।"));
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _fetchWeatherForCity(_currentCity);
      },
      color: Colors.green,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchCard(),
            _buildSuggestionList(),
            const SizedBox(height: 20),
            _buildKrishiAlertBox(),
            const SizedBox(height: 20),
            _buildCurrentWeather(),
            const SizedBox(height: 30),
            _buildSectionHeader("আজকের কৃষি কাজ", Icons.agriculture),
            _buildFarmingActivityGuide(),
            const SizedBox(height: 30),
            _buildSectionHeader("আজকের কৃষি তথ্য", Icons.analytics),
            _buildVitalAgriDataGrid(),
            const SizedBox(height: 30),
            _buildSectionHeader("ঘণ্টা অনুযায়ী পূর্বাভাস", Icons.access_time),
            _buildHourlyForecast(),
            const SizedBox(height: 30),
            _buildSectionHeader("আগামী ৫ দিন", Icons.calendar_today),
            _buildDailyForecast(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // =================== WIDGET COMPONENTS (All updated for new data) ===================

  Widget _buildSearchCard() {
    // This widget is unchanged
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "শহর বা এলাকার নাম লিখুন...",
          prefixIcon: const Icon(Icons.search, color: Colors.green),
          suffixIcon: IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _suggestions = [];
                });
              }),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        onChanged: (value) {
          _fetchSuggestions(value);
        },
        onSubmitted: (value) {
          _fetchWeatherForCity(value);
          setState(() {
            _suggestions = [];
          });
        },
      ),
    );
  }

  Widget _buildSuggestionList() {
    // This widget is unchanged
    if (_suggestions.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: ListView.builder(
        itemCount: _suggestions.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final suggestion = _suggestions[index];
          String name = suggestion['name'] ?? 'Unknown';
          String country = suggestion['country'] ?? '';
          String state = suggestion['state'] ?? '';
          String localName = suggestion['local_names']?['bn'] ?? name;
          String displayName =
              "$localName, ${state.isNotEmpty ? '$state, ' : ''}$country";

          return ListTile(
            leading: const Icon(Icons.location_city, color: Colors.green),
            title: Text(localName),
            subtitle: Text(displayName.replaceAll('$localName, ', '')),
            onTap: () {
              _searchController.text = name;
              _fetchWeatherForCity(name);
              setState(() {
                _suggestions = [];
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildKrishiAlertBox() {
    final today = _dailyForecast[0];
    double rain = (today['rain'] ?? 0.0).toDouble();
    double wind = (today['wind'] ?? 0.0).toDouble();

    String text = "আজ আবহাওয়া কৃষি কাজের জন্য নিরাপদ।";
    Color color = Colors.green[700]!;
    Color bg = Colors.green[50]!;
    IconData icon = Icons.verified_user;

    if (rain > 10) {
      text = "সতর্কতা: আজ ভারী বৃষ্টির সম্ভাবনা! জমিতে সেচ বা সার দেবেন না।";
      color = Colors.red[700]!;
      bg = Colors.red[50]!;
      icon = Icons.warning;
    } else if (wind > 20) {
      text =
          "সতর্কতা: আজ বাতাসের গতি বেশি। কীটনাশক স্প্রে করা থেকে বিরত থাকুন।";
      color = Colors.orange[800]!;
      bg = Colors.orange[50]!;
      icon = Icons.flag;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3))),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(
              child: Text(text,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color))),
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
    final current = _currentWeatherData!;
    final today = _dailyForecast[0];
    int code = current['weather'][0]['id'].round();
    String description = current['weather'][0]['description'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.green.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_currentCity,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              Text("এখন",
                  style: TextStyle(
                      fontSize: 16, color: Colors.white.withOpacity(0.8))),
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
                  Text("${current['main']['temp'].round()}°",
                      style: const TextStyle(
                          fontSize: 70,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1)),
                  Text(description,
                      style:
                          const TextStyle(fontSize: 20, color: Colors.white70)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text("সর্বোচ্চ: ${today['temp_max'].round()}°",
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
              Text("সর্বনিম্ন: ${today['temp_min'].round()}°",
                  style: const TextStyle(color: Colors.white70, fontSize: 16)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFarmingActivityGuide() {
    final today = _dailyForecast[0];
    double todayRain = (today['rain'] ?? 0.0).toDouble();
    double maxWind = (today['wind'] ?? 0.0).toDouble();

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
    // This widget is unchanged
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: isRecommended ? Colors.green[50] : Colors.red[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isRecommended
                ? Colors.green.withOpacity(0.5)
                : Colors.red.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.black87, size: 30),
            const SizedBox(height: 10),
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

  Widget _buildVitalAgriDataGrid() {
    final current = _currentWeatherData!;
    final today = _dailyForecast[0];
    double rain = (today['rain'] ?? 0.0).toDouble();
    double wind = (current['wind']['speed'] ?? 0.0).toDouble();
    int humidity = (current['main']['humidity'] ?? 0.0).round();
    final sunset = DateFormat('jm').format(DateTime.fromMillisecondsSinceEpoch(
        (current['sys']['sunset'] ?? 0) * 1000));

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildAgriCard("বৃষ্টিপাত", "$rain মিমি", Icons.water_drop_rounded,
            Colors.blue, rain > 5 ? Colors.red[50] : Colors.blue[50]),
        _buildAgriCard("বাতাসের গতি", "$wind কিমি/ঘ", Icons.air_rounded,
            Colors.teal, wind > 15 ? Colors.orange[50] : Colors.teal[50]),
        _buildAgriCard("আর্দ্রতা", "$humidity%", Icons.water_rounded,
            Colors.indigo, humidity > 85 ? Colors.red[50] : Colors.indigo[50]),
        _buildAgriCard("সূর্যাস্ত", sunset, Icons.wb_twilight_rounded,
            Colors.orange, Colors.orange[50]),
      ],
    );
  }

  Widget _buildAgriCard(String title, String value, IconData icon,
      Color iconColor, Color? bgColor) {
    // This widget is unchanged
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
          CircleAvatar(
              backgroundColor: iconColor.withOpacity(0.2),
              child: Icon(icon, color: iconColor)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
              Text(title,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700])),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHourlyForecast() {
    final hourlyList = (_forecastData!['list'] as List)
        .take(8)
        .toList(); // Show next 24 hours (8 * 3-hour blocks)

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: hourlyList.length,
        itemBuilder: (context, index) {
          final item = hourlyList[index];
          final time =
              DateTime.fromMillisecondsSinceEpoch((item['dt'] ?? 0) * 1000);
          final temp = (item['main']['temp'] ?? 0.0).round();
          final code = (item['weather'][0]['id'] ?? 800).round();
          bool isRainy = code >= 300 && code < 700;

          return Container(
            width: 80,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: index == 0
                  ? const Color(0xFF4CAF50)
                  : (isRainy ? Colors.blue[50] : Colors.white),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: isRainy
                      ? Colors.blue.withOpacity(0.3)
                      : Colors.grey.shade200),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(DateFormat('ha').format(time),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: index == 0 ? Colors.white : Colors.black87)),
                Icon(_getWeatherIcon(code),
                    size: 32,
                    color: index == 0
                        ? Colors.white
                        : (isRainy ? Colors.blue : Colors.orange)),
                Text("$temp°",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: index == 0 ? Colors.white : Colors.black87)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDailyForecast() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _dailyForecast.length, // Use our processed 5-day list
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = _dailyForecast[index];
        final date = DateTime.fromMillisecondsSinceEpoch((item['dt'] ?? 0));
        final min = (item['temp_min'] ?? 0.0).round();
        final max = (item['temp_max'] ?? 0.0).round();
        final code = (item['code'] ?? 800).round();
        final rain = (item['rain'] ?? 0.0).toDouble();
        bool isRainy = rain > 1.0;

        return InkWell(
          onTap: () {
            // Pass the list of hourly items for that day to the detail screen
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        WeatherDetailScreen(dailyItem: item)));
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: isRainy
                      ? Colors.blue.withOpacity(0.5)
                      : Colors.transparent,
                  width: 1.5),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          index == 0
                              ? "Today"
                              : DateFormat('EEEE').format(date),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(DateFormat('d MMM').format(date),
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Icon(_getWeatherIcon(code),
                          color: isRainy ? Colors.blue : Colors.orange,
                          size: 30),
                      if (isRainy)
                        Text("${rain.toStringAsFixed(1)} মিমি",
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold))
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text("$max°",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Text("$min°",
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[500])),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    // This widget is unchanged
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2E7D32), size: 24),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20))),
        ],
      ),
    );
  }

  // Helper Functions for OWM Codes
  IconData _getWeatherIcon(int code) {
    if (code >= 200 && code < 300) {
      return Icons.thunderstorm_rounded; // Thunderstorm
    } else if (code >= 300 && code < 400) {
      return Icons.grain_rounded; // Drizzle
    } else if (code >= 500 && code < 600) {
      return Icons.water_drop_rounded; // Rain
    } else if (code >= 600 && code < 700) {
      return Icons.ac_unit_rounded; // Snow
    } else if (code >= 700 && code < 800) {
      return Icons.foggy; // Atmosphere (Fog, Mist)
    } else if (code == 800) {
      return Icons.wb_sunny_rounded; // Clear
    } else if (code == 801) {
      return Icons.wb_cloudy_rounded; // Few Clouds
    } else if (code > 801 && code < 900) {
      return Icons.cloud_rounded; // Clouds
    } else {
      return Icons.cloud_outlined;
    }
  }

  String _getWeatherDescriptionBangla(int code) {
    if (code >= 200 && code < 300) {
      return "বজ্রসহ বৃষ্টি";
    } else if (code >= 300 && code < 400) {
      return "গুঁড়ি গুঁড়ি বৃষ্টি";
    } else if (code >= 500 && code < 600) {
      return "বৃষ্টি";
    } else if (code >= 600 && code < 700) {
      return "তুষার";
    } else if (code >= 700 && code < 800) {
      return "কুয়াশা";
    } else if (code == 800) {
      return "রৌদ্রোজ্জ্বল";
    } else if (code == 801) {
      return "আংশিক মেঘলা";
    } else if (code > 801 && code < 900) {
      return "মেঘলা";
    } else {
      return "মেঘলা";
    }
  }
}
