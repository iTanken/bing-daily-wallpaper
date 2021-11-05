object FormMain: TFormMain
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #27599#26085#24517#24212#26700#38754#22721#32440
  ClientHeight = 460
  ClientWidth = 784
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 15
  object ImageCurrent: TImage
    Left = 0
    Top = 0
    Width = 784
    Height = 441
    Center = True
    ParentShowHint = False
    Proportional = True
    ShowHint = True
    Stretch = True
    OnMouseDown = ImageCurrentMouseDown
    OnMouseEnter = ImageCurrentMouseEnter
    OnMouseLeave = ImageCurrentMouseLeave
    OnMouseMove = ImageCurrentMouseMove
  end
  object ImagePrev: TImage
    Left = 8
    Top = 176
    Width = 64
    Height = 64
    Cursor = crHandPoint
    Hint = #19978#19968#24352
    ParentShowHint = False
    Picture.Data = {
      0954506E67496D61676589504E470D0A1A0A0000000D49484452000000400000
      00400806000000AA6971DE000003B74944415478DAED9B414C13411486DF2C50
      B05EDA44E2CD96783121311A6F9A68397B10CE1E00BD086A442FDE103D711348
      040E463031C6C44B351E3C698917134D0413A317A4E0410FCA168922A5EDF876
      69B72DB674BBFBBA3353FB0EB43BD919DEFFCDDB99B7335306FFB931D10E88B6
      0600D10E88B60600D10E8836E9008427F55EF42A627CB50A39CC63D993F84030
      56B7005078377A739B150ADF611C200619B81ABF189CAF2B00E129BD0F1D99B1
      732FE79040AF7BA8A241388052E2B1A717F0239ABD0C300E4674848A2070E8A2
      8804A100FE15CFD738677DF1C160B4C4BD2378EF8D0248318C822E650194149F
      6191DD7A15EB8C619D2B568D0C1C751B05420038116FD69BD1036CC39C11CCC7
      01A3601CA3604829004EC517D48F62FD33664D0E73F8B8449401E0567CB60D6B
      2C500A008578B39D497D9631E8550A0095F86C5B4BB96449893180587CF154C8
      31212A31654A038054FC1DFD08D3E05DBE29585E1A0C86DDFA583300D4E2D1D3
      97F8EC07ACD60872809A01A8B978807E7CF667297C2507A092787200A1497D42
      D3E0B2E165D6DD9F9C6B0FE383810119C59302E898D6EFA287E77164061CACC0
      DF02EBA934FB914CF33016CDA2E3FDB289270390139FBBD680A53A022CB998C8
      F80B04D882E0A57812003BC503E3FCD689B615BF4F0B0DBFDA80DF5BF97B2B41
      F05ABC6B00E5C477B6379B6F6B4B6B19B00B41847857002A89CF991D08A2C43B
      066057BC1D0822C53B02109E4E8CA2DEEB76C55780F014FF9C1425BE6A00B924
      C79CEA987DF11520584E782DBE2A003B33BC668D6D0E1FF77DB32BBE12041020
      DE3100BF0FD6832D9AAFE7504B6BD781E6AAFF6935B3833400F210F8B8AF495B
      35323CA3ECD2B156501942D58360686AF52C667A0F0ACB5486E0681A2CB59BA3
      2A04C78950BD4070950AD70304D72F43AA4320791D561902D98288AA104897C4
      5484E0C1A2A8DC103C5A1627877013218C480BC0130804DB623505506B081805
      718C820EA901504378B6988299F79BD6B5F49BA3B58070EDC5062C63346401DC
      47007DD203A08430F17613E6BEA47200D438204109E1D1C7243CFEB4A526000A
      08A3AFFFC09BAF697501B881F02BC5E1C2736326D85E45A4C807243A28591942
      61EF9B00543D28B91B8473875BE1F4C1620846CFDF5B48426C2595174F10FEC2
      019483D0EE67D0B9AF09F6EFD5E073220D1FBE67ACB0CFCA5FE36D2C1CEF0F26
      9407500E4279737EE2445A002684ED3DC231C6E05459E998F8C01E18A2E879E9
      001481D0A01B87F848417114AF6394BF14911680D7D60020DA01D1D60020DA01
      D1F6DF03F80B670E106E96DFF30D0000000049454E44AE426082}
    ShowHint = True
    Visible = False
    OnClick = ImagePrevClick
    OnMouseEnter = ImagePrevMouseEnter
  end
  object ImageNext: TImage
    Left = 712
    Top = 176
    Width = 64
    Height = 64
    Cursor = crHandPoint
    Hint = #19979#19968#24352
    ParentShowHint = False
    Picture.Data = {
      0954506E67496D61676589504E470D0A1A0A0000000D49484452000000400000
      00400806000000AA6971DE000003B24944415478DAED9B3F4C135118C0BF8745
      5B18A468181CF49A38F82F81C44117B1BAB868A88389BA480712951871C25957
      0D0E4ADD4013079CEA628C0334318E4430213A98504874109283F80F04FAFCAE
      B4E7F552E85DFBDD7DEFA05F42EE4A2E5FBFDFEFDDBBF7EEEE55C0360FC15D00
      77D4057017C01D7501DC0570876702B4A77A17484818BB966F4BE3FF5E656F44
      B3DCE09E09D006F504661D1056705B48806108C39D6C32BAB0A50420FC8010D0
      E7E4582961024D24B3BDD1892D2100E1FB107EA0041260123719FC335ABA03BF
      ACCB2661010F3AC32981448096D2354C346D415B942012D8D733F6E370F3C82A
      825B028D80417D185BFF9A0905086483DFF4784609540274046A29C03CCBDE8C
      76BB96C624A16601DA13BD4334C00713A442EBAB26A17601293D8E49C64C8830
      44DD0C6FDC12E805B83803549040720D88A5746911904401C36E737049A0BA08
      66B0F8D366E111885533CBE39040350F28ED0612D238125CAC2A97CF12286782
      E659902F1CE7FBD81592AA4BA01330A4B7C0126430617B9024D0DE0C055002FD
      ED30B584D4C21B01F29C25D70FC8899E6C6FCB8892022825E0C5750873744777
      89717D591ECFE791F9AA254AB84221C1BB2742354A28C2173F1FD9B3637A6A7E
      2D2684998B4482A7CF04AB9560873FB0BB01EE7786E1EEE8D2F76FBF726D965C
      354BF0FCA1A85B091BC13787D64BBDF5F60FA9045F9E0A3B955009BE1894127C
      7B2C5E498253786A09BEBE17D84842A110C7F09B4990429E9FB9DEFA5A4901E5
      24485B114EE1CB4990EBF7A4AE264B2C6F868A1270B7BD1678AB84AF3F736DE6
      10E962C6C8F66A0C67782F703E73B5567823C66657E1DDECEA97C9B9B5830505
      8B3227E2CA0A707BC1AB04FF787CB9F8F13DC21F730ACF22C04378305A1E42D0
      39DDD3FAD1690E7F47018FE1DDB4BCEF025484F74D80AAF0BE085019DE7301AA
      C37B2A2008F09E09080ABC270282044F2E2068F0A40210DE58F9713B48F06402
      ECAFC682024F29206D5DF7F3E06C0462284175783A01962532970E35C2E5C33B
      03014F22C0BE44E6DEA9081CDDEBAEF5B9E06904D8FAFFF30B4DAEFA3E27BC27
      02DC9C01DCF024028CB02E91717A0D50019E4C807514686A14F0104781B6A68D
      53AB024F29A0A41B683804F69F0C9795F0F2F30A8C7CFAAB043C99803CB46D31
      8311F1FD2138B12F04CD8D0053F339189D5981B9DFD272042F3CA98082849275
      429B073F3CB980BC04DB3D41597463197D0EBAB9E13D115090A0E1C6F8E144FC
      FF7BC0FC12FA0CEEA4AB5948192801418ABA00EE02B8A32E80BB00EED8F602FE
      019D231F6E9FE6B40F0000000049454E44AE426082}
    ShowHint = True
    Visible = False
    OnClick = ImageNextClick
    OnMouseEnter = ImageNextMouseEnter
  end
  object LabelCopyrightLink: TLabel
    Left = 90
    Top = 442
    Width = 500
    Height = 15
    AutoSize = False
    Caption = 'LabelCopyrightLink'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold, fsUnderline]
    ParentFont = False
  end
  object loading: TProgressBar
    Left = 90
    Top = 422
    Width = 500
    Height = 17
    Position = 1
    Step = 1
    TabOrder = 0
    Visible = False
  end
  object StatusBarBtm: TStatusBar
    Left = 0
    Top = 441
    Width = 784
    Height = 19
    Panels = <
      item
        Alignment = taCenter
        BiDiMode = bdLeftToRight
        ParentBiDiMode = False
        Text = '2021-10-28'
        Width = 90
      end
      item
        Style = psOwnerDraw
        Width = 500
      end
      item
        Alignment = taCenter
        BiDiMode = bdLeftToRight
        ParentBiDiMode = False
        Text = #24403#21069#26102#38388#65306'2021-10-28 09:26:00'
        Width = 180
      end>
    OnDrawPanel = StatusBarBtmDrawPanel
  end
end