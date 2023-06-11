unit UCertManage;

interface

uses
  System.Generics.Collections,IdHTTP, System.Classes;

type
  TCertItem = class(TObject)
  private
    FRegistered: Boolean;
    FID: Int64;
    FLastNetCheckDate: TDateTime;
    FLastAlertDay: Integer;
    FCertNO: string;
    FDeadLine: TDateTime;
    FCompany: string;
    FAllowOfflineDay: Integer;
    FCertName: string;
    function GetRegistered: Boolean;
    function CreateHttp:TIdHTTP;
    function GetToken:string;
    function CheckRegistered:Boolean; //������֤
    function CheckOfflineFile:Boolean;//������֤
    procedure SaveOfflineFile;//���������ļ�
  public
    constructor Create(const AID: Int64;const ACertNO:string);
    /// ֤��ID,Ψһ
    property ID:Int64 read FID;
    /// ע�����
    property CertNO:string read FCertNO write FCertNO;
    property CertName: string read FCertName write FCertName;
    ///��˾��Ϣ
    property Company:string read FCompany write FCompany;
    /// �Ƿ��Ѿ�ע����
    property Registered: Boolean read GetRegistered;
    ///���һ��������֤ʱ��
    property LastNetCheckDate:TDateTime read FLastNetCheckDate;
    ///��ǰX���������
    property LastAlertDay: Integer read FLastAlertDay;
    ///������������
    property AllowOfflineDay:Integer read FAllowOfflineDay;
    ///����ʱ��
    property DeadLine:TDateTime read FDeadLine;
  end;
  TCertManage = class(TObject)
  private
    FCerts: TObjectDictionary<Int64, TCertItem>;
  public
    constructor Create;
    destructor Destroy; override;
    function AddCert(const AID: Int64;const ACertNO:string):TCertItem;
    function CheckRegistered(const AID: Int64): Boolean; overload;
    function CheckRegistered(const AID: Int64;const ACertNO:string): Boolean; overload;
    function CheckRegistered(ACertItem: TCertItem): Boolean; overload;
    property Certs: TObjectDictionary<Int64,TCertItem> read FCerts;
  end;
  TCheckRegistered = function(const AID: Int64;const ACertNO:PAnsiChar): Boolean; stdcall;
  const Cert_URL = 'http://182.92.81.190:8087';
  const Cert_Authorization = 'Basic c2FiZXI6NDQzOTc0ODE5YzQyZTMxNTY3MDBjMTAyNDFhOTNlZjc=';
  const Cert_Username = '17394971310';
  const Cert_PassWord = 'e6e407b1edb2cca3def82992c8ef32d9';
  const Cert_FileName = '%s\Data\Cert_%d_Info.lic';
  const Cert_RSA_PubKey='QF-Certs-DOG-3F5B21E907A8';
///  ��ƷID��productType��
///1658143961096065025  NXYB   ����ҽ��
///1660192856684826626  DY  ��ҽ���߽ӿ�
///1660193135694123009  GSYJ  ����ҩ��׷�ݽӿ�
implementation

uses
  System.DateUtils, System.SysUtils, System.JSON, UComVar, System.IOUtils,
  Soap.EncdDecd;

{ TCertManage }

function TCertManage.AddCert(const AID: Int64; const ACertNO: string): TCertItem;
begin
  if not Certs.TryGetValue(AID,Result) then
  begin
    Result := TCertItem.Create(AID,ACertNO);
    Certs.Add(AID,Result);
  end else Result.CertNO := ACertNO;
end;

function TCertManage.CheckRegistered(ACertItem: TCertItem): Boolean;
begin
  Result := False;
  if not Assigned(ACertItem) then Exit;
  Result := ACertItem.Registered;
  if not Result then Goo.Msg.ShowErrorAndAbort('��ģ�%s��֤�飺[%s]û���ҵ����Ѿ����ڣ����ȹ���֤�飡',[ACertItem.CertName,ACertItem.CertNO]);
