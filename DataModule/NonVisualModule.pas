unit NonVisualModule;

interface

uses
  Winapi.Windows,

  System.Actions, System.SysUtils, System.Classes,

  IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP,

  Vcl.ExtCtrls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtDlgs, Vcl.Menus;

type
  TDataModuleNonvisual = class(TDataModule)
    BingApiIdHTTP: TIdHTTP;
    BingApiIdSSLIOHandlerSocketOpenSSL: TIdSSLIOHandlerSocketOpenSSL;
    BingImageIdHTTP: TIdHTTP;
    BingImageIdSSLIOHandlerSocketOpenSSL: TIdSSLIOHandlerSocketOpenSSL;

    TimerShowNow: TTimer;
    TrayIconMain: TTrayIcon;
    SavePictureDialogCurr: TSavePictureDialog;
    PopupMenuIcon: TPopupMenu;
    N1_SHOW: TMenuItem;
    N2_ABOUT: TMenuItem;
    N3_CLOSE: TMenuItem;

    procedure DataModuleCreate(Sender: TObject);
    procedure TimerShowNowTimer(Sender: TObject);
    procedure TrayIconMainClick(Sender: TObject);
    procedure N3_CLOSEClick(Sender: TObject);
    procedure N1_SHOWClick(Sender: TObject);
    procedure N2_ABOUTClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ModuleNonvisual: TDataModuleNonvisual;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

uses uMain, uTools, uFormSplash, ABOUT;

{$R *.dfm}
{$R eay_dll.RES}

procedure TDataModuleNonvisual.DataModuleCreate(Sender: TObject);
begin
  // �ͷ����� dll ��Դ
  // FormSplash.AddTextln('�ͷ����� DLL ��Դ ...');

  uTools.ExtractRes(SysInit.HInstance, 'libeay32', 'RC_DLL',
    Concat(uTools.APP_PATH, 'libeay32.dll'));

  uTools.ExtractRes(SysInit.HInstance, 'ssleay32', 'RC_DLL',
    Concat(uTools.APP_PATH, 'ssleay32.dll'));

  // ��ʼ������ʱ���ʽ
  System.SysUtils.FormatSettings.DateSeparator := '-';
  System.SysUtils.FormatSettings.ShortDateFormat := 'yyyy-MM-dd';
  System.SysUtils.FormatSettings.LongDateFormat := 'yyyy-MM-dd';
  System.SysUtils.FormatSettings.LongTimeFormat := 'HH:mm:ss';
  System.SysUtils.FormatSettings.ShortTimeFormat := 'HH:mm';

  // ���� idHTTP User-Agent
  FormSplash.AddTextln('���� HTTP �����û������ַ��� ...');
  BingApiIdHTTP.Request.UserAgent := uTools.DEF_UA;
  BingImageIdHTTP.Request.UserAgent := uTools.DEF_UA;
end;

procedure TDataModuleNonvisual.TimerShowNowTimer(Sender: TObject);
// ��ʱ��ÿ�����ʱ��
begin
  FormMain.ShowNowTime();
end;

procedure TDataModuleNonvisual.TrayIconMainClick(Sender: TObject);
// ����ͼ�����¼�
begin
  FormMain.Show;
  FormMain.BringToFront;
  self.TrayIconMain.Visible := False;
  SetForegroundWindow(FormMain.Handle);
end;

procedure TDataModuleNonvisual.N1_SHOWClick(Sender: TObject);
// ����ͼ���Ҽ��˵���������ԭ��ʾ
begin
  self.TrayIconMainClick(Sender);
end;

procedure TDataModuleNonvisual.N2_ABOUTClick(Sender: TObject);
// ����ͼ���Ҽ��˵�����������
begin
  ABOUT.Show(self);
end;

procedure TDataModuleNonvisual.N3_CLOSEClick(Sender: TObject);
// ����ͼ���Ҽ��˵��������˳�ϵͳ
begin
  Application.Terminate;
end;

end.
