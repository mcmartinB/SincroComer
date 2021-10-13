object SSincroMain: TSSincroMain
  OldCreateOrder = False
  DisplayName = 'ServiceSincroComercial'
  OnExecute = ServiceExecute
  Height = 205
  Width = 297
  object tmrTemporizador: TTimer
    Enabled = False
    Interval = 600
    OnTimer = tmrTemporizadorTimer
    Left = 48
    Top = 24
  end
end
