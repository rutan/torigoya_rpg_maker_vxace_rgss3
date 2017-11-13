# coding: utf-8
#===============================================================================
# ■ 音量変更スクリプトさん for RGSS3
#-------------------------------------------------------------------------------
#　2016/04/23　Ru/むっくRu
#-------------------------------------------------------------------------------
#　全体の音量変更に関する機能を追加します
#
#　● タイトル画面，メニュー画面に音量調整の項目が追加されます
#
#　● Audioモジュールに以下のメソッドが追加されます
#　Audio.bgm_vol …… BGMのマスターボリューム取得
#　Audio.bgs_vol …… BGSのマスターボリューム取得
#　Audio.se_vol  …… SEのマスターボリューム取得
#　Audio.me_vol  …… MEのマスターボリューム取得
#　Audio.bgm_vol=数値 …… BGMのマスターボリューム設定（0～100）
#　Audio.bgs_vol=数値 …… BGSのマスターボリューム設定（0～100）
#　Audio.se_vol=数値  …… SEのマスターボリューム設定（0～100）
#　Audio.me_vol=数値  …… MEのマスターボリューム設定（0～100）
#
#-------------------------------------------------------------------------------
# 【更新履歴】
# 2016/04/23 コードの整理
# 2013/05/25 音量変更項目のタイプを変更するとエラー落ちしていたのを修正
# 2012/12/17 ベーススクリプトが無くても音量を保存できるように．スクリプト整理
# 2012/06/13 デザイン変更．設定項目追加．スクリプトの整理など
# 2012/01/02 Ini読込をHZM_VXAベーススクリプトさん for RGSS3依存に変更
# 2011/12/29 BGS再生時にエラーする不具合を修正
# 2011/12/26 BGM無音時に音量調整をするとエラーする不具合を修正
# 2011/12/13 ini読込との連携を可能に
# 2011/12/01 ぶっぱ
#-------------------------------------------------------------------------------

#===============================================================================
# ● 設定項目
#===============================================================================
module HZM_VXA
  module AudioVol
    # ● タイトル画面に音量調整を表示するか？
    #    ※タイトル画面のメニュー項目を再定義するため，
    #      他にタイトルのメニューをいじるスクリプトを導入する場合は
    #      競合する可能性があります．
    # 　true  …… 表示する
    # 　false …… 表示しない
    TITLE_FLAG = true
    # タイトル画面に表示する項目名
    TITLE_NAME        = "音量設定"

    # ● メニュー画面に音量調整を表示するか？
    # 　true  …… 表示する
    # 　false …… 表示しない
    MENU_FLAG = true
    # メニュー画面に表示する項目名
    MENU_NAME        = "音量設定"

    # ● 音量変更項目のタイプ
    # 　0 …… BGM/BGS/SE/MEすべて一括で設定
    #   1 …… BGM＋BGS と SE＋ME の2種類で設定
    #   2 …… BGM/BGS/SE/ME の4種類それぞれで設定
    TYPE = 2

    # ● 音量設定画面の項目名
    CONFIG_ALL_NAME  = "音量"        # タイプ「0」を選択時に使用されます
    CONFIG_BGM_NAME  = "BGM"         # タイプ「1」「2」を選択時に使用されます
    CONFIG_BGS_NAME  = "BGS"         # タイプ「2」を選択時に使用されます
    CONFIG_SE_NAME   = "SE"          # タイプ「1」「2」を選択時に使用されます
    CONFIG_ME_NAME   = "ME"          # タイプ「2」を選択時に使用されます
    CONFIG_EXIT_NAME = "決定"

    # ● 音量変更の変動量
    ADD_VOL_NORMAL =  5              # 左右キーの変動量
    ADD_VOL_HIGH   = 25              # LRキーの変動量

    # ● 音量設定画面のウィンドウ幅
    WINDOW_WIDTH   = 200

    # ● 音量変更画面の音量ゲージの色
    COLOR1 = Color.new(255, 255, 255)
    COLOR2 = Color.new( 64,  64, 255)

    # ● 音量設定を保存する
    #    Game.ini内に音量情報を保存することで
    #    次回起動時にも音量を反映できるようになります
    #    true  …… 保存する
    #    false …… 保存しない
    USE_INI = true
  end
