# encoding: utf-8
#===============================================================================
# ■ キー入力されるまで止まるバトルログ
#-------------------------------------------------------------------------------
# 2019/06/20　Ruたん
#-------------------------------------------------------------------------------
# バトルログのメッセージ切り替え時に
# プレイヤーがキー入力をするまでメッセージを停止する機能を追加します。
#-------------------------------------------------------------------------------
# 【更新履歴】
# 2019/06/20 ベータ版作成
#-------------------------------------------------------------------------------

#===============================================================================
# ● 設定項目
#===============================================================================
module Torigoya
  module BattleLogWaitKey
    module Setting
      # ● キーの押しっぱなしを許可するか？
      #    true : 許可する
      #    false : 許可しない
      REPEATABLE = true

      # ● 効果音の設定
      SE = {
        # 効果音のファイル名（Audio/SE/●● の●●部分）
        name: 'Decision1',

        # 効果音の音量
        volume: 80,

        # 効果音のピッチ
        pitch: 100
      }
    end
  end
end

#===============================================================================
# ↑ 　 ここまで設定 　 ↑
# ↓ 以下、スクリプト部 ↓
#===============================================================================

module Torigoya
  module BattleLogWaitKey
    unless method_defined?(:enabled_plugin?)
      #----------------------------------------------------------------------
      # ● このスクリプトを有効化するか？
      #    ※外部プラグインなどから再定義などされることを想定
      #----------------------------------------------------------------------
      def self.enabled_plugin?
        true
      end
    end

    if Torigoya::BattleLogWaitKey::Setting::REPEATABLE
      #----------------------------------------------------------------------
      # ● キー入力中であるか？（押しっぱなし有効版）
      #----------------------------------------------------------------------
      def self.input?
        Input.repeat?(:A) || Input.repeat?(:B) || Input.repeat?(:C)
      end
    else
      #----------------------------------------------------------------------
      # ● キー入力中であるか？（押しっぱなし無効版）
      #----------------------------------------------------------------------
      def self.input?
        Input.trigger?(:A) || Input.trigger?(:B) || Input.trigger?(:C)
      end
    end
  end
end

class Window_BattleLog < Window_Selectable
  #--------------------------------------------------------------------------
  # ● ウェイト用メソッドの設定（独自）
  #--------------------------------------------------------------------------
  def method_abs_wait=(method)
    @abs_wait = method
  end
  #--------------------------------------------------------------------------
  # ● キー入力まで待機（独自）
  #--------------------------------------------------------------------------
  def wait_input_key
    return unless Torigoya::BattleLogWaitKey.enabled_plugin?
    return unless @abs_wait

    self.pause = true
    loop do
      break if Torigoya::BattleLogWaitKey.input?
      @abs_wait.call(1)
    end
    self.pause = false

    # 決定音の再生
    unless Torigoya::BattleLogWaitKey::Setting::SE[:name].empty?
      Audio.se_play(
        "Audio/SE/#{Torigoya::BattleLogWaitKey::Setting::SE[:name]}",
        Torigoya::BattleLogWaitKey::Setting::SE[:volume],
        Torigoya::BattleLogWaitKey::Setting::SE[:pitch]
      )
    end
  end
  #--------------------------------------------------------------------------
  # ○ 一行戻る
  #--------------------------------------------------------------------------
  alias torigoya_battlelog_wait_key_back_one back_one
  def back_one
    wait_input_key unless @lines.last.empty?
    torigoya_battlelog_wait_key_back_one
  end
  #--------------------------------------------------------------------------
  # ○ 指定した行に戻る
  #--------------------------------------------------------------------------
  alias torigoya_battlelog_wait_key_back_to back_to
  def back_to(line_number)
    wait_input_key
    torigoya_battlelog_wait_key_back_to(line_number)
  end
  #--------------------------------------------------------------------------
  # ○ 文章の置き換え（エイリアス）
  #--------------------------------------------------------------------------
  alias torigoya_battlelog_wait_key_replace_text replace_text
  def replace_text(text)
    wait_input_key unless @lines.last.empty?
    torigoya_battlelog_wait_key_replace_text(text)
  end
  #--------------------------------------------------------------------------
  # ● ウェイトとクリア（再定義）
  #--------------------------------------------------------------------------
  def wait_and_clear
    if Torigoya::BattleLogWaitKey.enabled_plugin?
      wait_input_key if line_number > 0
    else
      wait while @num_wait < 2 if line_number > 0
    end
    clear
  end
end

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ○ ログウィンドウの作成（エイリアス）
  #--------------------------------------------------------------------------
  alias torigoya_battlelog_wait_key_create_log_window create_log_window
  def create_log_window
    torigoya_battlelog_wait_key_create_log_window
    @log_window.method_abs_wait = method(:abs_wait)
  end
end
