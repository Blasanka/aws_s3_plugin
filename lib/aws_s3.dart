import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AwsS3 {

  final File file;
  final String fileNameWithExt;
  final String awsFolderPath;
  final String poolId;
  final Regions region;
  final String bucketName;

  AwsS3({
    @required this.file,
    @required this.fileNameWithExt,
    @required this.awsFolderPath,
    @required this.poolId,
    this.region = Regions.US_WEST_2,
    @required this.bucketName,
  });

  static const MethodChannel _channel =
      const MethodChannel('com.blasanka.s3Flutter/aws_s3');

  static const EventChannel _eventChannel =
      const EventChannel('com.blasanka.s3Flutter/uploading_status');

  Future<String> get uploadFile async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("filePath", () => file.path);
    args.putIfAbsent("awsFolder", () => awsFolderPath);
    args.putIfAbsent("fileNameWithExt", () => fileNameWithExt);
    args.putIfAbsent("poolId", () => poolId);
    args.putIfAbsent("transPoolId", () => "");
    args.putIfAbsent("region", () => region.toString());
    args.putIfAbsent("bucketName", () => bucketName);

    debugPrint("AwsS3Plugin: file path is: ${file.path}");

    final String result = await _channel.invokeMethod('uploadToS3', args);

    return result;
  }

  Stream get getUploadStatus => _eventChannel.receiveBroadcastStream();
}

/// Enumeration of region names
enum Regions {
  GovCloud,
  US_GOV_EAST_1,
  US_EAST_1,
  US_EAST_2,
  US_WEST_1,
  US_WEST_2, ///Default: The default region of AWS Android SDK
  EU_WEST_1,
  EU_WEST_2,
  EU_WEST_3,
  EU_CENTRAL_1,
  EU_NORTH_1,
  AP_EAST_1,
  AP_SOUTH_1,
  AP_SOUTHEAST_1,
  AP_SOUTHEAST_2,
  AP_NORTHEAST_1,
  AP_NORTHEAST_2,
  SA_EAST_1,
  CA_CENTRAL_1,
  CN_NORTH_1,
  CN_NORTHWEST_1,
  ME_SOUTH_1
}