package com.urbanservyces.user;

import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;

import io.flutter.app.FlutterApplication;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService;

public class ApplicationStatus extends FlutterApplication implements PluginRegistry.PluginRegistrantCallback {

    @Override
    public void onCreate() {
        super.onCreate();
        FirebaseOptions options = new FirebaseOptions.Builder()
                .setApplicationId("com.idreams.project.smampl") // Required for Analytics.
                .setProjectId("smgrocery-b3c7a") // Required for Firebase Installations.
                .setApiKey("AIzaSyB1XTjbnWnsBEK-WxRSbESCcHkDC6gx0Kg") // Required for Auth.
                .build();
        FirebaseApp.initializeApp(this,options,"smampl");
        FlutterFirebaseMessagingService.setPluginRegistrant(this);
    }

    @Override
    public void registerWith(PluginRegistry registry) {
        FirebaseCloudMessagingPluginRegistrant.registerWith(registry);
    }
}
