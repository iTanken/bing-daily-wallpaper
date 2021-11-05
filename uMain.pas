unit uMain;

interface

uses
  Winapi.Messages, Winapi.ShellAPI, Winapi.Windows,

  System.Classes, System.Generics.Collections,
  System.JSON, System.JSON.Builders, System.JSON.Types, System.JSON.Writers,
  System.SysUtils, System.Types, System.Variants, System.UITypes,

  Vcl.ComCtrls, Vcl.Controls, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Forms,
  Vcl.Graphics, Vcl.Imaging.jpeg, Vcl.Imaging.pngimage, Vcl.StdCtrls,
  Vcl.Imaging.GIFImg;

type
  TFormMain = class(TForm)
    ImageCurrent: TImage;
    ImagePrev: TImage;
    ImageNext: TImage;
    loading: TProgressBar;
    StatusBarBtm: TStatusBar;
    LabelCopyrightLink: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);

    procedure ImageCurrentMouseEnter(Sender: TObject);
    procedure ImageCurrentMouseLeave(Sender: TObject);
    procedure ImagePrevMouseEnter(Sender: TObject);
    procedure ImageNextMouseEnter(Sender: TObject);
    procedure ImagePrevClick(Sender: TObject);
    procedure ImageNextClick(Sender: TObject);

    procedure ImageCurrentMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);

    procedure StatusBarBtmDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);

    procedure LabelCopyrightClick(Sender: TObject);
    procedure ImageCurrentMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
  private
    { Private declarations }
    procedure LoadStart();
    procedure LoadProgress(Position: Integer = 0);
    procedure LoadEnd();

    function IsFirstImage(): Boolean;
    function IsLastImage(): Boolean;

    function GetImages(data: TJSONObject; idx: Integer = 0; n: Integer = 7)
      : TJSONArray;
    function GetImageJSON(index: Integer = 0): TJSONObject;
    procedure ShowImage();

    // ע���ݼ�
    procedure RegHotKey();
    // ��Ӧ��ݼ���Ϣ
    procedure HotKeyDown(var msg: Tmessage); message WM_HOTKEY;

  var
    AllImages: TJSONArray; // ����ͼƬ��Ϣ
    ImageCount, ImageIndex: Integer; // ͼƬ�����͵�ǰͼƬ����
    InitCaption, CopyrightInfo, CopyrightLink: String; // ��ӦͼƬ��Ȩ��Ϣ������
    StatusDrawRect: TRect;

  public
    { Public declarations }
    procedure InitLoad();
    function ShowNowTime(): String;
    function GetImageDate(Image: TJSONObject = nil): String;
    function SaveCurrentImage(): String;
    procedure ShowFirstImage();
    procedure ShowLastImage();

  var
    ImageCurrentDate: String;
  end;

var
  FormMain: TFormMain;

procedure LoadingTimer(hWnd: THandle; msg: Word; idEvent: Word;
  dwTime: LongWord); stdcall;
procedure LoadedTimer(hWnd: THandle; msg: Word; idEvent: Word;
  dwTime: LongWord); stdcall;

implementation

{$R *.dfm}

uses NonVisualModule, uTools, uFormSplash;

procedure TFormMain.FormCreate(Sender: TObject);
// �����崴���¼�
begin
  self.InitCaption := self.Caption;

  FormSplash.AddTextln('ע������ܿ�ݼ� ...');
  RegHotKey();

  self.ShowNowTime();
  FormSplash.AddTextln('�����Ӧ��������ȡ��ֽ���� ...');
  self.InitLoad();
end;

procedure TFormMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
// �ر�ȷ��
var
  msg: PWideChar;
begin
  CanClose := False;
  msg := Concat('�Ƿ�رյ�ϵͳ���̣�', uTools.BR, 'ȡ����ֱ���˳�����');
  if MessageBox(self.Handle, msg, '�ر�ȷ��', MB_OKCANCEL + MB_ICONQUESTION) = mrOK
  then
  begin
    FormMain.Hide;
    ModuleNonVisual.TrayIconMain.Visible := True;
  end
  else
  begin
    CanClose := True;
  end;
end;

procedure TFormMain.InitLoad;
// ��ʼ������
var
  data: TJSONObject;
  moreImages: TJSONArray;
  i: Integer;
