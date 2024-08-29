// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:livekit_sample/utils/common_utils.dart';
import 'package:livekit_sample/values/asset_name.dart';

class CustExtendedImage extends StatefulWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final BoxShape? shape;
  final bool? cache;
  final String? errImage;
  final BorderRadius? borderRadius;

  const CustExtendedImage(
      {super.key,
      required this.url,
      this.width,
      this.height,
      this.fit,
      this.shape,
      this.cache,
      this.errImage,
      this.borderRadius});

  @override
  State<CustExtendedImage> createState() => _CustExtendedImageState();
}

class _CustExtendedImageState extends State<CustExtendedImage> {
  @override
  Widget build(BuildContext context) {
    return !CommonUtils.isStrNullEmpty(widget.url)
        ? SizedBox(
            height: widget.height,
            width: widget.width,
          )
        : ExtendedImage.network(widget.url,
            cache: true, //widget.cache??true,
            shape: widget.shape ?? BoxShape.rectangle,
            fit: widget.fit ?? BoxFit.fill,
            height: widget.height,
            width: widget.width,
            borderRadius: widget.borderRadius ??
                const BorderRadius.all(Radius.circular(6.0)),
            loadStateChanged: (ExtendedImageState state) {
            switch (state.extendedImageLoadState) {
              case LoadState.loading:
                return Image.asset(
                  widget.errImage ?? AssetName.iconAboutLogo,
                  height: widget.height,
                  width: widget.width,
                );
              case LoadState.completed:
                return ExtendedRawImage(
                  image: state.extendedImageInfo?.image,
                  height: widget.height,
                  width: widget.width,
                  fit: widget.fit ?? BoxFit.fill,
                );
              case LoadState.failed:
                return Image.asset(
                  widget.errImage ?? AssetName.iconAboutLogo,
                  height: widget.height,
                  width: widget.width,
                );
            }
          });
  }
}