end;

function TCertManage.CheckRegistered(const AID: Int64; const ACertNO: string): Boolean;
begin
  Result := CheckRegistered(AddCert(AID,ACertNO));
end;

constructor TCertManage.Create;
begin
  FCerts := TObjectDictionary<Int64,TCertItem>.Create;
end;

destructor TCertManage.Destroy;
begin
  if Assigned(FCerts) then
  begin
    for var i in FCerts do i.Value.Free;
    FreeAndNil(FCerts);
  end;
  inherited;
end;

function TCertManage.CheckRegistered(const AID: Int64): Boolean;
var ACertItem: TCertItem;
begin
  Result := False;
  if not Certs.TryGetValue(AID,ACertItem) then Exit;
  Result := CheckRegistered(ACertItem);
end;

{ TCertItem }

function TCertItem.CheckOfflineFile: Boolean;
var Json:TJSONObject;
  NextDate:TDateTime;
  ACertNO:string;
begin
  Result := False;
  if not FileExists(Format(Cert_FileName,[goo.SystemPath,ID])) then Exit;
  Json := TJSONObject.ParseJSONValue(Goo.Crypto.Decrypt_SM4(TFile.ReadAllText(Format(Cert_FileName,[goo.SystemPath,ID])),Cert_RSA_PubKey)) as TJSONObject;
  try
    if not Assigned(Json) then Exit;
    Json.TryGetValue<string>('Company',FCompany);
    Json.TryGetValue<TDateTime>('DeadLine',FDeadLine);
    Json.TryGetValue<TDateTime>('NextDate',NextDate);
    Json.TryGetValue<string>('CertNO',ACertNO);
    Json.TryGetValue<string>('CertName',FCertName);
    Json.TryGetValue<Integer>('AlertDay',FLastAlertDay);
    Json.TryGetValue<Integer>('AllowOfflineDay',FAllowOfflineDay);
    Result := (NextDate>=Date) and (DeadLine>=Date) and (String.Compare(CertNO,ACertNO,True)=0);
  finally
    Json.Free;
  end;
end;

function TCertItem.CheckRegistered: Boolean;
var http:TIdHTTP;
  item:TJSONObject;
  ADeadLine:string;
begin
  Result := False;
  http := CreateHttp;
  try
    http.Request.CustomHeaders.AddValue('Authorization',Cert_Authorization);
    http.Request.CustomHeaders.AddValue('Blade-Auth',GetToken);
    Goo.Logger.Debug('URL=%s/api/buy-bill-common/buybill/checkRegister2?registerNum=%s&productType=%d',[Cert_URL,CertNO,ID],'CertRegister');
    var outdata := http.Get(Cert_URL+'/api/buy-bill-common/buybill/checkRegister2?registerNum='+CertNO+'&productType='+IntToStr(ID));
    Goo.Logger.Debug('OutJson=%s',[outdata],'CertRegister');
    var json := TJSONValue.ParseJSONValue(outdata);
    try
      var success := json.GetValue<Boolean>('success');
      if not success then Exit;
      if not json.TryGetValue<TJSONObject>('data',item) then Exit;
      if not item.TryGetValue<string>('deadline',ADeadLine) then Exit;
      item.TryGetValue<string>('company',FCompany);
      item.TryGetValue<string>('certName',FCertName);
      item.TryGetValue<Integer>('alertDay',FLastAlertDay);
      item.TryGetValue<Integer>('allowOfflineDay',FAllowOfflineDay);
      ADeadLine := Copy(ADeadLine, 1, 10);
      FDeadLine := StrToDateDef(ADeadLine,Date-1);
      Result := success and (DeadLine>=Date);
      if Result then
      begin
        try
          SaveOfflineFile;
        except on E: Exception do
        end;
      end;
    finally
      json.Free;
    end;
  finally
    http.Free;
  end;
end;

