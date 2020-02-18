package com.blasanka.s3flutter.aws_s3;

import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;

import com.amazonaws.ClientConfiguration;
import com.amazonaws.auth.CognitoCredentialsProvider;
import com.amazonaws.mobile.client.AWSMobileClient;
import com.amazonaws.mobileconnectors.s3.transferutility.TransferListener;
import com.amazonaws.mobileconnectors.s3.transferutility.TransferObserver;
import com.amazonaws.mobileconnectors.s3.transferutility.TransferState;
import com.amazonaws.mobileconnectors.s3.transferutility.TransferUtility;
import com.amazonaws.regions.Regions;
import com.amazonaws.services.s3.AmazonS3Client;
import com.amazonaws.services.s3.model.CannedAccessControlList;

import java.io.File;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.shim.ShimPluginRegistry;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;

/**
 * AwsS3Plugin
 */
public class AwsS3Plugin implements FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {

    private static final String TAG = "awsS3Plugin";
    private static final String CHANNEL = "com.blasanka.s3Flutter/aws_s3";
    private static final String STREAM = "com.blasanka.s3Flutter/uploading_status";
    private String filePath;
    private String awsFolder;
    private String fileNameWithExt;
    private MethodChannel.Result parentResult;
    private ClientConfiguration clientConfiguration;
    private TransferUtility transferUtility1;
    private String bucketName;
    private Context mContext;
    private EventChannel eventChannel;
    private MethodChannel methodChannel;
    private EventChannel.EventSink events;

    public AwsS3Plugin() {
        filePath = "";
        awsFolder = "";
        fileNameWithExt = "";
        clientConfiguration = new ClientConfiguration();
    }

    public static void registerWith(PluginRegistry.Registrar registrar) {
        AwsS3Plugin s3Plugin = new AwsS3Plugin();
        s3Plugin.whenAttachedToEngine(registrar.context(), registrar.messenger());
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        whenAttachedToEngine(flutterPluginBinding.getApplicationContext(), flutterPluginBinding.getBinaryMessenger());
    }

    private void whenAttachedToEngine(Context applicationContext, BinaryMessenger messenger) {
        this.mContext = applicationContext;
        methodChannel = new MethodChannel(messenger, CHANNEL);
        eventChannel = new EventChannel(messenger, STREAM);
        eventChannel.setStreamHandler(this);
        methodChannel.setMethodCallHandler(this);

        Log.d(TAG, "whenAttachedToEngine");
    }


    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        mContext = null;
        methodChannel.setMethodCallHandler(null);
        methodChannel = null;
        eventChannel.setStreamHandler(null);
        eventChannel = null;

        Log.d(TAG, "onDetachedFromEngine");
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("uploadToS3")) {
            parentResult = result;
            filePath = call.argument("filePath");

            Log.d(TAG, "onMethodCall: " + filePath);

            awsFolder = call.argument("awsFolder");
            fileNameWithExt = call.argument("fileNameWithExt");
            String poolId = call.argument("poolId");
//        String transPoolId = call.argument("transPoolId");
            String reg = call.argument("region");
            bucketName = call.argument("bucketName");
            assert reg != null;
            try {
                String regionName = reg.replaceFirst("Regions.", "");
                Regions region = Regions.valueOf(regionName);

                clientConfiguration.setConnectionTimeout(250000);
                clientConfiguration.setSocketTimeout(250000);
                CognitoCredentialsProvider credentialsProvider = new CognitoCredentialsProvider(poolId, region, clientConfiguration);
                transferUtility1 = TransferUtility.builder().context(mContext).awsConfiguration(AWSMobileClient.getInstance().getConfiguration()).s3Client(new AmazonS3Client(credentialsProvider)).build();
                sendImage();
            } catch (Exception e) {
                Log.e(TAG, "onMethodCall: exception: " + e.getMessage());
            }
        } else {
            result.notImplemented();
        }
    }

    private void sendImage() {
        String awsPath = fileNameWithExt;
        if (awsFolder != null && !awsFolder.equals("")) {
            awsPath = awsFolder + "/" + fileNameWithExt;
        }
        TransferObserver transferObserver1 = transferUtility1
                .upload(bucketName, awsPath, new File(filePath), CannedAccessControlList.PublicRead);

        transferObserver1.setTransferListener(new Transfer());
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        this.events = events;
    }

    @Override
    public void onCancel(Object arguments) {
        invalidateEventSink();
    }

    private void invalidateEventSink() {
        if (events != null) {
            events.endOfStream();
            events = null;
        }
    }

    class Transfer implements TransferListener {

        private static final String TAG = "Transfer";

        @Override
        public void onStateChanged(int id, TransferState state) {
            switch (state) {
                case COMPLETED:
                    Log.d(TAG, "onStateChanged: \"COMPLETED, " + fileNameWithExt);
                    parentResult.success(fileNameWithExt);
                    break;
                case WAITING:
                    Log.d(TAG, "onStateChanged: \"WAITING, " + fileNameWithExt);
                    break;
                case FAILED:
                    invalidateEventSink();
                    Log.d(TAG, "onStateChanged: \"FAILED, " + fileNameWithExt);
                    parentResult.success(null);
                    break;
                default:
                    Log.d(TAG, "onStateChanged: \"SOMETHING ELSE, " + fileNameWithExt);
                    break;
            }
        }

        @Override
        public void onProgressChanged(int id, long bytesCurrent, long bytesTotal) {

            float percentDoNef = ((float) bytesCurrent / (float) bytesTotal) * 100;
            int percentDone = (int) percentDoNef;
            Log.d(TAG, "ID:" + id + " bytesCurrent: " + bytesCurrent + " bytesTotal: " + bytesTotal + " " + percentDone + "%");

            if (events != null) {
                events.success(percentDone);
            }
        }

        @Override
        public void onError(int id, Exception ex) {
            Log.e(TAG, "onError: " + ex);
            invalidateEventSink();
        }
    }
}
