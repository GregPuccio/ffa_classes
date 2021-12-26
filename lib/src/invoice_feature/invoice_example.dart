import 'package:ffaclasses/src/riverpod/providers.dart';
import 'package:ffaclasses/src/user_feature/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoiceninja/invoiceninja.dart';
import 'package:invoiceninja/models/client.dart';
import 'package:invoiceninja/models/invoice.dart';
import 'package:invoiceninja/models/product.dart';
import 'package:url_launcher/url_launcher.dart';

class InvoiceExample extends StatefulWidget {
  const InvoiceExample({Key? key}) : super(key: key);

  @override
  _InvoiceExampleState createState() => _InvoiceExampleState();
}

class _InvoiceExampleState extends State<InvoiceExample> {
  List<Product> _products = [];

  String _email = '';
  Product? _product;
  Invoice? _invoice;

  @override
  initState() {
    super.initState();

    InvoiceNinja.configure(
      // Set your company key or use 'KEY' to test
      // The key can be generated on Settings > Client Portal
      'HwkyOH5itK8vANSXTjdkrAPkTOxkhBMs',
      url: 'https://ffa.invoicing.co', // Set your selfhost app URL
      debugEnabled: true,
    );

    InvoiceNinja.products.load().then((products) {
      setState(() {
        _products = products;
      });
    });
  }

  void _createInvoice() async {
    if (_product == null) {
      return;
    }

    var client = Client.forContact(email: _email);
    client = await InvoiceNinja.clients.save(client);

    var invoice = Invoice.forClient(client, products: [_product!]);
    invoice = await InvoiceNinja.invoices.save(invoice);

    setState(() {
      _invoice = invoice;
    });
  }

  void _viewPdf() {
    if (_invoice == null) {
      return;
    }

    launch(
      'https://docs.google.com/gview?embedded=true&url=${_invoice!.pdfUrl}',
      forceWebView: true,
    );
  }

  void _viewPortal() {
    if (_invoice == null) {
      return;
    }

    final invitation = _invoice!.invitations.first;
    launch(invitation.url);
  }

  @override
  Widget build(BuildContext context) {
    Widget whenData(UserData? userData) {
      if (userData != null) {
        return ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        initialValue: userData.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          suffixIcon: Icon(Icons.email),
                        ),
                        onChanged: (value) => setState(() => _email = value),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      DropdownButtonFormField<Product>(
                        decoration: const InputDecoration(
                          labelText: 'Product',
                        ),
                        onChanged: (value) => setState(() => _product = value),
                        items: _products
                            .map((product) => DropdownMenuItem(
                                  child: Text(product.productKey),
                                  value: product,
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        child: const Text('Create Invoice'),
                        onPressed: (_email.isNotEmpty && _product != null)
                            ? () => _createInvoice()
                            : null,
                      ),
                      OutlinedButton(
                        child: const Text('View PDF'),
                        onPressed: (_invoice != null) ? () => _viewPdf() : null,
                      ),
                      OutlinedButton(
                        child: const Text('View Portal'),
                        onPressed:
                            (_invoice != null) ? () => _viewPortal() : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      } else {
        return const Center(child: CircularProgressIndicator());
      }
    }

    return Consumer(
      builder: (context, watch, child) {
        return watch.watch(userDataProvider).when(
              data: whenData,
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (object, stackTrace) => Center(
                child: Text(
                  "Error",
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
            );
      },
    );
  }
}
