package com.gotojmp.cordova.tusdk;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.LOG;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import java.util.Arrays;

import org.lasque.tusdk.core.TuSdk;

import org.lasque.tusdk.TuSdkGeeV1;
import org.lasque.tusdk.core.TuSdkResult;
import org.lasque.tusdk.core.struct.TuSdkSize;
import org.lasque.tusdk.core.utils.TLog;
import org.lasque.tusdk.impl.activity.TuFragment;
import org.lasque.tusdk.impl.components.TuAlbumMultipleComponent;
import org.lasque.tusdk.impl.components.TuEditMultipleComponent;
import org.lasque.tusdk.impl.components.edit.TuEditTurnAndCutOption;
import org.lasque.tusdk.impl.components.edit.TuEditTurnAndCutFragment;
import org.lasque.tusdk.impl.components.edit.TuEditTurnAndCutFragment.TuEditTurnAndCutFragmentDelegate;
import org.lasque.tusdk.modules.components.TuSdkComponent.TuSdkComponentDelegate;
import org.lasque.tusdk.modules.components.TuSdkHelperComponent;

import android.content.Context;
import android.app.Activity;
import com.gotojmp.cordova.textarea.MyDialog;

/**
 * Created by gotojmp on 16/7/13.
 */
public class Tusdk extends CordovaPlugin implements TuEditTurnAndCutFragmentDelegate {

    private static final String TAG = "Cordova.Plugin.Tusdk";

    private static CallbackContext currentCallbackContext;
    private static MyDialog myDialog;

    @Override
    protected void pluginInitialize() {
        super.pluginInitialize();

        String APPKEY = preferences.getString("tusdkappkey_android", "");
        TuSdk.init(cordova.getActivity(), APPKEY);
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        LOG.d(TAG, action + " is called.");

        if (action.equals("openPhotoBox")) {
            return openPhotoBox(callbackContext);
        } else if (action.equals("openAvatarBox")) {
            return openAvatarBox(callbackContext);
        }
        return super.execute(action, args, callbackContext);
    }

    public void openPhotoBoxNative(Context context, MyDialog dialog) {
        myDialog = dialog;
        TuAlbumMultipleComponent comp = TuSdkGeeV1.albumMultipleCommponent((Activity)context,
                new TuSdkComponentDelegate()
                {
                    @Override
                    public void onComponentFinished(TuSdkResult result, Error error, TuFragment lastFragment)
                    {
                        TLog.d("onAlbumCommponentReaded: %s | %s", result, error);
                        openEditMultipleNative(result, error, lastFragment);
                    }
                });
        // 在组件执行完成后自动关闭组件
        comp.setAutoDismissWhenCompleted(false).showComponent();
    }

    protected boolean openPhotoBox(CallbackContext callbackContext) {
        currentCallbackContext = callbackContext;
        TuAlbumMultipleComponent comp = TuSdkGeeV1.albumMultipleCommponent(cordova.getActivity(),
                new TuSdkComponentDelegate()
                {
                    @Override
                    public void onComponentFinished(TuSdkResult result, Error error, TuFragment lastFragment)
                    {
                        TLog.d("onAlbumCommponentReaded: %s | %s", result, error);
                        openEditMultiple(result, error, lastFragment);
                    }
                });
        // 在组件执行完成后自动关闭组件
        comp.setAutoDismissWhenCompleted(false).showComponent();
        return true;
    }

    protected boolean openAvatarBox(CallbackContext callbackContext) {
        currentCallbackContext = callbackContext;
        TuAlbumMultipleComponent comp = TuSdkGeeV1.albumMultipleCommponent(cordova.getActivity(),
                new TuSdkComponentDelegate()
                {
                    @Override
                    public void onComponentFinished(TuSdkResult result, Error error, TuFragment lastFragment)
                    {
                        // if (lastFragment != null)
                        // lastFragment.dismissActivityWithAnim();
                        // 多选状态下使用 result.images 获取所选图片
                        TLog.d("onAlbumCommponentReaded: %s | %s", result, error);
                        openTuEditTurnAndCut(result, error, lastFragment);
                    }
                });
        // 在组件执行完成后自动关闭组件
        comp.setAutoDismissWhenCompleted(false).showComponent();
        return true;
    }

    private void openEditMultipleNative(TuSdkResult result, Error error, TuFragment lastFragment)
    {
        if (result == null || error != null) return;

        // 组件委托
        TuSdkComponentDelegate delegate = new TuSdkComponentDelegate()
        {
            @Override
            public void onComponentFinished(TuSdkResult result, Error error, TuFragment lastFragment)
            {
                TLog.d("onEditMultipleComponentReaded: %s | %s", result, error);
                myDialog.insertImage(result.imageFile);
            }
        };

        // 组件选项配置
        // @see-http://tusdk.com/docs/android/api/org/lasque/tusdk/impl/components/TuEditMultipleComponent.html
        TuEditMultipleComponent component = null;

        if (lastFragment == null)
        {
            component = TuSdkGeeV1.editMultipleCommponent(cordova.getActivity(), delegate);
        }
        else
        {
            component = TuSdkGeeV1.editMultipleCommponent(lastFragment, delegate);
        }

        component.componentOption().editMultipleOption().setSaveToAlbum(false);
        component.componentOption().editMultipleOption().setSaveToTemp(true);
        component.componentOption().editMultipleOption().setAutoRemoveTemp(false);
        String[] filters = { "Brilliant", "Harmony", "Gloss" };
        component.componentOption().editFilterOption().setFilterGroup(Arrays.asList(filters));

        // 设置图片
        component.setImage(result.image)
                // 设置系统照片
                .setImageSqlInfo(result.imageSqlInfo)
                // 设置临时文件
                .setTempFilePath(result.imageFile)
                // 在组件执行完成后自动关闭组件
                .setAutoDismissWhenCompleted(true)
                // 开启组件
                .showComponent();
    }

