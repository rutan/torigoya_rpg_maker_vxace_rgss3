# coding: utf-8
#===============================================================================
# ■ HZM_VXAベーススクリプトさん for RGSS3
#-------------------------------------------------------------------------------
#　2012/08/01　Ru/むっくRu
#-------------------------------------------------------------------------------
#  他スクリプトを使用する際のベースとなるスクリプトです．
#  基本的にはこれ単体で何かが起こるわけでは無いです．
#-------------------------------------------------------------------------------
# 【更新履歴】
# 2012/08/01 [2.1.0] mkdir_p 追加
# 2012/08/01 【重要】仕様変更．メソッド名変更．ディレクトリ取得追加
# 2012/02/11 fps表示時にウィンドウハンドルを取得できない不具合を修正
# 2012/01/07 フルスクリーン時にウィンドウ拡大するとやばいことになる超不具合を修正
# 2012/01/02 ぶっぱ
#-------------------------------------------------------------------------------

#===============================================================================
# ↓ 以下、スクリプト部 ↓
#===============================================================================

module HZM_VXA
  module Base
    #---------------------------------------------------------------------------
    # ● ベーススクリプトのバージョン
    #    .区切りの3つの数字で表現
    #    1桁目：メジャーバージョン（仕様変更＝互換性破たん時に変更）
    #    2桁目：マイナーバージョン（機能追加時に変更）
    #    3桁目：パッチバージョン（不具合修正時に変更）
    #---------------------------------------------------------------------------
    VERSION = '2.1.0'
    #---------------------------------------------------------------------------
    # ● バージョン比較処理
    #---------------------------------------------------------------------------
    def self.check_version?(version_str)
      version     = version2array(VERSION)
      req_version = version2array(version_str)
      # メジャーバージョンが要求と一致するか？
      return false unless version[0] == req_version[0]
      # マイナーバージョンが要求より低くないか？
      return false unless version[1] >= req_version[1]
      true
    end
    #---------------------------------------------------------------------------
    # ● バージョン文字列の分解
    #---------------------------------------------------------------------------
    def self.version_to_array(version_str)
      version_str.split('.').map{|n| n.to_i}
    end
    #---------------------------------------------------------------------------
    # ● Win32API用意
    #---------------------------------------------------------------------------
    # ウィンドウハンドル取得
    FindWindow = Win32API.new('user32', 'FindWindow', %w(p p), 'l')
    # 文字コード変換
    MultiByteToWideChar = Win32API.new('kernel32', 'MultiByteToWideChar', %w(i i p i p i), 'i')
    WideCharToMultiByte = Win32API.new('kernel32', 'WideCharToMultiByte', %w(i i p i p i p p), 'i')
    # ini読込
    GetPrivateProfileString = Win32API.new('kernel32', 'GetPrivateProfileString', %w(p p p p i p), 'i')
    WritePrivateProfileString = Win32API.new('kernel32', 'WritePrivateProfileString', %w(p p p p), 'i')
    # ウィンドウサイズ操作
    GetWindowRect = Win32API.new('user32', 'GetWindowRect', %w(l p), 'i')
    MoveWindow = Win32API.new('user32', 'MoveWindow', %w(l i i i i i), 'i')
    GetClientRect = Win32API.new('user32', 'GetClientRect', %w(l p), 'i')
    # 関連付けされたプログラム起動
    ShellExecute = Win32API.new('shell32', 'ShellExecute', %w(p p p p p i), 'i')
    # ディレクトリ取得
    GetCurrentDirectory = Win32API.new('kernel32', 'GetCurrentDirectory', %(l p), 'i')
    SHGetFolderPath = Win32API.new('shell32', 'SHGetFolderPath', %(l i l i p), 'i')
    # ユーザ名取得
    GetUserName = Win32API.new('Advapi32', 'GetUserName', %w(p p), 'i')
    #---------------------------------------------------------------------------
    # ● Win32API用定数
    #---------------------------------------------------------------------------
    CP_ACP   = 0
    CP_UTF8  = 65001
    SW_SHOW  = 5
    MAX_PATH = 260
    #---------------------------------------------------------------------------
    # ● ウィンドウハンドルの取得
    #---------------------------------------------------------------------------
    def self.hwnd
      return @hwnd if @hwnd
      hwnd = FindWindow.call('RGSS Player', convUTF8toSJIS($data_system.game_title))
      return @hwnd = hwnd if hwnd != 0
      hwnd = FindWindow.call('RGSS Player', nil)
      (hwnd != 0 ? hwnd : nil)
    end
    #---------------------------------------------------------------------------
    # ● 文字コードの変換
    #    Win32APIはSJISじゃないといけないのでutf8と相互変換する
    #---------------------------------------------------------------------------
    def self.convert_sjis_to_utf8(str)
      convert_utf16_to_utf8(convert_sjis_to_utf16(str))
    end
    def self.convert_utf8_to_sjis(str)
      convert_utf16_to_sjis(convert_utf8_to_utf16(str))
    end
    def self.convert_sjis_to_utf16(str)
      length = MultiByteToWideChar.call(CP_ACP, 0, str, -1, nil, 0)
      buf = "\0" * (length * 2)
      MultiByteToWideChar.call(CP_ACP, 0, str, -1, buf, length)
      buf
    end
    def self.convert_utf16_to_utf8(str)
      length = WideCharToMultiByte.call(CP_UTF8, 0, str, -1, nil, 0, nil, nil)
      buf = "\0" * (length * 2)
      WideCharToMultiByte.call(CP_UTF8, 0, str, -1, buf, length, nil, nil)
      buf
    end
    def self.convert_utf8_to_utf16(str)
      length = MultiByteToWideChar.call(CP_UTF8, 0, str, -1, nil, 0)
      buf = "\0" * (length * 2)
      MultiByteToWideChar.call(CP_UTF8, 0, str, -1, buf, length)
      buf
    end
    def self.convert_utf16_to_sjis(str)
      length = WideCharToMultiByte.call(CP_ACP, 0, str, -1, nil, 0, nil, nil)
      buf = "\0" * (length * 2)
      WideCharToMultiByte.call(CP_ACP, 0, str, -1, buf, length, nil, nil)
      buf
    end
    #---------------------------------------------------------------------------
    # ● ウィンドウ表示倍率の変更
    #---------------------------------------------------------------------------
    def self.window_zoom(n = 1.0)
      return false unless n > 0
      return false unless hwnd = getHwnd
      return false if fullscreen?
      # 元の位置を確認しておく
      lp_rect = "\0" * 4 * 4
      return false if GetWindowRect.call(hwnd, lp_rect) == 0
      rect = lp_rect.unpack('llll')
      base_x = rect[0]
      base_y = rect[1]
      # ウィンドウサイズを一度もとに戻す
      base_w = Graphics.width
      base_h = Graphics.height
      Graphics.resize_screen((base_w < 640 ? base_w + 1 : base_w - 1), (base_h < 480 ? base_h + 1 : base_h - 1))
      Graphics.resize_screen(base_w, base_h)
      # ウィンドウの大きさを変更する
      return false if GetWindowRect.call(hwnd, lp_rect) == 0
      rect = lp_rect.unpack('llll')
      bw = (rect[2] - rect[0]) - Graphics.width
      bh = (rect[3] - rect[1]) - Graphics.height
      w = (Graphics.width * n).to_i
      h = (Graphics.height * n).to_i
      return MoveWindow.call(hwnd, base_x, base_y, w + bw, h + bh, 0) != 0
    end
    #---------------------------------------------------------------------------
    # ● フルスクリーンかどうか？
    #---------------------------------------------------------------------------
    def self.fullscreen?
      return false unless hwnd = getHwnd
      lp_rect1 = "\0" * 4 * 4
      lp_rect2 = "\0" * 4 * 4
      return false if GetClientRect.call(hwnd, lp_rect1) == 0 # 表示領域の大きさ
      return false if GetWindowRect.call(hwnd, lp_rect2) == 0 # ウィンドウの大きさ
      rect1 = lp_rect1.unpack('llll')
      rect2 = lp_rect2.unpack('llll')
      (rect1[2] - rect1[0] == rect2[2] - rect2[0] || rect1[3] - rect1[1] == rect2[3] - rect2[1])
    end
    #---------------------------------------------------------------------------
    # ● 関連付けされたプログラムで開く
    #---------------------------------------------------------------------------
    def self.open_program(path)
      ShellExecute.call(getHwnd, 'open', path, nil, nil, SW_SHOW) > 32
    end
    def self.open_browser(url)
      openProgram(url)
    end
    #---------------------------------------------------------------------------
    # ● URLエンコード
    #---------------------------------------------------------------------------
    def self.url_encode(str)
      ret = []
      str.each_byte { |s| ret.push "%#{s.to_s(16)}" }
      ret.join
    end
    #---------------------------------------------------------------------------
    # ● AppData取得
    #---------------------------------------------------------------------------
    def self.appdata_path
      buf = "\0" * (MAX_PATH + 1)
      SHGetFolderPath.call(0, 0x001a, 0, 0, buf)
      buf.strip
    end
    #---------------------------------------------------------------------------
    # ● ログインユーザ名取得
    #---------------------------------------------------------------------------
    def self.user_name
      str = "\0" * 257
      len = [256].pack('i')
      return nil unless GetUserName.call(str, len) != 0
      convert_sjis_to_utf8(str.strip)
    end
    #---------------------------------------------------------------------------
    # ● 再帰的なディレクトリ作成
    #---------------------------------------------------------------------------
    def self.mkdir_p(path)
      return if File.exist?(path)
      mkdir_p(File.dirname(path))
      Dir.mkdir(path)
    end
  end
  class << Base
    # 互換用エイリアス
    alias version2array version_to_array
    alias getHwnd hwnd
    alias convSJIStoUTF8 convert_sjis_to_utf8
    alias convUTF8toSJIS convert_utf8_to_sjis
    alias windowZoom window_zoom
    alias openProgram open_program
    alias openBrowser open_browser
    alias urlEncode url_encode
    alias getAppDataPath appdata_path
  end
  module Input
    #---------------------------------------------------------------------------
    # ● Win32API用意
    #---------------------------------------------------------------------------
    GetKeyboardState = Win32API.new('user32', 'GetKeyboardState', %w(p), 'i')
    #---------------------------------------------------------------------------
    # ● 更新
    #---------------------------------------------------------------------------
    def self.update
      buf = "\0" * 256
      ret = GetKeyboardState.call(buf)
      return clear if ret == 0
      buf = buf.unpack('c*')
      buf.each_with_index do |data, i|
        if data < 0
          @press[i] += 1
          if @press[i] == 1
            @repeat[i] = wait1
            @repeat_flag[i] = true
          else
            @repeat_flag[i] = (@repeat[i] <= 0)
            @repeat[i] = (@repeat_flag[i] ? wait2 : @repeat[i] - 1)
          end
        else
          @press[i] = 0
          @repeat[i] = 0
          @repeat_flag[i] = false
        end
      end
    end
    #---------------------------------------------------------------------------
    # ● 押し続け状態
    #---------------------------------------------------------------------------
    def self.press?(n)
      @press[n] > 0
    end
    def self.press(n)
      @press[n]
    end
    #---------------------------------------------------------------------------
    # ● トリガー
    #---------------------------------------------------------------------------
    def self.trigger?(n)
      @press[n] == 1
    end
    #---------------------------------------------------------------------------
    # ● 繰り返し
    #---------------------------------------------------------------------------
    def self.repeat?(n)
      @repeat_flag[n]
    end
    #---------------------------------------------------------------------------
    # ● 入力状態を消去
    #---------------------------------------------------------------------------
    def self.clear
      @press = Array.new(256) unless @press
      @repeat = Array.new(256) unless @repeat
      @repeat_flag = Array.new(256) unless @repeat_flag
      for i in 0...255
        @press[i] = 0
        @repeat[i] = 0
        @repeat_flag[i] = false
      end
    end
    #---------------------------------------------------------------------------
    # ● repeat?のウェイト時間
    #---------------------------------------------------------------------------
    def self.wait1
      20
    end
    def self.wait2
      5
    end
    #---------------------------------------------------------------------------
    # ● 初期化処理実行
    #---------------------------------------------------------------------------
    self.clear
  end
  #-----------------------------------------------------------------------------
  # ■ INIファイル読込クラス
  #-----------------------------------------------------------------------------
  class Ini
    #---------------------------------------------------------------------------
    # ● 定数
    #---------------------------------------------------------------------------
    INI_FILENAME = './Game.ini'
    #---------------------------------------------------------------------------
    # ● 生成
    #---------------------------------------------------------------------------
    def initialize(filename)
      @filename = filename
    end
    #---------------------------------------------------------------------------
    # ● 読込
    #    戻り値：読み込んだ情報．数値の場合は自動的に型変換します．
    #  section …… セクション名（[]の見出し的な部分）
    #  key     …… キー名（●●=値　の●●部分）
    #  length  …… データの最大の長さ（半角）省略時は255文字
    #---------------------------------------------------------------------------
    def load(section, key, length = 255)
      buf = "\0" * length
      ret = HZM_VXA::Base::GetPrivateProfileString.call(section, key, "", buf, length, @filename)
      if ret > 0
        ret = HZM_VXA::Base.convSJIStoUTF8(buf).delete("\0")
        (ret =~ /^\d+$/ ? ret.to_i : (ret =~ /^\d+\.\d+$/ ? ret.to_f : ret.to_s))
      else
        nil
      end
    end
    #---------------------------------------------------------------------------
    # ● 保存
    #  section …… セクション名（[]の見出し的な部分）
    #  key     …… キー名（●●=値　の●●部分）
    #  value   …… 保存する情報（数値 or 文字列）
    #---------------------------------------------------------------------------
    def save(section, key, value)
      value = HZM_VXA::Base.convUTF8toSJIS(value.to_s)
      HZM_VXA::Base::WritePrivateProfileString.call(section, key, value, @filename) != 0
    end
    #---------------------------------------------------------------------------
    # ● クラス変数・メソッド群
    #    標準のgame.iniを編集する
    #---------------------------------------------------------------------------
    @@ini = Ini.new(INI_FILENAME)
    def self.load(section, key, length = 255)
      @@ini.load(section, key, length)
    end
    def self.save(section, key, value)
      @@ini.save(section, key, value)
    end
  end
end

# キー入力処理拡張
# ※使用しない場合はfalseにする
if true
  class << Input
    alias hzm_vxa_base_update update
    def update
      hzm_vxa_base_update
      HZM_VXA::Input.update
    end
  end
end
