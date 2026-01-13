import 'package:flutter/material.dart';
import 'package:mapbox_navigation/service/routing_service_interface.dart';
import 'package:mapbox_navigation/service/routing_settings_service.dart';


/// Settings page for routing configuration
class RoutingSettingsPage extends StatefulWidget {
  const RoutingSettingsPage({super.key});

  @override
  State<RoutingSettingsPage> createState() => _RoutingSettingsPageState();
}

class _RoutingSettingsPageState extends State<RoutingSettingsPage> {
  final RoutingSettingsService _settingsService = RoutingSettingsService();
  RoutingProvider _selectedProvider = RoutingProvider.google;
  String? _googleApiKey;
  String? _mapboxAccessToken;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _googleApiKeyController.text = 'AIzaSyBmDivc_INAxU5uELl0xlxrbpnnk5hZ0EE';
      _mapboxTokenController.text =
          'pk.eyJ1Ijoic3JlZXJhbS1nYW5lc2FuIiwiYSI6ImNtOGJodWpjNTB0OTgyanI0Mm9sNGFqc28ifQ.vGIE0WuI1k4jua890aMCTw';
      _saveGoogleApiKey(_googleApiKeyController.text);
      _saveMapboxAccessToken(_mapboxTokenController.text);
    });
  }

  Future<void> _loadSettings() async {
    await _settingsService.initialize();
    final provider = await _settingsService.getRoutingProvider();
    final googleKey = await _settingsService.getGoogleApiKey();
    final mapboxToken = await _settingsService.getMapboxAccessToken();

    setState(() {
      _selectedProvider = provider;
      _googleApiKey = googleKey ?? '';
      _mapboxAccessToken = mapboxToken ?? '';
      _isLoading = false;
    });

    // Update text controllers
    _googleApiKeyController.text = _googleApiKey ?? '';
    _mapboxTokenController.text = _mapboxAccessToken ?? '';
  }

  Future<void> _saveProvider(RoutingProvider provider) async {
    await _settingsService.setRoutingProvider(provider);
    setState(() {
      _selectedProvider = provider;
    });
    _showSnackBar('Routing provider changed to ${provider.displayName}');
  }

  Future<void> _saveGoogleApiKey(String apiKey) async {
    await _settingsService.setGoogleApiKey(apiKey);
    setState(() {
      _googleApiKey = apiKey;
    });
    // _showSnackBar('Google API key saved');
  }

  Future<void> _saveMapboxAccessToken(String token) async {
    await _settingsService.setMapboxAccessToken(token);
    setState(() {
      _mapboxAccessToken = token;
    });
    // _showSnackBar('Mapbox access token saved');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Routing Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Routing Provider Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Routing Provider',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildProviderTile(
                      RoutingProvider.google,
                      Icons.map,
                      'Google Maps',
                      'Uses Google Directions API',
                    ),
                    const Divider(),
                    _buildProviderTile(
                      RoutingProvider.mapbox,
                      Icons.map_outlined,
                      'Mapbox',
                      'Uses Mapbox Directions API',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            /*             // API Keys Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'API Configuration',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),

                    // Google API Key
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Google API Key',
                        hintText: 'Enter your Google Maps API key',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.save),
                          onPressed: () {
                            if (_googleApiKeyController.text.isNotEmpty) {
                              _saveGoogleApiKey(_googleApiKeyController.text);
                            }
                          },
                        ),
                      ),
                      controller: _googleApiKeyController,
                      obscureText: true,
                      onChanged: (value) {
                        setState(() {
                          _googleApiKey = value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // Mapbox Access Token
                    TextField(
                      enableInteractiveSelection: true,
                      decoration: InputDecoration(
                        labelText: 'Mapbox Access Token',
                        hintText: 'Enter your Mapbox access token',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.save),
                          onPressed: () {
                            if (_mapboxTokenController.text.isNotEmpty) {
                              _saveMapboxAccessToken(
                                _mapboxTokenController.text,
                              );
                            }
                          },
                        ),
                      ),
                      controller: _mapboxTokenController,
                      obscureText: true,
                      onChanged: (value) {
                        setState(() {
                          _mapboxAccessToken = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16), */

            // Info Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Information',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Select your preferred routing provider using the toggle above\n'
                      '• Enter your API keys/tokens in the fields below\n'
                      '• The selected provider will be used for all route calculations\n'
                      '• Make sure to save your API keys after entering them',
                      style: TextStyle(color: Colors.blue.shade900),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  final TextEditingController _googleApiKeyController = TextEditingController();
  final TextEditingController _mapboxTokenController = TextEditingController();

  @override
  void dispose() {
    _googleApiKeyController.dispose();
    _mapboxTokenController.dispose();
    super.dispose();
  }

  Widget _buildProviderTile(
    RoutingProvider provider,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final isSelected = _selectedProvider == provider;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: isSelected,
        onChanged: (value) {
          if (value) {
            _saveProvider(provider);
          }
        },
      ),
      onTap: () {
        if (!isSelected) {
          _saveProvider(provider);
        }
      },
    );
  }
}
