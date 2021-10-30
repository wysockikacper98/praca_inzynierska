import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../helpers/colorfull_print_messages.dart';
import '../../helpers/firebase_firestore.dart';
import '../../models/address.dart';
import '../../models/firm.dart';

class PickLocationScreen extends StatefulWidget {
  static const String routeName = '/pick-location';

  @override
  _PickLocationScreenState createState() => _PickLocationScreenState();
}

class _PickLocationScreenState extends State<PickLocationScreen> {
  CameraPosition _position = const CameraPosition(
    target: LatLng(52, 20),
    zoom: 5,
  );
  late GoogleMapController _controller;
  MapType _mapType = MapType.normal;
  Set<Marker> _marker = Set<Marker>.of([]);
  Address? address;
  bool _isMapCreated = false;
  bool _nightMode = false;

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Wybór lokalizacji'),
        actions: [if (_isMapCreated) _nightModeToggler()],
      ),
      body: Column(
        children: [
          SizedBox(
            height: height * 0.6,
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: _position,
              compassEnabled: true,
              mapToolbarEnabled: false,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              mapType: _mapType,
              markers: _marker,
              onLongPress: (LatLng position) => _setMarker(position),
            ),
          ),
          buildAddressPreview(),
        ],
      ),
    );
  }

  Widget buildAddressPreview() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            if (address != null) ...[
              Text('Ulica: ${address!.streetAndHouseNumber}'),
              Text('Kod pocztowy: ${address!.zipCode}'),
              Text('Miejscowość: ${address!.city}'),
              Text('Powiat: ${address!.subAdministrativeArea ?? ''}'),
              Text('Województwo: ${address!.administrativeArea ?? ''}'),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.close),
                  label: Text('Anuluj'),
                  onPressed: Navigator.of(context).pop,
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.save),
                  label: Text('Zapisz'),
                  onPressed: (address == null || address!.zipCode == '')
                      ? null
                      : () {
                          Provider.of<FirmProvider>(context, listen: false)
                              .updateAddress(address!);
                          updateUserAddress(address!);
                          Navigator.of(context).pop();
                        },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      printColor(text: 'Map Created!!!', color: PrintColor.green);
      _controller = controller;
      _isMapCreated = true;
    });
  }

  void _setMapStyle(String mapStyle) {
    setState(() {
      _nightMode = true;
      _controller.setMapStyle(mapStyle);
    });
  }

  Widget _nightModeToggler() {
    assert(_isMapCreated);
    return IconButton(
      icon: _nightMode ? Icon(Icons.light_mode) : Icon(Icons.dark_mode),
      onPressed: () {
        if (_nightMode) {
          setState(() {
            _nightMode = false;
            _controller.setMapStyle(null);
          });
        } else {
          _getFileData('assets/night_mode.json').then(_setMapStyle);
        }
      },
    );
  }

  Future<String> _getFileData(String path) async {
    return await rootBundle.loadString(path);
  }

  void _setMarker(LatLng position) {
    geo
        .placemarkFromCoordinates(position.latitude, position.longitude)
        .then((value) {
      printColor(text: value.first.toString(), color: PrintColor.blue);
      setState(() {
        address = Address(
          streetAndHouseNumber: value.first.street ?? '',
          city: value.first.locality ?? '',
          zipCode: value.first.postalCode ?? '',
          administrativeArea: value.first.administrativeArea,
          subAdministrativeArea: value.first.subAdministrativeArea,
        );
      });
    });

    final MarkerId markerId = MarkerId(Uuid().v4());
    setState(() {
      _marker.clear();
      _marker.add(Marker(
        markerId: markerId,
        position: position,
        infoWindow: InfoWindow(
          title: 'Wybrana lokalizajca',
          snippet: 'To jest wybrana przez Ciebie lokalizacja',
        ),
      ));
    });
  }
}