begin
  data := TJSONObject.Create;
  try
    try
      self.LoadStart();

      self.AllImages := self.GetImages(data);
      self.LoadProgress(50);
      if self.AllImages = nil then
      begin
        Exit;
      end;

      moreImages := self.GetImages(data, 7, 8);
      self.LoadProgress(90);
      if moreImages = nil then
      begin
        Exit;
      end;

      for i := 0 to moreImages.Count - 1 do
      begin
        self.AllImages.Add(moreImages.Items[i] as TJSONObject);
      end;
    except
      on e: Exception do
      begin
        // ��ʼ������ʧ��
        uTools.AlertError(self.Handle, Concat('��ʼ������ʧ�ܣ�', uTools.BR,
          e.Message));
        Exit;
      end;
    end;
  finally
    data.Free;
    self.ImageCount := self.AllImages.Count;
    self.LoadEnd();
    // ��ʾ��һ�ű�ֽͼƬ
    self.ImageIndex := 0;
    self.ShowImage();
  end;
end;

procedure TFormMain.LoadStart;
// ���ؿ�ʼ����ʾ������
var
  i: Integer;
begin
  with self.loading do
  begin
    // ���ȹ���
    Position := 0;

    // ������λ�ü���С
    Top := self.StatusDrawRect.Top;
    Left := self.StatusDrawRect.Left;
    Width := self.StatusDrawRect.right - self.StatusDrawRect.Left;
    Height := self.StatusDrawRect.bottom - self.StatusDrawRect.Top;

    // ��ʾ������
    Visible := True;
    try
      // ��������ӵ����Ϊ״̬��
      Parent := self.StatusBarBtm;
      // ��ʱ���½���
      for i := Min to Max do
      begin
        StepIt();
        Application.ProcessMessages;
        // SetTimer(0, 0, 1, @LoadingTimer);
      end;
    except
      on e: Exception do
      begin
        AlertWarn(self.Handle, Concat('���������ȸ���ʧ�ܣ�', uTools.BR, e.Message));
      end;
    end;
  end;
end;

procedure LoadingTimer(hWnd: THandle; msg: Word; idEvent: Word;
  dwTime: LongWord); stdcall;
// SetTimer ��ʱ�������ӳ�ִ�лص�
begin
  try
    if FormMain.loading.Visible and
      (FormMain.loading.Position < FormMain.loading.Max) then
    begin
      FormMain.loading.StepIt(); // ���½���������
    end;
  except
  end;
end;

procedure TFormMain.LoadProgress(Position: Integer = 0);
// ���ؽ���
begin
  if Position < loading.Position then
  begin
    // �½���С�ڵ�ǰ����
    Exit;
  end;

  try
    // ���½���
    loading.Position := Position;
    Application.ProcessMessages;
  except
    on e: Exception do
    begin
      AlertWarn(self.Handle, Concat('���������ȸ���ʧ�ܣ�', uTools.BR, e.Message));
    end;
  end;
end;

procedure TFormMain.LoadEnd;
// ������ɣ����ؽ�����
begin
  loading.Position := loading.Max;
  Application.ProcessMessages;
  // �ӳ� 2 �������ؽ�����
  SetTimer(0, 0, 200, @LoadedTimer);
end;

procedure LoadedTimer(hWnd: THandle; msg: Word; idEvent: Word;
  dwTime: LongWord); stdcall;
// SetTimer ��ʱ�������ӳ�ִ�лص�
begin
  FormMain.loading.Visible := False;
  KillTimer(hWnd, idEvent); // �رն�ʱ��
end;

procedure TFormMain.StatusBarBtmDrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
// ����״̬��
begin
  StatusDrawRect := Rect;

  // ����Ӵ֡����»���
  StatusBar.Canvas.Font.Style := [TFontStyle.fsBold, TFontStyle.fsUnderline];

  // �������
  StatusBar.Canvas.FillRect(Rect);
  StatusBar.Canvas.TextRect(Rect, Rect.Left, Rect.Top, Panel.Text);
end;

procedure TFormMain.LabelCopyrightClick(Sender: TObject);
// �����Ȩ��Ϣ�򿪰�Ȩ����
begin
  uTools.OpenLink(self.CopyrightLink);
end;

function TFormMain.ShowNowTime: String;
// ��״̬����ʾ��ǰʱ��
begin
  Result := FormatDateTime('yyyy-MM-dd HH:mm:ss', Now);
  self.StatusBarBtm.Panels[2].Text := Concat('��ǰʱ�䣺', Result);
end;

function TFormMain.GetImages(data: TJSONObject; idx: Integer = 0;
  n: Integer = 7): TJSONArray;
