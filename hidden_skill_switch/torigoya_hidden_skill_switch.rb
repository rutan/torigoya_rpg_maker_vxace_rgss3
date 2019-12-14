# encoding: utf-8
#===============================================================================
# ■ スイッチでスキル非表示スクリプトさん
#-------------------------------------------------------------------------------
# 2019/12/15　Ruたん
#-------------------------------------------------------------------------------
# 指定のスイッチがONのときに一覧に表示されなくなる（＝使えなくなる）
# スキル・アイテムを作成できるようにします
#
# ＜設定方法＞
# スキルまたはアイテムのメモ欄に以下のように記載してください
#
# <非表示スキル: 1>
#
# 　または
#
# <非表示アイテム: 1>
#
# このように記述することで、
# スイッチID:1がONのときにその項目がリストに表示されなくなります。
# （スイッチIDを変えたい場合は、1の部分を変更してください）
#-------------------------------------------------------------------------------
# 【更新履歴】
# 2019/12/15 作成
#-------------------------------------------------------------------------------

module Torigoya
  module HiddenSkillSwitch
    module Config
      # [上級設定] メモ欄の正規表現
      # 設定方法を変えたい場合はここをいじってください
      NOTE_REGEXP = /<(?:HiddenSkillSwitch|HiddenItemSwitch|非表示スキル|非表示アイテム):\s*(?<switch_id>\d+)\s*>/
    end
  end
end

class RPG::BaseItem
  #--------------------------------------------------------------------------
  # ● スイッチ的にリスト内に表示可能なアイテムであるか？
  #--------------------------------------------------------------------------
  def torigoya_visible_in_list?
    unless instance_variable_defined?(:@torigoya_visible_in_list_switch)
      match = note.match(Torigoya::HiddenSkillSwitch::Config::NOTE_REGEXP)
      @torigoya_visible_in_list_switch = match ? match[:switch_id].to_i : 0
    end
    @torigoya_visible_in_list_switch ? !$game_switches[@torigoya_visible_in_list_switch] : true
  end
end

class Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの使用可能判定（エイリアス）
  #--------------------------------------------------------------------------
  alias torigoya_hidden_skill_switch_usable? usable?
  def usable?(item)
    return false unless torigoya_hidden_skill_switch_usable?(item)
    item.torigoya_visible_in_list?
  end
end

class Window_ItemList < Window_Selectable
  #--------------------------------------------------------------------------
  # ● アイテムをリストに含めるかどうか（エイリアス）
  #--------------------------------------------------------------------------
  alias torigoya_hidden_skill_switch_include? include?
  def include?(item)
    return false unless torigoya_hidden_skill_switch_include?(item)
    item && item.torigoya_visible_in_list?
  end
end

class Window_SkillList < Window_Selectable
  #--------------------------------------------------------------------------
  # ● アイテムをリストに含めるかどうか（エイリアス）
  #--------------------------------------------------------------------------
  alias torigoya_hidden_skill_switch_include? include?
  def include?(item)
    return false unless torigoya_hidden_skill_switch_include?(item)
    item && item.torigoya_visible_in_list?
  end
end
