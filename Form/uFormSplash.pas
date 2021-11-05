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
  Update; // ������ʾ�������ݣ���ֹ��������
end;

procedure TFormSplash.AddText(Value: string);
begin
  LabelSplash.Caption := Concat(LabelSplash.Caption, Value);
  Update; // ������ʾ�������ݣ���ֹ��������
end;

procedure TFormSplash.AddTextln(Value: string);
begin
  LabelSplash.Caption := Concat(LabelSplash.Caption, BR, BR, Value);
  Update; // ������ʾ�������ݣ���ֹ��������
end;

procedure TFormSplash.Close;
// �ر�����
begin
  // �ӳ� 1 ����������
  SetTimer(0, 0, 1000, @CloseTimer); // ����ʵ�������������ֹ����̫��ֱ�ӹر�
end;

procedure CloseTimer(hWnd: THandle; msg: Word; idEvent: Word;
  dwTime: LongWord); stdcall;
// SetTimer ��ʱ�������ӳ�ִ�лص�
begin
  FormSplash.Hide;
  FormSplash.Free;

  uMain.FormMain.BringToFront;

  KillTimer(hWnd, idEvent); // �رն�ʱ��
end;

end.
