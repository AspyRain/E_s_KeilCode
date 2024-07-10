package com.example.qqfuturecontroller.util;


import static com.example.qqfuturecontroller.util.BinaryConversionUtils.convertBinaryStringToByteArr;

import android.Manifest;
import android.annotation.SuppressLint;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothProfile;
import android.bluetooth.BluetoothSocket;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.AsyncTask;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.core.app.ActivityCompat;

import com.example.qqfuturecontroller.entity.BTdevice;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.UUID;




public class BTUtil {
    private BTdevice device;
    private Context context;
    private BluetoothAdapter bluetoothAdapter;
    private BluetoothSocket socket;
    private OutputStream outputStream;
    private InputStream inputStream;
    private ReadCallBack continuousReadCallBack;
    public BTUtil(Context context) {
        this.context = context;
        bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
    }

    public List<BTdevice> getBTDevices() {
        List<BTdevice> devices = new ArrayList<>();
        if (bluetoothAdapter == null) {
            // 设备不支持蓝牙
            return devices;
        }
        // 检查是否支持蓝牙，并且蓝牙已启用
        if (!bluetoothAdapter.isEnabled()) {
            // 若未启用蓝牙，则需要请求用户授权以启用蓝牙
            // 这里可以添加启用蓝牙的逻辑
            return devices;
        }
        // 获取已配对的设备列表
        if (ActivityCompat.checkSelfPermission(context, Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED) {
            // TODO: Consider calling
            //    ActivityCompat#requestPermissions
            // here to request the missing permissions, and then overriding
            //   public void onRequestPermissionsResult(int requestCode, String[] permissions,
            //                                          int[] grantResults)
            // to handle the case where the user grants the permission. See the documentation
            // for ActivityCompat#requestPermissions for more details.
            return devices;
        }
        Set<BluetoothDevice> pairedDevices = bluetoothAdapter.getBondedDevices();
        if (pairedDevices.size() > 0) {
            // 获取 A2DP 连接状态
            devices.add(new BTdevice(0, "请选择蓝牙设备", "", false));
            for (BluetoothDevice device : pairedDevices) {
                devices.add(new BTdevice(devices.size(), device.getName(), device.getAddress(), false));
            }

        }
        return devices;
    }


    /**连接线程
     * Created by zqf on 2018/7/7.
     */

    /**
     * 蓝牙连接线程
     */
    public class ConnectBlueTask extends AsyncTask<BTdevice, Integer, BluetoothSocket> {
        private BluetoothDevice bluetoothDevice;
        private ConnectBlueCallBack callBack;

        public ConnectBlueTask(ConnectBlueCallBack callBack, BTdevice device) {
            this.callBack = callBack;
            this.bluetoothDevice = bluetoothAdapter.getRemoteDevice(device.getAddress());
            ;
        }

        @SuppressLint("MissingPermission")
        @Override
        protected BluetoothSocket doInBackground(BTdevice... bluetoothDevices) {
            socket = null;
            try {
                socket = bluetoothDevice.createRfcommSocketToServiceRecord(UUID.fromString("00001101-0000-1000-8000-00805f9b34fb"));
                if (socket != null && !socket.isConnected()) {
                    socket.connect();
                }
            } catch (IOException e) {
                try {
                    socket.close();
                } catch (IOException e1) {
                    e1.printStackTrace();
                }
            }
            return socket;
        }

        @Override
        protected void onPreExecute() {
            if (callBack != null) callBack.onStartConnect();
        }

        @Override
        protected void onPostExecute(BluetoothSocket bluetoothSocket) {
            if (bluetoothSocket != null && bluetoothSocket.isConnected()) {
                if (callBack != null) callBack.onConnectSuccess();
            } else {
                if (callBack != null) callBack.onConnectFail(bluetoothDevice, "连接失败");
            }
        }
    }


    /**
     * 连接 （在配对之后调用）
     * @param device
     */
    @SuppressLint("MissingPermission")
    public void connect(BTdevice device, ConnectBlueCallBack callBack) {
        //连接之前把扫描关闭
        if (bluetoothAdapter.isDiscovering()) {
            bluetoothAdapter.cancelDiscovery();
        }
        new ConnectBlueTask(callBack, device).execute(device);
    }

    public void write(String data, WriteCallBack callBack) {
        if (socket != null) {
            new WriteTask(callBack,false).execute(data+'\n');
        }
    }
    public void writeBinary(String binaryData, WriteCallBack callBack) {
        if (socket != null) {
            new WriteTask(callBack,true).execute(binaryData);
        }
    }
    public void read(ReadCallBack callBack) {
        if (socket != null) {
            new ReadTask(callBack).execute();
        }
    }
    public void readBin(ReadCallBack callBack){
        if (socket != null) {
            new ReadBinTask(callBack).execute();
        }
    }
    /*
     * 蓝牙是否连接
     * @return
     */
    public boolean isConnectBlue(){
        return socket != null && socket.isConnected();
    }
    /**
     * 断开连接
     * @return
     */
    public boolean cancelConnect(){
        if (socket != null && socket.isConnected()){
            try {
                socket.close();
            } catch (IOException e) {
                e.printStackTrace();
                return false;
            }
        }
        socket = null;
        return true;
    }

    public interface ConnectBlueCallBack{
        void onStartConnect();
        void onConnectSuccess();
        void onConnectFail(BluetoothDevice device,String string);
    }
    /**写入线程
     * Created by zqf on 2018/7/7.
     */
    public interface WriteCallBack {
        void onStarted();

        void onFinished(boolean success, String message);
    }
    public class WriteTask extends AsyncTask<String, Integer, String>{
        private  final String TAG = WriteTask.class.getName();
        private final WriteCallBack callBack;
        private final boolean isBinary;
        public WriteTask(WriteCallBack callBack, boolean isBinary){
            this.callBack = callBack;
            this.isBinary = isBinary;
        }
        @Override
        protected String doInBackground(String... strings) {
            String string = strings[0];
            try{
                if (outputStream==null)
                    outputStream = socket.getOutputStream();
                if (isBinary){
                    outputStream.write(convertBinaryStringToByteArr(string));
                }else {
                    outputStream.write(string.getBytes());
                }

            } catch (IOException e) {
                Log.e("error", "ON RESUME: Exception during write.", e);
                return "发送失败";
            }
            return string;


        }

        @Override
        protected void onPreExecute() {
            if (callBack != null) callBack.onStarted();
        }

        @Override
        protected void onPostExecute(String s) {
            if (callBack != null){
                if ("发送成功".equals(s)){
                    callBack.onFinished(true, s);
                }else {
                    callBack.onFinished(false, s);
                }

            }
        }
    }
    public interface ReadCallBack {
        void onStarted();

        void onFinished(boolean success, String data);

    }
    /**读取线程
     * Created by zqf on 2018/7/7.
     */

    public class ReadTask extends AsyncTask<String, Integer, String> {
        private  final String TAG = ReadTask.class.getName();
        private ReadCallBack callBack;


        public ReadTask(ReadCallBack callBack){
            this.callBack = callBack;
        }
        @Override
        protected String doInBackground(String... strings) {
            BufferedInputStream in = null;
            try {
                StringBuffer sb = new StringBuffer();
                in = new BufferedInputStream(socket.getInputStream());

                int length = 0;
                byte[] buf = new byte[1024];
                while ((length = in.read()) != -1) {
                    sb.append(new String(buf,0,length));
                }
                return sb.toString();
            } catch (IOException e) {
                e.printStackTrace();
            }finally {
                try {
                    in.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
            return "读取失败";
        }

        @Override
        protected void onPreExecute() {
            Log.d(TAG,"开始读取数据");
            if (callBack != null) callBack.onStarted();
        }

        @Override
        protected void onPostExecute(String s) {
            Log.d(TAG,"完成读取数据");
            if (callBack != null){
                if ("读取失败".equals(s)){
                    callBack.onFinished(false, s);
                }else {
                    callBack.onFinished(true, s);
                    scheduleNextRead();
                }
            }
        }
    }
    public class ReadBinTask extends AsyncTask<Void, Byte, Void> {
        private final String TAG = ReadTask.class.getName();
        private ReadCallBack callBack;
        private InputStream inputStream;
        private volatile boolean running = true;

        public ReadBinTask(ReadCallBack callBack) {
            this.callBack = callBack;
        }

        @Override
        protected Void doInBackground(Void... voids) {
            try {
                inputStream = socket.getInputStream();
                byte[] buffer = new byte[1]; // 用于存储单个字节
                while (running) {
                    int bytesRead = inputStream.read(buffer);
                    if (bytesRead != -1) { // 成功读取到字节
                        publishProgress(buffer[0]); // 发布进度更新，包含读取到的字节
                    } else {
                        // 如果没有更多数据可读，可以考虑结束任务或者根据实际情况处理
                        break;
                    }
                    // 可能需要在这里加入适当的延迟或者条件判断以控制读取频率，避免过快读取导致资源占用过高
                    Thread.sleep(50); // 简单示例，休眠50毫秒
                }
            } catch (IOException | InterruptedException e) {
                Log.e(TAG, "Error reading from InputStream", e);
            } finally {
                try {
                    if (inputStream != null) {
                        inputStream.close();
                    }
                } catch (IOException e) {
                    Log.e(TAG, "Error closing InputStream", e);
                }
            }
            return null;
        }

        @Override
        protected void onProgressUpdate(Byte... values) {
            super.onProgressUpdate(values);
            if (callBack != null) {
                callBack.onFinished(true, String.format("%8s", Integer.toBinaryString(values[0] & 0xFF)).replace(' ', '0'));
            }
        }

        // 提供一个方法来停止读取任务
        public void stopReading() {
            running = false;
        }
    }
    private Handler handler; // 用于调度重复任务
    private Runnable readTaskRunnable; // 用于执行读取任务的Runnable
    private static final long READ_INTERVAL_MS = 1000; // 每50毫秒读取一次

    // 新增方法：启动持续读取任务
    public void startContinuousRead(ReadCallBack callBack) {
        this.continuousReadCallBack = callBack;
        if (handler == null) {
            handler = new Handler(Looper.getMainLooper());
        }
        if (readTaskRunnable == null) {
            readTaskRunnable = new Runnable() {
                @Override
                public void run() {
                    readBin(continuousReadCallBack);
                }
            };
        }

        scheduleNextRead();
    }
    private void scheduleNextRead() {
        handler.post(readTaskRunnable);
    }
    // 新增方法：停止持续读取任务
    public void stopContinuousRead() {
        if (handler != null && readTaskRunnable != null) {
            handler.removeCallbacks(readTaskRunnable);
            handler = null;
            readTaskRunnable = null;
        }
    }

    public BTdevice getDevice() {
        return device;
    }

    public void setDevice(BTdevice device) {
        this.device = device;
    }

    public Context getContext() {
        return context;
    }

    public void setContext(Context context) {
        this.context = context;
    }

    public BluetoothAdapter getBluetoothAdapter() {
        return bluetoothAdapter;
    }

    public void setBluetoothAdapter(BluetoothAdapter bluetoothAdapter) {
        this.bluetoothAdapter = bluetoothAdapter;
    }
}
