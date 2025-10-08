import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/providers/school_provider.dart';
import 'package:edu_sync/providers/school_settings_provider.dart';

class SchoolSettingsScreen extends ConsumerStatefulWidget {
  const SchoolSettingsScreen({super.key});

  @override
  ConsumerState<SchoolSettingsScreen> createState() => _SchoolSettingsScreenState();
}

class _SchoolSettingsScreenState extends ConsumerState<SchoolSettingsScreen> {
  LatLng? _selectedLocation;
  double _attendanceRadius = 50.0;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSchoolSettings();
    });
  }

  Future<void> _loadSchoolSettings() async {
    final schoolSettings = ref.read(schoolSettingsProvider);
    if (schoolSettings != null) {
      setState(() {
        _selectedLocation = LatLng(
          schoolSettings.latitude,
          schoolSettings.longitude,
        );
        _attendanceRadius = schoolSettings.radius.toDouble();
      });
    } else {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation({bool animateMap = true}) async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are permanently denied, we cannot request permissions.')),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
      });
      if (animateMap && _mapController != null) {
        _mapController?.animateCamera(CameraUpdate.newLatLng(_selectedLocation!));
      }
    } catch (e) {
      print("Error getting current location: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting current location: $e')),
        );
      }
      setState(() {
        _selectedLocation = const LatLng(0, 0);
      });
    }
  }

  Future<void> _locateMe() async {
    await _getCurrentLocation(animateMap: true);
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_selectedLocation != null) {
      _mapController?.animateCamera(CameraUpdate.newLatLng(_selectedLocation!));
    }
  }

  void _onMapTap(LatLng latLng) {
    setState(() {
      _selectedLocation = latLng;
    });
  }

  void _saveSettings() async {
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location on the map.')),
      );
      return;
    }

    final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
    final schoolId = schoolProvider.currentSchool?.id;

    if (schoolId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: School ID not found.')),
        );
      }
      return;
    }

    await ref.read(schoolSettingsProvider.notifier).saveSchoolSettings(
        _selectedLocation!.latitude,
        _selectedLocation!.longitude,
        _attendanceRadius,
        schoolId.toString());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('School settings saved successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SchoolSettings?>(schoolSettingsProvider, (previous, next) {
      if (next != null) {
        setState(() {
          _selectedLocation = LatLng(next.latitude, next.longitude);
          _attendanceRadius = next.radius.toDouble();
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('School Location Settings'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _selectedLocation == null
                ? const Center(child: CircularProgressIndicator())
                : GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _selectedLocation!,
                      zoom: 15.0,
                    ),
                    onTap: _onMapTap,
                    markers: _selectedLocation == null
                        ? {}
                        : {
                            Marker(
                              markerId: const MarkerId('schoolLocation'),
                              position: _selectedLocation!,
                              draggable: true,
                              onDragEnd: (newLatLng) {
                                setState(() {
                                  _selectedLocation = newLatLng;
                                });
                              },
                            ),
                          },
                    circles: _selectedLocation == null
                        ? {}
                        : {
                            Circle(
                              circleId: const CircleId('attendanceRadius'),
                              center: _selectedLocation!,
                              radius: _attendanceRadius,
                              fillColor: Colors.blue.withAlpha(51), // 0.2 opacity
                              strokeColor: Colors.blue,
                              strokeWidth: 2,
                            ),
                          },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('Attendance Radius: ${_attendanceRadius.round()} meters'),
                Slider(
                  value: _attendanceRadius,
                  min: 10,
                  max: 500,
                  divisions: 49,
                  label: _attendanceRadius.round().toString(),
                  onChanged: (value) {
                    setState(() {
                      _attendanceRadius = value;
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: _saveSettings,
                  child: const Text('Save Settings'),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _locateMe,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}