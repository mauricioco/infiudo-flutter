// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:infiudo/db/db_hive.dart';
import 'package:infiudo/models/service.dart';

class ServiceListItem extends StatelessWidget {
  
  late final String? title;           // Usually the search query
  
  ServiceListItem.fromService(final Service s, {super.key}) {
    title = Uri.decodeComponent(s.description);
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: SizedBox(
        height: 100,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0.0, 2.0, 0.0),
                child: TextButton(
                  onPressed: () {
                    print(key);
                  },
                  child: Text(
                    title!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceListWidget extends StatefulWidget {
  const ServiceListWidget({super.key});

  @override
  State<StatefulWidget> createState() => ServiceListWidgetState();
}

class ServiceListWidgetState extends State<ServiceListWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Service>>(
      future: DbHive().getAll<Service>(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                return ServiceListItem.fromService(snapshot.data![index], key: ObjectKey(snapshot.data![index]));   // TODO review this key creation
              });
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        // By default show a loading spinner.
        return const CircularProgressIndicator();
      },
    );
  }
}