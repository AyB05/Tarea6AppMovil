import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Caja de Herramientas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeToolbox(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeToolbox extends StatefulWidget {
  const HomeToolbox({super.key});

  @override
  State<HomeToolbox> createState() => _HomeToolboxState();
}

class _HomeToolboxState extends State<HomeToolbox> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ToolBoxImage(),
    const GenderPredictor(),
    const AgePredictor(),
    const UniversityFinder(),
    const WeatherRD(),
    const PokemonInfo(),
    const WordPressNews(),
    const AboutMe(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Caja de Herramientas")),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Caja"),
          BottomNavigationBarItem(icon: Icon(Icons.face), label: "Género"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Edad"),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: "Univ."),
          BottomNavigationBarItem(icon: Icon(Icons.cloud), label: "Clima"),
          BottomNavigationBarItem(
            icon: Icon(Icons.catching_pokemon),
            label: "Pokémon",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: "Noticias"),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: "Acerca de"),
        ],
      ),
    );
  }
}

class ToolBoxImage extends StatelessWidget {
  const ToolBoxImage({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(child: Image.asset("assets/tool-box.png", height: 200));
  }
}

class GenderPredictor extends StatefulWidget {
  const GenderPredictor({super.key});
  @override
  State<GenderPredictor> createState() => _GenderPredictorState();
}

class _GenderPredictorState extends State<GenderPredictor> {
  final controller = TextEditingController();
  String gender = '';
  Color color = const Color.fromARGB(255, 221, 214, 214);

  void predictGender() async {
    final name = controller.text.trim();
    final url = Uri.parse("https://api.genderize.io/?name=$name");
    final res = await http.get(url);
    final data = jsonDecode(res.body);
    setState(() {
      gender = data['gender'];
      color = (gender == 'male')
          ? const Color.fromARGB(255, 45, 156, 247)
          : const Color.fromARGB(255, 214, 72, 172);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
            ),
            ElevatedButton(
              onPressed: predictGender,
              child: const Text("Predecir Género"),
            ),
            if (gender.isNotEmpty)
              Text("Género: $gender", style: const TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}

class AgePredictor extends StatefulWidget {
  const AgePredictor({super.key});
  @override
  State<AgePredictor> createState() => _AgePredictorState();
}

class _AgePredictorState extends State<AgePredictor> {
  final controller = TextEditingController();
  int age = 0;
  String category = '';
  String img = '';

  void predictAge() async {
    final name = controller.text.trim();
    final url = Uri.parse("https://api.agify.io/?name=$name");
    final res = await http.get(url);
    final data = jsonDecode(res.body);
    setState(() {
      age = data['age'];
      if (age < 18) {
        category = "Joven";
        img = "assets/teen.png";
      } else if (age < 60) {
        category = "Adulto";
        img = "assets/man.png";
      } else {
        category = "Anciano";
        img = "assets/oldman.png";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nombre'),
        ),
        ElevatedButton(
          onPressed: predictAge,
          child: const Text("Determinar Edad"),
        ),
        if (age > 0) ...[
          Text("Edad: $age", style: const TextStyle(fontSize: 20)),
          Text("Categoría: $category", style: const TextStyle(fontSize: 18)),
          Image.asset(img, height: 100),
        ],
      ],
    );
  }
}

class UniversityFinder extends StatefulWidget {
  const UniversityFinder({super.key});
  @override
  State<UniversityFinder> createState() => _UniversityFinderState();
}

class _UniversityFinderState extends State<UniversityFinder> {
  final controller = TextEditingController();
  List<dynamic> universities = [];

  void fetchUniversities() async {
    final country = controller.text.trim().replaceAll(' ', '+');
    final url = Uri.parse(
      "http://universities.hipolabs.com/search?country=$country",
    );
    final res = await http.get(url);
    final data = jsonDecode(res.body);
    setState(() {
      universities = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nombre del país en inglés',
          ),
        ),
        ElevatedButton(
          onPressed: fetchUniversities,
          child: const Text("Buscar Universidades"),
        ),
        const SizedBox(height: 10),
        for (var u in universities.take(10))
          GestureDetector(
            onTap: () async {
              String originalUrl = u['web_pages'][0];
              if (originalUrl.startsWith('http://')) {
                originalUrl = originalUrl.replaceFirst('http://', 'https://');
              }

              final url = Uri.parse(originalUrl);

              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No se pudo abrir el enlace')),
                );
              }
            },
            child: Card(
              child: ListTile(
                title: Text(u['name']),
                subtitle: Text(
                  u['web_pages'][0],
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
                trailing: const Icon(Icons.open_in_browser),
              ),
            ),
          ),
      ],
    );
  }
}

class WeatherRD extends StatefulWidget {
  const WeatherRD({super.key});
  @override
  State<WeatherRD> createState() => _WeatherRDState();
}

class _WeatherRDState extends State<WeatherRD> {
  String weather = "Cargando...";
  IconData icon = Icons.cloud;

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    const apiKey = 'b7edef53e3bc97a50876f467e20f3cc1';
    final res = await http.get(
      Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?q=Santo%20Domingo,DO&appid=$apiKey&units=metric",
      ),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final temp = data['main']['temp'];
      final condition = data['weather'][0]['main'].toLowerCase();
      icon = condition.contains("cloud")
          ? Icons.cloud
          : condition.contains("rain")
          ? Icons.beach_access
          : condition.contains("clear")
          ? Icons.wb_sunny
          : Icons.wb_cloudy;

