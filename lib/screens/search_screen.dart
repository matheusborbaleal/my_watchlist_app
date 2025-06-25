import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_watchlist_app/services/tmdb_api_service.dart';
import 'package:my_watchlist_app/models/movie_series.dart';
import 'package:my_watchlist_app/providers/movie_series_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TmdbApiService _tmdbApiService = TmdbApiService();
  List<TmdbItem> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _search() async {
    if (_searchController.text.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await _tmdbApiService.searchMedia(
        _searchController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _searchResults = results;
        if (results.isEmpty && _searchController.text.isNotEmpty) {
          _errorMessage =
              'Nenhum resultado encontrado para "${_searchController.text.trim()}".';
        } else {
          _errorMessage = null;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Erro ao buscar dados: Verifique sua conexão ou tente novamente.';
        _searchResults = [];
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addTmdbItemToWatchlist(BuildContext context, TmdbItem tmdbItem) {
    final movieSeriesProvider = Provider.of<MovieSeriesProvider>(
      context,
      listen: false,
    );

    final newWatchlistItem = MovieSeries(
      id: '',
      title: tmdbItem.title,
      posterUrl: _tmdbApiService.getFullImageUrl(tmdbItem.posterPath),
      overview: tmdbItem.overview,
      releaseDate:
          tmdbItem.releaseDate != null && tmdbItem.releaseDate!.isNotEmpty
              ? DateTime.tryParse(tmdbItem.releaseDate!)
              : null,
    );

    movieSeriesProvider.addMovieSeries(newWatchlistItem);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${tmdbItem.title} adicionado à sua lista!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Filmes/Séries'), elevation: 0),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                labelText: 'Buscar por título...',
                hintText: 'Ex: Matrix, Game of Thrones',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _search();
                          },
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
              ),
              onChanged: (text) {
                setState(() {});
              },
            ),
          ),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
              : Expanded(
                child:
                    _searchResults.isEmpty
                        ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 80,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Nenhum resultado encontrado.\nComece a digitar para buscar!',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 18,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (ctx, index) {
                            final item = _searchResults[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child:
                                      item.posterPath != null &&
                                              item.posterPath!.isNotEmpty
                                          ? Image.network(
                                            _tmdbApiService.getFullImageUrl(
                                              item.posterPath,
                                            ),
                                            width: 60,
                                            height: 90,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Container(
                                                      width: 60,
                                                      height: 90,
                                                      color: Colors.grey[200],
                                                      child: const Icon(
                                                        Icons.broken_image,
                                                        size: 30,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                          )
                                          : Container(
                                            width: 60,
                                            height: 90,
                                            color: Colors.grey[200],
                                            child: const Icon(
                                              Icons.movie,
                                              size: 30,
                                              color: Colors.grey,
                                            ),
                                          ),
                                ),
                                title: Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (item.releaseDate != null &&
                                        item.releaseDate!.isNotEmpty)
                                      Text(
                                        'Lançamento: ${item.releaseDate}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    Text(
                                      item.overview != null &&
                                              item.overview!.isNotEmpty
                                          ? item.overview!
                                          : 'Sem sinopse disponível.',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.add_circle,
                                    color: Colors.green,
                                    size: 32,
                                  ),
                                  onPressed: () {
                                    _addTmdbItemToWatchlist(context, item);
                                  },
                                  tooltip: 'Adicionar à lista',
                                ),
                                contentPadding: const EdgeInsets.all(12),
                              ),
                            );
                          },
                        ),
              ),
        ],
      ),
    );
  }
}
