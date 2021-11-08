unit uMain;

interface

uses
  Winapi.Messages, Winapi.Windows,

  System.Classes, System.Generics.Collections,
  System.JSON, System.JSON.Builders, System.JSON.Types, System.JSON.Writers,
  System.SysUtils, System.Types, System.Variants, System.UITypes,

  Vcl.ComCtrls, Vcl.Controls, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Forms,
  Vcl.Graphics, Vcl.Imaging.jpeg, Vcl.Imaging.pngimage, Vcl.StdCtrls,
  Vcl.Imaging.GIFImg, System.Actions, Vcl.ActnList, Vcl.Menus;

type
  TFormMain = class(TForm)
    ImageCurrent: TImage;
    ImagePrev: TImage;
    ImageNext: TImage;
    loading: TProgressBar;
    StatusBarBtm: TStatusBar;
    LabelCopyrightLink: TLabel;

    PopupMenuImage: TPopupMenu;
    N1_SET: TMenuItem;
    N2_SAVE: TMenuItem;
    N3_REFRESH: TMenuItem;
    N4_FIRST: TMenuItem;
    N5_LAST: TMenuItem;
    N6_ABOUT: TMenuItem;
    N7_CLOSE: TMenuItem;

    ActionListPopup: TActionList;
    ActionSetWallpaper: TAction;
    ActionSaveImage: TAction;
    ActionRefreshImage: TAction;
    ActionFirst: TAction;
    ActionLast: TAction;
    ActionAbout: TAction;
    ActionExit: TAction;
    N8_EXPLORER: TMenuItem;
    ActionExplorer: TAction;

    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);

    procedure ActionSetWallpaperExecute(Sender: TObject);
    procedure ActionSaveImageExecute(Sender: TObject);
    procedure ActionRefreshImageExecute(Sender: TObject);
    procedure ActionFirstExecute(Sender: TObject);
    procedure ActionLastExecute(Sender: TObject);
    procedure ActionAboutExecute(Sender: TObject);
    procedure ActionExitExecute(Sender: TObject);

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

    procedure ImageCurrentDblClick(Sender: TObject);
    procedure ImageCurrentMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure ActionExplorerExecute(Sender: TObject);
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

  var
    AllImages: TJSONArray; // ����ͼƬ��Ϣ
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
    ImageCount, ImageIndex: Integer; // ͼƬ�����͵�ǰͼƬ����
    PopupMenuX, PopupMenuY: Integer; // ͼƬ����Ҽ��˵�����
  end;

var
  FormMain: TFormMain;

procedure LoadingTimer(handle: THandle; Msg: Word; idEvent: Word;
  dwTime: LongWord); stdcall;
procedure LoadedTimer(handle: THandle; Msg: Word; idEvent: Word;
  dwTime: LongWord); stdcall;
procedure PopupMenuTimer(handle: THandle; Msg: Word; idEvent: Word;
  dwTime: LongWord); stdcall;

implementation

{$R *.dfm}

uses NonVisualModule, uTools, uFormSplash, ABOUT;

procedure TFormMain.FormCreate(Sender: TObject);
// �����崴���¼�
begin
  self.InitCaption := self.Caption;
  self.PopupMenuImage.AutoPopup := False;

  self.ShowNowTime();
  FormSplash.AddTextln('�����Ӧ��������ȡ��ֽ���� ...');
  self.InitLoad();
end;

procedure TFormMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
// �ر�ȷ��
var
  Msg: PWideChar;
begin
  CanClose := False;
  Msg := Concat('�Ƿ�رյ�ϵͳ���̣�', uTools.BR, 'ȡ����ֱ���˳�����');
  if Application.MessageBox(Msg, '�ر�ȷ��', MB_OKCANCEL + MB_ICONQUESTION) = mrOK
  then
  begin
    self.Hide;
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
        uTools.AlertError(Concat('��ʼ������ʧ�ܣ�', uTools.BR, e.Message));
        Exit;
      end;
    end;
  finally
    data.Free;
    self.LoadEnd();
    if self.AllImages = nil then
    begin
      self.ImageCount := 0;
    end
    else
    begin
      self.ImageCount := self.AllImages.Count;
      self.Caption := Concat(self.InitCaption, ' ��',
        GetImageDate(self.GetImageJSON(self.ImageCount - 1)), ' �� ',
        GetImageDate(self.GetImageJSON(0)), '��');
      // ��ʾ��һ�ű�ֽͼƬ
      self.ImageIndex := 0;
      self.ShowImage();
    end;
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
        SetTimer(0, 0, 100, @LoadingTimer);
        Application.ProcessMessages;
      end;
    except
      on e: Exception do
      begin
        AlertWarn(Concat('���������ȸ���ʧ�ܣ�', uTools.BR, e.Message));
      end;
    end;
  end;
