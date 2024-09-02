
import 'package:flutter/material.dart';
import 'package:property_management/models/tenant_model.dart';
import 'package:property_management/services/tenant_service.dart';

class TenantScreen extends StatefulWidget {
  const TenantScreen({super.key});

  @override
  _TenantScreenState createState() => _TenantScreenState();
}

class _TenantScreenState extends State<TenantScreen> {
  List<TenantModel> _tenants = [];
  final TenantService _tenantService = TenantService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTenants();
  }

  Future<void> _fetchTenants() async {
    try {
      List<TenantModel> tenants = await _tenantService.fetchTenants();
      setState(() {
        _tenants = tenants;
        _isLoading = false;
      });
    } catch (e) {
      // Handle exceptions
      print('Error fetching tenants: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addTenant() async {
    // try {
    //   await _tenantService.addTenant(tenant);
    //   _fetchTenants(); // Refresh the list after adding
    // } catch (e) {
    //   print('Error adding tenant: $e');
    // }
    final result = await showDialog<TenantModel>(
      context: context,
      builder: (context) => _TenantDialog(),
    );

    if (result != null) {
      try {
        await _tenantService.addTenant(result);
        _fetchTenants(); // Refresh the list after adding
      } catch (e) {
        print('Error adding tenant: $e');
      }
    }

  }
  Future<void> _editTenant(TenantModel tenant) async {
    final result = await showDialog<TenantModel>(
      context: context,
      builder: (context) => _TenantDialog(tenant: tenant),
    );

    if (result != null) {
      try {
        await _tenantService.updateTenant(result);
        _fetchTenants(); // Refresh the list after editing
      } catch (e) {
        print('Error updating tenant: $e');
      }
    }

  }
  Future<void> _deleteTenant(int id) async {
    try {
      await _tenantService.deleteTenant(id);
      _fetchTenants(); // Refresh the list after deleting
    } catch (e) {
      print('Error deleting tenant: $e');
    }
  }
    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tenants', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.teal[700],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tenants.isEmpty
              ? Center(
                  child: Text(
                    'No tenants found.',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: _tenants.length,
                  itemBuilder: (context, index) {
                    final tenant = _tenants[index];
                    return _buildTenantCard(tenant);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTenant,
        backgroundColor: Colors.teal[700],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTenantCard(TenantModel tenant) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        onTap: () => _editTenant(tenant),
        contentPadding: const EdgeInsets.all(15),
        title: Text(
          tenant.name,
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
            Text(tenant.contact, style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 5),
            Text(
              'Section: ${tenant.section}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          onPressed: () => _deleteTenant(tenant.id),
        ),
      ),
    );
  }
}


class _TenantDialog extends StatefulWidget {
  final TenantModel? tenant;

  _TenantDialog({this.tenant});

  @override
  __TenantDialogState createState() => __TenantDialogState();
}

class __TenantDialogState extends State<_TenantDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _contactController;
  late TextEditingController _sectionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tenant?.name ?? '');
    _contactController = TextEditingController(text: widget.tenant?.contact ?? '');
    _sectionController = TextEditingController(text: widget.tenant?.section ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _sectionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newTenant = TenantModel(
        id: widget.tenant?.id ?? 0, // ID is 0 for a new tenant
        name: _nameController.text,
        contact: _contactController.text,
        section: _sectionController.text,
      );
      Navigator.of(context).pop(newTenant);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.tenant == null ? 'Add Tenant' : 'Edit Tenant'),  
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tenant Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a tenant name' : null,
              ),
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(labelText: 'Contact'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a contact' : null,
              ),
              TextFormField(
                controller: _sectionController,
                decoration: const InputDecoration(labelText: 'Section'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a section' : null,
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
          child: Text(widget.tenant == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }
}