end

#===============================================================================
# ↑ 　 ここまで設定 　 ↑
# ↓ 以下、スクリプト部 ↓
#===============================================================================

module Audio
  #-----------------------------------------------------------------------------
  # ● 音量設定：BGM（独自）
  #-----------------------------------------------------------------------------
  def self.bgm_vol=(vol)
    @hzm_vxa_audioVol_bgm = self.vol_range(vol)
  end
  #-----------------------------------------------------------------------------
  # ● 音量設定：BGS（独自）
  #-----------------------------------------------------------------------------
  def self.bgs_vol=(vol)
    @hzm_vxa_audioVol_bgs = self.vol_range(vol)
  end
  #-----------------------------------------------------------------------------
  # ● 音量設定：SE（独自）
  #-----------------------------------------------------------------------------
  def self.se_vol=(vol)
    @hzm_vxa_audioVol_se = self.vol_range(vol)
  end
  #-----------------------------------------------------------------------------
  # ● 音量設定：ME（独自）
  #-----------------------------------------------------------------------------
  def self.me_vol=(vol)
    @hzm_vxa_audioVol_me = self.vol_range(vol)
  end
  #-----------------------------------------------------------------------------
  # ● 音量範囲指定
  #-----------------------------------------------------------------------------
  def self.vol_range(vol)
    vol = vol.to_i
    vol < 0 ? 0 : vol < 100 ? vol : 100
  end
  #-----------------------------------------------------------------------------
  # ● 音量取得：BGM（独自）
  #-----------------------------------------------------------------------------
  def self.bgm_vol
    @hzm_vxa_audioVol_bgm ||= 100
  end
  #-----------------------------------------------------------------------------
  # ● 音量取得：BGS（独自）
  #-----------------------------------------------------------------------------
  def self.bgs_vol
    @hzm_vxa_audioVol_bgs ||= 100
  end
  #-----------------------------------------------------------------------------
  # ● 音量取得：SE（独自）
  #-----------------------------------------------------------------------------
  def self.se_vol
    @hzm_vxa_audioVol_se ||= 100
  end
  #-----------------------------------------------------------------------------
  # ● 音量取得：ME（独自）
  #-----------------------------------------------------------------------------
  def self.me_vol
    @hzm_vxa_audioVol_me ||= 100
  end
end

class << Audio
  #-----------------------------------------------------------------------------
  # ● 再生：BGM（エイリアス）
  #-----------------------------------------------------------------------------
  alias hzm_vxa_audioVol_bgm_play bgm_play
  def bgm_play(filename, volume = 100, pitch = 100, pos = 0)
    hzm_vxa_audioVol_bgm_play(filename, self.bgm_vol * volume / 100, pitch, pos)
  end
  #-----------------------------------------------------------------------------
  # ● 再生：BGS（エイリアス）
  #-----------------------------------------------------------------------------
  alias hzm_vxa_audioVol_bgs_play bgs_play
  def bgs_play(filename, volume = 100, pitch = 100, pos = 0)
    hzm_vxa_audioVol_bgs_play(filename, self.bgs_vol * volume / 100, pitch, pos)
  end
  #-----------------------------------------------------------------------------
  # ● 再生：SE（エイリアス）
  #-----------------------------------------------------------------------------
  alias hzm_vxa_audioVol_se_play se_play
  def se_play(filename, volume = 100, pitch = 100)
    hzm_vxa_audioVol_se_play(filename, self.se_vol * volume / 100, pitch)
  end
  #-----------------------------------------------------------------------------
  # ● 再生：ME（エイリアス）
  #-----------------------------------------------------------------------------
  alias hzm_vxa_audioVol_me_play me_play
  def me_play(filename, volume = 100, pitch = 100)
    hzm_vxa_audioVol_me_play(filename, self.me_vol * volume / 100, pitch)
  end
  #-----------------------------------------------------------------------------
  # ● 旧版との互換維持
  #-----------------------------------------------------------------------------
  if true
    alias volBGM bgm_vol
    alias volBGS bgs_vol
    alias volSE se_vol
    alias volME me_vol
    alias volBGM= bgm_vol=
    alias volBGS= bgs_vol=
    alias volSE= se_vol=
    alias volME= me_vol=
  end
