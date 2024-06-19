import 'package:kiosk/constants/employeelist_data.dart';
import 'package:kiosk/src/feature/authentication/presentation/screens/authentication.screen.dart';
import 'package:kiosk/src/feature/employees/presentation/screens/employee.screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kiosk/src/feature/projects/presentation/provider/selected.project.dart';
import 'package:provider/provider.dart';

import '../../core/domain/entities/common_get_request.model.dart';
import '../../core/domain/entities/project.entity.dart';
import '../../core/presentation/widgets/bottom_nav_bar.dart';
import '../../core/router/route.constants.dart';
import '../authentication/presentation/providers/auth.provider.dart';
import '../client_connection/presentation/providers/client.provider.dart';
import '../employees/presentation/providers/employee.provider.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  List<Project> projects = [];
  bool _isLoaded = false;

  @override
  void initState() {
    Future.microtask(() async => await fetchProjects());
    super.initState();
  }

  Future<void> fetchProjects() async {
    if (!mounted) return;
    var baseUrl = context.read<ClientConnectionProvider>().baseUrl;
    return await context
        .read<EmployeeProvider>()
        .fetchProject(
        context,
        baseUrl,
        CommonGetRequest(
            authToken: context.read<AuthProvider>().authToken!))
        .whenComplete(() async {
      setState(() {
        projects = context.read<EmployeeProvider>().projects;
        _isLoaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar:const BottomNavBar(),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Padding(
            padding: EdgeInsets.only(top: 5),
            child: Text(
              "Projects",
              style:
              TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
            child: Column(
              children: [
                _isLoaded ?
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: projects.length,
                  itemBuilder: (BuildContext context,int index){
                    return ListTile(
                      leading: SvgPicture.asset(
                        'assets/png/elements.svg',
                        height: 25,
                        width: 25,
                      ),
                      title: Text(
                        projects[index].projectName ?? '',
                        style: const TextStyle(
                            fontSize: 18,
                            color: Color(0xffF96B07),
                            fontWeight: FontWeight.w500),),
                      onTap: (){
                        context.read<SelectedProjectProvider>().saveToPrefs(
                            projects[index].id.toString(),
                            projects[index].projectName ?? '').whenComplete(() {

                          Navigator.pushNamedAndRemoveUntil(context, RouteConstants.employeeScreen,(_)=>false );
                        });

                      },
                    );

                  },
                ) :
                const Center(
                  child: CircularProgressIndicator(), // Display loading indicator
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
