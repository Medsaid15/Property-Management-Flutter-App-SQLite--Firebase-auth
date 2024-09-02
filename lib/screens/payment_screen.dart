import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:property_management/helpers/database_helper.dart';
import '../models/payment_model.dart';
import '../models/tenant_model.dart';
// import '../services/payment_service.dart';
import '../services/tenant_service.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // final PaymentService _paymentService = PaymentService();
  final TenantService _tenantService = TenantService();
  List<PaymentModel> _payments = [];
  List<TenantModel> _tenants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTenants();
    _fetchPayments();
  }

  Future<void> _fetchPayments() async {
    try {
      final payments = await DatabaseHelper().fetchPayments();
      setState(() {
        _payments = payments;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching payments: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchTenants() async {
    try {
      List<TenantModel> tenants = await _tenantService.fetchTenants();
      setState(() {
        _tenants = tenants;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching tenants: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addPayment() async {
    final selectedTenant = await _selectTenant();
    if (selectedTenant != null) {
      // final result = await showDialog<PaymentModel>(
      //   context: context,
      //   builder: (context) => _PaymentDialog(tenant: selectedTenant),
      // );

      final existingPayment = _payments.firstWhere(
        (payment) => payment.tenantId == selectedTenant.id,
        orElse: () => PaymentModel(
          id: 0,
          amount: 0.0,
          date: '',
          isSettled: false,
          tenantId: 0,
          tenantName: '',
        ), // Provide a default PaymentModel if no match is found
      );
      if (existingPayment.id != 0) {
        Fluttertoast.showToast(
          msg: "A payment is already saved for ${selectedTenant.name}.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        return; // Exit the method early
      }
      final result = await showDialog<PaymentModel>(
        context: context,
        builder: (context) => _PaymentDialog(tenant: selectedTenant, payment: null,),
      );
      if (result != null) {
        try {
          await DatabaseHelper().addPayment(result);
          _fetchPayments(); // Refresh the payments list after adding
        } catch (e) {
          print('Error adding payment: $e');
        }
      }
    }
  }
  Future<void> _updatePayment(PaymentModel payment) async {
    final result = await showDialog<PaymentModel>(
      context: context,
      builder: (context) => _PaymentDialog(
        tenant: TenantModel(id: payment.tenantId, name: payment.tenantName, contact: '', section: ''),
        payment: payment,
      ),
    );
    if (result != null) {
      try {
        await DatabaseHelper().updatePayment(result);
        _fetchPayments();
      } catch (e) {
        print('Error updating payment: $e');
      }
    }
  }

  Future<void> _deletePayment(int paymentId) async {
    try {
      await DatabaseHelper().deletePayment(paymentId);
      _fetchPayments();
    } catch (e) {
      print('Error deleting payment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.teal[700],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _payments.isEmpty
              ? Center(
                  child: Text(
                    'No payments found.',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: _payments.length,
                  itemBuilder: (context, index) {
                    final payment = _payments[index];
                    return _buildPaymentCard(payment);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPayment,
        backgroundColor: Colors.teal[700],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPaymentCard(PaymentModel payment) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        onTap: () => _updatePayment(payment),
        contentPadding: const EdgeInsets.all(15),
        title: Text(
          'Tenant: ${payment.tenantName} - ${payment.amount}',
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
            Text('Date Paid: ${payment.date.toString().split(' ')[0]}',
                style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 5),
            Text(
              payment.isSettled ? 'Status: Settled' : 'Status: Not Settled',
              style: TextStyle(
                  color: payment.isSettled ? Colors.green : Colors.red),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // IconButton(
            //   icon: const Icon(Icons.edit, color: Colors.blue),
            //   onPressed: () => _updatePayment(payment),
            // ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deletePayment(payment.id!),
            ),
          ],
        ),
      ),
    );
  }

  Future<TenantModel?> _selectTenant() async {
    final tenants = await DatabaseHelper().fetchTenants();
    if (tenants.isEmpty) {
      // print('No tenants found in the database.');
      Fluttertoast.showToast(
          msg: "No tenants found. Please add tenants first.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      return null;
    }

    return showDialog<TenantModel>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Tenant'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: tenants.length,
              itemBuilder: (BuildContext context, int index) {
                final tenant = tenants[index];
                return ListTile(
                  title: Text(tenant.name),
                  subtitle: Text(tenant.contact),
                  onTap: () {
                    Navigator.of(context).pop(tenant);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _PaymentDialog extends StatefulWidget {
  final TenantModel tenant;
  final PaymentModel? payment;

  const _PaymentDialog({required this.tenant, this.payment});

  @override
  __PaymentDialogState createState() => __PaymentDialogState();
}

class __PaymentDialogState extends State<_PaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _dateController;
  bool _isSettled = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _dateController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newPayment = PaymentModel(
        id: widget.tenant?.id ?? 0,
        amount: double.parse(_amountController.text),
        date: _dateController.text,
        isSettled: _isSettled,
        tenantId: widget.tenant.id,
        tenantName: widget.tenant.name,
      );
      Navigator.of(context).pop(newPayment);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.payment == null ? 'Add Payment for ${widget.tenant.name}' : 'Edit Payment'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter an amount' : null,
              ),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Date'),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null) {
                    setState(() {
                      _dateController.text =
                          picked.toLocal().toString().split(' ')[0];
                    });
                  }
                },
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a date' : null,
              ),
              CheckboxListTile(
                title: const Text('Settled'),
                value: _isSettled,
                onChanged: (bool? value) {
                  setState(() {
                    _isSettled = value ?? false;
                  });
                },
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
          child: const Text('Add'),
        ),
      ],
    );
  }
}