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
// 提示信息框
begin
  Application.MessageBox(PWideChar(msg), '提示', MB_OK + MB_ICONINFORMATION +
    MB_TOPMOST);

  Application.ProcessMessages;
end;

procedure AlertWarn(msg: string);
// 警告信息框
begin
  Application.MessageBox(PWideChar(msg), '警告', MB_OK + MB_ICONWARNING +
    MB_TOPMOST);

  Application.ProcessMessages;
end;

procedure AlertError(msg: string);
// 错误信息框
begin
  Application.MessageBox(PWideChar(msg), '错误', MB_OK + MB_ICONERROR +
    MB_TOPMOST);

  Application.ProcessMessages;
end;

procedure OpenLink(link: string);
// 使用默认程序打开链接或文件地址
begin
  ShellExecute(0, 'open', PChar(link), nil, nil, SW_SHOWNORMAL);
end;

function StreamToStr(const Stream: TStream; const Encoding: TEncoding): string;
// 数据流转字符串
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
  释放资源文件到指定文件夹，
  参数1：ResName - 资源名称
  参数2：ResType- 资源类型
  参数3：ResNewName - 存放路径
}
var
  Res: TResourceStream;
begin
  // 判断目标文件是否存在
  if FileExists(ResNewName) then
  begin
    Result := true;
    Exit;
  end;

  try
    Res := TResourceStream.Create(Instance, ResName, PChar(ResType));
    try
      Res.SavetoFile(ResNewName);
      // 隐藏资源文件
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
      AlertError(Concat('资源 [', ResName, '] 释放失败！', BR, e.Message));
    end;
  end;
end;

function GetApplicationVersion: String;
// 获取程序版本号
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
