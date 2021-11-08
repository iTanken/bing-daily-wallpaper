program BingWallpaper;

uses
  System.SysUtils,
  Vcl.Forms,
  NonVisualModule
    in 'DataModule\NonVisualModule.pas' {ModuleNonvisual: TDataModule} ,
  uMain in 'uMain.pas' {FormMain} ,
  uTools in 'Util\uTools.pas',
  ABOUT in 'Form\ABOUT.pas' {AboutBox} ,
  uFormSplash in 'Form\uFormSplash.pas' {FormSplash};

var
  i: Integer;

{$R *.res}

begin

  if ParamCount > 0 then
  begin
    // 传入指定命令行参数，显示相关信息
    if (ParamStr(1) = '-h') or (ParamStr(1) = '--help') then
    begin
      // 显示帮助信息
      uTools.AlertInfo(Concat('-h  --help    显示帮助信息', uTools.BR,
        '-t  --today   直接设置今天的壁纸', uTools.BR, '-v  --version 显示应用程序版本信息'));
      Exit;
    end;
    if (ParamStr(1) = '-v') or (ParamStr(1) = '--version') then
    begin
      // 显示版本信息
      uTools.AlertInfo(Concat('v', uTools.GetApplicationVersion));
      Exit;
    end;
  end;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;

  // 创建启动欢迎闪屏
  FormSplash := TFormSplash.Create(nil);
  FormSplash.Show;
  FormSplash.Update;

  FormSplash.SetText('必应每日桌面壁纸工具启动中，请稍后');
  for i := 0 to 5 do
  begin
    FormSplash.AddText('.');
  end;

  uTools.APP_PATH := System.SysUtils.ExtractFilePath(ParamStr(0));
  FormSplash.AddTextln(Concat('程序所在路径：', uTools.APP_PATH));
  FormSplash.AddTextln(Concat('系统屏幕分辨率：[', IntToStr(Screen.Width), 'px] * [',
    IntToStr(Screen.Height), 'px]'));

  Application.CreateForm(TDataModuleNonvisual, ModuleNonvisual);
  Application.CreateForm(TFormMain, FormMain);

  FormSplash.AddTextln('程序初始化启动完成！');
  FormSplash.Close;

  if (ParamCount > 0) and ((ParamStr(1) = '-t') or (ParamStr(1) = '--today'))
  then
  begin
    // 传入指定命令行参数，直接设置今天的壁纸并退出程序
    try
      FormMain.Visible := False;
      if FormMain.ImageCount > 0 then
      begin
        FormMain.ActionSetWallpaperExecute(Application);
      end;
      Exit;
    finally
      FormMain.Free;
      ModuleNonvisual.Free;
      Application.Terminate;
    end;
  end;

  Application.Run;

end.
