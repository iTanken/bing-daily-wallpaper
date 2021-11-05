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
  // 释放依赖 dll 资源
  // FormSplash.AddTextln('释放依赖 DLL 资源 ...');

  uTools.ExtractRes(SysInit.HInstance, 'libeay32', 'RC_DLL',
    Concat(uTools.APP_PATH, 'libeay32.dll'));

  uTools.ExtractRes(SysInit.HInstance, 'ssleay32', 'RC_DLL',
    Concat(uTools.APP_PATH, 'ssleay32.dll'));

  // 初始化日期时间格式
  System.SysUtils.FormatSettings.DateSeparator := '-';
  System.SysUtils.FormatSettings.ShortDateFormat := 'yyyy-MM-dd';
  System.SysUtils.FormatSettings.LongDateFormat := 'yyyy-MM-dd';
  System.SysUtils.FormatSettings.LongTimeFormat := 'HH:mm:ss';
  System.SysUtils.FormatSettings.ShortTimeFormat := 'HH:mm';

  // 设置 idHTTP User-Agent
  FormSplash.AddTextln('设置 HTTP 请求用户代理字符串 ...');
  BingApiIdHTTP.Request.UserAgent := uTools.DEF_UA;
  BingImageIdHTTP.Request.UserAgent := uTools.DEF_UA;
end;

procedure TDataModuleNonvisual.TimerShowNowTimer(Sender: TObject);
// 定时器每秒更新时间
begin
  FormMain.ShowNowTime();
end;

procedure TDataModuleNonvisual.TrayIconMainClick(Sender: TObject);
// 托盘图标点击事件
begin
  FormMain.Show;
  FormMain.BringToFront;
  self.TrayIconMain.Visible := False;
  SetForegroundWindow(FormMain.Handle);
end;

procedure TDataModuleNonvisual.N1_SHOWClick(Sender: TObject);
// 托盘图标右键菜单动作：还原显示
begin
  self.TrayIconMainClick(Sender);
end;

procedure TDataModuleNonvisual.N2_ABOUTClick(Sender: TObject);
// 托盘图标右键菜单动作：关于
begin
  ABOUT.Show(self);
end;

procedure TDataModuleNonvisual.N3_CLOSEClick(Sender: TObject);
// 托盘图标右键菜单动作：退出系统
begin
  Application.Terminate;
end;

end.
