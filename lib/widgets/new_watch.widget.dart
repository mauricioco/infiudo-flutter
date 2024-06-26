import 'package:flutter/material.dart';
import 'package:infiudo/models/service.dart';
import 'package:infiudo/models/watch.dart';
import 'package:infiudo/utils/api.helper.dart';

class NewWatchWidget extends StatefulWidget {
  const NewWatchWidget({super.key});
  
  @override 
  State<NewWatchWidget> createState() => _NewWatchWidget(); 
} 
  
class _NewWatchWidget extends State<NewWatchWidget> {

  bool _isLoading = false;
  List<Service> services = <Service>[];
  Service? selectedService;

  TextEditingController nameController = TextEditingController();

  @override void initState() {
    super.initState();
    _initState();
  }

  Future<void> _initState() async {
    services = ApiHelper().getCachedServices();
    if (services.isNotEmpty) {
      selectedService = services[0];
    }
    setState(() {});
  }

  finishSaving(BuildContext context, Watch w) {
    ApiHelper().watch(w, DateTime.now(), context).then((value) => Navigator.pop(context));
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration Page'),
      ),
      //for the form to be in center
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: ListView(
            shrinkWrap: true,
            children: [
              const Text('Source service'),
              const SizedBox(
                height: 4,
              ),
              DropdownButton(
                //items: services.map((e) => DropdownMenuItem(value: e, child: Text(e.description))).toList(),
                value: selectedService,
                items: [ for (Service s in services) DropdownMenuItem(key: ObjectKey(s.id), value: s, child: Text(s.description)) ],
                onChanged: (Service? service) {
                  setState(() {
                    selectedService = service;
                  });
                },
              ),
              const SizedBox(
                height: 16,
              ),
              const Text('Query'),
              const SizedBox(
                height: 4,
              ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter query',
                ),
              ),
              //some space between name and email
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: _isLoading ? null : () async {
                  setState(() => _isLoading = true);
                  Watch w = Watch(serviceId: selectedService!.id!, query: Uri.encodeComponent(nameController.text));
                  ApiHelper().saveNewWatch(w).whenComplete(() => finishSaving(context, w));
                  // TODO IMPROVE LOADING
                },
                child: _isLoading
                  ? Container(
                      width: 24,
                      height: 24,
                      padding: const EdgeInsets.all(2.0),
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : const Text(
                    'Watch',
                    style: TextStyle(
                    fontSize: 30,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
