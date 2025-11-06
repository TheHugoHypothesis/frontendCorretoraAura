import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

// Classe que retorna os dados selecionados pelo mapa
class SelectedLocation {
  final LatLng coordinates;
  final String address;
  final String cep;
  final String logradouro;
  final String cidade;
  final String bairro; // Assumindo que você pode extrair o bairro

  SelectedLocation({
    required this.coordinates,
    required this.address,
    required this.cep,
    required this.logradouro,
    required this.cidade,
    required this.bairro,
  });
}

class MapLocationPicker extends StatefulWidget {
  final LatLng initialCenter;

  const MapLocationPicker({
    super.key,
    required this.initialCenter,
  });

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  LatLng _currentLocation;
  String _currentAddress = "Arraste o mapa para selecionar a localização...";
  bool _isLoadingAddress = false;

  _MapLocationPickerState()
      : _currentLocation = const LatLng(-23.5505, -46.6333); // Padrão SP

  @override
  void initState() {
    super.initState();
    _currentLocation = widget.initialCenter;
    // Tenta carregar o endereço inicial
    _geocodeLocation(_currentLocation);
  }

  // Função para converter LatLng em um endereço legível
  Future<void> _geocodeLocation(LatLng coordinates) async {
    setState(() {
      _isLoadingAddress = true;
      _currentAddress = "Buscando endereço...";
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        coordinates.latitude,
        coordinates.longitude,
        // language: "pt_BR", // Adicione se o geocoding suportar
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          _currentAddress = [
            place.street,
            place.subLocality, // Bairro ou Sub-localidade
            place.locality, // Cidade
            place.postalCode, // CEP
          ].where((s) => s != null && s.isNotEmpty).join(', ');
        });
      } else {
        setState(() {
          _currentAddress = "Endereço não encontrado nas coordenadas.";
        });
      }
    } catch (e) {
      setState(() {
        _currentAddress = "Erro ao buscar endereço: $e";
      });
    } finally {
      setState(() {
        _isLoadingAddress = false;
      });
    }
  }

  // Função chamada ao confirmar a seleção
  void _selectLocation() async {
    // Geocodificação final para retornar todos os detalhes
    List<Placemark> placemarks = [];
    Placemark place = Placemark(); // Inicializa com um Placemark vazio

    // Tenta obter as placemarks. Envolve a chamada principal em um try/catch.
    try {
      placemarks = await placemarkFromCoordinates(
          _currentLocation.latitude, _currentLocation.longitude);

      // Se a lista não estiver vazia, pega o primeiro resultado
      if (placemarks.isNotEmpty) {
        place = placemarks.first;
      }
    } catch (e) {
      // Se houver qualquer erro (Null check, rede, etc.), o erro será pego aqui.
      print("Erro ao obter Placemarks durante a seleção: $e");

      // Criamos um Placemark de fallback com a coordenada atual e dados "Não disponível".
      place = Placemark(
        country: 'Não disponível',
        locality: 'Cidade não disponível',
        street: 'Logradouro não disponível',
        postalCode: 'N/A',
        subLocality: 'Bairro não disponível',
      );
    }

    // 1. Opcional: Para evitar a navegação em caso de erro total (se for crítico)
    /*
    if (placemarks.isEmpty && place.locality == 'Cidade não disponível') {
        if (mounted) {
            Navigator.pop(context, null); // Sai se falhou
        }
        return;
    }
    */

    // 2. Cria o objeto de resultado, usando o Placemark de fallback em caso de falha.
    SelectedLocation result = SelectedLocation(
      coordinates: _currentLocation,
      address: _currentAddress, // Usa o endereço exibido no painel

      // Garantimos que todos os campos sejam strings, mesmo que nulos na Placemark
      cep: place.postalCode ?? 'N/A',
      logradouro: place.street ?? 'Logradouro não disponível',
      cidade: place.locality ?? 'Cidade não disponível',
      // subAdministrativeArea é uma alternativa para Bairro se subLocality for nulo
      bairro: place.subLocality ??
          place.subAdministrativeArea ??
          'Bairro não disponível',
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
              // Ao mover o mapa, atualiza a localização
              onMapEvent: (event) {
                if (event is MapEventMoveEnd) {
                  LatLng center = event.camera.center;
                  // Não faz geocoding em todo movimento, mas no final do movimento
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
                // URL padrão do OpenStreetMap
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
