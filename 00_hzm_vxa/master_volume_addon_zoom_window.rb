# coding: utf-8
#===============================================================================
# ■ [音量変更スクリプトさんアドオン] ウィンドウ倍率設定さん for RGSS3
#-------------------------------------------------------------------------------
#　2017/11/14　Ruたん
#-------------------------------------------------------------------------------
#　このスクリプトは「音量変更スクリプトさん for RGSS3」に機能を追加するものです。
#　導入時は「音量変更スクリプトさん」より下に導入してください。
#　また、「HZM_VXAベーススクリプトさん for RGSS3」が必要です。
#-------------------------------------------------------------------------------
#　音量変更画面にウィンドウ倍率設定を追加します
#-------------------------------------------------------------------------------
# 【更新履歴】
# 2017/11/14 つくってみた
#-------------------------------------------------------------------------------

#===============================================================================
# ● 設定項目
#===============================================================================
module HZM_VXA
  module AudioVol
    module ZoomWindow
      # メニューの項目の名前
      SCALE_MENU_LABEL = '拡大率'

      # 1倍のときの表示
      SCALE_X1_LABEL = 'x1'

      # 2倍のときの表示
      SCALE_X2_LABEL = 'x2'
    end
  end
end

#===============================================================================
# ↑ 　 ここまで設定 　 ↑
# ↓ 以下、スクリプト部 ↓
#===============================================================================

raise '「HZM_VXAベーススクリプトさん for RGSS3」が必要です' unless defined?(HZM_VXA::Base)
raise '「HZM_VXAベーススクリプトさん for RGSS3」のバージョンが異なります' unless HZM_VXA::Base.check_version?('2.2.0')

# 音量変更ウィンドウ
module HZM_VXA
  module AudioVol
    class Window_VolConfig < Window_Command
      #-------------------------------------------------------------------------
      # ● コマンド生成：アクション
      #-------------------------------------------------------------------------
      alias hzm_vxa_volume_addon_zoom_window_make_command_list_actions make_command_list_actions
      def make_command_list_actions
        hzm_vxa_volume_addon_zoom_window_make_command_list_actions
        add_command(AudioVol::ZoomWindow::SCALE_MENU_LABEL, :addon_zoom_window, true, nil)
      end
      #-------------------------------------------------------------------------
      # ● 項目の描画
      #-------------------------------------------------------------------------
      alias hzm_vxa_volume_addon_zoom_window_draw_item draw_item
      def draw_item(index)
        hzm_vxa_volume_addon_zoom_window_draw_item(index)
        draw_item_addon_zoom_window(index) if command_symbol(index) == :addon_zoom_window
      end
      #-------------------------------------------------------------------------
      # ● 項目の描画：拡大率
      #-------------------------------------------------------------------------
      def draw_item_addon_zoom_window(index)
        draw_text(
          item_rect_for_text(index),
          HZM_VXA::Base.window_scale > 1 ? AudioVol::ZoomWindow::SCALE_X2_LABEL : AudioVol::ZoomWindow::SCALE_X1_LABEL,
          2
        )
      end
      #--------------------------------------------------------------------------
      # ● 決定ボタンが押されたときの処理
      #--------------------------------------------------------------------------
      alias hzm_vxa_volume_addon_zoom_window_process_ok process_ok
      def process_ok
        if current_symbol == :addon_zoom_window
          process_addon_zoom_window
        else
          hzm_vxa_volume_addon_zoom_window_process_ok
        end
      end
      #-------------------------------------------------------------------------
      # ● 拡大・縮小の実行
      #-------------------------------------------------------------------------
      def process_addon_zoom_window
        if HZM_VXA::Base.fullscreen?
          Sound.play_buzzer
        else
          Sound.play_ok
          Input.update
          HZM_VXA::Base.window_scale = HZM_VXA::Base.window_scale > 1 ? 1 : 2
          redraw_item(index)
        end
      end
    end
  end
end
