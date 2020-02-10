import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_s3/aws_s3.dart';

void main() {
  const MethodChannel channel = MethodChannel('aws_s3');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
//    expect(await AwsS3().uploadFile, '42');
  });
}
