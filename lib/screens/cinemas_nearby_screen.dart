import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:my_watchlist_app/models/cinema.dart';
import 'package:my_watchlist_app/services/places_api_service.dart';

class CinemasNearbyScreen extends StatefulWidget {
  final Position? userLocation;

  const CinemasNearbyScreen({super.key, this.userLocation});

  @override
  State<CinemasNearbyScreen> createState() => _CinemasNearbyScreenState();
}

class _CinemasNearbyScreenState extends State<CinemasNearbyScreen> {
  final PlacesApiService _placesApiService = PlacesApiService();
  List<Cinema> _cinemas = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.userLocation != null) {
      _fetchCinemas(
        widget.userLocation!.latitude,
        widget.userLocation!.longitude,
      );
    } else {
      _errorMessage = 'Localização do usuário não disponível.';
    }
  }

  Future<void> _fetchCinemas(double lat, double lng) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await _placesApiService.searchNearbyCinemas(lat, lng);
      if (!mounted) return;

      setState(() {
        _cinemas = results;
        if (_cinemas.isEmpty) {
          _errorMessage =
              'Nenhum cinema encontrado nas proximidades. Tente uma localização diferente ou aumente o raio de busca.';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Erro ao buscar cinemas: Verifique sua chave de API e conexão.';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _launchMaps(double lat, double lng, String cinemaName) async {
    final Uri uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&query=$cinemaName',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o mapa.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cinemas Próximos'), elevation: 0),
      body: Container(
        color: Colors.grey[100],
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_off, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tentar Novamente'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                : _cinemas.isEmpty
                ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sentiment_dissatisfied,
                        size: 80,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Nenhum cinema encontrado.\nVerifique sua localização simulada.',
                        style: TextStyle(color: Colors.grey, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
                : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: _cinemas.length,
                  itemBuilder: (ctx, index) {
                    final cinema = _cinemas[index];
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
                          _launchMaps(
                            cinema.latitude,
                            cinema.longitude,
                            cinema.name,
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child:
                                    (cinema.photoReference != null)
                                        ? Image.network(
                                          _placesApiService.getPhotoUrl(
                                            cinema.photoReference,
                                          )!,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                                    width: 80,
                                                    height: 80,
                                                    color: Colors.grey[200],
                                                    child: const Icon(
                                                      Icons.theaters,
                                                      size: 40,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                        )
                                        : Container(
                                          width: 80,
                                          height: 80,
                                          color: Colors.grey[200],
                                          child: const Icon(
                                            Icons.theaters,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                        ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cinema.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      cinema.address,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (cinema.rating > 0)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 4.0,
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${cinema.rating}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.directions,
                                  color: Colors.blue,
                                  size: 32,
                                ),
                                onPressed: () {
                                  _launchMaps(
                                    cinema.latitude,
                                    cinema.longitude,
                                    cinema.name,
                                  );
                                },
                                tooltip: 'Abrir no Mapa',
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
