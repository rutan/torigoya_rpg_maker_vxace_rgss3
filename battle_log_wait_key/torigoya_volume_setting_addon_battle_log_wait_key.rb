# encoding: utf-8
#===============================================================================
# ■ 音量変更スクリプトさんアドオン for キー入力されるまで止まるバトルログ
#-------------------------------------------------------------------------------
# 2019/06/21　Ruたん
#-------------------------------------------------------------------------------
# 「音量変更スクリプトさん」に
# 『キー入力されるまで止まるバトルログ』のON/OFF設定を追加します
#
# このスクリプトは「音量変更スクリプトさん」より下に導入してください。
#-------------------------------------------------------------------------------
# 【更新履歴】
# 2019/06/21 ベータ版作成
#===============================================================================

#===============================================================================
# ● 設定項目
#===============================================================================
module Torigoya
  module VolumeSetting
    module AddonBattleLogWaitKey
      # ● オプション項目名
      NAME = '戦闘ログ'

      # ● 有効時（キー入力されるまで停止）
      ENABLE = 'ウェイト'

      # ● 有効時（キー入力しなくても進む）
      DISABLE = 'スキップ'
    end
  end
end

#===============================================================================
# ↑ 　 ここまで設定 　 ↑
# ↓ 以下、スクリプト部 ↓
#===============================================================================

module Torigoya
  module VolumeSetting
    module AddonBattleLogWaitKey
      class << self
        attr_accessor :enable_flag
      end
    end
  end
end

module Torigoya
  module BattleLogWaitKey
    #----------------------------------------------------------------------
    # ● このスクリプトを有効化するか？
    #----------------------------------------------------------------------
    def self.enabled_plugin?
        Torigoya::VolumeSetting::AddonBattleLogWaitKey.enable_flag
    end
  end
end

# 音量変更スクリプトさん
if defined?(HZM_VXA) && defined?(HZM_VXA::AudioVol)
  module HZM_VXA
    module AudioVol
      class Window_VolConfig < Window_Command
        #-------------------------------------------------------------------------
        # ○ 項目の描画（エイリアス）
        #-------------------------------------------------------------------------
        alias hzm_vxa_volume_addon_battle_log_wait_key_draw_item draw_item
        def draw_item(index)
          hzm_vxa_volume_addon_battle_log_wait_key_draw_item(index)
          return unless command_symbol(index) == :battle_log_wait_key
          str =
            Torigoya::VolumeSetting::AddonBattleLogWaitKey.enable_flag ?
              Torigoya::VolumeSetting::AddonBattleLogWaitKey::ENABLE :
              Torigoya::VolumeSetting::AddonBattleLogWaitKey::DISABLE
          draw_text(item_rect_for_text(index), str, 2)
        end
        #-------------------------------------------------------------------------
        # ○ コマンド生成：アクション（エイリアス）
        #-------------------------------------------------------------------------
        alias hzm_vxa_volume_addon_battle_log_wait_key_make_command_list_actions make_command_list_actions
        def make_command_list_actions
          hzm_vxa_volume_addon_battle_log_wait_key_make_command_list_actions
          add_command(Torigoya::VolumeSetting::AddonBattleLogWaitKey::NAME, :battle_log_wait_key)
        end
        #--------------------------------------------------------------------------
        # ○ 決定ボタンが押されたときの処理（エイリアス）
        #--------------------------------------------------------------------------
        alias hzm_vxa_volume_addon_battle_log_wait_key_process_ok process_ok
        def process_ok
          puts current_symbol
          if current_symbol == :battle_log_wait_key
            process_addon_battle_log_wait_key
          else
            hzm_vxa_volume_addon_battle_log_wait_key_process_ok
          end
        end
        #-------------------------------------------------------------------------
        # ● 設定変更（独自）
        #-------------------------------------------------------------------------
        def process_addon_battle_log_wait_key
          Torigoya::VolumeSetting::AddonBattleLogWaitKey.enable_flag =
            !Torigoya::VolumeSetting::AddonBattleLogWaitKey.enable_flag
          Sound.play_ok
          refresh
        end
      end

      class Scene_VolConfig < Scene_MenuBase
        #-------------------------------------------------------------------------
        # ○ 終了処理（エイリアス）
        #-------------------------------------------------------------------------
        alias hzm_vxa_volume_addon_battle_log_wait_key_terminate terminate
        def terminate
          hzm_vxa_volume_addon_battle_log_wait_key_terminate
          Torigoya::VolumeSetting::AddonBattleLogWaitKey.save
        end
      end
    end
  end

  module Torigoya
    module VolumeSetting
      module AddonBattleLogWaitKey
        SAVE_SECTION_NAME = 'Addon'
        SAVE_KEY_NAME = 'BattleLogWaitKey'
        SAVE_FILE_NAME = 'battle_log_wait_key.rvdata2'

        class << self
          def save
            value = Torigoya::VolumeSetting::AddonBattleLogWaitKey.enable_flag ? 1 : 0
            if HZM_VXA::AudioVol::USE_INI
              HZM_VXA::Ini.save(SAVE_SECTION_NAME, SAVE_KEY_NAME, value)
            elsif HZM_VXA::AudioVol::USE_SAVE
              File.open(SAVE_FILE_NAME, 'wb') do |file|
                Marshal.dump({value: value}, file)
              end
            end
          end
          def load
            value =
              if HZM_VXA::AudioVol::USE_INI
                HZM_VXA::Ini.load(SAVE_SECTION_NAME, SAVE_KEY_NAME, value) || 1
              elsif HZM_VXA::AudioVol::USE_SAVE
                begin
                  File.open(SAVE_FILE_NAME, 'rb') do |file|
                    config = Marshal.load(file)
                    config[:value]
                  end
                rescue
                  1
                end
              else
                1
              end
            Torigoya::VolumeSetting::AddonBattleLogWaitKey.enable_flag = (value != 0)
          end
        end
      end
    end
  end

  # 起動時に読み込み
  Torigoya::VolumeSetting::AddonBattleLogWaitKey.load
end
