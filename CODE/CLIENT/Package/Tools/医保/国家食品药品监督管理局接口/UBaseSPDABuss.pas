unit UBaseSPDABuss;

interface

uses
  UBaseSPDADefine, UBaseSPDAData, System.SysUtils, System.JSON;

type
  TBaseSPDABuss = class(TBaseSPDA)
  private
    FDataInterface: TBaseSPDAData;
    FInJson: TJSONObject;
    FOutJson: TJSONObject;
    FID: Integer;
    FPosID: Integer;
    FPosName: string;
    FPosCode: string;
    FSignNo: string;
    FCertRegisterID: Int64;
    function GetMsgid: string;
    function GetSuccessed: Boolean;
  protected
    function GetSignNo: string; virtual;
    procedure BeforeExecute(ABussID: string); virtual;
    procedure AfterExecute(ABussID: string); virtual;
    function Execute(ABussID: string): Integer;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Init; virtual;
    property DataInterface:TBaseSPDAData read FDataInterface write FDataInterface;
    property AReaID: Integer read FID write FID; /// 医保地区ID
    property CertRegisterID : Int64 read FCertRegisterID write FCertRegisterID; ///注册验证类型 ，0表示不验证
    property PosID : Integer read FPosID write FPosID;
    property PosCode : string read FPosCode write FPosCode;
    property PosName : string read FPosName write FPosName;
    property InJson  : TJSONObject read FInJson write FInJson;
    property OutJson : TJSONObject read FOutJson;
    property Successed:Boolean read GetSuccessed;
    property Msgid   : string read GetMsgid;                                    //获取报文ID
    property SignNo  : string read GetSignNo write FSignNo;	                    //交易签到流水号	ANS	30		通过签到【9001】交易获取
    ///业务
  end;

var FBaseSPDABuss:TBaseSPDABuss;

function YBBuss:TBaseSPDABuss;

implementation

uses
  UJsonObjectHelper, UBaseSPDAClassFactory, System.IniFiles, UComvar;

function YBBuss:TBaseSPDABuss;
begin
  Result := nil;
  if not Assigned(FBaseSPDABuss) then
  begin
    var _ini := TIniFile.Create(Goo.SystemDataPath+'\SPDA_Config.ini');
    try
      var _AREA := _ini.ReadInteger('TSPDA_Config','SPDA_AREA',-1);
      if _AREA<0 then Exit;
      var _Factory := FSPDAClassFactory.Item[_AREA];
      if _Factory.ID>0 then
      begin
        FBaseSPDABuss := _Factory.BussClass.Create as TBaseSPDABuss;
        FBaseSPDABuss.AReaID := _Factory.ID;
        FBaseSPDABuss.PosID  := _ini.ReadInteger('TSPDA_Config','PosID',0);
        FBaseSPDABuss.PosCode:= _ini.ReadString('TSPDA_Config','PosCode','');
        FBaseSPDABuss.PosName:= _ini.ReadString('TSPDA_Config','PosName','');
        FBaseSPDABuss.DataInterface := _Factory.InterfaceClass.Create as TBaseSPDAData;
        FBaseSPDABuss.ParamList.Add('PosID'  ,FBaseSPDABuss.PosID);
        FBaseSPDABuss.ParamList.Add('PosCode',FBaseSPDABuss.PosCode);
        FBaseSPDABuss.ParamList.Add('PosName',FBaseSPDABuss.PosName);
        FBaseSPDABuss.ParamList.Add('ApiUrl',_ini.ReadString('TSPDA_Config','ApiUrl',''));
        FBaseSPDABuss.Init;
      end;
    finally
      _ini.Free;
    end;
  end;
  Result := FBaseSPDABuss;
end;
{ TBaseSPDABuss }

procedure TBaseSPDABuss.AfterExecute(ABussID: string);
begin
  if not FDataInterface.Successed then LastErrorMessage := FDataInterface.LastErrorMessage;
end;

procedure TBaseSPDABuss.BeforeExecute(ABussID: string);
begin
  LastErrorMessage      := EmptyStr;
  FDataInterface.Input  := EmptyStr;
  FDataInterface.Output := EmptyStr;
end;

constructor TBaseSPDABuss.Create;
begin
  FCertRegisterID := 0;
end;

destructor TBaseSPDABuss.Destroy;
begin
  if Assigned(FDataInterface) then FreeAndNil(FDataInterface);
  if Assigned(FInJson)  then FreeAndNil(FInJson);
  if Assigned(FOutJson) then FreeAndNil(FOutJson);  
  inherited;
end;

function TBaseSPDABuss.Execute(ABussID: string): Integer;
begin
  Result := -1;
  if CertRegisterID>0 then Goo.Msg.CheckAndAbort(Goo.Cert.CheckRegistered(CertRegisterID,PosCode));
  BeforeExecute(ABussID);
  try
    if Assigned(InJson) then FDataInterface.Input := InJson.ToString;
    if Assigned(OutJson) then FreeAndNil(OutJson);                              //每次都先清空返回值
    FDataInterface.BussID := ABussID;
    Result := FDataInterface.Execute;
    if FDataInterface.Output<>EmptyStr then FOutJson := TJSONObject.SO(FDataInterface.Output);
  finally
    AfterExecute(ABussID);
  end;
end;

function TBaseSPDABuss.GetMsgid: string;
begin
  Result := EmptyStr;
  var _YbLSNo := Goo.DB.ExecProc('GP_QingDao_GetLSH');
  Result := Format('%s%s%s', [PosCode,FormatDateTime('YYYYMMDDHHMMSS', Now),Format('%.4d', [_YbLSNo])]);
end;

function TBaseSPDABuss.GetSignNo: string;
begin
  if FSignNo=EmptyStr then FSignNo := Goo.DB.QueryOneFiled<string>('select SignNo from YB_Sign where QdFlag=1 and Erec=%d and QdDate=''%s''',[Goo.Login.LoginUserRec,FormatDateTime('yyyy-MM-dd',Now)]);
  //如果今天还没有签到，就在线获取
  if FSignNo=EmptyStr then
  begin
    FSignNo := '';
    //将当天的签到保存到数据库
    if FSignNo<>EmptyStr then Goo.DB.ExecProc('GP_InsertYBSign', ['@Erec', '@SignNo', '@QdDate', '@QdFlag'],[Goo.Login.LoginUserRec,FSignNo, FormatDateTime('yyyy-MM-dd',Now), 1]);
  end;
  Result := FSignNo;
end;

function TBaseSPDABuss.GetSuccessed: Boolean;
begin
  Result := DataInterface.Successed;
end;

procedure TBaseSPDABuss.Init;
begin
  if Assigned(DataInterface) then DataInterface.ParamList.Assign(ParamList);
end;

initialization

finalization
  if Assigned(FBaseSPDABuss) then FreeAndNil(FBaseSPDABuss);
  

end.
