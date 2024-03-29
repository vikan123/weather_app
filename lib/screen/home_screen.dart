import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:whether_app/controller/api.dart';
import 'package:whether_app/modal/weather.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:whether_app/screen/search.dart';
import 'package:intl/intl.dart';

import '../controller/theme.dart';

class HomeScreen extends StatefulWidget {
  final cityname;
  const HomeScreen({super.key, this.cityname});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  WeatherResponseModel? wm;



  @override
  void initState() {
    super.initState();
     fetchData(widget.cityname ?? "Jaipur");
    initConnectivity();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    super.initState();
  }

  fetchData(String text) async {
      await Provider.of<APICallProvider>(context, listen: false)
        .fetchApiData(text)
        .then((value) {
      setState(() {
        wm = value;
      });
    });
  }
  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e);
      return;
    }

    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
  }

  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  Widget build(BuildContext context) {

    final Size size = MediaQuery.of(context).size;
    return _connectionStatus.toString() == "ConnectivityResult.wifi" ||
        _connectionStatus.toString() == "ConnectivityResult.mobile"?
    Scaffold(
        body: (wm != null)
            ? SafeArea(
            child: Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(

                          "https://www.gadgetsnow.com/photo/95580479/95580479.jpg"),
                      fit: BoxFit.fill,
                      opacity: 0.4)),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  title: Text(
                    "${wm?.location?.name}",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  centerTitle: true,
                  leading: IconButton(
                      icon: const Icon(Icons.location_city),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SearchScreen(),
                            ));
                      }),
                  actions: [
                    Consumer<ModelTheme>(
                      builder: (context, themevalue, child) {
                        return PopupMenuButton<int>(
                          itemBuilder: (context) => [
                            // PopupMenuItem 1
                            const PopupMenuItem(
                              value: 1,
                              child: Row(
                                children: [
                                  Icon(Icons.sunny),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text("Light ")
                                ],
                              ),
                            ),
                            // PopupMenuItem 2
                            const PopupMenuItem(
                              value: 2,
                              // row with two children
                              child: Row(
                                children: [
                                  Icon(Icons.dark_mode_sharp),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text("Dark")
                                ],
                              ),
                            ),
                          ],
                          elevation: 2,
                          onSelected: (value) {
                            if (value == 1) {
                              themevalue.isDark = false;
                            } else if (value == 2) {
                              themevalue.isDark = true;
                            }
                          },
                        );
                      },
                    )
                  ],
                ),
                body: CustomScrollView(
                  physics: const BouncingScrollPhysics(
                      decelerationRate: ScrollDecelerationRate.fast),
                  scrollDirection: Axis.vertical,
                  slivers: [
                    SliverAppBar(
                      automaticallyImplyLeading: false,
                      elevation: 0.0,
                      backgroundColor: Colors.transparent,
                      expandedHeight: size.height/2.2,
                      flexibleSpace: Container(
                        child: Center(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(children: [
                              TextSpan(
                                  text:
                                  "${wm?.timelines!.minutely![0].values!['temperature']}ºc",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 80)),
                              TextSpan(
                                  text:
                                  "\nSunny    ${wm?.timelines!.minutely![0].values!['temperature']}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 30)),
                              TextSpan(
                                  text: " ~ ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                      color:
                                      Colors.white.withOpacity(0.4))),
                              TextSpan(
                                  text:
                                  "${wm?.timelines!.minutely![0].values!['temperatureApparent']}ºc",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 30)),
                            ]),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                        padding:
                        const EdgeInsets.only(top: 20, right: 20, left: 20),
                        child: Column(
                          children: [

                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(
                                  width: 5,
                                ),
                                const Text("Today"),
                                const Spacer(),
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(children: [
                                    TextSpan(
                                        text:
                                        "${wm?.timelines!.daily![0].values!.temperatureMax}º",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w400)),
                                  ]),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(
                                  width: 5,
                                  height: 35,
                                ),
                                const Text("Tommorrow"),
                                const Spacer(),
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(children: [
                                    TextSpan(
                                        text:
                                        " ${wm?.timelines!.daily![1].values!.temperatureMax}º",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w400)),
                                  ]),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(
                                  width: 5,
                                ),
                                const Text("Next Day"),
                                const Spacer(),
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(children: [
                                    TextSpan(
                                        text:
                                        " ${wm?.timelines!.daily![2].values!.temperatureMax}º",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w400)),
                                  ]),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                        width: size.width/30,
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.all(5),
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.3),
                                    borderRadius:
                                    BorderRadius.circular(50)),
                                height: 30,
                                width: 100,
                                child: const Center(
                                  child: Text(
                                    "View More ↓",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Container(

                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        width: size.width/2.2,
                        child: Column(
                          children: [
                            const SingleChildScrollView(
                             scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.access_time_outlined,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 10, height: 20),
                                  Text(
                                    "24 - Hour Forecast                     >",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),

                            Container(
                              height: size.height/5,

                              child: ListView.separated(
                                itemCount: 24,
                                separatorBuilder: (context, index) {
                                  return const SizedBox(
                                    width:25,
                                  );
                                },
                                itemBuilder: (context, index) {
                                  return Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(

                                      color: Colors.blue.withOpacity(0.3),
                                    ),
                                    height: size.height/20,
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          DateFormat('HH:MM').format(wm
                                              ?.timelines!
                                              .hourly![index]
                                              .time ??
                                              DateTime.now()),
                                          style: const TextStyle(
                                              fontWeight:
                                              FontWeight.bold),
                                        ),
                                        Text(
                                            "${wm?.timelines?.hourly![index].values!["temperatureApparent"]}º"),
                                        Text(
                                            "${wm?.timelines?.hourly![index].values!["windSpeed"]}"),
                                        const Text(".km/h"),
                                        Image.network(
                                          "http://pluspng.com/img-png/rain-and-sun-png-open-2000.png",
                                          height: 30,
                                          width: 30,
                                        ),
                                        SizedBox(width:size.width/30,)
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              "💨 Wind Speed :         ${wm?.timelines!.daily![0].values!.windSpeedAvg}km/h",
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(height: size.height/30,),
                          Center(
                            child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(children: [
                                  TextSpan(
                                      text: DateFormat('🌅 HH:MM')
                                          .format(wm
                                          ?.timelines!
                                          .daily![0]
                                          .values!
                                          .sunriseTime! ??
                                          DateTime.now()),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20)),
                                  const TextSpan(
                                      text: " Sunrise\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                          color: Colors.white)),
                                  TextSpan(
                                      text:
                                      "\n${DateFormat('🌇 HH:MM').format(wm!.timelines!.daily![0].values!.sunsetTime ?? DateTime.now())}",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20)),
                                  const TextSpan(
                                      text: " Sunset",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                          color: Colors.white)),
                                  ])
                            ),

                          ),
                          SizedBox(height: size.height/20,),
                Container(

                  margin: const EdgeInsets.only(right: 10),

                  child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ListTile(
                            title: const Text("Humidity",style: TextStyle(fontSize: 20),),
                            trailing: Text(
                                "${wm?.timelines!.daily![0].values!.humidityAvg}%",style: const TextStyle(fontSize: 20)),
                          ),
                          ListTile(
                            title: const Text("RainIntensity",style: TextStyle(fontSize: 20)),
                            trailing: Text(
                                "${wm?.timelines!.daily![0].values!.rainIntensityAvg}",style: const TextStyle(fontSize: 20)),
                          ),
                          ListTile(
                            title: const Text("Weaker(UV)",style: TextStyle(fontSize: 20)),
                            trailing: Text(
                                "${wm?.timelines!.daily![0].values!.uvHealthConcernAvg}",style: const TextStyle(fontSize: 20)),
                          ),
                          ListTile(
                            title: const Text("AirPressure",style: TextStyle(fontSize: 20)),
                            trailing: Text(
                                "${wm?.timelines!.daily![0].values!.pressureSurfaceLevelAvg}hPa",style: const TextStyle(fontSize: 20)),
                          ),
                          ListTile(
                            title: const Text("RainChance"),
                            trailing: Text(
                                "${wm?.timelines!.daily![0].values!.rainAccumulationLweMax} %",style: const TextStyle(fontSize: 20)),
                          ),
                          ListTile(
                            title: const Text("Feelslike",style: TextStyle(fontSize: 20)),
                            trailing: Text(
                                " ${wm?.timelines!.daily![2].values!.temperatureMax}ºC",style: const TextStyle(fontSize: 20)),
                          ),

                          SizedBox(height: size.height/40,)
                        ],
                      )
                    ),

                )],
                ),
              ),
              ]))
            )): const Center(
          child: CircularProgressIndicator(),
        )
    ):const SafeArea(child: Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          "Network Connectivity is Unavailable!",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.blueAccent),
        ),
      ),
    ),);
  }


}


