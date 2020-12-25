# encoding: utf-8
#===============================================================================
# ■ バトルログに再生量表示スクリプト
#-------------------------------------------------------------------------------
# 2020/12/26　Ruたん
#-------------------------------------------------------------------------------
# このスクリプトはフトコロさんの作成した
# RPGツクールMV用の FTKR_DisplayRegenerateMessage.js を元ネタに作成しています
# https://github.com/futokoro/RPGMaker/blob/master/FTKR_DisplayRegenerateMessage.ja.md
#-------------------------------------------------------------------------------
# ターン終了時に HP / MP / TP の再生量をバトルログに表示するようにします
#-------------------------------------------------------------------------------
# 【更新履歴】
# 2020/12/26 HP以外動いていなかったのを修正(◞‸◟)
# 2019/03/09 作成
#-------------------------------------------------------------------------------

#===============================================================================
# ● 設定項目
#===============================================================================
module Torigoya
  module DisplayRegenerateMessage
    module Template
      HP_MESSAGE = {
        # ● HPが回復したときのメッセージ
        #    %1 … 名前
        #    %2 … ステータス名
        #    %3 … 増えた量
        gain: '%1 の %2 が %3 回復した！',

        # ● HPが減ったときのメッセージ
        #    %1 … 名前
        #    %2 … ステータス名
        #    %3 … 減った量
        lose: '%1 の %2 が %3 減少した！',
      }

      MP_MESSAGE = {
        # ● MPが回復したときのメッセージ
        #    %1 … 名前
        #    %2 … ステータス名
        #    %3 … 増えた量
        gain: '%1 の %2 が %3 回復した！',

        # ● MPが減ったときのメッセージ
        #    %1 … 名前
        #    %2 … ステータス名
        #    %3 … 減った量
        lose: '%1 の %2 が %3 減少した！',
      }

      TP_MESSAGE = {
        # ● TPが回復したときのメッセージ
        #    %1 … 名前
        #    %2 … ステータス名
        #    %3 … 増えた量
        gain: '%1 の %2 が %3 回復した！',

        # ● TPが減ったときのメッセージ
        #    %1 … 名前
        #    %2 … ステータス名
        #    %3 … 減った量
        lose: '%1 の %2 が %3 減少した！',
      }
    end
  end
end

#===============================================================================
# ↑ 　 ここまで設定 　 ↑
# ↓ 以下、スクリプト部 ↓
#===============================================================================

module Torigoya
  module DisplayRegenerateMessage
    class << self
      def in_turn_end_process?
        !!@in_turn_end_process
      end

      def turn_end_process(&block)
        @in_turn_end_process = true
        block.call
        @in_turn_end_process = false
      end

      def generate_message(type, name, value)
        template, status =
          case type
          when :hp
            [Template::HP_MESSAGE, Vocab.hp]
          when :mp
            [Template::MP_MESSAGE, Vocab.mp]
          when :tp
            [Template::TP_MESSAGE, Vocab.tp]
          else
            raise 'must not happen'
          end
        template[value > 0 ? :lose : :gain].gsub('%1', name).gsub('%2', status).gsub('%3', value.abs.to_s)
      end
    end
  end
end

class Window_BattleLog < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 自動で影響を受けたステータスの表示（エイリアス）
  #--------------------------------------------------------------------------
  alias torigoya_display_regenerate_message_display_auto_affected_status display_auto_affected_status
  def display_auto_affected_status(target)
    display_regenerate_message(target) if Torigoya::DisplayRegenerateMessage.in_turn_end_process?
    torigoya_display_regenerate_message_display_auto_affected_status(target)
  end
  #--------------------------------------------------------------------------
  # ● 回復メッセージの表示
  #--------------------------------------------------------------------------
  def display_regenerate_message(target)
    [:hp, :mp, :tp].each do |name|
      method_name = "#{name}_damage"
      next if target.result.public_send(method_name) == 0
      add_text(Torigoya::DisplayRegenerateMessage.generate_message(name, target.name, target.result.public_send(method_name)))
      wait
    end
  end
end

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● ターン終了（エイリアス）
  #--------------------------------------------------------------------------
  alias torigoya_display_regenerate_message_turn_end turn_end
  def turn_end
    Torigoya::DisplayRegenerateMessage.turn_end_process do
      torigoya_display_regenerate_message_turn_end
    end
  end
end