end;

procedure LoadingTimer(handle: THandle; Msg: Word; idEvent: Word;
  dwTime: LongWord); stdcall;
// SetTimer ��ʱ�������ӳ�ִ�лص�
begin
  try
    try
      if FormMain.loading.Visible and
        (FormMain.loading.Position < FormMain.loading.Max) then
      begin
        FormMain.loading.StepIt(); // ���½���������
        Application.ProcessMessages;
      end;
    except
    end;
  finally
    KillTimer(handle, idEvent); // �رն�ʱ��
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
      AlertWarn(Concat('���������ȸ���ʧ�ܣ�', uTools.BR, e.Message));
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
  Application.ProcessMessages;
end;

procedure LoadedTimer(handle: THandle; Msg: Word; idEvent: Word;
  dwTime: LongWord); stdcall;
// SetTimer ��ʱ�������ӳ�ִ�лص�
begin
  FormMain.loading.Visible := False;

  KillTimer(handle, idEvent); // �رն�ʱ��
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
        AlertError(Concat('����ʧ�ܣ�HTTP ERROR ', Code));
        Exit;
      end;

      JsonStr := uTools.StreamToStr(ApiResult, TEncoding.UTF8);
      if JsonStr = '' then
      begin
        AlertError('����ʧ�ܣ���ȡ����Ϊ�գ�');
        Exit;
      end;

      data := TJSONObject.ParseJSONValue(Trim(JsonStr)) as TJSONObject;
      if (data = nil) or (data.Count = 0) or (data.Values['images'] = nil) then
      begin
        AlertError('����ʧ�ܣ����ݽ���ʧ�ܣ����Ժ����ԣ�');
        Exit;
      end;

      Result := data.Values['images'] as TJSONArray;
    except
      on e: Exception do
      begin
        AlertError(Concat('�����������ȡͼƬ��Ϣʧ�ܣ�', uTools.BR, e.Message));
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
      AlertError(Concat('��ȡָ��ͼƬ��Ϣʧ�ܣ�', uTools.BR, e.Message));
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
      AlertError(Concat('��ȡͼƬ������Ϣʧ�ܣ�', uTools.BR, e.Message));
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
      AlertError(Concat('ͼƬ����ʧ�ܣ�', uTools.BR, e.Message));
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
        AlertError(Concat('ͼƬ����ʧ�ܣ�', uTools.BR, e.Message));
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

procedure TFormMain.ImageCurrentDblClick(Sender: TObject);
// ˫��ͼƬ�򿪱�Ӧ��������
begin
  uTools.OpenLink(self.CopyrightLink);
end;

procedure TFormMain.ImageCurrentMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
// ����Ҽ�ͼƬ�����˵�
begin
  if Button = mbRight then
  begin
    self.PopupMenuX := Left + X + 5;
    self.PopupMenuY := Top + Y + 29;
    // ModuleNonVisual.PopupMenuImage.Popup(PopupMenuX, PopupMenuY);
    SetTimer(0, 0, 0, @PopupMenuTimer);
    Application.ProcessMessages;
  end;
end;

procedure PopupMenuTimer(handle: THandle; Msg: Word; idEvent: Word;
  dwTime: LongWord); stdcall;
// SetTimer ��ʱ�������ӳ�ִ�лص�
begin
  FormMain.PopupMenuImage.Popup(FormMain.PopupMenuX, FormMain.PopupMenuY);

  KillTimer(handle, idEvent); // �رն�ʱ��
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
  if self.ImageCount = 0 then
  begin
    Exit;
  end;

  if self.IsLastImage() then
  begin
    // �Ѿ������һ��
    self.ImageIndex := self.ImageCount - 1;

    uTools.AlertWarn(Concat('�ѵ������һ��ͼƬ��', uTools.BR, '���һ��ͼƬ����Ϊ��', uTools.BR,
      '��', self.GetImageDate(nil), '��'));
    Exit;
  end;

  self.ImageIndex := self.ImageIndex + 1;
  self.ShowImage();
