import 'package:ffaclasses/src/constants/widgets/buttons.dart';
import 'package:ffaclasses/src/firebase/firestore_path.dart';
import 'package:ffaclasses/src/firebase/firestore_service.dart';
import 'package:ffaclasses/src/riverpod/providers.dart';
import 'package:ffaclasses/src/user_feature/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoiceninja/invoiceninja.dart';
import 'package:invoiceninja/models/client.dart';
import 'package:invoiceninja/models/invoice.dart';

class ClientInvoicing extends StatefulWidget {
  const ClientInvoicing({Key? key}) : super(key: key);

  @override
  _ClientInvoicingState createState() => _ClientInvoicingState();
}

class _ClientInvoicingState extends State<ClientInvoicing> {
  late UserData user;
  Client? client;

  final List<Invoice> _invoices = [];

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
      setState(() {});
    });
  }

  void _pullInvoices() async {
    if (client == null) {
      try {
        client = await InvoiceNinja.clients.findByKey(user.invoicingKey);
      } catch (e) {
        client = Client.forContact(
          firstName: user.parentFirstName,
          lastName: user.parentLastName,
          email: user.emailAddress,
        );
        client = await InvoiceNinja.clients.save(client!);
        await FirestoreService().updateData(
            path: FirestorePath.user(user.id),
            data: user.copyWith(invoicingKey: client!.key).toMap());
      }
    }

    for (String key in user.invoices) {
      try {
        _invoices.add(await InvoiceNinja.invoices.findByKey(key));
      } catch (e) {
        debugPrint("Could not find invoice with ID: $key");
      }
    }
  }

  // void _viewPdf(Invoice invoice) {
  //   launch(
  //     'https://docs.google.com/gview?embedded=true&url=${invoice.pdfUrl}',
  //     forceWebView: true,
  //   );
  // }

  // void _viewPortal(Invoice invoice) {
  //   final invitation = invoice.invitations.first;
  //   launch(invitation.url);
  // }

  @override
  Widget build(BuildContext context) {
    Widget whenData(UserData? userData) {
      if (userData != null) {
        user = userData;
        if (!userData.admin) {
          return const Center(
            child: Text("Coming Soon!"),
          );
        } else {
          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextFormField(
                                    initialValue: userData.emailAddress,
                                    enabled: false,
                                    decoration: const InputDecoration(
                                      labelText: 'Email',
                                      prefixIcon: Icon(Icons.email),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  const SizedBox(height: 16),
                                  SecondaryButton(
                                    text: 'Pull Invoices',
                                    onPressed: _pullInvoices,
                                  ),
                                  // SecondaryButton(
                                  //   text: 'View PDF',
                                  //   active: invoice != null,
                                  //   onPressed: _viewPdf,
                                  // ),
                                  // SecondaryButton(
                                  //   text: 'View Portal',
                                  //   active: _invoice != null,
                                  //   onPressed: _viewPortal,
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        ListView.builder(
                            shrinkWrap: true,
                            itemCount: _invoices.length,
                            itemBuilder: (context, index) {
                              Invoice invoice = _invoices[index];
                              return Padding(
                                padding: const EdgeInsets.all(8),
                                child: Card(
                                  child: ListTile(
                                    title: Text(
                                      DateTime.fromMicrosecondsSinceEpoch(
                                              invoice.createdAt)
                                          .toString(),
                                    ),
                                  ),
                                ),
                              );
                            }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
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
