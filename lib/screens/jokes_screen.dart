import 'package:flutter/material.dart';
import '../services/jokes_service.dart';
import '../services/cache_helper.dart';

class JokesScreen extends StatefulWidget {
  @override
  _JokesScreenState createState() => _JokesScreenState();
}

class _JokesScreenState extends State<JokesScreen> {
  final JokesService _jokesService = JokesService();
  final CacheHelper _cacheHelper = CacheHelper();

  List<dynamic>? _jokes;
  List<dynamic>? _filteredJokes;
  bool _isLoading = true;
  String? _errorMessage;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadJokes();
    _searchController.addListener(_filterJokes);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadJokes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      List<dynamic>? cachedJokes = await _cacheHelper.getCachedJokes();
      if (cachedJokes != null && cachedJokes.isNotEmpty) {
        setState(() {
          _jokes = cachedJokes;
          _filteredJokes = cachedJokes;
          _isLoading = false;
        });
      }

      final jokes = await _jokesService.fetchJokes();
      await _cacheHelper.saveJokes(jokes);
      setState(() {
        _jokes = jokes;
        _filteredJokes = jokes;
        _isLoading = false;
      });
    } catch (e) {
      if (_jokes == null) {
        setState(() {
          _errorMessage = 'Failed to load jokes. Please check your internet connection.';
          _isLoading = false;
        });
      }
    }
  }

  void _filterJokes() {
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      setState(() {
        _filteredJokes = _jokes?.where((joke) {
          final setup = joke['setup'].toString().toLowerCase();
          final punchline = joke['punchline'].toString().toLowerCase();
          return setup.contains(query) || punchline.contains(query);
        }).toList();
      });
    } else {
      setState(() {
        _filteredJokes = _jokes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jokes App'),
        centerTitle: true,
        backgroundColor: Colors.purple,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.pink],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // Search Box
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search jokes...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
                  : _errorMessage != null
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _filteredJokes?.length ?? 0,
                itemBuilder: (context, index) {
                  final joke = _filteredJokes![index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    color: Colors.white.withOpacity(0.9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 8,
                    shadowColor: Colors.black45,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            joke['setup'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            joke['punchline'],
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadJokes,
        backgroundColor: Colors.white,
        child: const Icon(Icons.refresh),
        tooltip: 'Refresh Jokes',
      ),
    );
  }
}
