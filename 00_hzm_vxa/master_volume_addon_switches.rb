# coding: utf-8
#===============================================================================
# ■ [音量変更スクリプトさんアドオン] スイッチ設定さん for RGSS3
#-------------------------------------------------------------------------------
#　2021/12/15　Ruたん
#-------------------------------------------------------------------------------
#　このスクリプトは「音量変更スクリプトさん for RGSS3」に機能を追加するものです。
#　導入時は「音量変更スクリプトさん」より下に導入してください。
#-------------------------------------------------------------------------------
#　音量変更画面にスイッチON/OFFの設定を追加します。
#-------------------------------------------------------------------------------
# 【更新履歴】
# 2021/12/15 有効な場面判定を行うように
#            デフォルトではタイトル画面ではスイッチを変更できないようにします
# 2016/04/23 デフォルトオプションを追加
# 2016/04/23 つくってみた
#===============================================================================

#===============================================================================
# ● 設定項目
#===============================================================================
module HZM_VXA
  module AudioVol
    module Switches
      LIST = [
        # ● 設定するスイッチの項目名と番号（複数設定可能）

        # 設定1つ目
        {
          # スイッチの番号
          id: 10,
          # 設定に表示する名前
          name: '10番！',
          # ONのときの表示
          label_on: 'ON',
          # OFFのときの表示
          label_off: 'OFF',
          # 初期のON/OFF状態(true: 最初からON  false: 最初からOFF)
          default: true,
          # この項目が有効な場面
          # （0: 常に / 1: タイトル画面のみ / 2: タイトル画面以外）
          enable_scene: 2,
        },

        # 設定2つ目
        {
          # スイッチの番号
          id: 11,
          # 設定に表示する名前
          name: '11番！',
          # ONのときの表示
          label_on: 'おん',
          # OFFのときの表示
          label_off: 'おふ',
          # 初期のON/OFF状態(true: 最初からON  false: 最初からOFF)
          default: false,
          # この項目が有効な場面
          # （0: 常に / 1: タイトル画面のみ / 2: タイトル画面以外）
          enable_scene: 2,
        },

        # 設定ここまで
      ]

      # ● 無効な場合も画面に項目を表示するか？
      #    true : する / false : しない
      SHOW_DISABLE_ITEM = true

      # ● 設定内容をなるべく他のセーブデータに引き継ぐ互換モードを使用する
      #    ※できる限り使用せず「共有スイッチ・変数スクリプトさん」をご利用ください
      #    true : 互換モードを使用する / false : 互換モードを使用しない
      LEGACY = false
    end
  end
end

#===============================================================================
# ↑ 　 ここまで設定 　 ↑
# ↓ 以下、スクリプト部 ↓
#===============================================================================

# 音量変更ウィンドウ
module HZM_VXA
  module AudioVol
    class Window_VolConfig < Window_Command
      #-------------------------------------------------------------------------
      # ● コマンド生成：アクション
      #-------------------------------------------------------------------------
      alias hzm_vxa_volume_addon_switches_make_command_list_actions make_command_list_actions
      def make_command_list_actions
        hzm_vxa_volume_addon_switches_make_command_list_actions
        HZM_VXA::AudioVol::Switches::LIST.each do |item|
          flag =
            case item[:enable_scene]
            when 1
              SceneManager.include_stack?(Scene_Title)
            when 2
              !SceneManager.include_stack?(Scene_Title)
            else
              true
            end

          # フラグが無効かつ非表示モードの場合は項目を追加しない
          next if !flag && !HZM_VXA::AudioVol::Switches::SHOW_DISABLE_ITEM

          add_command(item[:name], :addon_switch, flag, item)
        end
      end
      #-------------------------------------------------------------------------
      # ● 項目の描画
      #-------------------------------------------------------------------------
      alias hzm_vxa_volume_addon_switches_draw_item draw_item
      def draw_item(index)
        hzm_vxa_volume_addon_switches_draw_item(index)
        draw_item_addon_switch(index) if command_symbol(index) == :addon_switch
      end
      #-------------------------------------------------------------------------
      # ● 項目の描画：スイッチ
      #-------------------------------------------------------------------------
      def draw_item_addon_switch(index)
        item = command_ext(index)
        draw_text(
          item_rect_for_text(index),
          $game_switches[item[:id]] ? item[:label_on] : item[:label_off],
          2
        )
      end
      #--------------------------------------------------------------------------
      # ● 決定ボタンが押されたときの処理
      #--------------------------------------------------------------------------
      alias hzm_vxa_volume_addon_switches_process_ok process_ok
      def process_ok
        if current_symbol == :addon_switch
          process_addon_switch
        else
          hzm_vxa_volume_addon_switches_process_ok
        end
      end
      #-------------------------------------------------------------------------
      # ● スイッチのON/OFF
      #-------------------------------------------------------------------------
      def process_addon_switch
        if current_item_enabled?
          Sound.play_ok
          Input.update
          item = current_ext
          $game_switches[item[:id]] = !$game_switches[item[:id]]
          redraw_item(index)
        else
          Sound.play_buzzer
        end
      end
      #-------------------------------------------------------------------------
      # ● キー操作
      #-------------------------------------------------------------------------
      alias hzm_vxa_volume_addon_switches_cursor_left cursor_left
      def cursor_left(wrap = false)
        if current_symbol == :addon_switch
          process_addon_switch
        else
          hzm_vxa_volume_addon_switches_cursor_left(wrap)
        end
      end
      alias hzm_vxa_volume_addon_switches_cursor_right cursor_right
      def cursor_right(wrap = false)
        if current_symbol == :addon_switch
          process_addon_switch
        else
          hzm_vxa_volume_addon_switches_cursor_right(wrap)
        end
      end
    end
  end
end

class << DataManager
  #--------------------------------------------------------------------------
  # ● モジュール初期化（エイリアス）
  #--------------------------------------------------------------------------
  alias hzm_vxa_volume_addon_switches_init init
  def init
    hzm_vxa_volume_addon_switches_init
    HZM_VXA::AudioVol::Switches::LIST.each do |item|
      $game_switches[item[:id]] = item[:default]
    end
  end

  # [互換モード] 現在のスイッチの値をなるべく引き継ぐ
  if HZM_VXA::AudioVol::Switches::LEGACY
    #--------------------------------------------------------------------------
    # ● 各種ゲームオブジェクトの作成（エイリアス）
    #--------------------------------------------------------------------------
    alias hzm_vxa_volume_addon_switches_create_game_objects create_game_objects
    def create_game_objects
      backup_switches = {}
      if $game_switches
        HZM_VXA::AudioVol::Switches::LIST.each do |item|
          backup_switches[item[:id]] = $game_switches[item[:id]]
        end
      end
      hzm_vxa_volume_addon_switches_create_game_objects
      backup_switches.each do |id, value|
        $game_switches[id] = value
      end
    end
  end
end

module SceneManager
  #--------------------------------------------------------------------------
  # ● 呼び出し元のシーンクラス判定
  #    メニュー画面のようなスタック式のシーン遷移をした場合の
  #    親シーンの中に指定のシーンが含まれるかを判定します
  #--------------------------------------------------------------------------
  def self.include_stack?(scene_class)
    @stack.any? { |scene| scene.instance_of?(scene_class) }
  end
end
