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

    // 注册快捷键
    procedure RegHotKey();
    // 响应快捷键消息
    procedure HotKeyDown(var msg: Tmessage); message WM_HOTKEY;

  var
    AllImages: TJSONArray; // 所有图片信息
    ImageCount, ImageIndex: Integer; // 图片总数和当前图片索引
    InitCaption, CopyrightInfo, CopyrightLink: String; // 必应图片版权信息和链接
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
// 主窗体创建事件
begin
  self.InitCaption := self.Caption;

  FormSplash.AddTextln('注册程序功能快捷键 ...');
  RegHotKey();

  self.ShowNowTime();
  FormSplash.AddTextln('请求必应服务器获取壁纸数据 ...');
  self.InitLoad();
end;

procedure TFormMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
// 关闭确认
var
  msg: PWideChar;
begin
  CanClose := False;
  msg := Concat('是否关闭到系统托盘？', uTools.BR, '取消将直接退出程序！');
  if MessageBox(self.Handle, msg, '关闭确认', MB_OKCANCEL + MB_ICONQUESTION) = mrOK
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
// 初始化加载
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
        // 初始化加载失败
        uTools.AlertError(self.Handle, Concat('初始化加载失败！', uTools.BR,
          e.Message));
        Exit;
      end;
    end;
  finally
    data.Free;
    self.ImageCount := self.AllImages.Count;
    self.LoadEnd();
    // 显示第一张壁纸图片
    self.ImageIndex := 0;
    self.ShowImage();
  end;
end;

procedure TFormMain.LoadStart;
// 加载开始，显示进度条
var
  i: Integer;
begin
  with self.loading do
  begin
    // 进度归零
    Position := 0;

    // 进度条位置及大小
    Top := self.StatusDrawRect.Top;
    Left := self.StatusDrawRect.Left;
    Width := self.StatusDrawRect.right - self.StatusDrawRect.Left;
    Height := self.StatusDrawRect.bottom - self.StatusDrawRect.Top;

    // 显示进度条
    Visible := True;
    try
      // 进程条的拥有者为状态条
      Parent := self.StatusBarBtm;
      // 定时更新进度
      for i := Min to Max do
      begin
        StepIt();
        Application.ProcessMessages;
        // SetTimer(0, 0, 1, @LoadingTimer);
      end;
    except
      on e: Exception do
      begin
        AlertWarn(self.Handle, Concat('进度条进度更新失败！', uTools.BR, e.Message));
      end;
    end;
  end;
end;

procedure LoadingTimer(hWnd: THandle; msg: Word; idEvent: Word;
  dwTime: LongWord); stdcall;
// SetTimer 定时无阻塞延迟执行回调
begin
  try
    if FormMain.loading.Visible and
      (FormMain.loading.Position < FormMain.loading.Max) then
    begin
      FormMain.loading.StepIt(); // 更新进度条进度
    end;
  except
  end;
end;

procedure TFormMain.LoadProgress(Position: Integer = 0);
// 加载进度
begin
  if Position < loading.Position then
  begin
    // 新进度小于当前进度
    Exit;
  end;

  try
    // 更新进度
    loading.Position := Position;
    Application.ProcessMessages;
  except
    on e: Exception do
    begin
      AlertWarn(self.Handle, Concat('进度条进度更新失败！', uTools.BR, e.Message));
    end;
  end;
end;

procedure TFormMain.LoadEnd;
// 加载完成，隐藏进度条
begin
  loading.Position := loading.Max;
  Application.ProcessMessages;
  // 延迟 2 毫秒隐藏进度条
  SetTimer(0, 0, 200, @LoadedTimer);
end;

procedure LoadedTimer(hWnd: THandle; msg: Word; idEvent: Word;
  dwTime: LongWord); stdcall;
// SetTimer 定时无阻塞延迟执行回调
begin
  FormMain.loading.Visible := False;
  KillTimer(hWnd, idEvent); // 关闭定时器
end;

procedure TFormMain.StatusBarBtmDrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
// 绘制状态栏
begin
  StatusDrawRect := Rect;

  // 字体加粗、加下划线
  StatusBar.Canvas.Font.Style := [TFontStyle.fsBold, TFontStyle.fsUnderline];

  // 填充内容
  StatusBar.Canvas.FillRect(Rect);
  StatusBar.Canvas.TextRect(Rect, Rect.Left, Rect.Top, Panel.Text);
end;

procedure TFormMain.LabelCopyrightClick(Sender: TObject);
// 点击版权信息打开版权链接
begin
  uTools.OpenLink(self.CopyrightLink);
