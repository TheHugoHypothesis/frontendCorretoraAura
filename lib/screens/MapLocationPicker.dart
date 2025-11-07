import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Adiciona o import necessário para o AttributionWidget, se necessário (depende da versão do flutter_map)
// --- Widgets e Classes de Resultado (Mantidos) ---
class SelectedLocation {
  final LatLng coordinates;
  final String address;
  final String cep;
  final String logradouro;
  final String cidade;
  final String bairro;

  SelectedLocation({
    required this.coordinates,
    required this.address,
    required this.cep,
    required this.logradouro,
    required this.cidade,
    required this.bairro,
  });
}

// Classe de Fallback/Mapeamento para Placemark (Simplificada)
class NominatimResult {
  final String road;
  final String suburb;
  final String city;
  final String postcode;

  NominatimResult({
    this.road = 'Logradouro não disponível',
    this.suburb = 'Bairro não disponível',
    this.city = 'Cidade não disponível',
    this.postcode = 'N/A',
  });
}

class MapLocationPicker extends StatefulWidget {
// ... (código MapLocationPicker) ...
  final LatLng initialCenter;

  const MapLocationPicker({
    super.key,
    required this.initialCenter,
  });

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  late LatLng _currentLocation;
  String _currentAddress = "Arraste o mapa para selecionar a localização...";
  bool _isLoadingAddress = false;

  _MapLocationPickerState();

  @override
  void initState() {
    super.initState();
    _currentLocation = widget.initialCenter;
    _geocodeLocation(_currentLocation);
  }

  // NOVO MÉTODO: Geocodificação usando API Nominatim (HTTP)
  Future<NominatimResult> _geocodeWithNominatim(LatLng coordinates) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${coordinates.latitude}&lon=${coordinates.longitude}&zoom=18&addressdetails=1');

    try {
      final response = await http.get(url, headers: {
        // OBRIGATÓRIO: User-Agent para a política OSM
        'User-Agent': 'AuraImobiliariaApp/1.0 (contact: seu-email@exemplo.com)'
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'] ?? {};

        return NominatimResult(
          road: address['road'] ??
              address['footway'] ??
              address['pedestrian'] ??
              '',
          suburb: address['suburb'] ?? address['city_district'] ?? '',
          city: address['city'] ?? address['town'] ?? address['village'] ?? '',
          postcode: address['postcode'] ?? 'N/A',
        );
      }
    } catch (e) {
      print("Erro HTTP/JSON na geocodificação: $e");
    }
    // Retorna fallback em caso de falha de rede ou HTTP não-200
    return NominatimResult();
  }

  // Função para converter LatLng em um endereço legível (USANDO NOMINATIM)
  Future<void> _geocodeLocation(LatLng coordinates) async {
    setState(() {
      _isLoadingAddress = true;
      _currentAddress = "Buscando endereço...";
    });

    try {
      final NominatimResult place = await _geocodeWithNominatim(coordinates);

      if (place.road.isNotEmpty || place.city.isNotEmpty) {
        setState(() {
          // Constrói um endereço legível para exibição no painel
          _currentAddress = [
            place.road,
            place.suburb,
            place.city,
            place.postcode,
          ]
              .where((s) =>
                  s.isNotEmpty &&
                  s != 'Logradouro não disponível' &&
                  s != 'N/A')
              .join(', ');
        });
      } else {
        setState(() {
          _currentAddress = "Endereço não encontrado nas coordenadas.";
        });
      }
    } catch (e) {
      setState(() {
        _currentAddress = "Erro fatal ao buscar endereço.";
      });
    } finally {
      setState(() {
        _isLoadingAddress = false;
      });
    }
  }

  // Função chamada ao confirmar a seleção (USANDO NOMINATIM)
  void _selectLocation() async {
    // Apenas garante que a última busca foi concluída
    if (_isLoadingAddress) return;

    // Obtenção final dos detalhes
    final NominatimResult place = await _geocodeWithNominatim(_currentLocation);

    // Cria o objeto de resultado
    SelectedLocation result = SelectedLocation(
      coordinates: _currentLocation,
      address: _currentAddress,
      cep: place.postcode,
      logradouro: place.road,
      cidade: place.city,
      bairro: place.suburb,
    );

    // Retorna o resultado
    if (mounted) {
      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: Icon(CupertinoIcons.clear_thick, color: primaryColor),
        ),
        title: Text(
          "Selecionar Endereço",
          style:
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          CupertinoButton(
            onPressed: _selectLocation,
            child: Text(
              "Confirmar",
              style: theme.textTheme.titleMedium?.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Mapa Interativo (OpenStreetMap)
          FlutterMap(
            options: MapOptions(
              initialCenter: _currentLocation,
              initialZoom: 15.0,
              onMapEvent: (event) {
                if (event is MapEventMoveEnd) {
                  LatLng center = event.camera.center;
                  if (center.latitude != _currentLocation.latitude ||
                      center.longitude != _currentLocation.longitude) {
                    _currentLocation = center;
                    _geocodeLocation(_currentLocation);
                  }
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.aura_imobiliaria',
              ),

              // Marcador de Centro (Fixo no centro da tela)
              Center(
                child: Icon(
                  CupertinoIcons.location_solid,
                  color: primaryColor,
                  size: 40,
                ),
              ),
            ],
          ),

          // 2. Painel Inferior de Endereço (Estilo Apple Like)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withOpacity(0.9)
                    : Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Localização Selecionada:",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_isLoadingAddress)
                    const CupertinoActivityIndicator()
                  else
                    Text(
                      _currentAddress,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: primaryColor,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
