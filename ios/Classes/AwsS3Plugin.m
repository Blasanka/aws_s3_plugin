#import "AwsS3Plugin.h"
#if __has_include(<aws_s3/aws_s3-Swift.h>)
#import <aws_s3/aws_s3-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "aws_s3-Swift.h"
#endif

@implementation AwsS3Plugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAwsS3Plugin registerWithRegistrar:registrar];
}
@end
