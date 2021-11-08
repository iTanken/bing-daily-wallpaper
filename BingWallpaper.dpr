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
    // ����ָ�������в�������ʾ�����Ϣ
    if (ParamStr(1) = '-h') or (ParamStr(1) = '--help') then
    begin
      // ��ʾ������Ϣ
      uTools.AlertInfo(Concat('-h  --help    ��ʾ������Ϣ', uTools.BR,
        '-t  --today   ֱ�����ý���ı�ֽ', uTools.BR, '-v  --version ��ʾӦ�ó���汾��Ϣ'));
      Exit;
    end;
    if (ParamStr(1) = '-v') or (ParamStr(1) = '--version') then
    begin
      // ��ʾ�汾��Ϣ
      uTools.AlertInfo(Concat('v', uTools.GetApplicationVersion));
      Exit;
    end;
  end;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;

  // ����������ӭ����
  FormSplash := TFormSplash.Create(nil);
  FormSplash.Show;
  FormSplash.Update;

  FormSplash.SetText('��Ӧÿ�������ֽ���������У����Ժ�');
  for i := 0 to 5 do
  begin
    FormSplash.AddText('.');
  end;

  uTools.APP_PATH := System.SysUtils.ExtractFilePath(ParamStr(0));
  FormSplash.AddTextln(Concat('��������·����', uTools.APP_PATH));
  FormSplash.AddTextln(Concat('ϵͳ��Ļ�ֱ��ʣ�[', IntToStr(Screen.Width), 'px] * [',
    IntToStr(Screen.Height), 'px]'));

  Application.CreateForm(TDataModuleNonvisual, ModuleNonvisual);
  Application.CreateForm(TFormMain, FormMain);

  FormSplash.AddTextln('�����ʼ��������ɣ�');
  FormSplash.Close;

  if (ParamCount > 0) and ((ParamStr(1) = '-t') or (ParamStr(1) = '--today'))
  then
  begin
    // ����ָ�������в�����ֱ�����ý���ı�ֽ���˳�����
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
