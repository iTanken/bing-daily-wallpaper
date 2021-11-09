unit uTools;

interface

uses
  Winapi.Windows, Winapi.ShellAPI,

  System.Classes, System.SysUtils,

  Vcl.Forms;

procedure AlertInfo(msg: string);
procedure AlertWarn(msg: string);
procedure AlertError(msg: string);
procedure OpenLink(link: string);

function StreamToStr(const Stream: TStream; const Encoding: TEncoding): string;
function ExtractRes(Instance: NativeUInt;
  ResName, ResType, ResNewName: string): Boolean;
function GetApplicationVersion: String;

var
  APP_PATH: string;

const
  BR = #13#10;
  EXT_JPG = '.jpg';
  API_BASIC = 'https://cn.bing.com';
  API_PATH = '/HPImageArchive.aspx?format=js';
  DEF_UA = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/95.0.4638.54 Safari/537.36 Edg/95.0.1020.40';

implementation

uses uMain;

procedure AlertInfo(msg: string);
// ��ʾ��Ϣ��
begin
  Application.MessageBox(PWideChar(msg), '��ʾ', MB_OK + MB_ICONINFORMATION +
    MB_TOPMOST);

  Application.ProcessMessages;
end;

procedure AlertWarn(msg: string);
// ������Ϣ��
begin
  Application.MessageBox(PWideChar(msg), '����', MB_OK + MB_ICONWARNING +
    MB_TOPMOST);

  Application.ProcessMessages;
end;

procedure AlertError(msg: string);
// ������Ϣ��
begin
  Application.MessageBox(PWideChar(msg), '����', MB_OK + MB_ICONERROR +
    MB_TOPMOST);

  Application.ProcessMessages;
end;

procedure OpenLink(link: string);
// ʹ��Ĭ�ϳ�������ӻ��ļ���ַ
begin
  ShellExecute(0, 'open', PChar(link), nil, nil, SW_SHOWNORMAL);
end;

function StreamToStr(const Stream: TStream; const Encoding: TEncoding): string;
// ������ת�ַ���
var
  StringBytes: TBytes;
begin
  Stream.Position := 0;
  SetLength(StringBytes, Stream.Size);
  Stream.ReadBuffer(StringBytes, Stream.Size);
  Result := Encoding.GetString(StringBytes);
end;

function ExtractRes(Instance: THandle;
  ResName, ResType, ResNewName: string): Boolean;
{
  �ͷ���Դ�ļ���ָ���ļ��У�
  ����1��ResName - ��Դ����
  ����2��ResType- ��Դ����
  ����3��ResNewName - ���·��
}
var
  Res: TResourceStream;
begin
  // �ж�Ŀ���ļ��Ƿ����
  if FileExists(ResNewName) then
  begin
    Result := true;
    Exit;
  end;

  try
    Res := TResourceStream.Create(Instance, ResName, PChar(ResType));
    try
      Res.SavetoFile(ResNewName);
      // ������Դ�ļ�
      SetFileAttributes(PWideChar(ResNewName), FILE_ATTRIBUTE_HIDDEN +
        FILE_ATTRIBUTE_SYSTEM);
      Result := true;
    finally
      Res.Free;
    end;
  except
    on e: Exception do
    begin
      Result := false;
      AlertError(Concat('��Դ [', ResName, '] �ͷ�ʧ�ܣ�', BR, e.Message));
    end;
  end;
end;

function GetApplicationVersion: String;
// ��ȡ����汾��
var
  FileName: String;
  InfoSize, Wnd: DWORD;
  VerBuf: Pointer;
  VerInfo: ^VS_FIXEDFILEINFO;
begin
  Result := '0.0.0.0';
  FileName := Application.ExeName;
  InfoSize := GetFileVersionInfoSize(PChar(FileName), Wnd);
  if InfoSize <> 0 then
  begin
    GetMem(VerBuf, InfoSize);
    try
      if GetFileVersionInfo(PChar(FileName), Wnd, InfoSize, VerBuf) then
      begin
        VerInfo := nil;
        VerQueryValue(VerBuf, '\', Pointer(VerInfo), Wnd);
        if VerInfo <> nil then
          Result := Format('%d.%d.%d.%d', [VerInfo^.dwFileVersionMS shr 16,
            VerInfo^.dwFileVersionMS and $0000FFFF,
            VerInfo^.dwFileVersionLS shr 16, VerInfo^.dwFileVersionLS and
            $0000FFFF]);
      end;
    finally
      FreeMem(VerBuf, InfoSize);
    end;
  end;
end;

end.
