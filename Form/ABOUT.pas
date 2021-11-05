unit About;

interface

uses WinApi.Windows, WinApi.ShellAPI, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.ExtCtrls, Vcl.Imaging.pngimage;

type
  TAboutBox = class(TForm)
    PanelAbout: TPanel;
    ProgramIcon: TImage;
    ProductName: TLabel;
    Version: TLabel;
    Copyright: TLabel;
    Comments: TLabel;
    OKButton: TButton;
    LabelBingApi: TLabel;
    procedure OKButtonClick(Sender: TObject);
    procedure ProgramIconClick(Sender: TObject);
    procedure LabelBingApiClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutBox: TAboutBox;

procedure Show(AOwner: TComponent);

implementation

uses uTools;

{$R *.dfm}

procedure TAboutBox.FormCreate(Sender: TObject);
begin
  self.Version.Caption := Concat('版本：', uTools.GetApplicationVersion);
end;

procedure TAboutBox.LabelBingApiClick(Sender: TObject);
// 访问必应 API
begin
  uTools.OpenLink(Concat(API_BASIC, API_PATH, '&idx=0&n=7'));
end;

procedure TAboutBox.ProgramIconClick(Sender: TObject);
// 点击图标在浏览器中访问指定地址
begin
  uTools.OpenLink('http://192.168.200.39:999/liutianqi');
end;

procedure TAboutBox.OKButtonClick(Sender: TObject);
// 点击确定按钮关闭关于弹窗
begin
  self.Close;
  self.Free;
end;

procedure Show(AOwner: TComponent);
// 显示关于信息弹窗
begin
  AboutBox := About.TAboutBox.Create(AOwner);
  AboutBox.Visible := True;
end;

end.
