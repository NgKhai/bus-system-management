import 'package:bus_system_management/util/Constant.dart';
import 'package:bus_system_management/util/id_student.dart';
import 'package:bus_system_management/widget/home/bus_info_widget.dart';
import 'package:bus_system_management/widget/home/bus_list_widget.dart';
import 'package:bus_system_management/widget/home/title_view_widget.dart';
import 'package:bus_system_management/widget/home/top_view_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, this.animationController}) : super(key: key);

  final AnimationController? animationController;
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  Animation<double>? topBarAnimation;
  final user = FirebaseAuth.instance.currentUser;


  List<Widget> listViews = <Widget>[];
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;

  @override
  void initState() {
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: widget.animationController!,
            curve: const Interval(0, 0.5, curve: Curves.fastOutSlowIn)));
    addAllListData();

    super.initState();
  }

  String getLastTwoWords(String? input) {
    // Split the input string into words based on spaces
    List<String> words = input!.trim().split(RegExp(r'\s+'));

    // Check if the list has at least two words
    if (words.length <= 2) {
      return input; // Return the original input if less than two words
    }

    // Get the last two words
    String lastTwoWords = words.sublist(words.length - 2).join(' ');

    return lastTwoWords;
  }

  void addAllListData() {
    const int count = 9;
    listViews.add(
      TopViewWidget(
        titleTxt: getLastTwoWords(user!.displayName),
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve:
            const Interval((1 / count) * 0, 1.0, curve: Curves.fastLinearToSlowEaseIn))),
        animationController: widget.animationController!,
      ),
    );
    listViews.add(
      BusDetailWidget(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve:
            const Interval((1 / count) * 1, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!, studentID: IDStudent(user!.email).getID(),
      ),
    );
    listViews.add(
      TitleViewWidget(
        titleTxt: 'Các tuyến xe',
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve:
            const Interval((1 / count) * 2, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
      ),
    );

    listViews.add(
      BusListWidget(
        mainScreenAnimation: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
                parent: widget.animationController!,
                curve: const Interval((1 / count) * 3, 1.0,
                    curve: Curves.fastOutSlowIn))),
        mainScreenAnimationController: widget.animationController,
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