end;

function TFormMain.ShowNowTime: String;
// 在状态栏显示当前时间
begin
  Result := FormatDateTime('yyyy-MM-dd HH:mm:ss', Now);
  self.StatusBarBtm.Panels[2].Text := Concat('当前时间：', Result);
end;

function TFormMain.GetImages(data: TJSONObject; idx: Integer = 0;
  n: Integer = 7): TJSONArray;
// 请求 Bing HPImageArchive API 获取图片信息 JSON 数组
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
        AlertError(self.Handle, Concat('请求失败：HTTP ERROR ', Code));
        Exit;
      end;

      ApiResSize := ApiResult.Size;
      if ApiResSize = 0 then
      begin
        AlertError(self.Handle, '请求失败：返回数据为空！');
        Exit;
      end;

      ApiResPtr := AllocMem(ApiResSize); // 申请内存
      ApiResult.Position := 0; // 设置要读取的内容的起始位置
      ApiResult.ReadBuffer(ApiResPtr^, ApiResSize); // 读取流中的数据

      JsonStr := String(UTF8ToAnsi(ApiResPtr));
      if JsonStr = '' then
      begin
        AlertError(self.Handle, '请求失败：读取数据为空！');
        Exit;
      end;

      data := TJSONObject.ParseJSONValue(Trim(JsonStr)) as TJSONObject;
      if (data = nil) or (data.Count = 0) or (data.Values['images'] = nil) then
      begin
        AlertError(self.Handle, '请求失败：数据解析失败，请稍后再试！');
        Exit;
      end;

      Result := data.Values['images'] as TJSONArray;
    except
      on e: Exception do
      begin
        AlertError(self.Handle, Concat('请求服务器获取图片信息失败！', uTools.BR, e.Message));
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
// 根据图片信息 JSON 数组下标获取指定图片信息
begin
  Result := nil;
  try
    if (index < 0) or (index > (self.ImageCount - 1)) then
    begin
      // 下标越界
      Exit;
    end;
    Result := self.AllImages.Items[index] as TJSONObject;
  except
    on e: Exception do
    begin
      AlertError(self.Handle, Concat('获取指定图片信息失败！', uTools.BR, e.Message));
    end;
  end;
end;

function TFormMain.GetImageDate(Image: TJSONObject = nil): String;
// 获取指定图片或当前图片日期信息
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
      AlertError(self.Handle, Concat('获取图片日期信息失败！', uTools.BR, e.Message));
    end;
  end;
end;

function TFormMain.SaveCurrentImage: String;
// 保存当前显示图片，并返回图片保存物理路径
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
      AlertError(self.Handle, Concat('图片保存失败！', uTools.BR, e.Message));
    end;
  end;
end;

procedure TFormMain.ShowImage();
// 根据图片信息 JSON 数组下标显示指定壁纸图片
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

      // 在状态栏显示壁纸日期
      self.StatusBarBtm.Panels[0].Text := self.GetImageDate(Image);
      self.LoadProgress(50);

      // 在状态栏显示壁纸版权信息
      self.CopyrightLink := Image.GetValue('copyrightlink').Value;
      self.CopyrightInfo := Image.GetValue('copyright').Value;
      self.StatusBarBtm.Panels[1].Text := self.CopyrightInfo;
      self.StatusBarBtm.Hint := self.CopyrightInfo;
      self.LoadProgress(60);

      // 获取壁纸文件流
      imageStream := TMemoryStream.Create();
      ModuleNonVisual.BingImageIdHTTP.Get
        (Concat(API_BASIC, Image.GetValue('url').Value), imageStream);
      self.LoadProgress(70);
      // 显示壁纸文件
      imageStream.Position := 0;
      self.ImageCurrent.Picture.LoadFromStream(imageStream);
      self.LoadProgress(90);
    except
      on e: Exception do
      begin
        AlertError(self.Handle, Concat('图片加载失败！', uTools.BR, e.Message));
      end;
    end;
  finally
    FreeAndNil(imageStream);
    self.LoadEnd();
  end;
end;

procedure TFormMain.ShowFirstImage;
// 显示第一张图片（最新）
begin
  self.ImageIndex := 0;
  self.ShowImage();
end;

procedure TFormMain.ShowLastImage;
// 显示最后一张图片（最旧）
begin
  self.ImageIndex := self.ImageCount - 1;
  self.ShowImage();
end;

procedure TFormMain.ImageCurrentMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
// 鼠标右键图片弹出菜单
begin
  if Button = mbRight then
  begin
    ModuleNonVisual.PopupMenuImage.Popup(Left + X + 5, Top + Y + 29);
  end;
