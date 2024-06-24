package com.example.qqfuturecontroller.util;

import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentTransaction;

public class FragmentUtil {
    public static void openFragment(FragmentManager fragmentManager, Fragment fragment, int frag_id) {
        // 步骤2：获取FragmentTransaction
        FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();

        // 移除之前的Fragment
        Fragment currentFragment = fragmentManager.findFragmentById(frag_id);
        if (currentFragment != null) {
            fragmentTransaction.remove(currentFragment);
        }

        // 步骤3：创建需要添加的Fragment
        // 步骤4：动态添加fragment
        // 即将创建的fragment添加到Activity布局文件中定义的占位符中（FrameLayout）
        fragmentTransaction.replace(frag_id, fragment);
        fragmentTransaction.addToBackStack(null);  // 将Fragment添加到返回栈，以便返回时恢复前一个Fragment状态
        fragmentTransaction.commit();
    }
}
