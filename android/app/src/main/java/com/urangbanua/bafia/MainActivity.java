/* package com.urangbanua.bafia;

import android.os.Bundle;
import android.widget.Toast;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Get version name and version code from BuildConfig
        String versionName = BuildConfig.VERSION_NAME;
        int versionCode = BuildConfig.VERSION_CODE;

        // Display version information as a Toast
        Toast.makeText(this, "Version: " + versionName + " (" + versionCode + ")", Toast.LENGTH_LONG).show();
    }

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
    }
} */


/* package com.urangbanua.bafia;

import android.os.Bundle;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import com.google.android.play.core.integrity.IntegrityManager;
import com.google.android.play.core.integrity.IntegrityManagerFactory;
import com.google.android.play.core.integrity.IntegrityTokenRequest;
import com.google.android.play.core.integrity.IntegrityTokenResponse;
import com.google.android.play.core.tasks.OnFailureListener;
import com.google.android.play.core.tasks.OnSuccessListener;

public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "com.urangbanua.bafia/integrity";

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    super.configureFlutterEngine(flutterEngine);
    new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
      .setMethodCallHandler(
        (call, result) -> {
          if (call.method.equals("requestIntegrityToken")) {
            requestIntegrityToken(result);
          } else {
            result.notImplemented();
          }
        }
      );
  }

  private void requestIntegrityToken(MethodChannel.Result result) {
    IntegrityManager integrityManager = IntegrityManagerFactory.create(this);

    IntegrityTokenRequest integrityTokenRequest = IntegrityTokenRequest.builder()
      .setNonce("YOUR_NONCE")
      .build();

    integrityManager.requestIntegrityToken(integrityTokenRequest)
      .addOnSuccessListener(new OnSuccessListener<IntegrityTokenResponse>() {
        @Override
        public void onSuccess(IntegrityTokenResponse response) {
          String integrityToken = response.token();
          result.success(integrityToken);
        }
      })
      .addOnFailureListener(new OnFailureListener() {
        @Override
        public void onFailure(Exception e) {
          result.error("ERROR", "Failed to get integrity token", e.getMessage());
        }
      });
  }
} */