end;

procedure TFormMain.ImageCurrentMouseEnter(Sender: TObject);
// 鼠标移入图片显示箭头
begin
  self.ImagePrev.Visible := not self.IsLastImage();
  self.ImageNext.Visible := not self.IsFirstImage();
end;

procedure TFormMain.ImageCurrentMouseLeave(Sender: TObject);
// 鼠标移出图片隐藏箭头
begin
  self.ImagePrev.Visible := False;
  self.ImageNext.Visible := False;
end;

procedure TFormMain.ImageCurrentMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
// 鼠标在图片上移动
begin
  self.ImageCurrentMouseEnter(Sender);
end;

procedure TFormMain.ImagePrevMouseEnter(Sender: TObject);
// 左箭头鼠标移入事件
begin
  self.ImagePrev.Visible := True;
end;

procedure TFormMain.ImageNextMouseEnter(Sender: TObject);
// 右箭头鼠标移入事件
begin
  self.ImageNext.Visible := True;
end;

procedure TFormMain.ImagePrevClick(Sender: TObject);
// 左箭头点击事件
begin
  if self.IsLastImage() then
  begin
    // 已经是最后一张
    self.ImageIndex := self.ImageCount - 1;

    uTools.AlertWarn(self.Handle, Concat('已到达最后一张图片！', uTools.BR, '最后一张图片日期为：',
      uTools.BR, '【', self.GetImageDate(nil), '】'));
    Exit;
  end;

  self.ImageIndex := self.ImageIndex + 1;
  self.ShowImage();
end;

procedure TFormMain.ImageNextClick(Sender: TObject);
// 右箭头点击事件
begin
  if self.IsFirstImage() then
  begin
    // 已经是第一张
    self.ImageIndex := 0;
    uTools.AlertWarn(self.Handle, Concat('已到达第一张图片！', uTools.BR, '最新图片的日期为：',
      uTools.BR, '【', self.GetImageDate(nil), '】'));
    Exit;
  end;

  self.ImageIndex := self.ImageIndex - 1;
  self.ShowImage();
end;

function TFormMain.IsFirstImage: Boolean;
// 是否为第一张图片
begin
  Result := self.ImageIndex <= 0;
end;

function TFormMain.IsLastImage: Boolean;
// 是否为最后一张图片
begin
  Result := self.ImageIndex >= (self.ImageCount - 1);
end;

procedure TFormMain.RegHotKey;
// 注册快捷键
var
  HotKeyID: Integer;
begin
  // 注册快捷键，减 $C000 保证取值范围的限制
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
// 监听快捷键
begin
  // ← 左方向键：上一张
  if (msg.LParamLo = 0) AND (msg.LParamHi = VK_LEFT) then
  begin
    self.ImagePrevClick(self);
    Exit;
  end;

  // → 右方向键：下一张
  if (msg.LParamLo = 0) AND (msg.LParamHi = VK_RIGHT) then
  begin
    self.ImageNextClick(self);
    Exit;
  end;

  // Ctrl + D : 设置桌面壁纸
  if (msg.LParamLo = MOD_CONTROL) AND (msg.LParamHi = 68) then
  begin
    ModuleNonVisual.ActionSetWallpaperExecute(self);
    Exit;
  end;
  // Ctrl + S : 保存当前图片
  if (msg.LParamLo = MOD_CONTROL) AND (msg.LParamHi = 83) then
  begin
    ModuleNonVisual.ActionSaveImageExecute(self);
    Exit;
  end;
  // Ctrl + R : 刷新（重新请求 API 获取数据）
  if (msg.LParamLo = MOD_CONTROL) AND (msg.LParamHi = 82) then
  begin
    self.InitLoad;
    Exit;
  end;
  // Alt + F1 : 首页
  if (msg.LParamLo = MOD_ALT) AND (msg.LParamHi = VK_F1) then
  begin
    self.ShowFirstImage();
    Exit;
  end;
  // Alt + F2 : 尾页
  if (msg.LParamLo = MOD_ALT) AND (msg.LParamHi = VK_F2) then
  begin
    self.ShowLastImage();
    Exit;
  end;
  // Ctrl + A : 关于
  if (msg.LParamLo = MOD_CONTROL) AND (msg.LParamHi = 65) then
  begin
    ModuleNonVisual.ActionAboutExecute(self);
    Exit;
  end;
  // Ctrl + W : 退出
  if (msg.LParamLo = MOD_CONTROL) AND (msg.LParamHi = 87) then
  begin
    self.Close;
  end;
end;

end.
