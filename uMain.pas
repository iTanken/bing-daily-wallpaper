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
    AllImages: TJSONArray; // 所有图片信息
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
    ImageCount, ImageIndex: Integer; // 图片总数和当前图片索引
    PopupMenuX, PopupMenuY: Integer; // 图片鼠标右键菜单坐标
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
// 主窗体创建事件
begin
  self.InitCaption := self.Caption;
  self.PopupMenuImage.AutoPopup := False;

  self.ShowNowTime();
  FormSplash.AddTextln('请求必应服务器获取壁纸数据 ...');
  self.InitLoad();
end;

procedure TFormMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
// 关闭确认
var
  Msg: PWideChar;
begin
  CanClose := False;
  Msg := Concat('是否关闭到系统托盘？', uTools.BR, '取消将直接退出程序！');
  if Application.MessageBox(Msg, '关闭确认', MB_OKCANCEL + MB_ICONQUESTION) = mrOK
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
        uTools.AlertError(Concat('初始化加载失败！', uTools.BR, e.Message));
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
      self.Caption := Concat(self.InitCaption, ' （',
        GetImageDate(self.GetImageJSON(self.ImageCount - 1)), ' 至 ',
        GetImageDate(self.GetImageJSON(0)), '）');
      // 显示第一张壁纸图片
      self.ImageIndex := 0;
      self.ShowImage();
    end;
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
        SetTimer(0, 0, 100, @LoadingTimer);
        Application.ProcessMessages;
      end;
    except
      on e: Exception do
      begin
        AlertWarn(Concat('进度条进度更新失败！', uTools.BR, e.Message));
      end;
    end;
  end;
end;

procedure LoadingTimer(handle: THandle; Msg: Word; idEvent: Word;
  dwTime: LongWord); stdcall;
// SetTimer 定时无阻塞延迟执行回调
begin
  try
    try
      if FormMain.loading.Visible and
        (FormMain.loading.Position < FormMain.loading.Max) then
      begin
        FormMain.loading.StepIt(); // 更新进度条进度
        Application.ProcessMessages;
      end;
    except
    end;
  finally
    KillTimer(handle, idEvent); // 关闭定时器
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
      AlertWarn(Concat('进度条进度更新失败！', uTools.BR, e.Message));
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
  Application.ProcessMessages;
end;

procedure LoadedTimer(handle: THandle; Msg: Word; idEvent: Word;
  dwTime: LongWord); stdcall;
// SetTimer 定时无阻塞延迟执行回调
begin
  FormMain.loading.Visible := False;

  KillTimer(handle, idEvent); // 关闭定时器
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
        AlertError(Concat('请求失败：HTTP ERROR ', Code));
        Exit;
      end;

      JsonStr := uTools.StreamToStr(ApiResult, TEncoding.UTF8);
      if JsonStr = '' then
      begin
        AlertError('请求失败：读取数据为空！');
        Exit;
      end;

      data := TJSONObject.ParseJSONValue(Trim(JsonStr)) as TJSONObject;
      if (data = nil) or (data.Count = 0) or (data.Values['images'] = nil) then
      begin
        AlertError('请求失败：数据解析失败，请稍后再试！');
        Exit;
      end;

      Result := data.Values['images'] as TJSONArray;
    except
      on e: Exception do
      begin
        AlertError(Concat('请求服务器获取图片信息失败！', uTools.BR, e.Message));
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
      AlertError(Concat('获取指定图片信息失败！', uTools.BR, e.Message));
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
      AlertError(Concat('获取图片日期信息失败！', uTools.BR, e.Message));
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
      AlertError(Concat('图片保存失败！', uTools.BR, e.Message));
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
        AlertError(Concat('图片加载失败！', uTools.BR, e.Message));
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

procedure TFormMain.ImageCurrentDblClick(Sender: TObject);
// 双击图片打开必应搜索链接
begin
  uTools.OpenLink(self.CopyrightLink);
end;

