import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_watchlist_app/models/movie_series.dart';

class MovieSeriesProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<MovieSeries> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<MovieSeries> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  MovieSeriesProvider() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        fetchMovieSeries();
      } else {
        _items = [];
        notifyListeners();
      }
    });
  }

  CollectionReference<Map<String, dynamic>>? get _userWatchlistCollection {
    final user = _auth.currentUser;
    if (user == null) {
      _errorMessage = 'Usuário não autenticado.';
      notifyListeners();
      return null;
    }
    return _firestore.collection('users').doc(user.uid).collection('watchlist');
  }

  Future<void> fetchMovieSeries() async {
    final userWatchlist = _userWatchlistCollection;
    if (userWatchlist == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final querySnapshot =
          await userWatchlist.orderBy('createdAt', descending: true).get();
      _items =
          querySnapshot.docs.map((doc) {
            return MovieSeries.fromFirestore(doc.data(), doc.id);
          }).toList();
    } catch (e) {
      _errorMessage = 'Erro ao carregar filmes: $e';
      debugPrint('Erro ao carregar filmes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMovieSeries(MovieSeries item) async {
    final userWatchlist = _userWatchlistCollection;
    if (userWatchlist == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final docRef = await userWatchlist.add(item.toFirestore());
      final newItem = MovieSeries(
        id: docRef.id,
        title: item.title,
        posterUrl: item.posterUrl,
        overview: item.overview,
        releaseDate: item.releaseDate,
        watched: item.watched,
      );
      _items.insert(0, newItem);
    } catch (e) {
      _errorMessage = 'Erro ao adicionar filme: $e';
      debugPrint('Erro ao adicionar filme: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleWatchedStatus(MovieSeries item) async {
    final userWatchlist = _userWatchlistCollection;
    if (userWatchlist == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await userWatchlist.doc(item.id).update({'watched': !item.watched});
      final index = _items.indexWhere((element) => element.id == item.id);
      if (index != -1) {
        _items[index].watched = !item.watched;
      }
    } catch (e) {
      _errorMessage = 'Erro ao atualizar status: $e';
      debugPrint('Erro ao atualizar status: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteMovieSeries(String itemId) async {
    final userWatchlist = _userWatchlistCollection;
    if (userWatchlist == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await userWatchlist.doc(itemId).delete();
      _items.removeWhere((item) => item.id == itemId);
    } catch (e) {
      _errorMessage = 'Erro ao excluir filme: $e';
      debugPrint('Erro ao excluir filme: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
