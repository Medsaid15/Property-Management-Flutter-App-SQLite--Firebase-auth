import 'package:flutter/material.dart';
import 'package:property_management/models/payment_model.dart';
import 'package:property_management/models/property_model.dart';
import 'package:property_management/models/tenant_model.dart';
import 'package:property_management/screens/tenant_screen.dart';
import 'package:property_management/services/tenant_service.dart';
import 'package:property_management/services/payment_service.dart';
import '../services/property_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PropertyScreen extends StatefulWidget {
  const PropertyScreen({super.key});

  @override
  _PropertyScreenState createState() => _PropertyScreenState();
}

class _PropertyScreenState extends State<PropertyScreen> {
  final PropertyService _propertyService = PropertyService();
  final TenantService _tenantService = TenantService();
  final PaymentService _paymentService = PaymentService();
  List<PropertyModel> _properties = [];
  List<TenantModel> _tenants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProperties();
    _loadTenants();
  }

  Future<void> _loadProperties() async {
    try {
      final properties = await _propertyService.fetchProperties();
      setState(() {
        _properties = properties;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading properties: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTenants() async {
    try {
      final tenants = await _tenantService.fetchTenants();
      setState(() {
        _tenants = tenants;
      });
    } catch (e) {
      print('Error loading tenants: $e');
    }
  }

  Future<void> _addProperty() async {
    final result = await showDialog<PropertyModel>(
      context: context,
      builder: (context) => const _PropertyDialog(),
    );

    if (result != null) {
      try {
        await _propertyService.addProperty(result);
        _loadProperties(); // Refresh the list
      } catch (e) {
        print('Error adding property: $e');
      }
    }
  }

  Future<void> _editProperty(PropertyModel property) async {
    final result = await showDialog<PropertyModel>(
      context: context,
      builder: (context) => _PropertyDialog(property: property),
    );

    if (result != null) {
      try {
        await _propertyService.updateProperty(result);
        _loadProperties(); // Refresh the list
      } catch (e) {
        print('Error updating property: $e');
      }
    }
  }

  Future<void> _deleteProperty(int id) async {
    try {
      await _propertyService.deleteProperty(id);
      _loadProperties(); // Refresh the list
    } catch (e) {
      print('Error deleting property: $e');
    }
  }

//------------------------------
  void _openTenantScreen(PropertyModel property) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TenantScreen(
            ),
      ),
    ).then((_) {
      _loadProperties(); 
    });
  }

  void _openTenantSelectionDialog(PropertyModel property) async {
    final tenants = await TenantService().fetchTenants();
    if (tenants.isEmpty) {
      // Show a toast if no tenants are found
      Fluttertoast.showToast(
        msg: "No tenants found. Please add tenants first.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return; // Exit the function early
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select a Tenant'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: tenants.length,
              itemBuilder: (context, index) {
                final tenant = tenants[index];
                return ListTile(
                  title: Text(tenant.name),
                  onTap: () => _confirmTenantSelection(property, tenant),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _confirmTenantSelection(
      PropertyModel property, TenantModel tenant) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Tenant Selection'),
          content: Text(
              'Are you sure you want to add ${tenant.name} to ${property.name}?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      // Update the property with the selected tenant
      property.tenantId = tenant.id;
      await _propertyService.updateProperty(property);

      // Refresh the property list
      _loadProperties();

      // Dismiss the dialog
      Navigator.of(context).pop();
    }
  }

  Future<void> _linkTenantToProperty(
      PropertyModel property, TenantModel tenant) async {
    try {
      // Link the tenant to the property
      property.tenantId = tenant.id;
      await _propertyService.updateProperty(property);
      _loadProperties(); // Refresh the list
    } catch (e) {
      print('Error linking tenant to property: $e');
    }
  }

  Future<String> _fetchPaymentStatus(int tenantId) async {
    try {
      final payments = await _paymentService.fetchPayments();
      final tenantPayments =
          payments.where((payment) => payment.tenantId == tenantId).toList();
      final isSettled = tenantPayments.any((payment) => payment.isSettled);
      return isSettled ? 'Settled' : 'Not Settled';
    } catch (e) {
      print('Error fetching payment status: $e');
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Properties', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.teal[700],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _properties.isEmpty
              ? Center(
                  child: Text(
                    'No properties found.',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: _properties.length,
                  itemBuilder: (context, index) {
                    final property = _properties[index];
                    return _buildPropertyCard(property);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProperty,
        backgroundColor: Colors.teal[700],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPropertyCard(PropertyModel property) {
    return FutureBuilder<TenantModel?>(
      future: _tenantService.getTenantById(property.tenantId),
      builder: (context, tenantSnapshot) {
        // final tenantName = tenantSnapshot.data?.name ?? 'No tenant assigned';
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            onTap: () => _editProperty(property),
            contentPadding: const EdgeInsets.all(15),
            title: Text(
              property.name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal[800],
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                Text(property.address,
                    style: TextStyle(color: Colors.grey[700])),
                const SizedBox(height: 5),
                Text(
                  'Type: ${property.type} • Units: ${property.units}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 5),
                Text(
                  'Rent: \$${property.rentalCost.toStringAsFixed(2)}',
                  style: TextStyle(
                      color: Colors.teal[700], fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 5),
                if (property.tenantId != null) ...[
                  FutureBuilder<TenantModel?>(
                    future: TenantService().getTenantById(property.tenantId!),
                    builder: (context, snapshot) {
                      if (tenantSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (tenantSnapshot.hasError) {
                        return Text('Error: ${tenantSnapshot.error}');
                      } else if (!tenantSnapshot.hasData ||
                          tenantSnapshot.data == null) {
                        return const Text('No tenant assigned');
                      } else {
                        final tenant = tenantSnapshot.data!;
                        return FutureBuilder<List<PaymentModel>>(
                          future: PaymentService()
                              .fetchPaymentsForTenant(tenant.id),
                          builder: (context, paymentSnapshot) {
                            if (paymentSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (paymentSnapshot.hasError) {
                              return Text('Error: ${paymentSnapshot.error}');
                            } else if (!paymentSnapshot.hasData ||
                                paymentSnapshot.data!.isEmpty) {
                              return Text(
                                  'Tenant: ${tenant.name} - No payments');
                            } else {
                              final payments = paymentSnapshot.data!;
                              final paymentStatus =
                                  payments.any((payment) => payment.isSettled)
                                      ? 'Settled'
                                      : 'Not Settled';
                              return Text(
                                  'Tenant: ${tenant.name} - Payment Status: $paymentStatus');
                            }
                          },
                        );
                      }
                    },
                  )
                ],
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.people, color: Colors.blue),
                  onPressed: () => _openTenantSelectionDialog(property),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => _deleteProperty(property.id!),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PropertyDialog extends StatefulWidget {
  final PropertyModel? property;

  const _PropertyDialog({this.property});

  @override
  __PropertyDialogState createState() => __PropertyDialogState();
}

class __PropertyDialogState extends State<_PropertyDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  String _selectedType = 'Apartment'; // Default value
  late TextEditingController _unitsController;
  late TextEditingController _rentalCostController;

  final List<String> _propertyTypes = ['Apartment', 'House'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.property?.name ?? '');
    _addressController =
        TextEditingController(text: widget.property?.address ?? '');
    _selectedType = widget.property?.type ?? 'Apartment'; // Default value
    _unitsController =
        TextEditingController(text: widget.property?.units.toString() ?? '');
    _rentalCostController = TextEditingController(
        text: widget.property?.rentalCost.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _unitsController.dispose();
    _rentalCostController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newProperty = PropertyModel(
        id: widget.property?.id ?? 0, // 0 for a new property
        name: _nameController.text,
        address: _addressController.text,
        type: _selectedType, // Use selected type
        units: int.tryParse(_unitsController.text) ?? 1,
        rentalCost: double.tryParse(_rentalCostController.text) ?? 0.0,
      );
      Navigator.of(context).pop(newProperty);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.property == null ? 'Add Property' : 'Edit Property'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Property Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a property name' : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter an address' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Type'),
                items: _propertyTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a type' : null,
              ),
              TextFormField(
                controller: _unitsController,
                decoration: const InputDecoration(labelText: 'Number of Units'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    (value!.isEmpty || int.tryParse(value) == null)
                        ? 'Please enter a valid number of units'
                        : null,
              ),
              TextFormField(
                controller: _rentalCostController,
                decoration: const InputDecoration(labelText: 'Rental Cost'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    (value!.isEmpty || double.tryParse(value) == null)
                        ? 'Please enter a valid rental cost'
                        : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(widget.property == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }
}
