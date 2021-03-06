object FrmEnvironment: TFrmEnvironment
  Left = 209
  Top = 184
  Width = 347
  Height = 186
  BorderIcons = [biSystemMenu]
  Caption = '参数设置'
  Color = clBtnFace
  Font.Charset = GB2312_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = '宋体'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 339
    Height = 159
    Align = alClient
    BevelInner = bvLowered
    BorderWidth = 2
    TabOrder = 0
    object DRLabel1: TDRLabel
      Left = 16
      Top = 32
      Width = 72
      Height = 12
      Caption = '数据库路径：'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = '宋体'
      Font.Style = []
      ParentFont = False
      HiColor = clBlue
      LoColor = clNavy
      Border = boNone
      Ctl3D = True
      BlinkInterval = 300
      Blink = blNone
      Deep = 1
    end
    object DRLabel2: TDRLabel
      Left = 16
      Top = 80
      Width = 72
      Height = 12
      Caption = '输入法选择：'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = '宋体'
      Font.Style = []
      ParentFont = False
      HiColor = clBlue
      LoColor = clNavy
      Border = boNone
      Ctl3D = True
      BlinkInterval = 300
      Blink = blNone
      Deep = 1
    end
    object DRLabel3: TDRLabel
      Left = 16
      Top = 56
      Width = 72
      Height = 12
      Caption = 'SPLASH图像：'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = '宋体'
      Font.Style = []
      ParentFont = False
      HiColor = clBlue
      LoColor = clNavy
      Border = boNone
      Ctl3D = True
      BlinkInterval = 300
      Blink = blNone
      Deep = 1
    end
    object BBtnOK: TBitBtn
      Left = 212
      Top = 112
      Width = 100
      Height = 30
      Caption = '确定'
      TabOrder = 0
      OnClick = BBtnOKClick
    end
    object BBtnCancel: TBitBtn
      Left = 28
      Top = 112
      Width = 100
      Height = 30
      Caption = '取消'
      TabOrder = 1
      OnClick = BBtnCancelClick
    end
    object EdtDBFPath: TEditN
      Left = 88
      Top = 28
      Width = 225
      Height = 20
      Color = clSilver
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = '宋体'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 2
      ColorOnFocus = clWhite
      ColorOnNotFocus = clSilver
      FontColorOnFocus = clRed
      FontColorOnNotFocus = clBlack
      FontColorOnOverWrite = clBlue
      EditType = etString
      EditKeyByTab = #13
      EditAlign = etAlignNone
      EditLengthAlign = 0
      EditPrecision = 0
      ValueInteger = 0
      ValueDate = 36910
      ValueTime = 0.624175462962963
      TimeSeconds = False
      FirstCharUpper = False
      FirstCharUpList = ' ('
      WidthOnFocus = 0
      TextHint = True
    end
    object CmbIMEName: TComboBox
      Left = 88
      Top = 76
      Width = 225
      Height = 20
      Style = csDropDownList
      Color = clSilver
      ItemHeight = 12
      TabOrder = 3
      OnEnter = CmbIMENameEnter
      OnExit = CmbIMENameExit
    end
    object BitBtn1: TBitBtn
      Left = 293
      Top = 30
      Width = 18
      Height = 17
      Caption = '...'
      TabOrder = 4
      OnClick = BitBtn1Click
    end
    object EdtSplash: TEditN
      Left = 88
      Top = 52
      Width = 225
      Height = 20
      Color = clSilver
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = '宋体'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 5
      ColorOnFocus = clWhite
      ColorOnNotFocus = clSilver
      FontColorOnFocus = clRed
      FontColorOnNotFocus = clBlack
      FontColorOnOverWrite = clBlue
      EditType = etString
      EditKeyByTab = #13
      EditAlign = etAlignNone
      EditLengthAlign = 0
      EditPrecision = 0
      ValueInteger = 0
      ValueDate = 36910
      ValueTime = 0.624175462962963
      TimeSeconds = False
      FirstCharUpper = False
      FirstCharUpList = ' ('
      WidthOnFocus = 0
      TextHint = True
    end
    object BBtnSplash: TBitBtn
      Left = 293
      Top = 54
      Width = 18
      Height = 17
      Caption = '...'
      Enabled = False
      TabOrder = 6
      OnClick = BBtnSplashClick
    end
  end
  object OpenPictureDialog1: TOpenPictureDialog
    DefaultExt = '*.jpg;*.bmp'
    InitialDir = 'c:\windows'
    Title = '请选择图像文件：'
    Left = 40
    Top = 8
  end
  object BrowseDirectoryDlg1: TBrowseDirectoryDlg
    ShowSelectionInStatus = False
    Left = 72
    Top = 8
  end
end