end

# タイトル画面に追加
if HZM_VXA::AudioVol::TITLE_FLAG
  class Window_TitleCommand < Window_Command
    if true
      # ↑ この true を false に変更すると，
      #    タイトル画面のメニュー項目を再定義ではなくエイリアスで
      #    追加するようになります．
      #    他のタイトルメニュー拡張系のスクリプトとの競合は起きにくくなりますが，
      #    副作用として，シャットダウンの下に音量設定の項目が追加されます．
      #    必要に合わせて……(・ｘ・)
      #---------------------------------------------------------------------------
      # ● コマンドリストの作成（再定義）
      #---------------------------------------------------------------------------
      def make_command_list
        add_command(Vocab::new_game, :new_game)
        add_command(Vocab::continue, :continue, continue_enabled)
        add_command(HZM_VXA::AudioVol::TITLE_NAME, :hzm_vxa_audioVol)
        add_command(Vocab::shutdown, :shutdown)
      end
    else
      #---------------------------------------------------------------------------
      # ● コマンドリストの作成（エイリアス）
      #---------------------------------------------------------------------------
      alias hzm_vxa_audioVol_make_command_list make_command_list
      def make_command_list
        hzm_vxa_audioVol_make_command_list
        add_command(HZM_VXA::AudioVol::TITLE_NAME, :hzm_vxa_audioVol)
      end
    end
  end
  class Scene_Title < Scene_Base
    #---------------------------------------------------------------------------
    # ● コマンドウィンドウの作成（エイリアス）
    #---------------------------------------------------------------------------
    alias hzm_vxa_audioVol_create_command_window create_command_window
    def create_command_window
      hzm_vxa_audioVol_create_command_window
      @command_window.set_handler(:hzm_vxa_audioVol, method(:hzm_vxa_audioVol_command_config))
    end
    #---------------------------------------------------------------------------
    # ● コマンド［音量調整］（独自）
    #---------------------------------------------------------------------------
    def hzm_vxa_audioVol_command_config
      close_command_window
      SceneManager.call(HZM_VXA::AudioVol::Scene_VolConfig)
    end
  end
end

# メニューに追加
if HZM_VXA::AudioVol::MENU_FLAG
  class Window_MenuCommand
    #---------------------------------------------------------------------------
    # ● 独自コマンドの追加用（エイリアス）
    #---------------------------------------------------------------------------
    alias hzm_vxa_audioVol_add_original_commands add_original_commands
    def add_original_commands
      hzm_vxa_audioVol_add_original_commands
      add_command(HZM_VXA::AudioVol::MENU_NAME, :hzm_vxa_audioVol)
    end
  end
  class Scene_Menu
    #---------------------------------------------------------------------------
    # ● コマンドウィンドウの作成（エイリアス）
    #---------------------------------------------------------------------------
    alias hzm_vxa_audioVol_create_command_window create_command_window
    def create_command_window
      hzm_vxa_audioVol_create_command_window
      @command_window.set_handler(:hzm_vxa_audioVol, method(:hzm_vxa_audioVol_command_config))
    end
    #---------------------------------------------------------------------------
    # ● 音量設定画面呼び出し
    #---------------------------------------------------------------------------
    def hzm_vxa_audioVol_command_config
      SceneManager.call(HZM_VXA::AudioVol::Scene_VolConfig)
    end
  end
end

