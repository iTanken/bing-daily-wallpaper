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

  Application.CreateForm(TDataModuleNonvisual, ModuleNonvisual);
  Application.CreateForm(TFormMain, FormMain);

  FormSplash.AddTextln('程序初始化启动完成！');
  FormSplash.Close;

  Application.Run;

end.
