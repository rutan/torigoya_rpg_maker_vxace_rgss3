# coding: utf-8
#===============================================================================
# ■ [音量変更スクリプトさんアドオン] ボイス設定さん for RGSS3
#-------------------------------------------------------------------------------
#　2022/05/21　Ruたん (ru_shalm)
#-------------------------------------------------------------------------------
#　このスクリプトは「音量変更スクリプトさん for RGSS3」に機能を追加するものです。
#　導入時は「音量変更スクリプトさん」より下に導入してください。
#-------------------------------------------------------------------------------
#　音量変更画面にボイス設定を追加します。
#　また特定フォルダまたはファイル名の効果音をボイス扱いにして再生します。
#-------------------------------------------------------------------------------
# 【更新履歴】
# 2022/05/21 つくってみた
#===============================================================================

#===============================================================================
# ● 設定項目
#===============================================================================
module HZM_VXA
  module AudioVol
    module Voices
      # ● ボイス扱いにする音声ファイルを保存するフォルダ
      #    このフォルダ内の音声はすべてボイス扱いとします
      VOICE_DIRECTORY_NAME = 'Audio/VOICE/'

      # ● ボイス扱いにする効果音ファイルのファイル名の先頭につける識別子
      #    このファイル名の場合は Audio/SE/ 内にあってもボイス扱いとします
      VOICE_SE_PREFIX = '[VC]'

      # ● 音量設定画面の項目名
      CONFIG_VOICE_NAME = 'ボイス'
    end
  end
end

#===============================================================================
# ↑ 　 ここまで設定 　 ↑
# ↓ 以下、スクリプト部 ↓
#===============================================================================

module HZM_VXA
  module AudioVol
    module Voices
      #-------------------------------------------------------------------------
      # ● ボイス用の音声ファイルであるか？
      #-------------------------------------------------------------------------
      def self.voice_file?(filename)
        return true if filename.index(VOICE_DIRECTORY_NAME) == 0
        return true if File.basename(filename).index(VOICE_SE_PREFIX) == 0

        false
      end
    end
  end
end

class << HZM_VXA::AudioVol
  #---------------------------------------------------------------------------
  # ● iniファイルから音量設定を読み込む（エイリアス）
  #---------------------------------------------------------------------------
  alias hzm_vxa_volume_addon_voices_load_from_ini load_from_ini
  def load_from_ini
    hzm_vxa_volume_addon_voices_load_from_ini
    Audio.voice_vol = (HZM_VXA::Ini.load('AudioVol', 'VOICE') || 100)
  end
  #---------------------------------------------------------------------------
  # ● 設定ファイルのデータを反映する（エイリアス）
  #---------------------------------------------------------------------------
  alias hzm_vxa_volume_addon_voices_extract_save_from_file extract_save_from_file
  def extract_save_from_file(data)
    hzm_vxa_volume_addon_voices_extract_save_from_file(data)
    Audio.voice_vol = (data['voice'] || 100).to_i
  end
  #---------------------------------------------------------------------------
  # ● iniファイルに音量設定を書き込む（エイリアス）
  #---------------------------------------------------------------------------
  alias hzm_vxa_volume_addon_voices_save_to_ini save_to_ini
  def save_to_ini
    hzm_vxa_volume_addon_voices_save_to_ini
    HZM_VXA::Ini.save('AudioVol', 'VOICE', Audio.voice_vol)
  end
  #---------------------------------------------------------------------------
  # ● 設定値を設定ファイルのデータ化する（エイリアス）
  #---------------------------------------------------------------------------
  alias hzm_vxa_volume_addon_voices_make_save_for_file make_save_for_file
  def make_save_for_file
    hzm_vxa_volume_addon_voices_make_save_for_file.tap do |data|
      data['voice'] = Audio.voice_vol
    end
  end
end

module Audio
  #-----------------------------------------------------------------------------
  # ● 音量取得：ボイス（独自）
  #-----------------------------------------------------------------------------
  def self.voice_vol
    @hzm_vxa_audioVol_voice ||= 100
  end
  #-----------------------------------------------------------------------------
  # ● 音量設定：ボイス（独自）
  #-----------------------------------------------------------------------------
  def self.voice_vol=(vol)
    @hzm_vxa_audioVol_voice = self.vol_range(vol)
  end
end

class << Audio
  #-----------------------------------------------------------------------------
  # ○ 再生：SE（エイリアス）
  #-----------------------------------------------------------------------------
  alias hzm_vxa_volume_addon_voices_se_play se_play
  def se_play(filename, volume = 100, pitch = 100)
    if HZM_VXA::AudioVol::Voices.voice_file?(filename)
      hzm_vxa_audioVol_se_play(filename, volume * self.voice_vol, pitch)
    else
      hzm_vxa_volume_addon_voices_se_play(filename, volume, pitch)
    end
  end

  # voice_play という名のメソッドが定義されている場合は上書きする
  if defined?(:voice_play)
    #---------------------------------------------------------------------------
    # ○ 再生：ボイス（エイリアス）
    #---------------------------------------------------------------------------
    alias hzm_vxa_volume_addon_voices_voice_play voice_play
    def voice_play(filename, volume = 100, pitch = 100)
      hzm_vxa_volume_addon_voices_voice_play(filename, volume * self.voice_vol, pitch)
    end
  end
end

# 音量変更ウィンドウ
module HZM_VXA
  module AudioVol
    class Window_VolConfig < Window_Command
      #-------------------------------------------------------------------------
      # ● コマンド生成：アクション（エイリアス）
      #-------------------------------------------------------------------------
      alias hzm_vxa_volume_addon_voices_make_command_list_actions make_command_list_actions
      def make_command_list_actions
        hzm_vxa_volume_addon_switches_make_command_list_actions
        add_command(HZM_VXA::AudioVol::Voices::CONFIG_VOICE_NAME, :voice) if @mode == 2
      end
      #-------------------------------------------------------------------------
      # ● 項目の描画（エイリアス）
      #-------------------------------------------------------------------------
      alias hzm_vxa_volume_addon_voices_draw_item draw_item
      def draw_item(index)
        hzm_vxa_volume_addon_voices_draw_item(index)

        if command_symbol(index) == :voice
          draw_item_volume_guage(index, Audio.voice_vol)
        end
      end
      #-------------------------------------------------------------------------
      # ● 音量増加（エイリアス）
      #-------------------------------------------------------------------------
      alias hzm_vxa_volume_addon_voices_vol_add vol_add
      def vol_add(index, val)
        hzm_vxa_volume_addon_voices_vol_add(index, val)

        case command_symbol(index)
        when :all
          Audio.voice_val = Audio.bgm_vol
        when :se
          Audio.voice_vol = Audio.se_vol if @mode == 1
        when :voice
          old_volume = Audio.voice_vol
          Audio.voice_vol += val
          if old_volume != Audio.voice_vol
            Sound.play_cursor
            redraw_item(index)
          end
        end
      end
    end
  end
end
