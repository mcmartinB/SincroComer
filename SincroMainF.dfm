object FSincroMain: TFSincroMain
  Left = 790
  Top = 230
  Width = 511
  Height = 383
  Caption = '    SINCRONIZAR MAESTROS COMERCIALES'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object btnAlbaranes: TButton
    Left = 16
    Top = 42
    Width = 160
    Height = 25
    Caption = 'Comprobar Albaranes de Venta'
    TabOrder = 0
    OnClick = btnAlbaranesClick
  end
  object btnClose: TButton
    Left = 15
    Top = 10
    Width = 458
    Height = 25
    Caption = 'Cerrar Aplicaci'#243'n'
    TabOrder = 1
    OnClick = btnCloseClick
  end
  object dbgrd1: TDBGrid
    Left = 16
    Top = 95
    Width = 465
    Height = 120
    TabOrder = 2
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
  end
  object dbgrd2: TDBGrid
    Left = 16
    Top = 223
    Width = 465
    Height = 120
    TabOrder = 3
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
  end
  object btnTraerRF: TButton
    Left = 180
    Top = 42
    Width = 145
    Height = 25
    Caption = 'Traer RF'
    TabOrder = 4
    OnClick = btnTraerRFClick
  end
  object btnCobros: TButton
    Left = 328
    Top = 42
    Width = 145
    Height = 25
    Caption = 'Cobros'
    TabOrder = 5
    OnClick = btnCobrosClick
  end
  object btnFacturasX3: TButton
    Left = 16
    Top = 68
    Width = 160
    Height = 25
    Caption = 'Facturas Comercial Vs X3'
    TabOrder = 6
    OnClick = btnFacturasX3Click
  end
  object ds1: TDataSource
    DataSet = DSincroData.qryCentral
    Left = 200
    Top = 112
  end
  object ds2: TDataSource
    DataSet = DSincroData.qryAlmacen
    Left = 216
    Top = 248
  end
end
