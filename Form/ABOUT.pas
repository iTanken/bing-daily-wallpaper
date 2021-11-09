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

    procedure FormCreate(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
    procedure ProgramIconClick(Sender: TObject);
    procedure LabelBingApiClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
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
  self.Version.Caption := Concat('�汾��', uTools.GetApplicationVersion);
end;

procedure TAboutBox.LabelBingApiClick(Sender: TObject);
// ���ʱ�Ӧ API
begin
  uTools.OpenLink(Concat(API_BASIC, API_PATH, '&idx=0&n=7'));
end;

procedure TAboutBox.ProgramIconClick(Sender: TObject);
// ���ͼ����������з���ָ����ַ
begin
  uTools.OpenLink('https://192.168.200.39:999/liutianqi');
end;

procedure TAboutBox.OKButtonClick(Sender: TObject);
// ���ȷ����ť�رչ��ڵ���
begin
  self.Close;
end;

procedure TAboutBox.FormClose(Sender: TObject; var Action: TCloseAction);
// �رպ��ͷ�
begin
  FreeAndNil(AboutBox);
end;

procedure Show(AOwner: TComponent);
// ��ʾ������Ϣ����
begin
  if AboutBox <> nil then
  begin
    AboutBox.Visible := True;
    Exit;
  end;

  AboutBox := TAboutBox.Create(AOwner);
  AboutBox.Visible := True;
end;

end.
