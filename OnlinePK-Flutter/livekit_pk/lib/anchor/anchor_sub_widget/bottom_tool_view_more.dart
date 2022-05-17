// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:livekit_pk/values/asset_name.dart';
import 'package:livekit_pk/values/colors.dart';

class BottomToolViewMore extends StatefulWidget {
  final void Function(Model) tapCallBack;
  final List<Model> modelDatas;

  const BottomToolViewMore({Key? key, required this.modelDatas, required this.tapCallBack})
      : super(key: key);

  @override
  State<BottomToolViewMore> createState() {
    return _BottomToolViewMoreState();
  }
}

class _BottomToolViewMoreState extends State<BottomToolViewMore> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: buildBottomToolViewMore(),
    );
  }

  Widget buildBottomToolViewMore() {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final itemSpace = (width - 4 * 60 - 60) / 3;

    return Container(
      height: 299,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
      ),
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            height: 48,
            child: const Text(
              'More',
              style: TextStyle(fontSize: 16, color: AppColors.black_333333),
            ),
          ),
          Container(
            color: AppColors.color_e6e7eb,
            height: 1,
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(30.0, 16.0, 30.0, 0.0),
            height: 250,
            child: GridView.builder(
                itemCount: widget.modelDatas.length,
                shrinkWrap: false,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 15.0,
                    crossAxisSpacing: itemSpace,
                    childAspectRatio: 0.7),
                itemBuilder: (BuildContext context, int index) {
                  return getItemContainer(widget.modelDatas[index]);
                }),
          )
        ],
      ),
    );
  }

  Widget getItemContainer(Model model) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: AppColors.color_f2f2f5,
              ),
              // color: Colors.black,
              // child: Container(),
              child: Center(
                child: Image(
                  width: 20,
                  height: 20,
                  fit: BoxFit.fill,
                  key: ValueKey(model.itemImageName),
                  image: AssetImage(
                    model.itemSelected ? model.itemImageName : model.itemAnotherImageName,
                  ),
                ),
              ),
            ),
            onTap: () {
              widget.tapCallBack(model);
              setState(() {
                model.itemSelected = !model.itemSelected;
              });
            },
          ),
          const SizedBox(
            height: 5,
          ),
          Text(model.itemTitle,
              style:
                  const TextStyle(color: AppColors.color_333333, fontSize: 12))
        ],
      ),
      // color: Colors.blue,
    );
  }
}

class Model {
  String itemTitle;
  String itemImageName;
  int itemStatus;
  String itemAnotherImageName;
  int itemIndex;
  bool itemSelected = true;

  Model(this.itemTitle, this.itemImageName, this.itemStatus,
      this.itemAnotherImageName, this.itemIndex);
}