constructor TCertItem.Create(const AID: Int64;const ACertNO:string);
begin
  FRegistered := False;
  FLastNetCheckDate := StrToDate('2000-01-01');
  FID := AID;
  FCertNO := ACertNO;
  FLastAlertDay := 7;  //Ĭ����ǰ7������
  FAllowOfflineDay := 7;
end;

function TCertItem.CreateHttp: TIdHTTP;
begin
  Result := TIdHTTP.Create(nil);
  Result.HandleRedirects := True; //����ͷת��
  Result.ReadTimeout :=10000;     //����ʱ����
  Result.Request.ContentType := 'application/json;charset=UTF-8'; //������������Ϊjson
  Result.Request.ContentEncoding := 'utf-8';
  Result.ProtocolVersion := pv1_1;
  Result.Request.CustomHeaders.FoldLines := False;
end;

function TCertItem.GetRegistered: Boolean;
var ACheckRegistered:TCheckRegistered;
begin
  Result := FRegistered;
  //����ֻ��֤һ��
  if Result and (DaysBetween(LastNetCheckDate,Date)=0) then Exit;
  //if Assigned(ACheckRegistered) then Result := ACheckRegistered(ID,PAnsiChar(CertNO));
  //���߼��
  Result := CheckOfflineFile;
  if not Result then
  begin
    try
      Result := CheckRegistered;      //���߼��
    except on E: Exception do
    end;
  end;
  //��ǰX������
  FRegistered := Result;
  if Result then FLastNetCheckDate := Date;
  if Result and (DaysBetween(Date,DeadLine)<LastAlertDay) then
    Goo.Msg.ShowMsg('���֤�飺%s[%s]�������ڣ�����ǰ��Լ��',[CertName,CertNO]);
end;

function TCertItem.GetToken: string;
var http:TIdHTTP;
  ASource: TStream;
begin
  Result := EmptyStr;
  http := CreateHttp;
  ASource := TStringStream.Create('');
  try
    http.Request.CustomHeaders.AddValue('Authorization',Cert_Authorization);
    //http.Request.CustomHeaders.AddValue('Blade-Auth',GetToken);
    var outdata := http.Post(Cert_URL+'/api/blade-auth/oauth/token?tenantId=000000&username='+Cert_Username+'&password='+Cert_PassWord,ASource);
    var json := TJSONValue.ParseJSONValue(outdata);
    try
      Result := json.GetValue<string>('token_type') + ' ' + json.GetValue<string>('access_token');
    finally
      json.Free;
    end;
  finally
    http.Free;
    ASource.Free;
  end;

end;

procedure TCertItem.SaveOfflineFile;
var Json: TJSONObject;
begin
  Json := TJSONObject.Create;
  try
    Json.AddPair('Company',Company);
    Json.AddPair('CertNO',CertNO);
    Json.AddPair('CertName',CertName);
    Json.AddPair('AlertDay',LastAlertDay);
    Json.AddPair('AllowOfflineDay',AllowOfflineDay);
    Json.AddPair('DeadLine',FormatDateTime('YYYY-MM-DD',DeadLine));
    Json.AddPair('NextDate',FormatDateTime('YYYY-MM-DD',Now+AllowOfflineDay));
    var FileStream := TStringStream.Create(Goo.Crypto.Encrypt_SM4(Json.ToJSON,Cert_RSA_PubKey));
    try
//      TFileStream.Create(Format(Cert_FileName,[goo.SystemPath,ID]), fmCreate);
//      var JSONString := Goo.Crypto.Encrypt_AES128(Json.ToJSON,Cert_RSA_PubKey);
//      var UTF8Encoding:= TEncoding.UTF8;
//      FileStream.WriteBuffer(UTF8Encoding.GetBytes(JSONString), UTF8Encoding.GetByteCount(JSONString));
      FileStream.SaveToFile(Format(Cert_FileName,[goo.SystemPath,ID]));
    finally
      FileStream.Free;
    end;
  finally
    Json.Free;
  end;
end;

end.
