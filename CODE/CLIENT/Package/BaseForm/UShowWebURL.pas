unit UShowWebURL;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UBaseMdiForm, Winapi.WebView2,
  Winapi.ActiveX, Vcl.Edge, cxStyles, cxClasses, System.ImageList, Vcl.ImgList,
  System.Actions, Vcl.ActnList, Vcl.ExtCtrls;

type
  TShowWebURL = class(TBaseMdiForm)
    EdgeBrowser: TEdgeBrowser;
    ///��ȡ��ҳ�ı���
    procedure EdgeBrowserDocumentTitleChanged(Sender: TCustomEdgeBrowser; const ADocumentTitle: string);
    ///��ҳ�д��µĴ���
    procedure EdgeBrowserNewWindowRequested(Sender: TCustomEdgeBrowser; Args: TNewWindowRequestedEventArgs);
    ///��ȡ���ʹ� Web ��Ϣ���ĵ��� URI��
    procedure EdgeBrowserWebMessageReceived(Sender: TCustomEdgeBrowser; Args: TWebMessageReceivedEventArgs);
    ///��ȡ Web ��Դ����
    ///  ��ȡ������ CoreWebView2WebResourceResponse ���� ��������˴˶����� CoreWebView2.WebResourceRequest �¼���ʹ�ô���Ӧ��ɡ�
    ///  ����ʹ�� CoreWebView2Environment.CreateWebResourceResponse
    ///  ����һ���յ� CoreWebView2WebResourceResponse ����Ȼ������޸��Թ�����Ӧ��
    procedure EdgeBrowserWebResourceRequested(Sender: TCustomEdgeBrowser; Args: TWebResourceRequestedEventArgs);
    ///��ȡ��ҳ�����Ĺر��¼�
    procedure EdgeBrowserWindowCloseRequested(Sender: TObject);
  private
    FAllowJump: Boolean;
    function GetURL: string;
  public
    /// <remarks>
    ///  �Ƿ�������ҳ����ҳ����ת
    /// </remarks>
    property AllowJump :Boolean read FAllowJump write FAllowJump;
    /// <summary>
    ///  Ĭ�ϴ򿪵� URL
    /// </summary>
    property URL:string read GetURL;
    procedure BeforeFormShow; override;
  end;

var
  ShowWebURL: TShowWebURL;

implementation

uses
  UComvar;

{$R *.dfm}

procedure TShowWebURL.BeforeFormShow;
var LICoreWebView2:ICoreWebView2;
begin
  inherited;
  //GetInterface( StringToGUID('{189B8AAF-0426-4748-B9AD-243F537EB46B}'),LICoreWebView2);
  //if LICoreWebView2 = EdgeBrowser.DefaultInterface then ShowMessage('LICoreWebView2�ӿ�TGUID:'+'{189B8AAF-0426-4748-B9AD-243F537EB46B}');
  //if not EdgeBrowser.WebViewCreated then Exit;
  //���û���·��
  EdgeBrowser.UserDataFolder := Goo.SystemDataPath;
  //EdgeBrowser.Navigate(URL);
  //�߳��д����ӣ�
  TThread.CreateAnonymousThread(
    procedure
    begin
      TThread.Synchronize( nil,
        procedure //var AHTMLContent: string;
        begin
          //EdgeBrowser1.NavigateToString(AHTMLContent);
          if EdgeBrowser.Navigate(URL)=false then Goo.Logger.Error('��ҳ�򿪴���%s',[URL]);    //:Navigate:��������˴�����:=true,����:=false
        end);
    end
  ).Start;
end;

procedure TShowWebURL.EdgeBrowserDocumentTitleChanged(Sender:TCustomEdgeBrowser; const ADocumentTitle: string);
begin
  inherited;
  Caption := ADocumentTitle;
end;

procedure TShowWebURL.EdgeBrowserNewWindowRequested(Sender: TCustomEdgeBrowser; Args: TNewWindowRequestedEventArgs);
begin
  inherited;
  if not AllowJump then
  begin
    Args.ArgsInterface.Set_Handled(Integer(LongBool(True)));
    var _uri:PWideChar;
    Args.ArgsInterface.Get_uri(_uri);
    Goo.Reg.ShowWebUrl(_uri);
    _uri := nil;
  end;
end;

procedure TShowWebURL.EdgeBrowserWebMessageReceived(Sender: TCustomEdgeBrowser; Args: TWebMessageReceivedEventArgs);
var webMessageAsJson,webMessageAsString: PWideChar;
begin
  inherited;
  //��ȡ�� WebView ���ݷ�����ת��Ϊ JSON �ַ�������������Ϣ��
  if Args.ArgsInterface.Get_webMessageAsJson(webMessageAsJson)<>0 then
  begin

  end;
  //��ȡ�� WebView �������ַ�����ʽ��������������Ϣ��
  if Args.ArgsInterface.TryGetWebMessageAsString(webMessageAsString)<>0 then
  begin

  end;
end;

procedure TShowWebURL.EdgeBrowserWebResourceRequested(Sender: TCustomEdgeBrowser; Args: TWebResourceRequestedEventArgs);
begin
  inherited;
  //Goo.Msg.ShowMsg(Sender.LocationURL);
end;

procedure TShowWebURL.EdgeBrowserWindowCloseRequested(Sender: TObject);
begin
  inherited;
  Close;
end;

function TShowWebURL.GetURL: string;
begin
  Result := Self.ParamList.AsString('@URL');
end;

initialization
  Goo.Reg.RegisterClass(TShowWebURL);

end.
