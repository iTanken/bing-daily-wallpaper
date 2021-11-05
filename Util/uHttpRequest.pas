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
  Get方式访问网站
  参数：
  url：要访问的网站网址
  responseText：访问的返回值
  proxyServer：代理服务器Ip
  proxyPort：代理服务器端口
  返回值：
  访问是否成功的布尔值
}
function THttpReq.Get(url: string; var responseText: string;
  proxyServer: string = ''; proxyPort: integer = 0): Boolean;
var
  IdHTTPTemp: TIdHTTP; // http客户端对象
  IdSSLIOHandlerSocketOpenSSLTemp: TIdSSLIOHandlerSocketOpenSSL; // ssl对象
  IdCompressorZLibTemp: TIdCompressorZLib; // 数据压缩对象
  isSuccess: Boolean; // 是否访问成功的布尔值
begin

  isSuccess := False; // 设置是否访问成功的布尔值默认值为false

  try
    try

      { 1, 创建TIdHTTP对象 }
      IdHTTPTemp := TIdHTTP.Create(nil);

      IdHTTPTemp.HandleRedirects := true; // 设置重定向属性，防止不能转发Url
      IdHTTPTemp.Request.BasicAuthentication := true; // 必须设置此项为true才能一次通过验证

      {
        这里设置很重要，如果不这样设置，会出错:
        HTTP/1.1 403 Bad Behavior
      }
      IdHTTPTemp.Request.Accept :=
        'text/html, image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, */*';
      IdHTTPTemp.Request.AcceptEncoding := 'gzip, deflate';
      IdHTTPTemp.Request.UserAgent := 'Mozilla/4.0';

      // 设置代理服务器
      if Trim(proxyServer) <> '' then
      begin
        IdHTTPTemp.ProxyParams.proxyServer := Trim(proxyServer); // 代理服务器IP
        IdHTTPTemp.ProxyParams.proxyPort := proxyPort; // 代理服务器端口
      end;

      { 2，创建SSL组件 }
      IdSSLIOHandlerSocketOpenSSLTemp :=
        TIdSSLIOHandlerSocketOpenSSL.Create(nil);
      {
        设置SSL组件使用的OpenSSL版本号，如果设置不正确，会出错：
        Error connectiong with ssl.
        error:1409442E:SSL routines:ssl3_read_bytes:tlsv1 alert protocal version
      }
      IdSSLIOHandlerSocketOpenSSLTemp.SSLOptions.Method := sslvTLSv1_2;
      // 设置indy的http控件使用的ssl依赖组件，必须设置，否则无法访问ssl网站
      IdHTTPTemp.IOHandler := IdSSLIOHandlerSocketOpenSSLTemp;

      { 3，创建传输数据用的压缩组件 }
      IdCompressorZLibTemp := TIdCompressorZLib.Create(nil);
      // 设置indy的http控件使用的数据压缩组件，如果不设置，那么得到的是压缩的数据，不报任何错误
      IdHTTPTemp.Compressor := IdCompressorZLibTemp;

      { 备用属性，暂时未用 }
      // // 设置身份验证帐号
      // IdHTTP1.Request.Username := Trim(account);
      // // 设置身份验证密码
      // IdHTTP1.Request.password := Trim(password);

      // 得到web回应
      responseText := IdHTTPTemp.Get(url);

      // 如果web相应正常，则设置判断请求是否成功的布尔值为true
      if IdHTTPTemp.ResponseCode = 200 then
      begin
        isSuccess := true; // 设置判断请求是否成功的布尔值为true
      end;

      // 关闭IdHTTP1连接
      IdHTTPTemp.Disconnect;

    except
      on e: Exception do
      begin
        // 调试使用
        // showMessage(e.ToString); //这里可以忽略错误，防止IdHTTP1无法访问的错误提示

        isSuccess := False;
      end;
    end;
  finally
    // 释放创建过的各个对象
    IdCompressorZLibTemp.Free;
    IdSSLIOHandlerSocketOpenSSLTemp.Free;
    IdHTTPTemp.Free;
  end;

  Result := isSuccess;
end;

end.
