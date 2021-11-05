object DataModuleNonvisual: TDataModuleNonvisual
  OnCreate = DataModuleCreate
  Height = 500
  Width = 700
  PixelsPerInch = 96
  object BingApiIdHTTP: TIdHTTP
    IOHandler = BingApiIdSSLIOHandlerSocketOpenSSL
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.ContentRangeEnd = -1
    Request.ContentRangeStart = -1
    Request.ContentRangeInstanceLength = -1
    Request.Accept = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    Request.Ranges.Units = 'bytes'
    Request.Ranges = <>
    HTTPOptions = [hoForceEncodeParams]
    Left = 96
    Top = 8
  end
  object BingApiIdSSLIOHandlerSocketOpenSSL: TIdSSLIOHandlerSocketOpenSSL
    MaxLineAction = maException
    Port = 0
    DefaultPort = 0
    SSLOptions.Mode = sslmUnassigned
    SSLOptions.VerifyMode = []
    SSLOptions.VerifyDepth = 0
    Left = 96
    Top = 64
  end
  object BingImageIdHTTP: TIdHTTP
    IOHandler = BingImageIdSSLIOHandlerSocketOpenSSL
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.ContentRangeEnd = -1
    Request.ContentRangeStart = -1
    Request.ContentRangeInstanceLength = -1
    Request.Accept = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    Request.Ranges.Units = 'bytes'
    Request.Ranges = <>
    HTTPOptions = [hoForceEncodeParams]
    Left = 96
    Top = 136
  end
  object BingImageIdSSLIOHandlerSocketOpenSSL: TIdSSLIOHandlerSocketOpenSSL
    MaxLineAction = maException
    Port = 0
    DefaultPort = 0
    SSLOptions.Mode = sslmUnassigned
    SSLOptions.VerifyMode = []
    SSLOptions.VerifyDepth = 0
    Left = 96
    Top = 192
  end
  object TimerShowNow: TTimer
    OnTimer = TimerShowNowTimer
    Left = 600
    Top = 8
  end
  object TrayIconMain: TTrayIcon
    PopupMenu = PopupMenuIcon
    OnClick = TrayIconMainClick
    Left = 360
    Top = 8
  end
  object SavePictureDialogCurr: TSavePictureDialog
    Filter = 'JPEG Image File|*.jpg'
    Title = #20445#23384#24403#21069#22270#29255
    Left = 600
    Top = 64
  end
  object PopupMenuIcon: TPopupMenu
    Left = 360
    Top = 64
    object N1_SHOW: TMenuItem
      Bitmap.Data = {
        36030000424D3603000000000000360000002800000010000000100000000100
        18000000000000030000C40E0000C40E00000000000000000000DBD7D5D0CCC6
        D0CCC6D0CCC6D0CCC6D0CCC6D0CCC6D0CCC6D0CCC6D0CCC6D0CCC6D0CCC6D0CC
        C6D0CCC6D0CCC6DBD7D5D2CDC9EDECE7EDECE7EDECE7EDECE7EDECE7EDECE7ED
        ECE7EDECE7EDECE7EDECE7EDECE7EDECE7EDECE7EDECE7D2CDC9D2CDC9EDECE7
        EDECE7EDECE7EDECE7EDECE7EDECE7EDECE7EDECE7EDECE7EDECE7EDECE7EDEC
        E7EDECE7EDECE7D2CDC9C9C1BD9295648F9B538F9B538F9B538F9B538F9B538F
        9B538F9B538F9B538A9155848D4E848D4E848D4E848D4EC9C1BDC2B9B663503F
        809B2A88AE2588AE2588AE2588AE2588AE2588AE257C912972911A72911A7291
        1A72911A72911AC2B9B6C2B9B6604A42604A4279882F88AE2588AE2588AE2588
        AE257C912972911A72911A72911A72911A72911A72911AC2B9B6C2B9B6604A42
        604A42604A4277823088AE2588AE2579883070881E72911A72911A72911A7291
        1A72911A6B7629C2B9B6C2B9B6604A42604A42604A42604A426F6F3779883060
        4A42635739708B1C72911A72911A72911A6B7629604A42C2B9B6C2B9B6604A42
        604A42604A42604A42604A42604A42604A42604A42635739708B1C72911A6B76
        29604A42604A42C2B9B6C2B9B6604A42604A42604A42604A42604A42604A4260
        4A42604A42604A42645B37676432604A42604A42604A42C2B9B6C2B9B6604A42
        604A425A6B6D558C995D5A57604A42604A42604A42604A42604A42604A42604A
        42604A42604A42C2B9B6C2B9B6604A42604A424BC5E44ACEEF529CAE604A4260
        4A42604A42604A42604A42604A42604A42604A42604A42C2B9B6C2B9B6604A42
        604A424DBEDA4ACEEF56838E604A42604A42604A42604A42604A42604A42604A
        42604A42604A42C2B9B6C2B9B6604A42604A42604A425C6362604A42604A4260
        4A42604A42604A42604A42604A42604A42604A42604A42C2B9B6C2B9B6604A42
        604A42604A42604A42604A42604A42604A42604A42604A42604A42604A42604A
        42604A42604A42C2B9B6D5CFCD91827C91827C91827C91827C91827C91827C91
        827C91827C91827C91827C91827C91827C91827C91827CD5CFCD}
      Caption = #36824#21407
      OnClick = N1_SHOWClick
    end
    object N2_ABOUT: TMenuItem
      Bitmap.Data = {
        36030000424D3603000000000000360000002800000010000000100000000100
        18000000000000030000C40E0000C40E00000000000000000000FFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5F4F1F1F0ED
        F1F0EDF1F0EDF1F0EDF1F0EDF1F0EDF1F0EDF1F0EDF1F0EDF1F0EDF1F0EDF1F0
        EDF1F0EDF1F0EDF5F4F1EDECE7EAE5DFE7DED8EDECE7EDECE7EDECE7EDECE7ED
        ECE7EDECE7B9B0AACFC9C5D9D4D1D9D4D1C6BEBAC9C3BDEDECE7EDECE7D9BDB3
        D3B1A6D9BDB3D3B1A6CEA397D6B8ACEDECE7EDECE76E5B5492827DF5F3F3E1DD
        DB7E6C65958780EDECE7EDECE7EDECE7D6B8ACE7DED8EAE5DFEAE5DFEAE5DFED
        ECE7EDECE76E5B54746059F6F4F4E2DDDC604A42958780EDECE7EDECE7EDECE7
        EDECE7EDECE7EDECE7EDECE7EDECE7EDECE7EDECE76E5B54B0A5A1FFFFFFFFFF
        FF7E6C65958780EDECE7EDECE7DAD7D2E0DFD9E0DFD9DAD7D2E0DFD9E0DFD9E0
        DFD9EDECE76E5B54887771D7D1CFB9AFAC604A42958780EDECE7EDECE7D7D4CE
        D4D1CBD4D1CBE7E5E0D4D1CBD4D1CBDAD7D2EDECE76E5B54604A42604A42604A
        42604A42958780EDECE7EDECE7EDECE7EDECE7EDECE7EDECE7EDECE7EDECE7ED
        ECE7EDECE7E1DDD8DFDBD6DFDBD6DFDBD6DFDBD6E4E1DDEDECE76F675C6F675C
        6F675C6F675C6F675C6F675C6F675C6F675C6F675C6F675C6F675C6F675C6F67
        5C6F675C6F675C6F675C4F45384F45384F45384F45384F45384F45384F45384F
        45384F45384F45384F45384F45384F45384F45384F45384F4538ACA79FACA79F
        ACA79FACA79FACA79FACA79FACA79FACA79FACA79FACA79FACA79FACA79FACA7
        9FACA79FACA79FACA79FF4F3F0F1F1EDF1F1EDF1F1EDF1F1EDF1F1EDF1F1EDF1
        F1EDF1F1EDF1F1EDF1F1EDF1F1EDF1F1EDF1F1EDF1F1EDF4F3F0FFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
      Caption = #20851#20110
      OnClick = N2_ABOUTClick
    end
    object N3_CLOSE: TMenuItem
      Bitmap.Data = {
        36030000424D3603000000000000360000002800000010000000100000000100
        18000000000000030000C40E0000C40E00000000000000000000FFFFFFFFFFFF
        FFFFFFFFFFFFFCFCFBF5F4F1F8F8F6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFBFAF9F5F4F1EFEEEAEDECE7EDECE7F6F5F3FF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE5E4DEEDECE7
        EDECE7EDECE7EDECE7EDECE7B3AFA87A73697A73697A7369FFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFEDECE7EDECE7EDECE7EDECE7EDECE7EDECE79E98904F
        45384F45384F4538FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEDECE7EDECE7
        EDECE7EDECE7EDECE7EDECE79E98904F45384F45384F4538FFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFEDECE7EDECE7EDECE7EDECE7EDECE7EDECE79E98904F
        45384F45384F4538FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEDECE7EDECE7
        EDECE7EDECE7EDECE7EDECE79E98904F45384F45384F4538FFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFEDECE7EDECE7EDECE7EDECE7EDECE7EDECE79E98904F
        45384F45384F4538FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEDECE7EDECE7
        EDECE7EDECE7EDECE7EDECE79E98904F45384F45384F4538FFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFEDECE7EDECE7EDECE7EDECE7EDECE7EDECE79E98904F
        45384F45384F4538FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEDECE7EDECE7
        EDECE7EDECE7EDECE7EDECE79E98904F45384F45384F4538FFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFEDECE7EDECE7EDECE7EDECE7EDECE7EDECE79E98904F
        45384F45384F4538FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEDECE7EDECE7
        EDECE7EDECE7EDECE7EDECE79E98904F45384F45384F4538FFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFEDECE7EDECE7EDECE7EDECE7EDECE7EDECE7948E844F
        45384F45384F4538FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEDECE7EDECE7
        EDECE7BAB7AF938E84635A4E4F45384F45384F45384F4538FFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFC8C6BFA5A098827A727B736A7B736A7B736A7B736A7B
        736A7B736A7B736AFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
      Caption = #36864#20986
      OnClick = N3_CLOSEClick
    end
  end
end
