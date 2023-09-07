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
    procedure EdgeBrowserWebResourceRequested(Sender: TCustomEdgeBrowser; Args:
        TWebResourceRequestedEventArgs);
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
begin
  inherited;
  //���û���·��
  EdgeBrowser.UserDataFolder := Goo.SystemDataPath;
  EdgeBrowser.Navigate(URL);
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
