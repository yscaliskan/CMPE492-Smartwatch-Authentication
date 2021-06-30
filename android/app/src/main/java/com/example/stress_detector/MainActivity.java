package com.example.ppg_authentication;

import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;

import com.empatica.empalink.ConnectionNotAllowedException;
import com.empatica.empalink.EmpaDeviceManager;
import com.empatica.empalink.EmpaticaDevice;
import com.empatica.empalink.config.EmpaSensorType;
import com.empatica.empalink.config.EmpaStatus;
import com.empatica.empalink.delegate.EmpaDataDelegate;
import com.empatica.empalink.delegate.EmpaStatusDelegate;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import java.lang.Math;
import java.util.HashMap;
import java.util.PriorityQueue;
import java.util.Queue;

public class MainActivity extends FlutterActivity implements EmpaDataDelegate, EmpaStatusDelegate {
    private static final String CHANNEL = "ppg_authentication/empatica";
    private MethodChannel methodChannel;
    private EmpaDeviceManager deviceManager;

    Queue<Double> accx = new PriorityQueue<>();
    Queue<Double> accy = new PriorityQueue<>();
    Queue<Double> accz = new PriorityQueue<>();
    Queue<Double> eda = new PriorityQueue<>();
    Queue<Double> bvp = new PriorityQueue<>();
    Queue<Double> temp = new PriorityQueue<>();

    int accFreq = 32 / 2;
    int edaFreq = 4 / 2;
    int bvpFreq = 64 / 2;
    int tempFreq = 4 / 2;

    double secAvg(Queue<Double> queue, int freq) {
        double sum = 0.0;
        for (int i = 0; i < freq; i++)
            sum += queue.poll();
        return sum / (double) freq;
    }

    public void handleData() {
        if (eda.size() >= edaFreq && accx.size() >= accFreq && accy.size() >= accFreq && accz.size() >= accFreq && bvp.size() >= bvpFreq && temp.size() >= tempFreq) {

            HashMap<String, Double> res = new HashMap<>();

            res.put("ACCX", secAvg(accx, accFreq));
            res.put("ACCY", secAvg(accy, accFreq));
            res.put("ACCZ", secAvg(accz, accFreq));
            res.put("BVP", secAvg(bvp, bvpFreq));
            res.put("TEMP", secAvg(temp, tempFreq));
            res.put("GSR", secAvg(eda, edaFreq));
            new Handler(Looper.getMainLooper()).post(new Runnable() {
                @Override
                public void run() {
                    methodChannel.invokeMethod("getSensorData", res);
                }
            });
        }
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        System.out.println("======= PLATFORM CHANNEL STARTED =======");
        methodChannel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL);
        deviceManager = new EmpaDeviceManager(getApplicationContext(), this, this);
        deviceManager.authenticateWithAPIKey("566dd8431c934faba8a480d3930c111c");
    }

    @Override
    public void didReceiveGSR(float gsr, double timestamp) {
        this.eda.add((double) gsr);
        handleData();
    }

    @Override
    public void didReceiveBVP(float bvp, double timestamp) {
        this.bvp.add((double) bvp);
        handleData();
    }

    @Override
    public void didReceiveIBI(float ibi, double timestamp) {
    }

    @Override
    public void didReceiveTemperature(float t, double timestamp) {
        this.temp.add((double) t);
        handleData();
    }

    @Override
    public void didReceiveAcceleration(int x, int y, int z, double timestamp) {
        this.accx.add((double) x);
        this.accy.add((double) y);
        this.accz.add((double) z);
        handleData();
    }

    @Override
    public void didReceiveBatteryLevel(float level, double timestamp) {
    }

    @Override
    public void didReceiveTag(double timestamp) {
    }

    @Override
    public void didUpdateStatus(EmpaStatus status) {
        System.out.println("======= STATUS UPDATE: " + status);
        switch (status) {
            case READY:
                deviceManager.startScanning();
                break;
            case CONNECTED:
                new Handler(Looper.getMainLooper()).post(new Runnable() {
                    @Override
                    public void run() {
                        methodChannel.invokeMethod("bandConnection", true);
                    }
                });
                break;
            case DISCONNECTED:
                new Handler(Looper.getMainLooper()).post(new Runnable() {
                    @Override
                    public void run() {
                        methodChannel.invokeMethod("bandConnection", false);
                    }
                });
                break;
        }
    }

    @Override
    public void didEstablishConnection() {
        System.out.println("======= ESTABLISHED CONNECTION =======");
    }

    @Override
    public void didUpdateSensorStatus(int status, EmpaSensorType type) {
        System.out.println("======= UPDATED SENSOR STATUS: " + status + " " + type);
    }

    @Override
    public void didDiscoverDevice(EmpaticaDevice device, String deviceLabel, int rssi, boolean allowed) {
        System.out.println("======= DISCOVERED DEVICE: " + device);
        if (allowed) {
            try {
                deviceManager.connectDevice(device);
            } catch (ConnectionNotAllowedException e) {
                e.printStackTrace();
            }
        }
    }

    @Override
    public void didFailedScanning(int errorCode) {
        System.out.println("======= FAILED SCANNING: " + errorCode);
    }

    @Override
    public void didRequestEnableBluetooth() {
        System.out.println("======= REQUEST ENABLE BLUETOOTH");
    }

    @Override
    public void bluetoothStateChanged() {
        System.out.println("======= BLUETOOTH STATE CHANGED");
    }

    @Override
    public void didUpdateOnWristStatus(int status) {
        System.out.println("======= UPDATE ON WRIST STATUS: " + status);
        switch (status) {
            case 1:
                new Handler(Looper.getMainLooper()).post(new Runnable() {
                    @Override
                    public void run() {
                        methodChannel.invokeMethod("updateWristStatus", true);
                    }
                });
                break;
            case 0:
                new Handler(Looper.getMainLooper()).post(new Runnable() {
                    @Override
                    public void run() {
                        methodChannel.invokeMethod("updateWristStatus", false);
                    }
                });
                break;
        }
    }
}
