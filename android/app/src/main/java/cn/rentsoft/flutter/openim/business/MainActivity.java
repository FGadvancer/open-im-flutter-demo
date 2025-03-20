package cn.rentsoft.flutter.openim.business;

import android.graphics.drawable.Drawable;
import android.os.Bundle;
import androidx.core.content.ContextCompat;
import io.flutter.embedding.android.FlutterFragmentActivity;

public class MainActivity extends FlutterFragmentActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // 设置背景图片
        Drawable background = ContextCompat.getDrawable(this, R.drawable.launch_background);
        getWindow().setBackgroundDrawable(background);
    }
}
