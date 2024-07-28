import 'package:bus_system_management/util/Constant.dart';
import 'package:bus_system_management/widget/info/info_button_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../widget/info/student_info_widget.dart';
import '../widget/info/top_info_widget.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({Key? key, this.animationController}) : super(key: key);

  final AnimationController? animationController;

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> with TickerProviderStateMixin {
  final user = FirebaseAuth.instance.currentUser;

  List<Widget> listViews = <Widget>[];
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    addAllListData();
  }

  void addAllListData() {
    const int count = 5;

    listViews.add(
      TopInfoWidget(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve: const Interval((1 / count) * 0, 1.0,
                curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
      ),
    );

    listViews.add(
      StudentInfoWidget(
        username: user!.displayName,
        usermail: user!.email,
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve: const Interval((1 / count) * 2, 1.0,
                curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
      ),
    );
    listViews.add(
      InfoButtonWidget(
        text: "Đăng xuất",
        onTap: () {
          // context.read<AuthBloc>().add(SignOutRequested());
          FirebaseAuth.instance.signOut();
          context.go('/');
        },
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve: const Interval((1 / count) * 3, 1.0,
                curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
      ),
    );
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 50));
    return true;
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      color: Constant.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: <Widget>[
            getMainListViewUI(),
            // getAppBarUI(),
            SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            )
          ],
        ),
      ),
    );
  }

  Widget getMainListViewUI() {
    return FutureBuilder<bool>(
      future: getData(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        } else {
          return ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.only(
              top: AppBar().preferredSize.height * 0.5,
              bottom: 62 + MediaQuery.of(context).padding.bottom,
            ),
            itemCount: listViews.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              widget.animationController?.forward();
              return listViews[index];
            },
          );
        }
      },
    );
  }
}
