unit UServer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.ImageList, Vcl.ImgList,
  Vcl.Buttons, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Menus;

type
  TServer = class(TForm)
    ImageList1: TImageList;
    Panel_Top: TPanel;
    btn_Start: TSpeedButton;
    btn_Stop: TSpeedButton;
    ListView_ConnectInfo: TListView;
    StatusBar: TStatusBar;
    MainMenu: TMainMenu;
    N1: TMenuItem;
    NDataBaseSet: TMenuItem;
    TrayIcon1: TTrayIcon;
    PopupMenu1: TPopupMenu;
    N2: TMenuItem;
    N3: TMenuItem;
    btn_Check: TSpeedButton;
    procedure btn_CheckClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btn_StartClick(Sender: TObject);
    procedure btn_StopClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListView_ConnectInfoDrawItem(Sender: TCustomListView; Item:
        TListItem; Rect: TRect; State: TOwnerDrawState);
    procedure N2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure NDataBaseSetClick(Sender: TObject);
    procedure TrayIcon1DblClick(Sender: TObject);
  private
    { Private declarations }
  public
    procedure AddLog(AMSG:string);
  end;

var
  Server: TServer;

implementation

uses UContainer, UCOMM, UDBSET, System.IniFiles,IdTCPConnection,
  Datasnap.DSCommonServer, Data.DBXCommon;

{$R *.dfm}

procedure TServer.AddLog(AMSG: string);
begin
  Logger.Debug(AMSG,'服务端');
end;

procedure TServer.btn_CheckClick(Sender: TObject);
var ds: TDSConnectEventObject;
  ClientConnection:TIdTCPConnection;
begin
  ListView_ConnectInfo.Items.Clear;
  for var list in Container.ClientConnectList do
  begin
    with ListView_ConnectInfo.items.add do
    begin    
      ds := list.Value.AsType<TDSConnectEventObject>;
      ClientConnection := TIdTCPConnection(list.Key);
      Caption := IntToStr(list.Key);
      subitems.add(ClientConnection.Socket.Binding.PeerIP + ':' + ClientConnection.Socket.Binding.PeerPort.ToString);
      //subitems.add(ds.ConnectProperties[TDBXPropertyNames.UserName]);
      //subitems.add(ds.ConnectProperties[TDBXPropertyNames.Password]);
      //then subitems.add(ds.ChannelInfo.ClientInfo.AppName);
      subitems.add(FormatDateTime('yyyy-mm-dd hh:nn:ss', Now));
    end;
  end;
end;

procedure TServer.FormCreate(Sender: TObject);
begin
  var iniFile := TIniFile.Create(ExtractFilePath(Application.ExeName)+'ServerConfig.ini');
  try
    //初始化数据库连接参数信息
    DataBaseAddress  := iniFile.ReadString('SERVER','DBADDR','127.0.0.1');
    DataBaseUser     := iniFile.ReadString('SERVER','DBUSER','sa');
    DataBasePassword := iniFile.ReadString('SERVER','DBPASS','df20010501');
    //服务器端口信息
    DataSnapPort := iniFile.ReadInteger('SERVER','DataSnapPort',212);   //DataSnap端口
    HttpPort     := iniFile.ReadInteger('SERVER','HttpPort',8080);;  //HTTP 端口
  finally
    iniFile.Free;
  end;
  Panel_Top.Color := RGB(105,181,219);  //淡蓝色
  Panel_Top.Color := RGB(133,193,95);  //浅绿色
  btn_StopClick(nil);
end;

procedure TServer.btn_StartClick(Sender: TObject);
begin
  ListView_ConnectInfo.Items.Clear;
  try
    Container.DSServer1.Stop;
    Container.DSServerClass1.Stop;
    Container.DSTCPServerTransport1.Port := DataSnapPort;
    Container.DSHTTPService1.DSPort      := DataSnapPort;
    Container.DSHTTPService1.HttpPort    := HttpPort;
    try
      Container.DSServerClass1.Start;
      Container.DSServer1.Start;      
    except on E: Exception do
      ShowMessage('错误：'+e.Message);
    end;
    if Container.DSServer1.Started then
    begin
      StatusBar.Panels[1].Text := Format('连接状态：%s',['打开']);
      StatusBar.Panels[2].Text := Format('服务器：%s',[DataBaseAddress]);
      StatusBar.Panels[3].Text := Format('端口：%d ; %d',[DataSnapPort,HttpPort]);
      btn_Start.ImageIndex := 5;
    end;
  except on E: Exception do
    ShowMessage('错误：'+e.Message);
  end;
end;

procedure TServer.btn_StopClick(Sender: TObject);
begin
  if Assigned(Sender) then Container.DSServer1.Stop;
  ListView_ConnectInfo.Items.Clear;
  btn_Start.ImageIndex := 2;
  StatusBar.Panels[1].Text := Format('连接状态：%s',['关闭']);
  StatusBar.Panels[2].Text := Format('服务器：%s',[DataBaseAddress]);
  StatusBar.Panels[3].Text := Format('端口：%d ; %d',[DataSnapPort,HttpPort]);
end;

procedure TServer.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caNone;
  Hide;
end;

procedure TServer.ListView_ConnectInfoDrawItem(Sender: TCustomListView; Item: TListItem; Rect: TRect; State: TOwnerDrawState);
begin
  if Item.Index mod 2 =0 then
      Sender.Canvas.Brush.Color :=clSkyBlue
  else
      Sender.Canvas.Brush.Color :=clWhite;
end;

procedure TServer.N2Click(Sender: TObject);
begin
  if not(MessageDlg('确认要退出系统',mtWarning,[mbYes, mbNo],0) in [mrYes,mrOk]) then Exit;
  Application.Terminate;
end;

procedure TServer.N3Click(Sender: TObject);
begin
  Show;
end;

procedure TServer.NDataBaseSetClick(Sender: TObject);
begin
   //设置数据库服务器
   if not ShowServerDBSET then Exit;
end;

procedure TServer.TrayIcon1DblClick(Sender: TObject);
begin
  if Visible then Hide else Show;
end;

end.
