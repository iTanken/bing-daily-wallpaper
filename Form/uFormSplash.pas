unit uFormSplash;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.GIFImg,
  Vcl.StdCtrls, Vcl.Imaging.jpeg;

type
  TFormSplash = class(TForm)
    ImageSplash: TImage;
    LabelSplash: TLabel;
  private
    { Private declarations }
    FParam: Pointer;
  public
    { Public declarations }
    class function Execute(AParam: Pointer): Boolean;
    procedure SetText(Value: string);
    procedure AddText(Value: string);
    procedure AddTextln(Value: string);
    procedure Close();
  published
    property StatusText: string write SetText;
  end;

var
  FormSplash: TFormSplash;

procedure CloseTimer(hWnd: THandle; msg: Word; idEvent: Word;
  dwTime: LongWord); stdcall;

implementation

uses uMain, uTools;

{$R *.dfm}
{ TFormSplash }

class function TFormSplash.Execute(AParam: Pointer): Boolean;
begin
  with TFormSplash.Create(nil) do
    try
      FParam := AParam;
      Result := ShowModal = mrOk;
    finally
      Free;
    end;
end;

procedure TFormSplash.SetText(Value: string);
begin
  LabelSplash.Caption := Value;
  Update; // 更新显示文字内容，防止界面阻塞
end;

procedure TFormSplash.AddText(Value: string);
begin
  LabelSplash.Caption := Concat(LabelSplash.Caption, Value);
  Update; // 更新显示文字内容，防止界面阻塞
end;

procedure TFormSplash.AddTextln(Value: string);
begin
  LabelSplash.Caption := Concat(LabelSplash.Caption, BR, BR, Value);
  Update; // 更新显示文字内容，防止界面阻塞
end;

procedure TFormSplash.Close;
// 关闭闪屏
begin
  // 延迟 1 秒隐藏闪屏
  SetTimer(0, 0, 1000, @CloseTimer); // 根据实际情况调整，防止闪屏太快直接关闭
end;

procedure CloseTimer(hWnd: THandle; msg: Word; idEvent: Word;
  dwTime: LongWord); stdcall;
// SetTimer 定时无阻塞延迟执行回调
begin
  FormSplash.Hide;
  FormSplash.Free;

  uMain.FormMain.BringToFront;

  KillTimer(hWnd, idEvent); // 关闭定时器
end;

end.
