package com.example.qqfuturecontroller;

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
    private int[] originResource={R.mipmap.left,R.mipmap.right,R.mipmap.up,R.mipmap.down};
    private int[] clickedResource={R.mipmap.left_clicked,R.mipmap.right_clicked,R.mipmap.up_clicked,R.mipmap.down_clicked};
    private boolean[] clickedFlag ={false,false,false,false};
    private BTUtil btUtil;
    final String address = "00:24:01:35:1A:8F"; // 例如："00:11:22:33:44:55"
    @SuppressLint("ClickableViewAccessibility")
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
        leftButton = findViewById(R.id.left_button);
        rightButton = findViewById(R.id.right_button);
        upButton = findViewById(R.id.up_button);
        downButton = findViewById(R.id.down_button);
        leftButton.setOnTouchListener(this);
        rightButton.setOnTouchListener(this);
        upButton.setOnTouchListener(this);
        downButton.setOnTouchListener(this);

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
                // 连接成功后，你可以开始读写数据
            }

            @Override
            public void onConnectFail(BluetoothDevice device, String string) {
                showToast("连接蓝牙设备失败：" + string,MainActivity.this);
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

        if (buttonIndex != -1) { // 防止未识别的View触发此逻辑
            switch (motionEvent.getAction()) {
                case MotionEvent.ACTION_DOWN:
                    // 按下按钮时改变背景
                    view.setBackgroundResource(clickedResource[buttonIndex-1]);
                    if (!clickedFlag[buttonIndex-1]){
                        btUtil.write(Integer.toString(buttonIndex), new BTUtil.WriteCallBack() {
                            @Override
                            public void onStarted() {

                            }

                            @Override
                            public void onFinished(boolean success, String message) {

                            }
                        });
                    }

                    clickedFlag[buttonIndex-1] = true;
                    break;
                case MotionEvent.ACTION_UP:
                    // 松开按钮时的操作，恢复原始背景
                    if (clickedFlag[buttonIndex-1]) {
                        view.setBackgroundResource(originResource[buttonIndex-1]);
                        if (clickedFlag[buttonIndex-1]){
                            btUtil.write(Integer.toString(buttonIndex+4), new BTUtil.WriteCallBack() {
                                @Override
                                public void onStarted() {

                                }

                                @Override
                                public void onFinished(boolean success, String message) {

                                }
                            });
                        }
                        clickedFlag[buttonIndex-1] = false;
                    }
                    break;
                case MotionEvent.ACTION_CANCEL:
                    // 取消按下的操作，恢复原始背景
                    if (clickedFlag[buttonIndex-1]) {
                        view.setBackgroundResource(originResource[buttonIndex-1]);
                        clickedFlag[buttonIndex-1] = false;
                        Log.d("TouchEvent", "Action cancelled on button " + buttonIndex);
                    }
                    break;
            }
            return true; // 消费事件以防止按钮的其他点击监听器被触发
        }
        return false;
    }

}