import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'model/ImageData.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Photo> photos = [];
  RefreshController controller = RefreshController(initialRefresh: true);

  var currentPage = 0;
  int? totalPage;
  Future getData<bool>({isRefresh = false}) async {
    if (isRefresh) {
      currentPage = 1;
    } else {
      if (currentPage >= totalPage!) {
        controller.loadNoData();
        return false;
      }
    }
    http.Response response = await http.get(
        Uri.parse(
            "https://api.pexels.com/v1/curated?per_page80&page=$currentPage%22563492ad6f917000010000016c0aab4b56484ba2990869b52cc89cc5"),
        headers: {
          "Authorization":
              "563492ad6f917000010000016c0aab4b56484ba2990869b52cc89cc5"
        });
    if (response.statusCode == 200) {
      final result = imageDataFromJson(response.body);
      if (isRefresh) {
        photos = result.photos!;
      } else {
        photos.addAll(result.photos!);
      }
      currentPage++;
      totalPage = result.totalResults!;

      print(response.body);
      setState(() {});
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // print("DATA   -----------------${Passenger}");
    return Scaffold(
      appBar: AppBar(title: Text("Pagination")),
      body: SmartRefresher(
        controller: controller,
        onRefresh: () async {
          var result = await getData(isRefresh: true);
          if (result) {
            controller.refreshCompleted();
          } else {
            controller.refreshFailed();
          }
        },
        enablePullUp: true,
        onLoading: () async {
          var result = await getData();
          if (result) {
            controller.loadComplete();
          } else {
            controller.loadFailed();
          }
        },
        child: GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: 5),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 5,
            mainAxisExtent: 300,
            mainAxisSpacing: 5,
          ),
          itemCount: photos.length,
          itemBuilder: (BuildContext context, int index) {
            final data = photos[index];
            return Image.network(
              "${data.src!.portrait}",
              fit: BoxFit.cover,
            );
          },
        ),
        // child: ListView.separated(
        //   itemCount: photos.length,
        //   separatorBuilder: (BuildContext context, int index) {
        //     return Divider();
        //   },
        //   itemBuilder: (BuildContext context, int index) {
        //     final data = photos[index];
        //     return Image.network(
        //       "${data.src!.portrait}",
        //       height: 200,
        //       width: 350,
        //       fit: BoxFit.cover,
        //     );
        //   },
        // ),
      ),
    );
  }
}
