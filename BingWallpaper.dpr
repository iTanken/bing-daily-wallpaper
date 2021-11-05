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

  Application.CreateForm(TDataModuleNonvisual, ModuleNonvisual);
  Application.CreateForm(TFormMain, FormMain);

  FormSplash.AddTextln('�����ʼ��������ɣ�');
  FormSplash.Close;

  Application.Run;

end.
