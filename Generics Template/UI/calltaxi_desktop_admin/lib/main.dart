import 'package:calltaxi_desktop_admin/providers/auth_provider.dart';
import 'package:calltaxi_desktop_admin/providers/city_provider.dart';
import 'package:calltaxi_desktop_admin/providers/brand_provider.dart';
import 'package:calltaxi_desktop_admin/providers/user_provider.dart';
import 'package:calltaxi_desktop_admin/providers/vehicle_provider.dart';
import 'package:calltaxi_desktop_admin/providers/review_provider.dart';
import 'package:calltaxi_desktop_admin/providers/driver_request_provider.dart';
import 'package:calltaxi_desktop_admin/providers/business_report_provider.dart';
import 'package:calltaxi_desktop_admin/screens/business_report_screen.dart';
import 'package:calltaxi_desktop_admin/screens/city_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calltaxi_desktop_admin/utils/text_field_decoration.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<CityProvider>(
          create: (context) => CityProvider(),
        ),
        ChangeNotifierProvider<BrandProvider>(
          create: (context) => BrandProvider(),
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (context) => UserProvider(),
        ),
        ChangeNotifierProvider<VehicleProvider>(
          create: (context) => VehicleProvider(),
        ),
        ChangeNotifierProvider<ReviewProvider>(
          create: (context) => ReviewProvider(),
        ),
        ChangeNotifierProvider<DriverRequestProvider>(
          create: (context) => DriverRequestProvider(),
        ),
        ChangeNotifierProvider<BusinessReportProvider>(
          create: (context) => BusinessReportProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Call Taxi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFFFF9800), // Vibrant orange
          primary: Color(0xFFFF6F00), // Deep orange
        ),
        useMaterial3: true,
      ),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/calltaxi_background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxHeight: 400, maxWidth: 400),
            child: Card(
              color: Color.fromARGB(255, 236, 236, 236),
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Image.asset(
                      "assets/images/calltaxi_logo.png",
                      height: 150,
                      width: 150,
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: usernameController,
                      decoration: customTextFieldDecoration(
                        "Username",
                        prefixIcon: Icons.account_circle_sharp,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: customTextFieldDecoration(
                        "Password",
                        prefixIcon: Icons.password,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        AuthProvider.username = usernameController.text;
                        AuthProvider.password = passwordController.text;

                        try {
                          print(
                            "Username: ${AuthProvider.username}, Password: ${AuthProvider.password}",
                          );
                          var cityProvider = CityProvider();
                          var cities = await cityProvider.get();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BusinessReportScreen(),
                            ),
                          );
                        } on Exception catch (e) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text("Login failed"),
                              content: Text(
                                e.toString().replaceFirst('Exception: ', ''),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text("OK"),
                                ),
                              ],
                            ),
                          );
                        } catch (e) {
                          print(e);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: 15.0,
                        ), // Button padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            10.0,
                          ), // Rounded corners
                        ),
                        minimumSize: Size(double.infinity, 30),
                      ),
                      child: Text("Login"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