end;

procedure TFormMain.ImageNextClick(Sender: TObject);
// �Ҽ�ͷ����¼�
begin
  if self.ImageCount = 0 then
  begin
    Exit;
  end;

  if self.IsFirstImage() then
  begin
    // �Ѿ��ǵ�һ��
    self.ImageIndex := 0;
    uTools.AlertWarn(Concat('�ѵ����һ��ͼƬ��', uTools.BR, '����ͼƬ������Ϊ��', uTools.BR, '��',
      self.GetImageDate(nil), '��'));
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

procedure TFormMain.ActionSetWallpaperExecute(Sender: TObject);
// 1. �Ҽ��˵����������������ֽ
var
  imagePath: String;
  callState: Boolean;
begin
  imagePath := self.SaveCurrentImage();

  // ���� Windows API ���������ֽ
  callState := SystemParametersInfo(SPI_SETDESKWALLPAPER, 1, PChar(imagePath),
    SPIF_UPDATEINIFILE);

  if callState then
  begin
    AlertInfo('�����ֽ���óɹ���');
    Exit;
  end;
  AlertWarn('�����ֽ����ʧ�ܣ�');
end;

procedure TFormMain.ActionSaveImageExecute(Sender: TObject);
// 2. �Ҽ��˵����������浱ǰͼƬ
begin
  ModuleNonVisual.SavePictureDialogCurr.Title :=
    Concat('���浱ǰͼƬ��', self.ImageCurrentDate);
  ModuleNonVisual.SavePictureDialogCurr.Filter := 'ͼƬ�ļ�(*.jpg)|*.jpg'; // �ļ����͹���
  ModuleNonVisual.SavePictureDialogCurr.DefaultExt := EXT_JPG; // �Զ������չ��
  ModuleNonVisual.SavePictureDialogCurr.FileName := self.ImageCurrentDate;

  if not ModuleNonVisual.SavePictureDialogCurr.Execute then
  begin
    // ȡ������
    AlertWarn('��ȡ�����浱ǰͼƬ��');
    Exit;
  end;

  // ����ͼƬ
  self.ImageCurrent.Picture.SavetoFile
    (ModuleNonVisual.SavePictureDialogCurr.FileName);
  AlertInfo('��ǰͼƬ����ɹ���');
end;

procedure TFormMain.ActionExplorerExecute(Sender: TObject);
// 3. �Ҽ��˵����������
var
  imagePath: String;
begin
  imagePath := Concat(uTools.APP_PATH, 'images\');
  if DirectoryExists(imagePath) then
  begin
    uTools.OpenLink(imagePath);
  end
  else
  begin
    uTools.OpenLink(uTools.APP_PATH);
  end;
end;

procedure TFormMain.ActionRefreshImageExecute(Sender: TObject);
// 4. �Ҽ��˵�������ˢ�¡�����
begin
  self.InitLoad;
end;

procedure TFormMain.ActionFirstExecute(Sender: TObject);
// 5. �Ҽ��˵���������ҳ
begin
  self.ShowFirstImage();
end;

procedure TFormMain.ActionLastExecute(Sender: TObject);
// 6. �Ҽ��˵�������βҳ
begin
  self.ShowLastImage();
end;

procedure TFormMain.ActionAboutExecute(Sender: TObject);
// 7. �Ҽ��˵�����������
begin
  ABOUT.Show(self);
end;

procedure TFormMain.ActionExitExecute(Sender: TObject);
// 8. �Ҽ��˵��������˳�����
begin
  self.Close;
end;

procedure TFormMain.FormShortCut(var Msg: TWMKey; var Handled: Boolean);
// ������ݼ�
begin
  // �� ���������һ��
  if Msg.CharCode = VK_LEFT then
  begin
    self.ImagePrevClick(self);
    Handled := True;
    Exit;
  end;

  // �� �ҷ��������һ��
  if Msg.CharCode = VK_RIGHT then
  begin
    self.ImageNextClick(self);
    Handled := True;
    Exit;
  end;
end;

end.