// ���� Bing HPImageArchive API ��ȡͼƬ��Ϣ JSON ����
var
  ApiResult: TMemoryStream;
  ApiResSize: Int64;
  ApiResPtr: PUTF8Char;
  HttpCode: Integer;
  JsonStr, Code: String;
begin
  Result := nil;
  ApiResPtr := nil;
  try
    try
      ApiResult := TMemoryStream.Create();
      ModuleNonVisual.BingApiIdHTTP.Get(Concat(API_BASIC, API_PATH, '&idx=',
        IntToStr(idx), '&n=', IntToStr(n)), ApiResult);

      HttpCode := ModuleNonVisual.BingApiIdHTTP.ResponseCode;
      Code := IntToStr(HttpCode);
      self.Caption := Concat(self.InitCaption, ' - HTTP ', Code);
      if HttpCode >= 400 then
      begin
        AlertError(self.Handle, Concat('����ʧ�ܣ�HTTP ERROR ', Code));
        Exit;
      end;

      ApiResSize := ApiResult.Size;
      if ApiResSize = 0 then
      begin
        AlertError(self.Handle, '����ʧ�ܣ���������Ϊ�գ�');
        Exit;
      end;

      ApiResPtr := AllocMem(ApiResSize); // �����ڴ�
      ApiResult.Position := 0; // ����Ҫ��ȡ�����ݵ���ʼλ��
      ApiResult.ReadBuffer(ApiResPtr^, ApiResSize); // ��ȡ���е�����

      JsonStr := String(UTF8ToAnsi(ApiResPtr));
      if JsonStr = '' then
      begin
        AlertError(self.Handle, '����ʧ�ܣ���ȡ����Ϊ�գ�');
        Exit;
      end;

      data := TJSONObject.ParseJSONValue(Trim(JsonStr)) as TJSONObject;
      if (data = nil) or (data.Count = 0) or (data.Values['images'] = nil) then
      begin
        AlertError(self.Handle, '����ʧ�ܣ����ݽ���ʧ�ܣ����Ժ����ԣ�');
        Exit;
      end;

      Result := data.Values['images'] as TJSONArray;
    except
      on e: Exception do
      begin
        AlertError(self.Handle, Concat('�����������ȡͼƬ��Ϣʧ�ܣ�', uTools.BR, e.Message));
      end;
    end;
  finally
    JsonStr := '';
    if ApiResPtr <> nil then
    begin
      FreeMem(ApiResPtr);
    end;
    FreeAndNil(ApiResult);
  end;
end;

function TFormMain.GetImageJSON(index: Integer = 0): TJSONObject;
// ����ͼƬ��Ϣ JSON �����±��ȡָ��ͼƬ��Ϣ
begin
  Result := nil;
  try
    if (index < 0) or (index > (self.ImageCount - 1)) then
    begin
      // �±�Խ��
      Exit;
    end;
    Result := self.AllImages.Items[index] as TJSONObject;
  except
    on e: Exception do
    begin
      AlertError(self.Handle, Concat('��ȡָ��ͼƬ��Ϣʧ�ܣ�', uTools.BR, e.Message));
    end;
  end;
end;

function TFormMain.GetImageDate(Image: TJSONObject = nil): String;
// ��ȡָ��ͼƬ��ǰͼƬ������Ϣ
var
  formatSetting: TFormatSettings;
begin
  try
    if Image = nil then
    begin
      Image := self.GetImageJSON(self.ImageIndex);
    end;

    formatSetting.ShortDateFormat := 'yyyyMMdd';
    self.ImageCurrentDate := FormatDateTime('yyyy-MM-dd',
      StrToDate(Image.GetValue('enddate').Value, formatSetting));

    Result := self.ImageCurrentDate;
  except
    on e: Exception do
    begin
      AlertError(self.Handle, Concat('��ȡͼƬ������Ϣʧ�ܣ�', uTools.BR, e.Message));
    end;
  end;
end;

function TFormMain.SaveCurrentImage: String;
// ���浱ǰ��ʾͼƬ��������ͼƬ��������·��
var
  imagePath: String;
