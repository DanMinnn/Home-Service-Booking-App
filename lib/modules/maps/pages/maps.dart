import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:home_service/modules/booking/models/booking_data.dart';
import 'package:home_service/providers/log_provider.dart';
import 'package:home_service/themes/app_assets.dart';
import 'package:home_service/themes/app_colors.dart';
import 'package:http/http.dart' as http;
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../../common/widgets/stateless/custom_snack_bar.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  MapLibreMapController? mapController;

  //final int _symbolCount = 0;
  LatLng? _currentPosition;
  LatLng? _destinationPosition;

  //static const clusterLayer = "clusters";
  //static const unclusteredPointLayer = "unclustered-points";
  PolylinePoints polylinePoints = PolylinePoints();
  Symbol? _currentMarker;
  Symbol? _currentLocationSymbol;
  Circle? _currentLocationCircle;
  OverlayEntry? _popupOverlayEntry;
  Timer? _debounce;
  bool _isLoading = false;
  final String apiKey = dotenv.env['GOONG_API_KEY'] ?? '';
  final String mapKey = dotenv.env['API_KEY_MAPTILES'] ?? '';

  LogProvider get logger => LogProvider(":::::MAPS-PAGE:::::");

  late BookingData bookingData;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is BookingData) {
      bookingData = args;
    } else {
      bookingData = BookingData();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _popupOverlayEntry?.remove();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _currentPosition = LatLng(10.588016772109414, 107.06048011779785);
    });
  }

  void _onMapCreated(MapLibreMapController controller) async {
    mapController = controller;
    await _loadMarkerImage();
    await _loadMarkerEndImage();
  }

  Future<void> _loadMarkerImage() async {
    final ByteData bytes =
        await rootBundle.load('assets/images/icons/current_location_ic.png');
    mapController?.addImage('location', bytes.buffer.asUint8List());
  }

  Future<void> _loadMarkerEndImage() async {
    final ByteData bytes =
        await rootBundle.load('assets/images/icons/locationEnd.png');
    mapController?.addImage('locationEnd', bytes.buffer.asUint8List());
  }

  void _onStyleLoadedCallback() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Loading map....."),
        backgroundColor: AppColors.blue,
        duration: const Duration(seconds: 1),
      ),
    );
    if (_currentPosition != null) {
      _addMarkerAtCurrentPosition();
    }
  }

  void _addMarkerAtCurrentPosition() async {
    if (mapController == null) return;

    const initialLatitude = 10.588016772109414;
    const initialLongitude = 107.06048011779785;

    try {
      if (_currentLocationSymbol != null) {
        await mapController!.removeSymbol(_currentLocationSymbol!);
      }

      if (_currentLocationCircle != null) {
        await mapController!.removeCircle(_currentLocationCircle!);
      }

      // Add a marker at the current position
      _currentLocationCircle = await mapController?.addCircle(CircleOptions(
        geometry: _currentPosition != null
            ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
            : LatLng(initialLatitude, initialLongitude),
        circleRadius: 100.0,
        circleColor: "#2AB749",
        circleOpacity: 0.2,
        circleStrokeWidth: 2,
        circleStrokeColor: "#2AB749",
      ));

      _currentLocationSymbol = await mapController?.addSymbol(SymbolOptions(
        geometry: _currentPosition != null
            ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
            : LatLng(initialLatitude, initialLongitude),
        iconImage: 'location',
        iconSize: 0.1,
        zIndex: 1,
      ));

      // Set default destination position if none exists
      if (_destinationPosition == null) {
        _destinationPosition =
            LatLng(initialLatitude + 0.001, initialLongitude + 0.001);
        _addMarkerAtDestinationPoint();
      }

      if (_currentPosition != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(_currentPosition!, 15.0),
        );
      }
    } catch (e) {
      logger.log('Error adding initial marker: $e');
    }
  }

  void _addMarkerAtDestinationPoint() async {
    if (mapController == null || _destinationPosition == null) return;

    try {
      // Remove existing marker if any
      if (_currentMarker != null) {
        await mapController!.removeSymbol(_currentMarker!);
      }

      // Add a marker
      _currentMarker = await mapController!.addSymbol(SymbolOptions(
        geometry: _destinationPosition!,
        iconImage: 'locationEnd',
        iconSize: 0.2,
      ));

      // Animate camera to destination
      mapController!
          .animateCamera(CameraUpdate.newLatLng(_destinationPosition!));

      // Get address for the initial position
      _getAddressFromLatLng(_destinationPosition!);
    } catch (e) {
      logger.log('Error adding marker: $e');
    }
  }

  // Update to use the correct callback signature for symbol tapping
  void _onSymbolTappedCallback(Symbol symbol) {
    // When a symbol is tapped, we'll enable the "tap to move" mode
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Now tap on the map to move the marker"),
        backgroundColor: AppColors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onMapClick(Point<double> point, LatLng coordinates) async {
    // Move the marker to the tapped location
    if (_currentMarker != null) {
      await mapController!.updateSymbol(
        _currentMarker!,
        SymbolOptions(geometry: coordinates),
      );

      setState(() {
        _destinationPosition = coordinates;
      });

      // Get address from the new position
      _getAddressFromLatLng(coordinates);
    }
  }

  // when user taps on the map, we will get the address from the coordinates and update the search bar
  Future<void> _getAddressFromLatLng(LatLng position) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse(
          'https://rsapi.goong.io/Geocode?latlng=${position.latitude},${position.longitude}&api_key=$apiKey');

      final response = await http.get(url);
      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse['results'] != null &&
          jsonResponse['results'].isNotEmpty) {
        final address = jsonResponse['results'][0]['formatted_address'];
        _searchController.text = address;

        bookingData = bookingData.copyWith(
          address: address,
          latitude: position.latitude,
          longitude: position.longitude,
        );
      } else {
        // If no address found, display the coordinates
        _searchController.text = '${position.latitude}, ${position.longitude}';
      }
    } catch (e) {
      logger.log('Error getting address: $e');
      // Display coordinates as fallback
      _searchController.text = '${position.latitude}, ${position.longitude}';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentUserLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      //check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      final LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );

      //get current position
      Position position = await Geolocator.getCurrentPosition(
          locationSettings: locationSettings);

      LatLng newPosition = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentPosition = newPosition;
      });

      // Update the map view
      if (mapController != null) {
        mapController!
            .animateCamera(CameraUpdate.newLatLngZoom(_currentPosition!, 15.0));

        _addMarkerAtCurrentPosition();
      }

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: const Text("Current location found"),
      //     backgroundColor: AppColors.blue,
      //     duration: const Duration(seconds: 1),
      //   ),
      // );
    } catch (e) {
      logger.log('Error getting current location: $e');
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const CustomSnackBar(
          backgroundColor: AppColors.snackBarErrorDark,
          closeColor: AppColors.bubblesDark,
          bubbleColor: AppColors.bubblesDark,
          title: "Oh snap!",
          message: "Some thing went wrong, please check your location",
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.transparent,
        elevation: 0,
        duration: const Duration(seconds: 3),
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  final TextEditingController _searchController = TextEditingController();
  String mainText = "";
  String secondText = "";
  List<dynamic> places = [];
  var details = {};
  bool isShow = false;
  bool isHidden = true;

  Future<void> fetchData(String input) async {
    if (input.isEmpty) {
      setState(() {
        places = [];
        isShow = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse(
          'https://rsapi.goong.io/Place/AutoComplete?location=21.013715429594125%2C%20105.79829597455202&input=$input&api_key=$apiKey');

      var response = await http.get(url);
      final jsonResponse = jsonDecode(response.body);

      setState(() {
        places = jsonResponse['predictions'] as List<dynamic>;
        isShow = places.isNotEmpty;
        isHidden = true;
        _isLoading = false;
      });
    } catch (e) {
      logger.log('Error fetching place data: $e');
      setState(() {
        _isLoading = false;
        isShow = false;
      });
    }
  }

  Future<void> fetchDataDirection() async {
    if (_currentPosition == null || _destinationPosition == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse(
          'https://rsapi.goong.io/Direction?origin=${_currentPosition!.latitude},${_currentPosition!.longitude}&destination=${_destinationPosition!.latitude},${_destinationPosition!.longitude}&vehicle=bike&api_key=$apiKey');

      var response = await http.get(url);
      final jsonResponse = jsonDecode(response.body);
      var route = jsonResponse['routes'][0]['overview_polyline']['points'];
      List<PointLatLng> result = polylinePoints.decodePolyline(route);
      List<List<double>> coordinates =
          result.map((point) => [point.longitude, point.latitude]).toList();

      _drawLine(coordinates);
    } catch (e) {
      logger.log('Error fetching directions: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _drawLine(List<List<double>> coordinates) {
    mapController?.removeLayer("line_layer");
    mapController?.removeSource("line_source");

    final geoJsonData = {
      "type": "FeatureCollection",
      "features": [
        {
          "type": "Feature",
          "geometry": {
            "type": "LineString",
            "coordinates": coordinates,
          },
        },
      ],
    };

    mapController?.addSource(
      "line_source",
      GeojsonSourceProperties(
        data: geoJsonData,
      ),
    );

    mapController?.addLineLayer(
      "line_source",
      "line_layer",
      LineLayerProperties(
        lineColor: "#0000FF",
        lineCap: "round",
        lineJoin: "round",
        lineWidth: 6,
      ),
    );
  }

  // Optimized search with debounce (delay to avoid too many requests)
  void _onSearchTextChanged(String text) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchData(text);
    });
  }

  Widget _buildListView() {
    return Container(
      constraints: BoxConstraints(maxHeight: 300),
      child: ListView.separated(
        itemCount: places.length < 5 ? places.length : 5,
        shrinkWrap: true,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final coordinate = places[index];
          return ListTile(
            horizontalTitleGap: 5,
            title: Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: Colors.blue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    coordinate['description'],
                    softWrap: true,
                    style: const TextStyle(color: Colors.black54),
                  ),
                )
              ],
            ),
            onTap: () async {
              setState(() {
                isShow = false;
                isHidden = false;
                _isLoading = true;
              });

              final url = Uri.parse(
                  'https://rsapi.goong.io/place/detail?place_id=${coordinate['place_id']}&api_key=$apiKey');

              try {
                var response = await http.get(url);
                final jsonResponse = jsonDecode(response.body);
                details = jsonResponse['result'];

                setState(() {
                  _destinationPosition = LatLng(
                      details['geometry']['location']['lat'],
                      details['geometry']['location']['lng']);
                  _searchController.text = coordinate['description'];
                  mainText = coordinate['structured_formatting']['main_text'];
                  secondText =
                      coordinate['structured_formatting']['secondary_text'];
                  _isLoading = false;
                });

                _addMarkerAtDestinationPoint();
              } catch (e) {
                logger.log('Error fetching place details: $e');
                setState(() {
                  _isLoading = false;
                });
              }
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: MapLibreMap(
              onMapCreated: _onMapCreated,
              onStyleLoadedCallback: _onStyleLoadedCallback,
              initialCameraPosition: CameraPosition(
                target: LatLng(10.588016772109414, 107.06048011779785),
                zoom: 14.0,
              ),
              styleString:
                  'https://tiles.goong.io/assets/goong_map_web.json?api_key=$mapKey',
              attributionButtonPosition: null,
              onMapClick: _onMapClick, // Provide callback here instead
            ),
          ),

          // Search bar
          Container(
            height: 70,
            alignment: Alignment.topLeft,
            margin: const EdgeInsets.fromLTRB(5, 80, 5, 10),
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            decoration: BoxDecoration(
                color: AppColors.darkBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(left: 4),
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Row(
                          children: [
                            Image.asset(AppAssetIcons.location),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 4, right: 8),
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: _onSearchTextChanged,
                                  decoration: const InputDecoration(
                                    hintText:
                                        "Enter your address or tap on the map",
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(
                                        color: AppColors.black, fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(bookingData);
                              },
                              child: const Text(
                                "Pick location",
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Search results
          if (isShow)
            Container(
              margin: const EdgeInsets.fromLTRB(5, 160, 5, 0),
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.1),
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: _buildListView(),
            ),

          // Loading indicator
          if (_isLoading)
            Container(
              color: AppColors.black.withValues(alpha: 0.3),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),

          // Drag instruction
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  "Tap on map to move marker",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.blue,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: MediaQuery.of(context).size.width - 100,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _getCurrentUserLocation,
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: AppColors.darkBlue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      AppColors.white,
                      BlendMode.srcIn,
                    ),
                    child: Image.asset(AppAssetIcons.gps),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