    private void openEditMultiple(TuSdkResult result, Error error, TuFragment lastFragment)
    {
        if (result == null || error != null) return;

        // 组件委托
        TuSdkComponentDelegate delegate = new TuSdkComponentDelegate()
        {
            @Override
            public void onComponentFinished(TuSdkResult result, Error error, TuFragment lastFragment)
            {
                TLog.d("onEditMultipleComponentReaded: %s | %s", result, error);
                JSONObject info = new JSONObject();
                try {
                    info.put("platform", "android");
                    info.put("image", result.imageFile);
                    //info.put("thumb", "");
                } catch (JSONException e) {
                    LOG.e(TAG, "make json error");
                }
                currentCallbackContext.success(info);
            }
        };

        // 组件选项配置
        // @see-http://tusdk.com/docs/android/api/org/lasque/tusdk/impl/components/TuEditMultipleComponent.html
        TuEditMultipleComponent component = null;

        if (lastFragment == null)
        {
            component = TuSdkGeeV1.editMultipleCommponent(cordova.getActivity(), delegate);
        }
        else
        {
            component = TuSdkGeeV1.editMultipleCommponent(lastFragment, delegate);
        }

        component.componentOption().editMultipleOption().setSaveToAlbum(false);
        component.componentOption().editMultipleOption().setSaveToTemp(true);
        component.componentOption().editMultipleOption().setAutoRemoveTemp(false);
        String[] filters = { "Brilliant", "Harmony", "Gloss" };
        component.componentOption().editFilterOption().setFilterGroup(Arrays.asList(filters));

        // 设置图片
        component.setImage(result.image)
                // 设置系统照片
                .setImageSqlInfo(result.imageSqlInfo)
                // 设置临时文件
                .setTempFilePath(result.imageFile)
                // 在组件执行完成后自动关闭组件
                .setAutoDismissWhenCompleted(true)
                // 开启组件
                .showComponent();
    }

    private void openTuEditTurnAndCut(TuSdkResult result, Error error, TuFragment lastFragment)
    {
        if (result == null || error != null) return;

        TuEditTurnAndCutOption option = new TuEditTurnAndCutOption();
        // 是否开启滤镜支持 (默认: 关闭)
        option.setEnableFilters(false);
        // 开启用户滤镜历史记录
        option.setEnableFiltersHistory(true);
        // 开启在线滤镜
        option.setEnableOnlineFilter(true);
        // 显示滤镜标题视图
        option.setDisplayFiltersSubtitles(true);
        // 需要裁剪的长宽
        option.setCutSize(new TuSdkSize(640, 640));
        option.setSaveToAlbum(false);
        option.setSaveToTemp(true);
        // 是否在控制器结束后自动删除临时文件
        option.setAutoRemoveTemp(false);
        // 是否显示处理结果预览图 (默认：关闭，调试时可以开启)
        option.setShowResultPreview(false);
        // 是否渲染滤镜封面 (使用设置的滤镜直接渲染，需要拥有滤镜列表封面设置权限，请访问TuSDK.com控制台)
        // option.setRenderFilterThumb(true);

        TuEditTurnAndCutFragment fragment = option.fragment();
        // 输入的图片对象 (处理优先级: Image > TempFilePath > ImageSqlInfo)
        fragment.setImage(result.image);
        fragment.setTempFilePath(result.imageFile);
        fragment.setImageSqlInfo(result.imageSqlInfo);
        fragment.setDelegate(this);

        // 如果lastFragment不存在，您可以使用如下方法开启fragment
        if (lastFragment == null) {
            TuSdkHelperComponent componentHelper = new TuSdkHelperComponent(cordova.getActivity());
            componentHelper.presentModalNavigationActivity(fragment);
        } else { // 开启裁切+滤镜组件
            lastFragment.pushFragment(fragment);
        }
    }

    /**
     * 图片编辑完成
     *
     * @param fragment
     *            旋转和裁剪视图控制器
     * @param result
     *            旋转和裁剪视图控制器处理结果
     */
    @Override
    public void onTuEditTurnAndCutFragmentEdited(TuEditTurnAndCutFragment fragment, TuSdkResult result)
    {
        if (!fragment.isShowResultPreview())
        {
            fragment.hubDismissRightNow();
            fragment.dismissActivityWithAnim();
        }
        TLog.d("onTuEditTurnAndCutFragmentEdited: %s", result);

        JSONObject info = new JSONObject();
        try {
            info.put("platform", "android");
            info.put("image", result.imageFile);
            //info.put("thumb", "");
        } catch (JSONException e) {
            LOG.e(TAG, "make json error");
        }
        currentCallbackContext.success(info);
    }

    /**
     * 图片编辑完成 (异步方法)
     *
     * @param fragment
     *            旋转和裁剪视图控制器
     * @param result
     *            旋转和裁剪视图控制器处理结果
     * @return 是否截断默认处理逻辑 (默认: false, 设置为True时使用自定义处理逻辑)
     */
    @Override
    public boolean onTuEditTurnAndCutFragmentEditedAsync(TuEditTurnAndCutFragment fragment, TuSdkResult result)
    {
        TLog.d("onTuEditTurnAndCutFragmentEditedAsync: %s", result);
        return false;
    }

    @Override
    public void onComponentError(TuFragment fragment, TuSdkResult result, Error error)
    {
        TLog.d("onComponentError: fragment - %s, result - %s, error - %s", fragment, result, error);
        currentCallbackContext.error(error.getMessage());
    }
}