      setState(() {
        weather =
            "Clima en Santo Domingo: ${data['weather'][0]['description']}, ${temp.toStringAsFixed(1)}°C";
      });
    } else {
      setState(() => weather = "Error al obtener clima");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: const Color.fromARGB(255, 93, 41, 160)),
          Text(weather, style: const TextStyle(fontSize: 20)),
        ],
      ),
    );
  }
}

class PokemonInfo extends StatefulWidget {
  const PokemonInfo({super.key});
  @override
  State<PokemonInfo> createState() => _PokemonInfoState();
}

class _PokemonInfoState extends State<PokemonInfo> {
  final controller = TextEditingController();
  String name = '';
  String img = '';
  int exp = 0;
  List<String> abilities = [];
  String soundUrl = '';
  final AudioPlayer player = AudioPlayer();

  void fetchPokemon() async {
    final poke = controller.text.trim().toLowerCase();
    final res = await http.get(
      Uri.parse("https://pokeapi.co/api/v2/pokemon/$poke"),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        name = data['name'];
        img = data['sprites']['front_default'];
        exp = data['base_experience'];
        abilities = (data['abilities'] as List)
            .map((a) => a['ability']['name'].toString())
            .toList();
        soundUrl =
            "https://raw.githubusercontent.com/PokeAPI/cries/main/cries/pokemon/latest/${data['id']}.ogg";
      });
      player.play(UrlSource(soundUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nombre del Pokémon'),
        ),
        ElevatedButton(
          onPressed: fetchPokemon,
          child: const Text("Buscar Pokémon"),
        ),
        if (name.isNotEmpty) ...[
          Image.network(img),
          Text("Nombre: $name", style: const TextStyle(fontSize: 20)),
          Text("Experiencia Base: $exp"),
          Text("Habilidades: ${abilities.join(', ')}"),
        ],
      ],
    );
  }
}

class WordPressNews extends StatefulWidget {
  const WordPressNews({super.key});
  @override
  State<WordPressNews> createState() => _WordPressNewsState();
}

class _WordPressNewsState extends State<WordPressNews> {
  List<dynamic> posts = [];
  String error = '';

  Future<void> fetchPosts() async {
    final res = await http.get(
      Uri.parse('https://wpmayor.com/wp-json/wp/v2/posts?per_page=3'),
    );
    print('Status code: ${res.statusCode}');
    print('Body: ${res.body}');

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        posts = data;
        error = '';
      });
    } else {
      setState(() {
        error = 'Error: ${res.statusCode}';
        posts = [];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  String removeHtmlTags(String htmlString) {
    final regex = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(regex, '');
  }

  @override
  Widget build(BuildContext context) {
    if (error.isNotEmpty) {
      return Center(child: Text(error));
    }
    if (posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Image.asset("assets/WP-Mayor_Social.webp", height: 100),
        const SizedBox(height: 30),
        ...posts.map(
          (p) => ListTile(
            title: Text(p['title']['rendered'] ?? "Sin título"),
            subtitle: Text(
              removeHtmlTags(p['excerpt']['rendered'] ?? "Sin descripción"),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.open_in_browser),
              onPressed: () async {
                final url = Uri.parse(p['link']);
                if (await canLaunchUrl(url)) await launchUrl(url);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class AboutMe extends StatelessWidget {
  const AboutMe({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircleAvatar(
            radius: 60,
            backgroundImage: AssetImage("assets/yo.jpeg"),
          ),
          SizedBox(height: 10),
          Text("Nombre: Albert De los Santos", style: TextStyle(fontSize: 20)),
          Text("Email: 20230553@itla.edu.do"),
          Text("Tel: +1 809 000 0000"),
        ],
      ),
    );
  }
}
