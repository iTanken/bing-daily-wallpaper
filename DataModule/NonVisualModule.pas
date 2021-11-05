unit NonVisualModule;

interface

uses
  Winapi.Windows,

  System.Actions, System.SysUtils, System.Classes,

  IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP,

  Vcl.ExtCtrls, Vcl.Forms, Vcl.Menus, Vcl.ActnList, Vcl.Dialogs, Vcl.ExtDlgs;

type
  TDataModuleNonvisual = class(TDataModule)
    BingApiIdHTTP: TIdHTTP;
    BingApiIdSSLIOHandlerSocketOpenSSL: TIdSSLIOHandlerSocketOpenSSL;
    BingImageIdHTTP: TIdHTTP;
    BingImageIdSSLIOHandlerSocketOpenSSL: TIdSSLIOHandlerSocketOpenSSL;
    TimerShowNow: TTimer;
    PopupMenuImage: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    ActionListPopup: TActionList;
    ActionSetWallpaper: TAction;
    ActionRefreshImage: TAction;
    ActionSaveImage: TAction;
    ActionAbout: TAction;
    ActionExit: TAction;
    TrayIconMain: TTrayIcon;
    SavePictureDialogCurr: TSavePictureDialog;
    ActionLast: TAction;
    ActionFirst: TAction;
    N6: TMenuItem;
    N7: TMenuItem;
    procedure TimerShowNowTimer(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
    procedure ActionExitExecute(Sender: TObject);
    procedure TrayIconMainClick(Sender: TObject);
    procedure ActionSetWallpaperExecute(Sender: TObject);
    procedure ActionSaveImageExecute(Sender: TObject);
    procedure ActionRefreshImageExecute(Sender: TObject);
    procedure ActionAboutExecute(Sender: TObject);
    procedure ActionLastExecute(Sender: TObject);
    procedure ActionFirstExecute(Sender: TObject);
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
  FormSplash.AddTextln('释放依赖 DLL 资源 ...');

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
  FormSplash.AddTextln('设置 HTTP 请求 User-Agent ...');
  BingApiIdHTTP.Request.UserAgent := uTools.DEF_UA;
  BingImageIdHTTP.Request.UserAgent := uTools.DEF_UA;

  self.PopupMenuImage.AutoPopup := False;
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

procedure TDataModuleNonvisual.ActionSetWallpaperExecute(Sender: TObject);
// 右键菜单动作：设置桌面壁纸
var
  imagePath: String;
  callState: Boolean;
begin
  imagePath := FormMain.SaveCurrentImage();

  // 调用 Windows API 设置桌面壁纸
  callState := SystemParametersInfo(SPI_SETDESKWALLPAPER, 1, PChar(imagePath),
    SPIF_UPDATEINIFILE);

  if callState then
  begin
    AlertInfo(FormMain.Handle, '桌面壁纸设置成功！');
    Exit;
  end;
  AlertWarn(FormMain.Handle, '桌面壁纸设置失败！');
end;

procedure TDataModuleNonvisual.ActionSaveImageExecute(Sender: TObject);
// 右键菜单动作：保存当前图片
var
  imageName: string;
begin
  imageName := FormMain.ImageCurrentDate;
  self.SavePictureDialogCurr.Title := Concat('保存当前图片：', imageName);
  self.SavePictureDialogCurr.Filter := '图片文件(*.jpg)|*.jpg'; // 文件类型过滤
  self.SavePictureDialogCurr.DefaultExt := EXT_JPG; // 自动添加扩展名
  self.SavePictureDialogCurr.FileName := imageName;

  if not self.SavePictureDialogCurr.Execute then
  begin
    // 取消保存
    AlertWarn(FormMain.Handle, '已取消保存当前图片！');
    Exit;
  end;

  // 保存图片
  FormMain.ImageCurrent.Picture.SaveToFile(self.SavePictureDialogCurr.FileName);
  AlertInfo(FormMain.Handle, '当前图片保存成功！');
end;

procedure TDataModuleNonvisual.ActionRefreshImageExecute(Sender: TObject);
// 右键菜单动作：刷新、重载
begin
  FormMain.InitLoad;
end;

procedure TDataModuleNonvisual.ActionFirstExecute(Sender: TObject);
// 右键菜单动作：首页
begin
  FormMain.ShowFirstImage();
end;

procedure TDataModuleNonvisual.ActionLastExecute(Sender: TObject);
// 右键菜单动作：尾页
begin
  FormMain.ShowLastImage();
end;

procedure TDataModuleNonvisual.ActionAboutExecute(Sender: TObject);
// 右键菜单动作：关于
begin
  ABOUT.Show(FormMain);
end;

procedure TDataModuleNonvisual.ActionExitExecute(Sender: TObject);
// 右键菜单动作：退出程序
begin
  FormMain.Close;
end;

end.
