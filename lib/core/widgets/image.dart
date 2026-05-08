import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

Widget assetImageWidget(String imageUrl , {double scale = 1, BoxFit fit = BoxFit.contain}){
  return Image.asset("assets/images/$imageUrl",scale: scale,fit: fit,);
}

Widget assetSvgImageWidget(String imageUrl , {double? width, double? height,Color? color,BoxFit? fit}){
  return SvgPicture.asset("assets/images/$imageUrl",width: width, height: height,color: color,fit: fit??BoxFit.contain,);
}

Widget networkImageWidget({required String imageUrl, double? width, double? height ,BoxFit? fit, String errorImageUrl = "category.svg" , double borderRadius = 10 , Color errorImageColor = Colors.black}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(borderRadius - 2),
    child: CachedNetworkImage(
      imageUrl: imageUrl,
      width: width??50,
      height: height??40,
      fit: fit??BoxFit.cover,
      errorWidget: (context, url, error) => errorImageUrl.contains(".svg")?assetSvgImageWidget(errorImageUrl,color: errorImageColor,width: width,height: height):assetImageWidget(errorImageUrl)
    ),
  );
}

Widget fileImageWidget({File? file, double? width, double? height, String errorImageUrl = "category.svg", double borderRadius = 10, Color errorImageColor = Colors.black,}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(borderRadius - 2),
    child: file != null  && file.existsSync()
        ? Image.file(file, width: width ?? 50, height: height ?? 40, fit: BoxFit.cover,)
        : errorImageUrl.contains(".svg")
        ? assetSvgImageWidget(errorImageUrl,color: errorImageColor,width: width,height: height)
        :assetImageWidget(errorImageUrl),);
}