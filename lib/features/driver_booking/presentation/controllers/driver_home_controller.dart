import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/driver_remote_datasource.dart';
import '../../../staff_core/data/models/vehicle_type_model.dart';

final driverRemoteDatasourceProvider = Provider<DriverRemoteDatasource>((ref) {
  return DriverRemoteDatasource();
});

class DriverHomeState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? parkingLot;
  final List<VehicleTypeModel> vehicleTypes;

  DriverHomeState({
    this.isLoading = false,
    this.error,
    this.parkingLot,
    this.vehicleTypes = const [],
  });

  DriverHomeState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? parkingLot,
    List<VehicleTypeModel>? vehicleTypes,
  }) {
    return DriverHomeState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      parkingLot: parkingLot ?? this.parkingLot,
      vehicleTypes: vehicleTypes ?? this.vehicleTypes,
    );
  }
}

class DriverHomeController extends Notifier<DriverHomeState> {
  late final DriverRemoteDatasource _datasource;

  @override
  DriverHomeState build() {
    _datasource = ref.watch(driverRemoteDatasourceProvider);
    Future.microtask(() => fetchHomeData());
    return DriverHomeState();
  }

  Future<void> fetchHomeData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final lots = await _datasource.getParkingLots();
      final types = await _datasource.getVehicleTypes();
      
      Map<String, dynamic>? firstLot;
      if (lots.isNotEmpty) {
        firstLot = lots.first;
      }
      
      state = state.copyWith(
        isLoading: false,
        parkingLot: firstLot,
        vehicleTypes: types,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final driverHomeControllerProvider =
    NotifierProvider<DriverHomeController, DriverHomeState>(DriverHomeController.new);
