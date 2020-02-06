# aws_s3_example

Demonstrates how to use the aws_s3 plugin.

```
Future<String> _uploadImage(File file, int number,
  {String extension = 'jpg'}) async {

String result;

if (result == null) {
  // generating file name
  String fileName =
      "$number$extension\_${DateTime.now().millisecondsSinceEpoch}.$extension";

  AwsS3 awsS3 = AwsS3(
      awsFolderPath: "your aws folder path",
      file: selectedFile,
      fileNameWithExt: fileName,
      poolId: "your_aws_pool_id",
      region: Regions.AP_SOUTHEAST_2,
      bucketName: "your bucket name to upload");

  setState(() {
    isFileUploading = true;
  });
  displayUploadDialog(awsS3); 
  try {
    try {
      result = await awsS3.uploadFile;
      debugPrint("Result :'$result'.");
    } on PlatformException {
      debugPrint("Result :'$result'.");
    }
  } on PlatformException catch (e) {
    debugPrint("Failed :'${e.message}'.");
  }
}
Navigator.of(context).pop();
return result;
}

Future displayUploadDialog(AwsS3 awsS3) {
return showDialog(
  context: context,
  barrierDismissible: false,
  builder: (context) => StreamBuilder(
    stream: awsS3.getUploadStatus,
    builder: (BuildContext context, AsyncSnapshot snapshot) {
      return buildFileUploadDialog(snapshot, context);
    },
  ),
);
}

AlertDialog buildFileUploadDialog(
  AsyncSnapshot snapshot, BuildContext context) {
    return AlertDialog(
      title: Container(
        padding: EdgeInsets.all(6),
        child: LinearProgressIndicator(
          value: (snapshot.data != null) ? snapshot.data / 100 : 0,
          valueColor:
              AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColorDark),
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: Text('Uploading...')),
            Text("${snapshot.data ?? 0}%"),
          ],
        ),
      ),
    );
}
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
