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
  // �ͷ����� dll ��Դ
  FormSplash.AddTextln('�ͷ����� DLL ��Դ ...');

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
  FormSplash.AddTextln('���� HTTP ���� User-Agent ...');
  BingApiIdHTTP.Request.UserAgent := uTools.DEF_UA;
  BingImageIdHTTP.Request.UserAgent := uTools.DEF_UA;

  self.PopupMenuImage.AutoPopup := False;
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

procedure TDataModuleNonvisual.ActionSetWallpaperExecute(Sender: TObject);
// �Ҽ��˵����������������ֽ
var
  imagePath: String;
  callState: Boolean;
begin
  imagePath := FormMain.SaveCurrentImage();

  // ���� Windows API ���������ֽ
  callState := SystemParametersInfo(SPI_SETDESKWALLPAPER, 1, PChar(imagePath),
    SPIF_UPDATEINIFILE);

  if callState then
  begin
    AlertInfo(FormMain.Handle, '�����ֽ���óɹ���');
    Exit;
  end;
  AlertWarn(FormMain.Handle, '�����ֽ����ʧ�ܣ�');
end;

procedure TDataModuleNonvisual.ActionSaveImageExecute(Sender: TObject);
// �Ҽ��˵����������浱ǰͼƬ
var
  imageName: string;
begin
  imageName := FormMain.ImageCurrentDate;
  self.SavePictureDialogCurr.Title := Concat('���浱ǰͼƬ��', imageName);
  self.SavePictureDialogCurr.Filter := 'ͼƬ�ļ�(*.jpg)|*.jpg'; // �ļ����͹���
  self.SavePictureDialogCurr.DefaultExt := EXT_JPG; // �Զ������չ��
  self.SavePictureDialogCurr.FileName := imageName;

  if not self.SavePictureDialogCurr.Execute then
  begin
    // ȡ������
    AlertWarn(FormMain.Handle, '��ȡ�����浱ǰͼƬ��');
    Exit;
  end;

  // ����ͼƬ
  FormMain.ImageCurrent.Picture.SaveToFile(self.SavePictureDialogCurr.FileName);
  AlertInfo(FormMain.Handle, '��ǰͼƬ����ɹ���');
end;

procedure TDataModuleNonvisual.ActionRefreshImageExecute(Sender: TObject);
// �Ҽ��˵�������ˢ�¡�����
begin
  FormMain.InitLoad;
end;

procedure TDataModuleNonvisual.ActionFirstExecute(Sender: TObject);
// �Ҽ��˵���������ҳ
begin
  FormMain.ShowFirstImage();
end;

procedure TDataModuleNonvisual.ActionLastExecute(Sender: TObject);
// �Ҽ��˵�������βҳ
begin
  FormMain.ShowLastImage();
end;

procedure TDataModuleNonvisual.ActionAboutExecute(Sender: TObject);
// �Ҽ��˵�����������
begin
  ABOUT.Show(FormMain);
end;

procedure TDataModuleNonvisual.ActionExitExecute(Sender: TObject);
// �Ҽ��˵��������˳�����
begin
  FormMain.Close;
end;

end.