# 音量変更ウィンドウ
module HZM_VXA
  module AudioVol
    class Window_VolConfig < Window_Command
      #-------------------------------------------------------------------------
      # ● 生成
      #-------------------------------------------------------------------------
      def initialize
        @mode = HZM_VXA::AudioVol::TYPE.to_i
        super(0, 0)
        self.x = (Graphics.width  - self.window_width ) / 2
        self.y = (Graphics.height - self.window_height) / 2
      end
      #-------------------------------------------------------------------------
      # ● コマンドシンボルの取得
      #-------------------------------------------------------------------------
      def command_symbol(index)
        @list[index][:symbol]
      end
      #-------------------------------------------------------------------------
      # ● コマンド拡張データを取得
      #-------------------------------------------------------------------------
      def command_ext(index)
        @list[index][:ext]
      end
      #-------------------------------------------------------------------------
      # ● ウィンドウ幅の取得
      #-------------------------------------------------------------------------
      def window_width
        HZM_VXA::AudioVol::WINDOW_WIDTH
      end
      #--------------------------------------------------------------------------
      # ● アライメントの取得
      #--------------------------------------------------------------------------
      def alignment
        command_symbol(@now_drawing_index) == :cancel ? 1 : 0
      end
      #-------------------------------------------------------------------------
      # ● コマンド生成
      #-------------------------------------------------------------------------
      def make_command_list
        make_command_list_actions
        make_command_list_exit
      end
      #-------------------------------------------------------------------------
      # ● コマンド生成：アクション
      #-------------------------------------------------------------------------
      def make_command_list_actions
        case @mode
        when 0
          add_command(HZM_VXA::AudioVol::CONFIG_ALL_NAME,  :all)
        when 1
          add_command(HZM_VXA::AudioVol::CONFIG_BGM_NAME,  :bgm)
          add_command(HZM_VXA::AudioVol::CONFIG_SE_NAME,   :se)
        else
          add_command(HZM_VXA::AudioVol::CONFIG_BGM_NAME,  :bgm)
          add_command(HZM_VXA::AudioVol::CONFIG_BGS_NAME,  :bgs)
          add_command(HZM_VXA::AudioVol::CONFIG_SE_NAME,   :se)
          add_command(HZM_VXA::AudioVol::CONFIG_ME_NAME,   :me)
        end
      end
      #-------------------------------------------------------------------------
      # ● コマンド生成：キャンセル
      #-------------------------------------------------------------------------
      def make_command_list_exit
        add_command(HZM_VXA::AudioVol::CONFIG_EXIT_NAME, :cancel)
      end
      #-------------------------------------------------------------------------
      # ● 項目の描画
      #-------------------------------------------------------------------------
      def draw_item(index)
        @now_drawing_index = index
        super
        case command_symbol(index)
        when :all, :bgm, :bgs, :se, :me
          draw_item_volume_guage(index)
        end
      end
      #-------------------------------------------------------------------------
      # ● 項目の描画：音量ゲージ
      #-------------------------------------------------------------------------
      def draw_item_volume_guage(index)
        vol =
          case command_symbol(index)
          when :all, :bgm
            Audio.bgm_vol
          when :bgs
            Audio.bgs_vol
          when :se
            Audio.se_vol
          when :me
            Audio.me_vol
          end
        draw_gauge(item_rect_for_text(index).x + 96 - 8, item_rect_for_text(index).y, contents_width - 96, vol/100.0, HZM_VXA::AudioVol::COLOR1, HZM_VXA::AudioVol::COLOR2)
        draw_text(item_rect_for_text(index), vol, 2)
      end
      #-------------------------------------------------------------------------
      # ● 音量増加
      #-------------------------------------------------------------------------
      def vol_add(index, val)
        call_flag = false

        case command_symbol(index)
        when :all
          call_flag = add_vol_bgm(val)
          Audio.bgs_vol = Audio.bgm_vol
          Audio.se_vol = Audio.bgm_vol
          Audio.me_vol = Audio.bgm_vol
        when :bgm
          call_flag = add_vol_bgm(val)
          Audio.bgs_vol = Audio.bgm_vol if @mode == 1
        when :bgs
          call_flag = add_vol_bgs(val)
        when :se
          call_flag = add_vol_se(val)
          Audio.me_vol = Audio.se_vol if @mode == 1
        when :me
          call_flag = add_vol_me(val)
        end

        if call_flag
          Sound.play_cursor
          redraw_item(index)
        end
      end
      def add_vol_bgm(val)
        old = Audio.bgm_vol
        Audio.bgm_vol += val
        if music = RPG::BGM.last and music.name.size > 0
          Audio.bgm_play("Audio/BGM/#{music.name}", music.volume, music.pitch, music.pos)
        end
        Audio.bgm_vol != old
      end
      def add_vol_bgs(val)
        old = Audio.bgs_vol
        Audio.bgs_vol += val
        Audio.bgs_vol != old
      end
      def add_vol_se(val)
        old = Audio.se_vol
        Audio.se_vol += val
        Audio.se_vol != old
      end
      def add_vol_me(val)
        old = Audio.me_vol
        Audio.me_vol += val
        Audio.me_vol != old
      end
      #--------------------------------------------------------------------------
      # ● 決定ボタンが押されたときの処理
      #    ※音量設定欄だったら無視する
      #--------------------------------------------------------------------------
      def process_ok
        case current_symbol
        when :bgm, :bgs, :se, :me
          return
        else
          super
        end
      end
      #-------------------------------------------------------------------------
      # ● キー操作
      #-------------------------------------------------------------------------
      def cursor_left(wrap = false)
        vol_add(@index, -HZM_VXA::AudioVol::ADD_VOL_NORMAL)
      end
      def cursor_right(wrap = false)
        vol_add(@index,  HZM_VXA::AudioVol::ADD_VOL_NORMAL)
      end
      def cursor_pageup
        vol_add(@index, -HZM_VXA::AudioVol::ADD_VOL_HIGH)
      end
      def cursor_pagedown
        vol_add(@index,  HZM_VXA::AudioVol::ADD_VOL_HIGH)
      end
    end
    class Scene_VolConfig < Scene_MenuBase
      #-------------------------------------------------------------------------
      # ● 開始処理
      #-------------------------------------------------------------------------
      def start
        super
        create_help_window
        @command_window = Window_VolConfig.new
        @command_window.viewport = @viewport
        @command_window.set_handler(:cancel,   method(:return_scene))
        @help_window.set_text("ゲームの音量の調整ができます。（0：無音～100:最大）\n←　音量を下げる　／　音量を上げる　→")
      end
      #-------------------------------------------------------------------------
      # ● 終了処理
      #-------------------------------------------------------------------------
      def terminate
        super
        @command_window.dispose
        if HZM_VXA::AudioVol::USE_INI
          HZM_VXA::Ini.save('AudioVol', 'BGM', Audio.bgm_vol)
          HZM_VXA::Ini.save('AudioVol', 'BGS', Audio.bgs_vol)
          HZM_VXA::Ini.save('AudioVol', 'SE', Audio.se_vol)
          HZM_VXA::Ini.save('AudioVol', 'ME', Audio.me_vol)
        end
      end
    end
  end
