import Flutter
import UIKit
import AWSS3
import AWSCognito

enum ChannelName { 
    static let awsS3 = "com.blasanka.s3Flutter/aws_s3" 
    static let uploadingSatus = "com.blasanka.s3Flutter/uploading_status"
}

public class SwiftAwsS3Plugin: NSObject, FlutterPlugin  {
    private var events: FlutterEventSink?
    private var uploadedPercentage: Int64?
       
    public static func register(with registrar: FlutterPluginRegistrar) {       
        let channel = FlutterMethodChannel(name: ChannelName.awsS3, binaryMessenger: registrar.messenger())                let instance = SwiftAwsS3Plugin()                let eventChannel = FlutterEventChannel(name: ChannelName.uploadingSatus, binaryMessenger: registrar.messenger())                registrar.addMethodCallDelegate(instance, channel: channel)
        eventChannel.setStreamHandler(instance)
    }       

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
            case "uploadToS3":
                self.uploadImage(result: result, args: call.arguments)
                break;
            default:
                result(FlutterMethodNotImplemented)
            }
        }
       
    private func decideRegion(_ region: String) -> AWSRegionType {
        let reg: String = (region as AnyObject).replacingOccurrences(of: "Regions.", with: "")
        switch reg {
            case "Unknown":
                return AWSRegionType.Unknown
            case "US_EAST_1":
                return AWSRegionType.USEast1
            case "US_EAST_2":
                return AWSRegionType.USEast2
            case "US_WEST_1":
                return AWSRegionType.USWest1
            case "US_WEST_2":
                return AWSRegionType.USWest2
            case "EU_WEST_1":
                return AWSRegionType.EUWest1
            case "EU_WEST_2":
                return AWSRegionType.EUWest2
            case "EU_CENTRAL_1":
                return AWSRegionType.EUCentral1
            case "AP_SOUTHEAST_1":
                return AWSRegionType.APSoutheast1
            case "AP_NORTHEAST_1":
                return AWSRegionType.APNortheast1
            case "AP_NORTHEAST_2":
                return AWSRegionType.APNortheast2
            case "AP_SOUTHEAST_2":
                return AWSRegionType.APSoutheast2
            case "AP_SOUTH_1":
                return AWSRegionType.APSouth1
            case "CN_NORTH_1":
                return AWSRegionType.CNNorth1
            case "CA_CENTRAL_1":
                return AWSRegionType.CACentral1
            case "USGovWest1":
                return AWSRegionType.USGovWest1
            case "CN_NORTHWEST_1":
                return AWSRegionType.CNNorthWest1
            case "EU_WEST_3":
                return AWSRegionType.EUWest3
            case "US_GOV_EAST_1":
                return AWSRegionType.USGovEast1
            case "EU_NORTH_1":
                return AWSRegionType.EUNorth1
            case "AP_EAST_1":               
                return AWSRegionType.APEast1
            case "ME_SOUTH_1":
                return AWSRegionType.MESouth1
            default:
                return AWSRegionType.Unknown
        }
    }

    private func uploadImage(result: @escaping FlutterResult, args: Any?) {
        let argsMap = args as! NSDictionary
               
        if let filePath = argsMap["filePath"], let awsFolder = argsMap["awsFolder"],
            let fileNameWithExt = argsMap["fileNameWithExt"], let poolId = argsMap["poolId"],
            let bucketName = argsMap["bucketName"], let region = argsMap["region"] {
               
                print(decideRegion(region as! String))
               
                let credentialsProvider = AWSCognitoCredentialsProvider(regionType:
                    decideRegion(region as! String), identityPoolId: poolId as! String)
                let configuration = AWSServiceConfiguration(region: decideRegion(region as! String),
                    credentialsProvider: credentialsProvider)

                AWSServiceManager.default().defaultServiceConfiguration = configuration
                var imageAmazonUrl = ""
                let url = NSURL(fileURLWithPath: filePath as! String)
                let fileType: String = (fileNameWithExt as AnyObject).components(separatedBy: ".")[1]
                let uploadRequest = AWSS3TransferManagerUploadRequest()!
                uploadRequest.body = url as URL
                uploadRequest.key = "\(awsFolder)_\(fileNameWithExt as! String)"
                uploadRequest.bucket = bucketName as! String
                uploadRequest.contentType = "\(fileType)"
                uploadRequest.acl = .publicReadWrite
                uploadRequest.uploadProgress = { (bytesSent, totalBytesSent,
                    totalBytesExpectedToSend) -> Void in
                    DispatchQueue.main.async(execute: {
                        self.uploadedPercentage = (bytesSent / totalBytesSent) * 100
                    })
                }
               let transferManager = AWSS3TransferManager.default()
               transferManager.upload(uploadRequest).continueWith { (task) -> AnyObject? in
                    if let error = task.error as NSError? {
                        if error.domain == AWSS3TransferManagerErrorDomain as String {
                            if let errorCode = AWSS3TransferManagerErrorType(rawValue: error.code) {
                                switch (errorCode) {
                                    case .cancelled, .paused:
                                        print("upload failed .cancelled, .paused:")
                                        result(nil)
                                        break;
                                    default:
                                        print("upload() failed: defaultd [\(error)]")
                                        result(nil)
                                        break;
                                    }
                                } else {
                                    print("upload() failed: [\(error)]")
                                    result(nil)
                                }
                            } else {
                                //upload failed
                                print("upload() failed: domain [\(error)]")
                                                       
                result(FlutterError(code: "UNAVAILABLE", message: "Battery info unavailable", details: nil))                   
                }
            }

            if task.result != nil {
                imageAmazonUrl = "https://d212imxpbiy5j1.cloudfront.net/\(fileNameWithExt)"
                print("✅ Upload successed (\(imageAmazonUrl))")
                result(imageAmazonUrl)
            }
            return nil
        }
    } else {
            print("Did not provided required args")
            result(nil)
    }
    }
}

extension SwiftAwsS3Plugin : FlutterStreamHandler {
        public func onListen(withArguments arguments: Any?,
            eventSink events: @escaping FlutterEventSink) -> FlutterError? {
            self.events = events
            onUploadingStatusChange();
            return nil
        }
        public func onCancel(withArguments arguments: Any?) -> FlutterError? {
            self.events = nil
            return nil
        }
 
       @objc private func onUploadingStatusChange() {
            sendUploadingStatus();
    }

     private func sendUploadingStatus() {
        guard let events = self.events else {
            return
        }
       events(self.uploadedPercentage)
    }
}