procedure TFormMain.ImageCurrentMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
// 鼠标右键图片弹出菜单
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
// SetTimer 定时无阻塞延迟执行回调
begin
  FormMain.PopupMenuImage.Popup(FormMain.PopupMenuX, FormMain.PopupMenuY);

  KillTimer(handle, idEvent); // 关闭定时器
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
  if self.ImageCount = 0 then
  begin
    Exit;
  end;

  if self.IsLastImage() then
  begin
    // 已经是最后一张
    self.ImageIndex := self.ImageCount - 1;

    uTools.AlertWarn(Concat('已到达最后一张图片！', uTools.BR, '最后一张图片日期为：', uTools.BR,
      '【', self.GetImageDate(nil), '】'));
    Exit;
  end;

  self.ImageIndex := self.ImageIndex + 1;
  self.ShowImage();
end;

procedure TFormMain.ImageNextClick(Sender: TObject);
// 右箭头点击事件
begin
  if self.ImageCount = 0 then
  begin
    Exit;
  end;

  if self.IsFirstImage() then
  begin
    // 已经是第一张
    self.ImageIndex := 0;
    uTools.AlertWarn(Concat('已到达第一张图片！', uTools.BR, '最新图片的日期为：', uTools.BR, '【',
      self.GetImageDate(nil), '】'));
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

procedure TFormMain.ActionSetWallpaperExecute(Sender: TObject);
// 1. 右键菜单动作：设置桌面壁纸
var
  imagePath: String;
  callState: Boolean;
begin
  imagePath := self.SaveCurrentImage();

  // 调用 Windows API 设置桌面壁纸
  callState := SystemParametersInfo(SPI_SETDESKWALLPAPER, 1, PChar(imagePath),
    SPIF_UPDATEINIFILE);

  if callState then
  begin
    AlertInfo('桌面壁纸设置成功！');
    Exit;
  end;
  AlertWarn('桌面壁纸设置失败！');
end;

procedure TFormMain.ActionSaveImageExecute(Sender: TObject);
// 2. 右键菜单动作：保存当前图片
begin
  ModuleNonVisual.SavePictureDialogCurr.Title :=
    Concat('保存当前图片：', self.ImageCurrentDate);
  ModuleNonVisual.SavePictureDialogCurr.Filter := '图片文件(*.jpg)|*.jpg'; // 文件类型过滤
  ModuleNonVisual.SavePictureDialogCurr.DefaultExt := EXT_JPG; // 自动添加扩展名
  ModuleNonVisual.SavePictureDialogCurr.FileName := self.ImageCurrentDate;

  if not ModuleNonVisual.SavePictureDialogCurr.Execute then
  begin
    // 取消保存
    AlertWarn('已取消保存当前图片！');
    Exit;
  end;

  // 保存图片
  self.ImageCurrent.Picture.SavetoFile
    (ModuleNonVisual.SavePictureDialogCurr.FileName);
  AlertInfo('当前图片保存成功！');
end;

procedure TFormMain.ActionExplorerExecute(Sender: TObject);
// 3. 右键菜单动作：浏览
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
// 4. 右键菜单动作：刷新、重载
begin
  self.InitLoad;
end;

procedure TFormMain.ActionFirstExecute(Sender: TObject);
// 5. 右键菜单动作：首页
begin
  self.ShowFirstImage();
end;

procedure TFormMain.ActionLastExecute(Sender: TObject);
// 6. 右键菜单动作：尾页
begin
  self.ShowLastImage();
end;

procedure TFormMain.ActionAboutExecute(Sender: TObject);
// 7. 右键菜单动作：关于
begin
  ABOUT.Show(self);
end;

procedure TFormMain.ActionExitExecute(Sender: TObject);
// 8. 右键菜单动作：退出程序
begin
  self.Close;
end;

procedure TFormMain.FormShortCut(var Msg: TWMKey; var Handled: Boolean);
// 监听快捷键
begin
  // ← 左方向键：上一张
  if Msg.CharCode = VK_LEFT then
  begin
    self.ImagePrevClick(self);
    Handled := True;
    Exit;
  end;

  // → 右方向键：下一张
  if Msg.CharCode = VK_RIGHT then
  begin
    self.ImageNextClick(self);
    Handled := True;
    Exit;
  end;
end;

end.
