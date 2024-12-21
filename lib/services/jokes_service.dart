import 'dart:convert';
import 'package:http/http.dart' as http;

class JokesService {
  Future<List<dynamic>> fetchJokes() async {
    final uri = Uri.parse('https://official-joke-api.appspot.com/random_ten');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jokes = json.decode(response.body);
      return jokes.take(5).toList();
    } else {
      throw Exception('Failed to load jokes');
    }
  }
}