end

if HZM_VXA::AudioVol::USE_INI
  # ベーススクリプトが導入されてない場合は簡易版で動作
  unless defined?(HZM_VXA::Ini)
    module HZM_VXA
      module Base
        GetPrivateProfileInt = Win32API.new('kernel32', 'GetPrivateProfileInt', %w(p p i p), 'i')
        WritePrivateProfileString = Win32API.new('kernel32', 'WritePrivateProfileString', %w(p p p p), 'i')
      end
      class Ini
        INI_FILENAME = './Game.ini'
        def self.load(section, key)
          HZM_VXA::Base::GetPrivateProfileInt.call(section, key, 100, INI_FILENAME).to_i
        end
        def self.save(section, key, value)
          HZM_VXA::Base::WritePrivateProfileString.call(section, key, value.to_i.to_s, INI_FILENAME) != 0
        end
      end
    end
  end
  # 音量初期値読込
  Audio.bgm_vol = (HZM_VXA::Ini.load('AudioVol', 'BGM') or 100)
  Audio.bgs_vol = (HZM_VXA::Ini.load('AudioVol', 'BGS') or 100)
  Audio.se_vol  = (HZM_VXA::Ini.load('AudioVol', 'SE') or 100)
  Audio.me_vol  = (HZM_VXA::Ini.load('AudioVol', 'ME') or 100)
end