begin
  try
    imagePath := Concat(uTools.APP_PATH, 'images\');
    if not DirectoryExists(imagePath) then
    begin
      CreateDir(imagePath);
    end;

    Result := imagePath + self.ImageCurrentDate + EXT_JPG;
    self.ImageCurrent.Picture.SavetoFile(Result);
  except
    on e: Exception do
    begin
      AlertError(self.Handle, Concat('ͼƬ����ʧ�ܣ�', uTools.BR, e.Message));
    end;
  end;
end;

procedure TFormMain.ShowImage();
// ����ͼƬ��Ϣ JSON �����±���ʾָ����ֽͼƬ
var
  Image: TJSONObject;
  imageStream: TMemoryStream;
begin
  self.LoadStart();
  try
    try
      self.LoadProgress(10);
      Image := self.GetImageJSON(self.ImageIndex);
      self.LoadProgress(30);
      if Image = nil then
      begin
        Exit;
      end;

      // ��״̬����ʾ��ֽ����
      self.StatusBarBtm.Panels[0].Text := self.GetImageDate(Image);
      self.LoadProgress(50);

      // ��״̬����ʾ��ֽ��Ȩ��Ϣ
      self.CopyrightLink := Image.GetValue('copyrightlink').Value;
      self.CopyrightInfo := Image.GetValue('copyright').Value;
      self.StatusBarBtm.Panels[1].Text := self.CopyrightInfo;
      self.StatusBarBtm.Hint := self.CopyrightInfo;
      self.LoadProgress(60);

      // ��ȡ��ֽ�ļ���
      imageStream := TMemoryStream.Create();
      ModuleNonVisual.BingImageIdHTTP.Get
        (Concat(API_BASIC, Image.GetValue('url').Value), imageStream);
      self.LoadProgress(70);
      // ��ʾ��ֽ�ļ�
      imageStream.Position := 0;
      self.ImageCurrent.Picture.LoadFromStream(imageStream);
      self.LoadProgress(90);
    except
      on e: Exception do
      begin
        AlertError(self.Handle, Concat('ͼƬ����ʧ�ܣ�', uTools.BR, e.Message));
      end;
    end;
  finally
    FreeAndNil(imageStream);
    self.LoadEnd();
  end;
end;

procedure TFormMain.ShowFirstImage;
// ��ʾ��һ��ͼƬ�����£�
begin
  self.ImageIndex := 0;
  self.ShowImage();
end;

procedure TFormMain.ShowLastImage;
// ��ʾ���һ��ͼƬ����ɣ�
begin
  self.ImageIndex := self.ImageCount - 1;
  self.ShowImage();
end;

procedure TFormMain.ImageCurrentMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
// ����Ҽ�ͼƬ�����˵�
begin
  if Button = mbRight then
  begin
    ModuleNonVisual.PopupMenuImage.Popup(Left + X + 5, Top + Y + 29);
  end;
end;

procedure TFormMain.ImageCurrentMouseEnter(Sender: TObject);
// �������ͼƬ��ʾ��ͷ
begin
  self.ImagePrev.Visible := not self.IsLastImage();
  self.ImageNext.Visible := not self.IsFirstImage();
end;

procedure TFormMain.ImageCurrentMouseLeave(Sender: TObject);
// ����Ƴ�ͼƬ���ؼ�ͷ
begin
  self.ImagePrev.Visible := False;
  self.ImageNext.Visible := False;
end;

procedure TFormMain.ImageCurrentMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
// �����ͼƬ���ƶ�
begin
  self.ImageCurrentMouseEnter(Sender);
end;

procedure TFormMain.ImagePrevMouseEnter(Sender: TObject);
// ���ͷ��������¼�
begin
  self.ImagePrev.Visible := True;
end;

procedure TFormMain.ImageNextMouseEnter(Sender: TObject);
// �Ҽ�ͷ��������¼�
begin
  self.ImageNext.Visible := True;
end;

procedure TFormMain.ImagePrevClick(Sender: TObject);
// ���ͷ����¼�
begin
  if self.IsLastImage() then
  begin
    // �Ѿ������һ��
    self.ImageIndex := self.ImageCount - 1;

    uTools.AlertWarn(self.Handle, Concat('�ѵ������һ��ͼƬ��', uTools.BR, '���һ��ͼƬ����Ϊ��',
      uTools.BR, '��', self.GetImageDate(nil), '��'));
    Exit;
  end;

  self.ImageIndex := self.ImageIndex + 1;
  self.ShowImage();
end;

procedure TFormMain.ImageNextClick(Sender: TObject);
// �Ҽ�ͷ����¼�
begin
  if self.IsFirstImage() then
  begin
    // �Ѿ��ǵ�һ��
    self.ImageIndex := 0;
    uTools.AlertWarn(self.Handle, Concat('�ѵ����һ��ͼƬ��', uTools.BR, '����ͼƬ������Ϊ��',
      uTools.BR, '��', self.GetImageDate(nil), '��'));
    Exit;
  end;

  self.ImageIndex := self.ImageIndex - 1;
  self.ShowImage();
end;

function TFormMain.IsFirstImage: Boolean;
// �Ƿ�Ϊ��һ��ͼƬ
begin
  Result := self.ImageIndex <= 0;
end;

function TFormMain.IsLastImage: Boolean;
// �Ƿ�Ϊ���һ��ͼƬ
begin
  Result := self.ImageIndex >= (self.ImageCount - 1);
end;

procedure TFormMain.RegHotKey;
// ע���ݼ�
var
  HotKeyID: Integer;
begin
  // ע���ݼ����� $C000 ��֤ȡֵ��Χ������
  HotKeyID := GlobalAddAtom(PChar('ImagePrevClick')) - $C000;
  RegisterHotKey(self.Handle, HotKeyID, 0, VK_LEFT);

  HotKeyID := GlobalAddAtom(PChar('ImageNextClick')) - $C000;
  RegisterHotKey(self.Handle, HotKeyID, 0, VK_RIGHT);

  HotKeyID := GlobalAddAtom(PChar('ActionSetWallpaperExecute')) - $C000;
  RegisterHotKey(self.Handle, HotKeyID, MOD_CONTROL, 68);

  HotKeyID := GlobalAddAtom(PChar('ActionSaveImageExecute')) - $C000;
  RegisterHotKey(self.Handle, HotKeyID, MOD_CONTROL, 83);

  HotKeyID := GlobalAddAtom(PChar('InitLoad')) - $C000;
  RegisterHotKey(self.Handle, HotKeyID, MOD_CONTROL, 82);

  HotKeyID := GlobalAddAtom(PChar('ShowFirstImage')) - $C000;
  RegisterHotKey(self.Handle, HotKeyID, MOD_ALT, VK_F1);

  HotKeyID := GlobalAddAtom(PChar('ShowLastImage')) - $C000;
  RegisterHotKey(self.Handle, HotKeyID, MOD_ALT, VK_F2);

  HotKeyID := GlobalAddAtom(PChar('ActionAboutExecute')) - $C000;
  RegisterHotKey(self.Handle, HotKeyID, MOD_CONTROL, 65);

  HotKeyID := GlobalAddAtom(PChar('Close')) - $C000;
  RegisterHotKey(self.Handle, HotKeyID, MOD_CONTROL, 87);
end;

procedure TFormMain.HotKeyDown(var msg: Tmessage);
// ������ݼ�
begin
  // �� ���������һ��
  if (msg.LParamLo = 0) AND (msg.LParamHi = VK_LEFT) then
  begin
    self.ImagePrevClick(self);
    Exit;
  end;

  // �� �ҷ��������һ��
  if (msg.LParamLo = 0) AND (msg.LParamHi = VK_RIGHT) then
  begin
    self.ImageNextClick(self);
    Exit;
  end;

  // Ctrl + D : ���������ֽ
  if (msg.LParamLo = MOD_CONTROL) AND (msg.LParamHi = 68) then
  begin
    ModuleNonVisual.ActionSetWallpaperExecute(self);
    Exit;
  end;
  // Ctrl + S : ���浱ǰͼƬ
  if (msg.LParamLo = MOD_CONTROL) AND (msg.LParamHi = 83) then
  begin
    ModuleNonVisual.ActionSaveImageExecute(self);
    Exit;
  end;
  // Ctrl + R : ˢ�£��������� API ��ȡ���ݣ�
  if (msg.LParamLo = MOD_CONTROL) AND (msg.LParamHi = 82) then
  begin
    self.InitLoad;
    Exit;
  end;
  // Alt + F1 : ��ҳ
  if (msg.LParamLo = MOD_ALT) AND (msg.LParamHi = VK_F1) then
  begin
    self.ShowFirstImage();
    Exit;
  end;
  // Alt + F2 : βҳ
  if (msg.LParamLo = MOD_ALT) AND (msg.LParamHi = VK_F2) then
  begin
    self.ShowLastImage();
    Exit;
  end;
  // Ctrl + A : ����
  if (msg.LParamLo = MOD_CONTROL) AND (msg.LParamHi = 65) then
  begin
    ModuleNonVisual.ActionAboutExecute(self);
    Exit;
  end;
  // Ctrl + W : �˳�
  if (msg.LParamLo = MOD_CONTROL) AND (msg.LParamHi = 87) then
  begin
    self.Close;
  end;
end;

end.
