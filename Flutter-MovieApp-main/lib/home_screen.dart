import 'package:flutter/material.dart';
import 'api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'movie_detail_screen.dart';
import 'listgenre_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<dynamic>> _popularMovies;
  late Future<List<dynamic>> _categories;
  late Future<List<dynamic>> _newestMovies;
  List<dynamic> _allMovies = [];
  List<dynamic> _filteredMovies = [];
  List<dynamic> _selectedCategoryMovies = [];
  int _selectedTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _popularMovies = ApiService().getPopularMovies();
    _newestMovies = ApiService().getNewestMovies();
    _categories = ApiService().getCategories();
  }

  List<dynamic> _getLimitedCategories(List<dynamic> categories) {
    return categories.take(5).toList();
  }

  void _filterMovies(String query) {
    setState(() {
      _filteredMovies = _allMovies
          .where((movie) =>
              movie['title'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _filterMoviesByCategory(int categoryId) {
    setState(() {
      if (_selectedCategoryMovies.isNotEmpty) {
        _selectedCategoryMovies = [];
      } else {
        _selectedCategoryMovies = _allMovies
            .where((movie) => movie['genre_ids'].contains(categoryId))
            .toList();
      }
    });
  }

  void _clearCategoryFilter() {
    setState(() {
      _selectedCategoryMovies = [];
    });
  }

  Widget _buildCategoryButton(dynamic category) {
    return ElevatedButton(
      onPressed: () => _filterMoviesByCategory(category['id']),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(category['name'], style: TextStyle(fontSize: 16)),
    );
  }

  Widget _buildMovieGrid(List<dynamic> movies) {
    var moviesToDisplay =
        _selectedCategoryMovies.isEmpty ? movies : _selectedCategoryMovies;

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Dua kolom untuk menjaga keseimbangan
        crossAxisSpacing: 8, // Jarak horizontal antar elemen
        mainAxisSpacing: 8, // Jarak vertikal antar elemen
        childAspectRatio: 0.7, // Rasio untuk menjaga proporsi poster
      ),
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 8), // Padding keseluruhan
      itemCount: moviesToDisplay.length,
      itemBuilder: (context, index) {
        var movie = moviesToDisplay[index];
        var posterPath =
            'https://image.tmdb.org/t/p/w500${movie['poster_path']}';

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MovieDetailScreen(movieId: movie['id']),
              ),
            );
          },
          child: Card(
            elevation: 5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CachedNetworkImage(
                  imageUrl: posterPath,
                  height: 180, // Tinggi tetap untuk gambar poster
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    movie['title'],
                    textAlign: TextAlign.center, // Judul diformat ke tengah
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      overflow:
                          TextOverflow.ellipsis, // Potong judul yang panjang
                    ),
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purpleAccent, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 60),
            Text(
              'Find Movies, TV Shows & More...',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Container(
              width: 250,
              child: TextField(
                controller: _searchController,
                onChanged: (query) => _filterMovies(query),
                decoration: InputDecoration(
                  hintText: 'Search movies...',
                  hintStyle: TextStyle(color: Colors.white),
                  suffixIcon: Icon(Icons.search, color: Colors.white),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purpleAccent, Colors.blueAccent],
                ),
              ),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.category, color: Colors.deepPurple),
              title: Text('Genres'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GenreListScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Search Movies by Category',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
            FutureBuilder<List<dynamic>>(
              future: _categories,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error: ${snapshot.error}',
                          style: TextStyle(color: Colors.black)));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                      child: Text('No categories found.',
                          style: TextStyle(color: Colors.black)));
                }

                List<dynamic> categories =
                    _getLimitedCategories(snapshot.data!);
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Wrap(
                    spacing: 10.0,
                    runSpacing: 10.0,
                    children: categories.map((category) {
                      return _buildCategoryButton(category);
                    }).toList(),
                  ),
                );
              },
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Trending Movies',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
            FutureBuilder<List<dynamic>>(
              future: _popularMovies,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error: ${snapshot.error}',
                          style: TextStyle(color: Colors.black)));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                      child: Text('No movies found.',
                          style: TextStyle(color: Colors.black)));
                }

                List<dynamic> movies = snapshot.data!;
                _allMovies = movies;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: movies.take(5).map((movie) {
                      var posterPath =
                          'https://image.tmdb.org/t/p/w500${movie['poster_path']}';

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MovieDetailScreen(movieId: movie['id']),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CachedNetworkImage(
                            imageUrl: posterPath,
                            width: 120,
                            height: 180,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Newest Movies',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
            FutureBuilder<List<dynamic>>(
              future: _newestMovies,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error: ${snapshot.error}',
                          style: TextStyle(color: Colors.black)));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                      child: Text('No movies found.',
                          style: TextStyle(color: Colors.black)));
                }

                List<dynamic> movies = snapshot.data!;
                return _buildMovieGrid(
                    movies); // Gunakan fungsi yang telah diperbarui
              },
            ),
          ],
        ),
      ),
    );
  }
}
