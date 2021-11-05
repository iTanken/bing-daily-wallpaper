unit uHttpRequest;

interface

uses
  System.SysUtils, System.Variants, System.Classes, System.Types,
  IdIOHandler, IdIOHandlerSocket,
  IdIOHandlerStack, IdSSL, IdSSLOpenSSL, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdHTTP, IdZLibCompressorBase, IdCompressorZLib;

type
  THttpReq = class
    IdHTTP1: TIdHTTP;
    IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;

  public
    { Public declarations }
    function Get(url: string; var responseText: string;
      proxyServer: string = ''; proxyPort: integer = 0): Boolean;
  end;

var
  httpReq: THttpReq;

implementation

{ THttpReq }

{
  Get��ʽ������վ
  ������
  url��Ҫ���ʵ���վ��ַ
  responseText�����ʵķ���ֵ
  proxyServer�����������Ip
  proxyPort������������˿�
  ����ֵ��
  �����Ƿ�ɹ��Ĳ���ֵ
}
function THttpReq.Get(url: string; var responseText: string;
  proxyServer: string = ''; proxyPort: integer = 0): Boolean;
var
  IdHTTPTemp: TIdHTTP; // http�ͻ��˶���
  IdSSLIOHandlerSocketOpenSSLTemp: TIdSSLIOHandlerSocketOpenSSL; // ssl����
  IdCompressorZLibTemp: TIdCompressorZLib; // ����ѹ������
  isSuccess: Boolean; // �Ƿ���ʳɹ��Ĳ���ֵ
begin

  isSuccess := False; // �����Ƿ���ʳɹ��Ĳ���ֵĬ��ֵΪfalse

  try
    try

      { 1, ����TIdHTTP���� }
      IdHTTPTemp := TIdHTTP.Create(nil);

      IdHTTPTemp.HandleRedirects := true; // �����ض������ԣ���ֹ����ת��Url
      IdHTTPTemp.Request.BasicAuthentication := true; // �������ô���Ϊtrue����һ��ͨ����֤

      {
        �������ú���Ҫ��������������ã������:
        HTTP/1.1 403 Bad Behavior
      }
      IdHTTPTemp.Request.Accept :=
        'text/html, image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, */*';
      IdHTTPTemp.Request.AcceptEncoding := 'gzip, deflate';
      IdHTTPTemp.Request.UserAgent := 'Mozilla/4.0';

      // ���ô��������
      if Trim(proxyServer) <> '' then
      begin
        IdHTTPTemp.ProxyParams.proxyServer := Trim(proxyServer); // ���������IP
        IdHTTPTemp.ProxyParams.proxyPort := proxyPort; // ����������˿�
      end;

      { 2������SSL��� }
      IdSSLIOHandlerSocketOpenSSLTemp :=
        TIdSSLIOHandlerSocketOpenSSL.Create(nil);
      {
        ����SSL���ʹ�õ�OpenSSL�汾�ţ�������ò���ȷ�������
        Error connectiong with ssl.
        error:1409442E:SSL routines:ssl3_read_bytes:tlsv1 alert protocal version
      }
      IdSSLIOHandlerSocketOpenSSLTemp.SSLOptions.Method := sslvTLSv1_2;
      // ����indy��http�ؼ�ʹ�õ�ssl����������������ã������޷�����ssl��վ
      IdHTTPTemp.IOHandler := IdSSLIOHandlerSocketOpenSSLTemp;

      { 3���������������õ�ѹ����� }
      IdCompressorZLibTemp := TIdCompressorZLib.Create(nil);
      // ����indy��http�ؼ�ʹ�õ�����ѹ���������������ã���ô�õ�����ѹ�������ݣ������κδ���
      IdHTTPTemp.Compressor := IdCompressorZLibTemp;

      { �������ԣ���ʱδ�� }
      // // ���������֤�ʺ�
      // IdHTTP1.Request.Username := Trim(account);
      // // ���������֤����
      // IdHTTP1.Request.password := Trim(password);

      // �õ�web��Ӧ
      responseText := IdHTTPTemp.Get(url);

      // ���web��Ӧ�������������ж������Ƿ�ɹ��Ĳ���ֵΪtrue
      if IdHTTPTemp.ResponseCode = 200 then
      begin
        isSuccess := true; // �����ж������Ƿ�ɹ��Ĳ���ֵΪtrue
      end;

      // �ر�IdHTTP1����
      IdHTTPTemp.Disconnect;

    except
      on e: Exception do
      begin
        // ����ʹ��
        // showMessage(e.ToString); //������Ժ��Դ��󣬷�ֹIdHTTP1�޷����ʵĴ�����ʾ

        isSuccess := False;
      end;
    end;
  finally
    // �ͷŴ������ĸ�������
    IdCompressorZLibTemp.Free;
    IdSSLIOHandlerSocketOpenSSLTemp.Free;
    IdHTTPTemp.Free;
  end;

  Result := isSuccess;
end;

end.
