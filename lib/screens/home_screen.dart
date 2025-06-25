import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_watchlist_app/providers/movie_series_provider.dart';
import 'package:my_auth_plugin/my_auth_plugin.dart';
import 'package:my_watchlist_app/models/movie_series.dart';
import 'package:my_watchlist_app/services/location_service.dart';
import 'package:my_watchlist_app/screens/cinemas_nearby_screen.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MovieSeriesProvider>(
        context,
        listen: false,
      ).fetchMovieSeries();
    });
  }

  void _showAddItemDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Adicionar Filme/Série Manualmente'),
            content: TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.isNotEmpty) {
                    Provider.of<MovieSeriesProvider>(
                      context,
                      listen: false,
                    ).addMovieSeries(
                      MovieSeries(id: '', title: titleController.text),
                    );
                    Navigator.of(ctx).pop();
                  }
                },
                child: const Text('Adicionar'),
              ),
            ],
          ),
    );
  }

  Future<void> _findCinemasNearby() async {
    final locationService = Provider.of<LocationService>(
      context,
      listen: false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Buscando sua localização...')),
    );

    final Position? position = await locationService.getCurrentLocation();

    if (!mounted) return;

    if (position != null) {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => CinemasNearbyScreen(userLocation: position),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível obter a localização para buscar cinemas.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MovieSeriesProvider>(
      builder: (context, movieSeriesProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Minha Lista de Filmes/Séries'),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.theaters),
                onPressed: _findCinemasNearby,
                tooltip: 'Cinemas Próximos',
              ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  Navigator.of(context).pushNamed('/search');
                },
                tooltip: 'Buscar Filmes/Séries',
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await Provider.of<AuthPluginProvider>(
                    context,
                    listen: false,
                  ).signOut();
                },
                tooltip: 'Sair',
              ),
            ],
          ),
          body: Container(
            color: Colors.grey[100],
            child:
                movieSeriesProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : movieSeriesProvider.errorMessage != null
                    ? Center(
                      child: Text(
                        movieSeriesProvider.errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    )
                    : movieSeriesProvider.items.isEmpty
                    ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.movie_filter,
                            size: 80,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Sua lista está vazia!\nAdicione um filme ou série.',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: movieSeriesProvider.items.length,
                      itemBuilder: (ctx, index) {
                        final item = movieSeriesProvider.items[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 8,
                          ),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () {
                              print('Abrir detalhes de: ${item.title}');
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child:
                                        item.posterUrl != null &&
                                                item.posterUrl!.isNotEmpty
                                            ? Image.network(
                                              item.posterUrl!,
                                              width: 70,
                                              height: 100,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Container(
                                                    width: 70,
                                                    height: 100,
                                                    color: Colors.grey[200],
                                                    child: const Icon(
                                                      Icons.movie,
                                                      size: 40,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                            )
                                            : Container(
                                              width: 70,
                                              height: 100,
                                              color: Colors.grey[200],
                                              child: const Icon(
                                                Icons.movie,
                                                size: 40,
                                                color: Colors.grey,
                                              ),
                                            ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            decoration:
                                                item.watched
                                                    ? TextDecoration.lineThrough
                                                    : TextDecoration.none,
                                            color:
                                                item.watched
                                                    ? Colors.grey
                                                    : Colors.black87,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        if (item.overview != null &&
                                            item.overview!.isNotEmpty)
                                          Text(
                                            item.overview!,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        const SizedBox(height: 8),
                                        if (item.watched)
                                          const Row(
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                size: 16,
                                                color: Colors.green,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'Assistido',
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          )
                                        else if (item.releaseDate != null)
                                          Text(
                                            'Lançamento: ${item.releaseDate!.day}/${item.releaseDate!.month}/${item.releaseDate!.year}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.orange,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          item.watched
                                              ? Icons.visibility_off
                                              : Icons.check_box_outline_blank,
                                          color:
                                              item.watched
                                                  ? Colors.grey
                                                  : Theme.of(
                                                    context,
                                                  ).primaryColor,
                                          size: 28,
                                        ),
                                        onPressed: () {
                                          movieSeriesProvider
                                              .toggleWatchedStatus(item);
                                        },
                                        tooltip:
                                            item.watched
                                                ? 'Desmarcar como assistido'
                                                : 'Marcar como assistido',
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: 28,
                                        ),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder:
                                                (dialogCtx) => AlertDialog(
                                                  title: const Text(
                                                    'Confirmar Exclusão',
                                                  ),
                                                  content: Text(
                                                    'Tem certeza que deseja excluir "${item.title}" da sua lista?',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed:
                                                          () =>
                                                              Navigator.of(
                                                                dialogCtx,
                                                              ).pop(),
                                                      child: const Text(
                                                        'Cancelar',
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        movieSeriesProvider
                                                            .deleteMovieSeries(
                                                              item.id,
                                                            );
                                                        Navigator.of(
                                                          dialogCtx,
                                                        ).pop();
                                                      },
                                                      child: const Text(
                                                        'Excluir',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                          );
                                        },
                                        tooltip: 'Excluir',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context).pushNamed('/search');
            },
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Novo'),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }
}
