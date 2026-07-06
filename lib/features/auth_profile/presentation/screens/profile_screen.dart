import 'package:flutter/material.dart';
import '../../../../app/app.dart' as import_app;
import 'auth_profile_screen.dart';
import 'change_password_screen.dart';
import '../../../driver_tracking/presentation/screens/feedback_screen.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/models/vehicle_model.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../../../driver_booking/data/datasources/driver_remote_datasource.dart';
import '../../../staff_core/data/models/vehicle_type_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;

  final _authRepo = AuthRepository();
  final _vehicleRepo = VehicleRepository();
  final _driverDatasource = DriverRemoteDatasource();

  UserModel? _user;
  List<VehicleModel> _vehicles = [];
  List<VehicleTypeModel> _vehicleTypes = [];

  bool _isLoading = true;

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = await _authRepo.getMe();
      final vehicles = await _vehicleRepo.getMyVehicles();
      final types = await _driverDatasource.getVehicleTypes();
      if (mounted) {
        setState(() {
          _user = user;
          _vehicles = vehicles;
          _vehicleTypes = types;
          _nameController.text = user.fullName;
          _phoneController.text = user.phone;
          _emailController.text = user.email;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _toggleEditMode() async {
    if (_isEditing) {
      setState(() => _isLoading = true);
      try {
        final updatedUser = await _authRepo.updateProfile(
          _nameController.text,
          _phoneController.text,
        );
        if (mounted) {
          setState(() {
            _user = updatedUser;
            _isEditing = false;
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Color(0xFF0B7A59),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      setState(() {
        _isEditing = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0B7A59)),
          onPressed: () {},
        ),
        title: Text(
          'Profile',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: isDark ? Colors.amber : const Color(0xFF0F172A)),
            onPressed: () {
              import_app.SmartParkingApp.of(context).toggleTheme(isDark);
            },
          ),
          if (_isEditing) ...[
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _nameController.text = _user?.fullName ?? '';
                  _phoneController.text = _user?.phone ?? '';
                  _emailController.text = _user?.email ?? '';
                });
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            TextButton(
              onPressed: _toggleEditMode,
              child: const Text(
                'Save',
                style: TextStyle(color: Color(0xFF0B7A59), fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ] else
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Color(0xFF0B7A59)),
              onPressed: () {},
            ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF0B7A59)))
        : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            _buildProfileHeader(isDark),
            const SizedBox(height: 32),
            _buildSectionTitle('PERSONAL DETAILS', isDark),
            const SizedBox(height: 12),
            _buildPersonalDetails(isDark),
            const SizedBox(height: 24),
            _buildSectionTitle(
              'VEHICLE INFO',
              isDark,
              trailing: InkWell(
                onTap: _showAddVehicleDialog,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    '+ ADD',
                    style: TextStyle(
                      color: isDark ? const Color(0xFF34D399) : const Color(0xFF0B7A59),
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildVehicleInfo(isDark),
            const SizedBox(height: 24),
            _buildSectionTitle('ACCOUNT SETTINGS', isDark),
            const SizedBox(height: 12),
            _buildAccountSettings(context, isDark),
            const SizedBox(height: 32),
            _buildLogoutButton(context, isDark),
            const SizedBox(height: 16),
            Text(
              'App Version 2.4.0 (1024)',
              style: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark, {Widget? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.grey.shade400 : const Color(0xFF64748B),
            letterSpacing: 1.2,
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildProfileHeader(bool isDark) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF0B7A59).withOpacity(0.3), width: 3),
              ),
              child: const CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/32.jpg'),
              ),
            ),
            if (!_isEditing)
              InkWell(
                onTap: _toggleEditMode,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B7A59),
                    shape: BoxShape.circle,
                    border: Border.all(color: isDark ? const Color(0xFF1E293B) : Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 14),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: isDark ? const Color(0xFF1E293B) : Colors.white, width: 2),
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _isEditing ? 'Editing Profile' : _nameController.text,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _getDisplayRole(_user?.role),
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey.shade400 : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  String _getDisplayRole(String? role) {
    if (role == 'staff') return 'Staff Member';
    if (role == 'admin') return 'Administrator';
    return 'Professional Driver';
  }

  Widget _buildPersonalDetails(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildEditableRow(Icons.person_outline, 'Full Name', _nameController, isDark: isDark),
          Divider(color: isDark ? Colors.grey.shade700 : Colors.grey.shade100, height: 1),
          _buildEditableRow(Icons.phone_outlined, 'Phone Number', _phoneController, keyboardType: TextInputType.phone, isDark: isDark),
          Divider(color: isDark ? Colors.grey.shade700 : Colors.grey.shade100, height: 1),
          _buildEditableRow(Icons.mail_outline, 'Email Address', _emailController, keyboardType: TextInputType.emailAddress, isDark: isDark),
        ],
      ),
    );
  }

  Widget _buildEditableRow(IconData icon, String title, TextEditingController controller, {TextInputType? keyboardType, required bool isDark}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: isDark ? const Color(0xFF34D399) : const Color(0xFF0B7A59), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade500, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                if (_isEditing && title != 'Email Address')
                  TextFormField(
                    controller: controller,
                    keyboardType: keyboardType,
                    style: TextStyle(fontSize: 15, color: isDark ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: isDark ? Colors.grey.shade600 : Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: isDark ? const Color(0xFF34D399) : const Color(0xFF0B7A59), width: 1.5),
                      ),
                    ),
                  )
                else
                  Text(
                    controller.text,
                    style: TextStyle(fontSize: 15, color: isDark ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.w600),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleInfo(bool isDark) {
    if (_vehicles.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('No vehicles added yet.', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
      );
    }
    return Column(
      children: _vehicles.map((v) => _buildSingleVehicleCard(v, isDark)).toList(),
    );
  }

  Widget _buildSingleVehicleCard(VehicleModel vehicle, bool isDark) {
    String typeName = 'Vehicle';
    if (vehicle.vehicleType != null) {
      if (vehicle.vehicleType is Map) {
        typeName = vehicle.vehicleType['name'] ?? typeName;
      } else {
        final t = _vehicleTypes.where((e) => e.id == vehicle.vehicleType).firstOrNull;
        if (t != null) typeName = t.name;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF064E3B).withOpacity(0.3) : const Color(0xFFE8F5EE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF064E3B) : const Color(0xFFCEE8DE)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showVehicleDetailsDialog(vehicle),
          borderRadius: BorderRadius.circular(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF064E3B) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  typeName.toLowerCase().contains('motorbike') ? Icons.two_wheeler_rounded : Icons.directions_car_outlined, 
                  color: isDark ? const Color(0xFF34D399) : const Color(0xFF0B7A59), size: 30
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (vehicle.isDefault)
                      Row(
                        children: [
                          Text(
                            'Default Vehicle',
                            style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF34D399) : const Color(0xFF0B7A59), fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF34D399) : const Color(0xFF0B7A59),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'ACTIVE',
                              style: TextStyle(color: isDark ? Colors.black : Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 4),
                    Text(
                      typeName,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text('Plate: ', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: isDark ? Colors.grey.shade600 : Colors.grey.shade300),
                          ),
                          child: Text(
                            vehicle.licensePlate,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: isDark ? Colors.grey.shade500 : Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountSettings(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildActionRow(Icons.lock_outline, 'Change Password', isDark: isDark, onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
            );
          }),
          Divider(color: isDark ? Colors.grey.shade700 : Colors.grey.shade100, height: 1),
          _buildActionRow(Icons.notifications_none, 'Notification Settings', isDark: isDark, onTap: () {}),
          Divider(color: isDark ? Colors.grey.shade700 : Colors.grey.shade100, height: 1),
          _buildActionRow(Icons.feedback_outlined, 'Feedback & Report', isDark: isDark, onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FeedbackScreen()),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionRow(IconData icon, String title, {required VoidCallback onTap, required bool isDark}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: isDark ? Colors.grey.shade400 : const Color(0xFF475569), size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 15, color: isDark ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.w600),
              ),
            ),
            Icon(Icons.chevron_right, color: isDark ? Colors.grey.shade500 : Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, bool isDark) {
    return OutlinedButton.icon(
      onPressed: () async {
        try {
          await _authRepo.logout();
        } catch (_) {}
        
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const AuthProfileScreen()),
            (route) => false,
          );
        }
      },
      icon: Icon(Icons.logout, color: isDark ? const Color(0xFFEF4444) : const Color(0xFF0B7A59)),
      label: Text(
        'Log Out',
        style: TextStyle(color: isDark ? const Color(0xFFEF4444) : const Color(0xFF0B7A59), fontWeight: FontWeight.bold, fontSize: 16),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        side: BorderSide(color: isDark ? const Color(0xFFEF4444) : const Color(0xFF0B7A59), width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _showVehicleDetailsDialog(VehicleModel vehicle) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String typeName = 'Vehicle';
    if (vehicle.vehicleType != null) {
      if (vehicle.vehicleType is Map) {
        typeName = vehicle.vehicleType['name'] ?? typeName;
      } else {
        final t = _vehicleTypes.where((e) => e.id == vehicle.vehicleType).firstOrNull;
        if (t != null) typeName = t.name;
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.directions_car, color: isDark ? const Color(0xFF34D399) : const Color(0xFF0B7A59)),
            const SizedBox(width: 8),
            Text('Vehicle Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white : Colors.black)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDialogRow('Type', typeName, isDark),
            const SizedBox(height: 12),
            _buildDialogRow('Plate', vehicle.licensePlate, isDark),
            const SizedBox(height: 12),
            _buildDialogRow('Status', vehicle.isDefault ? 'Active (Default)' : 'Normal', isDark),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                await _vehicleRepo.deleteVehicle(vehicle.id);
                if (mounted) {
                  Navigator.pop(context);
                  _loadProfile();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 14)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF0F172A))),
      ],
    );
  }

  void _showAddVehicleDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final plateController = TextEditingController();
    String? selectedType = _vehicleTypes.isNotEmpty ? _vehicleTypes.first.id : null;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add New Vehicle',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 24),
                  if (_vehicleTypes.isNotEmpty)
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Vehicle Type',
                        labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: isDark ? Colors.grey.shade600 : Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: isDark ? const Color(0xFF34D399) : const Color(0xFF0B7A59), width: 1.5),
                        ),
                      ),
                      items: _vehicleTypes.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
                      onChanged: (val) {
                        setModalState(() {
                          selectedType = val;
                        });
                      },
                    ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: plateController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      labelText: 'License Plate (e.g. 29A-12345)',
                      labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? Colors.grey.shade600 : Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? const Color(0xFF34D399) : const Color(0xFF0B7A59), width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : () async {
                        if (plateController.text.trim().isEmpty || selectedType == null) return;
                        setModalState(() => isSaving = true);
                        try {
                          await _vehicleRepo.addVehicle(
                            licensePlate: plateController.text.trim(),
                            vehicleType: selectedType!,
                            isDefault: _vehicles.isEmpty,
                          );
                          if (mounted) {
                            Navigator.pop(context);
                            _loadProfile();
                          }
                        } catch (e) {
                          setModalState(() => isSaving = false);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: isDark ? const Color(0xFF34D399) : const Color(0xFF0B7A59),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: isSaving 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text('SAVE VEHICLE', style: TextStyle(color: isDark ? Colors.black : Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}
