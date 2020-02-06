# aws_s3

This plugin developed to make it easy to upload any file(s) to AWS S3 without
writing Android, and IOS code separately using method channel.

DISCLAIMER: This is not an AWS officially released plugin but this plugin uses
AWS official Android native and IOS native AWS plugins (So nothing to be worried).
Check the package implementation on github: https://github.com/blasanka/aws_s3

Contributors are highly welcome.

To use this package, you have to create a instance of `AwsS3` with parameters like below code snippet:

```
AwsS3 awsS3 = AwsS3(
  awsFolderPath: "your aws folder path",
  file: "file is of type File",
  fileNameWithExt: "file name",
  poolId: "your aws pool id",
  region: "your region using enum Regions",
  bucketName: "your bucket name to upload");
```

`AwsS3` class, parameters:

```
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
```

All the available regions from official Amazon AWS S3 android are supported in this Flutter plugin:

```
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
```

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.
