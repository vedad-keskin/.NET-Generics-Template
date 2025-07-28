import 'package:calltaxi_mobile_client/utils/custom_map_view_with_selection.dart';
import 'package:calltaxi_mobile_client/providers/vehicle_tier_provider.dart';
import 'package:calltaxi_mobile_client/providers/driver_request_provider.dart';
import 'package:calltaxi_mobile_client/model/vehicle_tier.dart';
import 'package:calltaxi_mobile_client/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calltaxi_mobile_client/model/driver_request.dart';

class CallTaxiScreen extends StatefulWidget {
  const CallTaxiScreen({Key? key}) : super(key: key);

  @override
  State<CallTaxiScreen> createState() => _CallTaxiScreenState();
}

class _CallTaxiScreenState extends State<CallTaxiScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _showForm = false;
  bool _waitingForDriver = false;
  String? _startLocation;
  String? _endLocation;
  double? _distanceKm;
  int? _selectedTierId;
  double? _basePrice;
  double? _finalPrice;
  List<VehicleTier> _tiers = [];
  bool _loadingTiers = true;
  bool _submitting = false;
  String? _error;
  DriverRequest? _pendingDrive;
  int? _recommendedTierId; // Add this variable for recommended tier

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000), // Slower for smoother pulsing
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut, // Smoother curve for up and down motion
    );
    _controller.repeat(reverse: true); // This creates the up and down motion
    _fetchTiers();
    _checkPendingDrive();
  }

  Future<void> _fetchTiers() async {
    setState(() => _loadingTiers = true);
    final provider = VehicleTierProvider();

    // Get all tiers
    final result = await provider.get();
    final tiers = result.items ?? [];

    // Get recommended tier for current user
    int? recommendedTierId;
    final user = UserProvider.currentUser;
    if (user != null) {
      try {
        final recommendedTier = await provider.recommendForUser(user.id);
        if (recommendedTier != null) {
          recommendedTierId = recommendedTier.id;
        }
      } catch (e) {
        print('Error getting recommended tier: $e');
      }
    }

    int? defaultTierId;
    for (final t in tiers) {
      if (t.name == 'Standard') {
        defaultTierId = t.id;
        break;
      }
    }

    setState(() {
      _tiers = tiers;
      _loadingTiers = false;
      _recommendedTierId = recommendedTierId;
      // Prefer recommended tier, fallback to Standard, then first available
      _selectedTierId =
          recommendedTierId ??
          defaultTierId ??
          (tiers.isNotEmpty ? tiers.first.id : null);
    });
    _updateFinalPrice();
  }

  Future<void> _checkPendingDrive() async {
    final user = UserProvider.currentUser;
    if (user == null) return;
    final provider = DriverRequestProvider();
    final result = await provider.get(
      filter: {'userId': user.id, 'status': 'Pending'},
    );
    if (result.items != null && result.items!.isNotEmpty) {
      setState(() {
        _pendingDrive = result.items!.first;
        _waitingForDriver = true;
        _showForm = false;
      });
    } else {
      setState(() {
        _pendingDrive = null;
        _waitingForDriver = false;
        _showForm = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onRequestDrivePressed() {
    setState(() {
      _showForm = true;
      _waitingForDriver = false;
      // Use recommended tier if available, otherwise fallback to Standard
      _selectedTierId =
          _recommendedTierId ??
          _tiers
              .firstWhere(
                (t) => t.name == 'Standard',
                orElse: () => _tiers.isNotEmpty ? _tiers.first : VehicleTier(),
              )
              .id;
      _updateFinalPrice();
    });
  }

  void _onStartSelected(String? loc) {
    setState(() {
      _startLocation = loc;
      _endLocation = null;
      _distanceKm = null;
    });
  }

  void _onEndSelected(String? loc) {
    setState(() {
      _endLocation = loc;
    });
  }

  void _onDistanceChanged(double? km) {
    setState(() {
      _distanceKm = km;
      _basePrice = (km != null) ? (km * 3.0) : null;
      _updateFinalPrice();
    });
  }

  void _onTierSelected(int id) {
    setState(() {
      _selectedTierId = id;
      _updateFinalPrice();
    });
  }

  void _updateFinalPrice() {
    if (_basePrice == null || _selectedTierId == null) {
      _finalPrice = null;
      return;
    }
    final tier = _tiers.firstWhere(
      (t) => t.id == _selectedTierId,
      orElse: () => VehicleTier(),
    );
    double multiplier = 1.0;
    if (tier.name == 'Premium') multiplier = 1.25;
    if (tier.name == 'Luxury') multiplier = 1.5;
    _finalPrice = _basePrice! * multiplier;
  }

  Future<void> _submitRequest() async {
    if (_startLocation == null ||
        _endLocation == null ||
        _selectedTierId == null ||
        _basePrice == null) {
      setState(() {
        _error = 'Please select all required fields.';
      });
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final provider = DriverRequestProvider();
      final user = UserProvider.currentUser;
      final req = {
        'userId': user?.id,
        'vehicleTierId': _selectedTierId,
        'startLocation': _startLocation,
        'endLocation': _endLocation,
        'basePrice': _basePrice,
      };
      await provider.insert(req);
      await _checkPendingDrive(); // refresh state after submit
      setState(() {
        _submitting = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _submitting = false;
      });
    }
  }

  Widget _buildTierCard(VehicleTier tier) {
    final selected = _selectedTierId == tier.id;
    final isRecommended = _recommendedTierId == tier.id;
    return GestureDetector(
      onTap: () => _onTierSelected(tier.id),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 250),
        margin: EdgeInsets.symmetric(horizontal: 6),
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16), // smaller
        decoration: BoxDecoration(
          color: selected ? Colors.orange.shade100 : Colors.white,
          border: Border.all(
            color: isRecommended
                ? Colors.green
                : selected
                ? Colors.deepOrange
                : Colors.grey.shade300,
            width: isRecommended
                ? 3.0
                : selected
                ? 2.5
                : 1.0,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: selected || isRecommended
              ? [
                  BoxShadow(
                    color: isRecommended
                        ? Colors.green.withOpacity(0.3)
                        : Colors.orange.withOpacity(0.15),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              tier.name == 'Standard'
                  ? Icons.directions_car
                  : tier.name == 'Premium'
                  ? Icons.star
                  : Icons.diamond,
              color: isRecommended
                  ? Colors.green
                  : selected
                  ? Colors.deepOrange
                  : Colors.grey,
              size: 28,
            ),
            SizedBox(height: 6),
            Text(
              tier.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isRecommended
                    ? Colors.green
                    : selected
                    ? Colors.deepOrange
                    : Colors.black87,
              ),
            ),
            if (isRecommended) ...[
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'RECOMMENDED',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return WillPopScope(
      onWillPop: () async {
        await _checkPendingDrive();
        setState(() {
          _showForm = false;
          _waitingForDriver = false;
          _pendingDrive = null;
          _startLocation = null;
          _endLocation = null;
          _distanceKm = null;
          _selectedTierId = _tiers
              .firstWhere(
                (t) => t.name == 'Standard',
                orElse: () => _tiers.isNotEmpty ? _tiers.first : VehicleTier(),
              )
              .id;
          _basePrice = null;
          _finalPrice = null;
        });
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: Icon(Icons.close, color: Colors.black87),
              onPressed: () async {
                await _checkPendingDrive();
                setState(() {
                  _showForm = false;
                  _waitingForDriver = false;
                  _pendingDrive = null;
                  _startLocation = null;
                  _endLocation = null;
                  _distanceKm = null;
                  _selectedTierId = _tiers
                      .firstWhere(
                        (t) => t.name == 'Standard',
                        orElse: () =>
                            _tiers.isNotEmpty ? _tiers.first : VehicleTier(),
                      )
                      .id;
                  _basePrice = null;
                  _finalPrice = null;
                });
              },
              tooltip: 'Close',
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomMapViewWithSelection(
                  height: 320,
                  width: MediaQuery.of(context).size.width * 0.95,
                  onStartSelected: (loc) {
                    _onStartSelected(loc);
                    _onDistanceChanged(null);
                  },
                  onEndSelected: (loc) async {
                    _onEndSelected(loc);
                  },
                  onDistanceChanged: _onDistanceChanged,
                ),
                SizedBox(height: 18),
                if (_loadingTiers)
                  CircularProgressIndicator()
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _tiers.map(_buildTierCard).toList(),
                    ),
                  ),
                SizedBox(height: 18),
                if (_finalPrice != null)
                  Text(
                    'Final Price: ${_finalPrice!.toStringAsFixed(2)} KM',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                SizedBox(height: 24),
                if (_error != null)
                  Text(_error!, style: TextStyle(color: Colors.red)),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _submitting ? null : _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    minimumSize: Size(double.infinity, 48),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.black12, width: 1.2),
                    ),
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    elevation: 2,
                  ),
                  child: _submitting
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.black87,
                            strokeWidth: 2,
                          ),
                        )
                      : Text('Accept'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernRequestCard() {
    return Center(
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Need a Ride?',
                style: TextStyle(
                  color: Color(0xFFFF6F00),
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  letterSpacing: 1.1,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Tap below to request a taxi quickly and safely.',
                style: TextStyle(color: Colors.black54, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 28),
              // Spinning animated circular button (no image above)
              Center(
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return GestureDetector(
                          onTap: _onRequestDrivePressed,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 4),
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF66BB6A),
                                  Color(0xFF81C784),
                                  Color(0xFFA5D6A7),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF66BB6A).withOpacity(0.3),
                                  blurRadius: 18,
                                  spreadRadius: 2,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Transform.scale(
                                scale:
                                    1.0 +
                                    0.3 *
                                        _scaleAnimation
                                            .value, // More pronounced pulsing
                                child: Icon(
                                  Icons.local_taxi,
                                  size: 65,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 18),
                    Text(
                      'Request',
                      style: TextStyle(
                        color: Color(0xFFFF6F00),
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernWaitingScreen() {
    return Center(
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Looking for Driver',
                style: TextStyle(
                  color: Color(0xFF6a11cb),
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  letterSpacing: 1.1,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Please wait while we find your driver...',
                style: TextStyle(color: Colors.black54, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 28),
              // Animated waiting icon
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return GestureDetector(
                    onTap: () {}, // No action needed for waiting
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 4),
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF6a11cb),
                            Color(0xFF2575fc),
                            Color(0xFF4a148c),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF6a11cb).withOpacity(0.3),
                            blurRadius: 18,
                            spreadRadius: 2,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Transform.scale(
                          scale:
                              1.0 +
                              0.3 * _scaleAnimation.value, // Pulsing hourglass
                          child: Icon(
                            Icons.hourglass_top,
                            size: 65,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 18),
              Text(
                'Searching...',
                style: TextStyle(
                  color: Color(0xFF6a11cb),
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  letterSpacing: 1.1,
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () async {
                  if (_pendingDrive != null) {
                    try {
                      await DriverRequestProvider().cancel(_pendingDrive!.id);
                      await _checkPendingDrive(); // Refresh state from backend
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to cancel request: $e')),
                      );
                    }
                  }
                  int? standardId;
                  for (final t in _tiers) {
                    if (t.name == 'Standard') {
                      standardId = t.id;
                      break;
                    }
                  }
                  setState(() {
                    _waitingForDriver = false;
                    _showForm = false;
                    _pendingDrive = null;
                    _startLocation = null;
                    _endLocation = null;
                    _distanceKm = null;
                    _selectedTierId =
                        standardId ??
                        (_tiers.isNotEmpty ? _tiers.first.id : null);
                    _basePrice = null;
                    _finalPrice = null;
                  });
                },
                icon: Icon(Icons.cancel, color: Colors.white),
                label: Text(
                  'Cancel Request',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_waitingForDriver) {
      return _buildModernWaitingScreen();
    }
    if (_showForm) {
      return _buildForm();
    }
    return _buildModernRequestCard();
  }
}
