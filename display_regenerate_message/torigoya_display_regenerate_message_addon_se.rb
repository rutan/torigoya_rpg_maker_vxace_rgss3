# encoding: utf-8
#===============================================================================
# ■ バトルログに再生量表示スクリプトアドオン：表示時効果音
#-------------------------------------------------------------------------------
# 2020/12/26　Ruたん
#-------------------------------------------------------------------------------
# このスクリプトは「バトルログに再生量表示スクリプト」の追加アドオンです。
# 「バトルログに再生量表示スクリプト」より下に導入してください。
#-------------------------------------------------------------------------------
# 再生量表示時に効果音を再生します。
#-------------------------------------------------------------------------------
# 【更新履歴】
# 2020/12/26 作成
#-------------------------------------------------------------------------------

class Window_BattleLog < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 回復メッセージの個別表示（エイリアス）
  #--------------------------------------------------------------------------
  alias torigoya_display_regenerate_addon_se_display_regenerate_message_item display_regenerate_message_item
  def display_regenerate_message_item(target, name)
    value = target.result.public_send("#{name}_damage")
    return if value == 0
    if value > 0
      target.actor? ? Sound.play_actor_damage : Sound.play_enemy_damage
    else
      Sound.play_recovery
    end
    torigoya_display_regenerate_addon_se_display_regenerate_message_item(target, name)
  end
end
