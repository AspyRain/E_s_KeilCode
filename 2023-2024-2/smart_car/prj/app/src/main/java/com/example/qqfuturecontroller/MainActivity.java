package com.example.qqfuturecontroller;

import static com.example.qqfuturecontroller.util.BinaryConversionUtils.convertIntStringToSixBitBinary;
import static com.example.qqfuturecontroller.util.ToastUtil.showToast;

import android.annotation.SuppressLint;
import android.bluetooth.BluetoothDevice;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.SeekBar;
import android.widget.TextView;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.example.qqfuturecontroller.entity.BTdevice;
import com.example.qqfuturecontroller.util.BTUtil;

import java.util.List;

public class MainActivity extends AppCompatActivity implements View.OnTouchListener {

    private ImageView leftButton;
    private ImageView rightButton;
    private ImageView upButton;
    private ImageView downButton;
    private LinearLayout stopButton;
    private SeekBar speedSeekBar;
    private TextView    speedValue;
    private int[] originResource={0,R.mipmap.left,R.mipmap.right,R.mipmap.up,R.mipmap.down};
    private int[] clickedResource={R.drawable.red_bg,R.mipmap.left_clicked,R.mipmap.right_clicked,R.mipmap.up_clicked,R.mipmap.down_clicked};
    private boolean[] clickedFlag ={false,false,false,false,false};
    private ImageView[] disGear ;
    private BTUtil btUtil;
    final String address = "00:24:01:35:1A:8F"; // 例如："00:11:22:33:44:55"
    @SuppressLint({"ClickableViewAccessibility", "MissingInflatedId", "WrongViewCast"})
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_main);
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });
        disGear = new ImageView[4];
        stopButton = findViewById(R.id.stop_button);
        speedValue = findViewById(R.id.speed_value);
        leftButton = findViewById(R.id.left_button);
        rightButton = findViewById(R.id.right_button);
        upButton = findViewById(R.id.up_button);
        downButton = findViewById(R.id.down_button);
        speedSeekBar = findViewById(R.id.speed_seekBar);
        disGear[0] = findViewById(R.id.dis_gear_front);
        disGear[1] = findViewById(R.id.dis_gear_back);
        disGear[2] = findViewById(R.id.dis_gear_left);
        disGear[3] = findViewById(R.id.dis_gear_right);
        leftButton.setOnTouchListener(this);
        rightButton.setOnTouchListener(this);
        upButton.setOnTouchListener(this);
        downButton.setOnTouchListener(this);
        stopButton.setOnTouchListener(this);
        btUtil = new BTUtil(this);
        List<BTdevice> bTdevices=btUtil.getBTDevices();
        btUtil.connect(new BTdevice(0, "AVOCAR", address, false), new BTUtil.ConnectBlueCallBack() {
            @Override
            public void onStartConnect() {
                showToast("开始连接蓝牙设备...",MainActivity.this);
            }

            @Override
            public void onConnectSuccess() {
                showToast("连接蓝牙设备成功！",MainActivity.this);
                btUtil.startContinuousRead(new BTUtil.ReadCallBack() {
                    @Override
                    public void onStarted() {
                        System.out.println("开始发送");
                    }

                    @Override
                    public void onFinished(boolean success, String data) {
                        String[] binaryPairArray = new String[4]; // 8位二进制分为4组，每组2位
                        for (int i = 0; i < 4; i++) {
                            binaryPairArray[i] = data.substring(i * 2, i * 2 + 2); // 分割字符串
                        }
                        for (int i = 0 ;i <4 ;i++){
                            if ("00".equals(binaryPairArray[i])){
                                disGear[i].setBackgroundResource(R.mipmap.gears_1);
                            }else if ("01".equals(binaryPairArray[i])){
                                disGear[i].setBackgroundResource(R.mipmap.gears_2);
                            }
                            else if ("10".equals(binaryPairArray[i])){
                                disGear[i].setBackgroundResource(R.mipmap.gears_2);
                            }
                        }

                    }
                });
            }

            @Override
            public void onConnectFail(BluetoothDevice device, String string) {
                showToast("连接蓝牙设备失败：" + string,MainActivity.this);
            }
        });
        speedSeekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                speedValue.setText(Integer.toString(progress));
                String command = "1" + convertIntStringToSixBitBinary(Integer.toString(progress/2));
                btUtil.writeBinary(command, new BTUtil.WriteCallBack()
                {
                    @Override
                    public void onStarted() {

                    }

                    @Override
                    public void onFinished(boolean success, String message) {

                    }
                });
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

            }
        });

    }

    @SuppressLint("ClickableViewAccessibility")
    @Override
    public boolean onTouch(View view, MotionEvent motionEvent) {
        // 确保数组索引与按钮对应
        int buttonIndex = -1;
        if (view == leftButton) buttonIndex = 1;
        else if (view == rightButton) buttonIndex = 2;
        else if (view == upButton) buttonIndex = 3;
        else if (view == downButton) buttonIndex = 4;
        else if (view == stopButton) buttonIndex = 0;
        // 防止未识别的View触发此逻辑
        if (buttonIndex>=0){
            switch (motionEvent.getAction()) {
                case MotionEvent.ACTION_DOWN:
                    // 按下按钮时改变背景
                    view.setBackgroundResource(clickedResource[buttonIndex]);
                    if (!clickedFlag[buttonIndex]){
                        btUtil.write(Integer.toString(buttonIndex), new BTUtil.WriteCallBack()
//                        String command = "0" + convertIntStringToSixBitBinary(Integer.toString(buttonIndex));
//                        btUtil.writeBinary(command, new BTUtil.WriteCallBack()
                        {
                            @Override
                            public void onStarted() {

                            }

                            @Override
                            public void onFinished(boolean success, String message) {

                            }
                        });
                    }

                    clickedFlag[buttonIndex] = true;
                    break;
                case MotionEvent.ACTION_UP:
                    // 松开按钮时的操作，恢复原始背景
                    if (clickedFlag[buttonIndex]) {
                        view.setBackgroundResource(originResource[buttonIndex]);
                        if (clickedFlag[buttonIndex]){
                            btUtil.write(Integer.toString(buttonIndex+4), new BTUtil.WriteCallBack()
//                            String command = "0" + convertIntStringToSixBitBinary(Integer.toString(buttonIndex+4));
//                            btUtil.writeBinary(command, new BTUtil.WriteCallBack()
                            {
                                @Override
                                public void onStarted() {

                                }

                                @Override
                                public void onFinished(boolean success, String message) {

                                }
                            });
                        }
                        clickedFlag[buttonIndex] = false;
                    }
                    break;
                case MotionEvent.ACTION_CANCEL:
                    // 取消按下的操作，恢复原始背景
                    if (clickedFlag[buttonIndex]) {
                        view.setBackgroundResource(originResource[buttonIndex]);
                        clickedFlag[buttonIndex] = false;
                        Log.d("TouchEvent", "Action cancelled on button " + buttonIndex);
                    }
                    break;
            }
        }

        return true; // 消费事件以防止按钮的其他点击监听器被触发
    }

}