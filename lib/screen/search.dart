import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whether_app/screen/home_screen.dart';

import '../controller/api.dart';
import '../controller/cities.dart';
import '../controller/shared_preference.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchPageState();
}

List<String> cityName = [];

class _SearchPageState extends State<SearchScreen> {
  TextEditingController _searchName = TextEditingController();

  @override
  void initState() {
    valueFunction();
    super.initState();
  }

  List<String>? valuex;

  valueFunction() {
    SharedPref.getListString().then((value) {
      print(value);
      setState(() {
        valuex = value;
        print(valuex);
        print(cityName);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final lanProvider = Provider.of<APICallProvider>(context, listen: true);
    return Scaffold(
      backgroundColor: Colors.blue[400],
      appBar: AppBar(
        title: Text(
          "City Management      +",
          style: TextStyle(fontSize: 30),
        ),

        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  child: Autocomplete(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text == '') {
                        return const Iterable<String>.empty();
                      } else {
                        List<String> matches = <String>[];
                        matches.addAll(city);

                        matches.retainWhere((v) {
                          return v
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase());
                        });
                        return matches;
                      }
                    },
                    onSelected: (selection) async {
                      cityName.add(selection);
                      print(cityName.length);
                      SharedPref.setListString(token: cityName);
                      valueFunction();

                      await lanProvider.fetchApiData(selection).then((value) {
                        if (value != null) {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomeScreen(
                                  cityname: selection,
                                ),
                              ),
                                  (route) => false);
                        } else {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("This City Was Not Found"),
                              content: const Text("Try again!"),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(ctx).pop();
                                  },
                                  child: Container(
                                    color: Colors.green,
                                    padding: const EdgeInsets.all(14),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      });
                    },
                  )),
              SizedBox(
                height: 20,
              ),
              valuex?.length != null
                  ? InkWell(
                child: Container(
                  height: 759,
                  child: ListView.separated(
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomeScreen(
                                    cityname: valuex?[index],
                                  ),
                                ));
                          },
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage(
                                      "assets/images/dark.jpeg"),
                                  fit: BoxFit.cover),
                              color: Colors.red.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: ListTile(
                              leading: Icon(
                                Icons.location_city,
                                color: Colors.white,
                                size: 30,
                              ),
                              title: Center(
                                child: Text(
                                  "📍${valuex?[index]}",
                                  style: TextStyle(fontSize: 25),
                                ),
                              ),
                              trailing: Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return SizedBox(
                          height: 10,
                        );
                      },
                      itemCount: valuex!.length),
                ),
              )
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}