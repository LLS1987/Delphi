unit UCommRXTrans;

interface

uses Windows, SysUtils, IdHTTP, Classes,Variants, DBClient, ComObj,
 DB, Math,Forms,Dialogs, System.JSON;

type
  TQFHTTP = class(TIdHTTP)
  public
    function Post(AURL: string; const ASource: TStrings; FailedTryCount: Integer):string; overload;
  end;
  TRXTrans = class
  private
    FLastErrorMessage: string;
    FDoctorName: string;
    FBillStatus: Integer;
    FID: string;
    procedure AddLog(AMSG:string);
    function GetHTTP(ATimeOut: Integer = -1): TQFHTTP;
    function CheckSuccess(const AJson:string):Boolean;
    function GetPicName(const APicURL:string):string;
    procedure DeletePicture(TypeChar: Integer; TypeRec: Integer);   //ɾ�����ݿ�ͼƬ
  protected
    FSaveLog:Boolean;//�Ƿ񱣴���־
  public
    constructor Create;
    destructor Destroy; override;
    function GetToken:string;
    property ID:string read FID;
    property LastErrorMessage:string read FLastErrorMessage;
    property DoctorName:string read FDoctorName;  //��˵�ҽ������
    property BillStatus:Integer read FBillStatus; // 1 ͨ�� -1 ���� 0 �ȴ�
  end;

const C_RXTranUrl = 'http://agent.dyzhkj.cn/bbox2-web-wagent/%s';   //��ʽ
//const C_RXTranUrl = 'http://39.108.95.246:6418/bbox2-web-wagent/%s';  //����

implementation

uses jpeg, UComVar, UParamList, IniFiles, IdURI;

const C_HttpReadTimeOutDefault=60;//Ĭ��http post�ĳ�ʱʱ��,��λs

procedure TRXTrans.AddLog(AMSG: string);
begin
  Goo.Logger.Info(AMSG,'��ҽ');
end;

function TRXTrans.CheckSuccess(const AJson: string): Boolean;
begin
  Result := False;
  if AJson = '' then
  begin
    FLastErrorMessage := '����������Ϣ����ҩƷ��Ϣ��';
    Exit;
  end;
  var json := TJSONValue.ParseJSONValue(AJson);
  try
    json.TryGetValue<Boolean>('success',Result);
    json.TryGetValue<string>('message',FLastErrorMessage);
  finally
    json := nil;
  end;
end;

constructor TRXTrans.Create;
var iniFile:TIniFile;
begin
  FLastErrorMessage := '';
  FBillStatus        := 0;
  iniFile := TIniFile.Create(Goo.SystemDataPath + '\print.dat');
  try
    FID    := iniFile.ReadString('RXTransSet','PosID','');
    FSaveLog  := iniFile.ReadBool('RXTransSet','SaveLog',False);
  finally
    iniFile.Free;
  end;
end;

procedure TRXTrans.DeletePicture(TypeChar, TypeRec: Integer);
var
  AParamList: TParamList;
  cdstmp: TClientDataSet;
  pigname: string;
begin
  if TypeRec <=0 then Exit;
  AParamList := TParamList.Create;
  cdstmp := TClientDataSet.Create(nil);
  try
    //zfl ɾ��ͼƬ���ͬʱɾ������Ŀ¼��ŵ�ͼƬ
    goo.DB.OpenSQL(Format('SELECT [Guid] FROM dbo.MultImage WHERE TypeChar = %d AND typeRec = %d',[TypeChar,TypeRec]),cdstmp);
    cdstmp.First;
    while not cdstmp.Eof do
    begin
      pigname := cdstmp.fieldbyname('Guid').AsString;
//      if FileExists(ImageLocalUrl + '\' + pigname) then DeleteFile(ImageLocalUrl + '\' + pigname) ;
//      DeleteImageFromServer(pigname);
      cdstmp.Next;
    end;
    AParamList.Add('@TypeChar',TypeChar);
    AParamList.Add('@TypeRec',TypeRec);
    AParamList.Add('@Place',0);
    Goo.DB.ExecProc('gp_deleteImage',AParamList);
  finally
    AParamList.Free;
    cdstmp.Free;
  end;
end;

destructor TRXTrans.Destroy;
begin

  inherited;
end;

function TRXTrans.GetHTTP(ATimeOut: Integer): TQFHTTP;
begin
  Result := TQFHTTP.Create(nil);
  Result.Request.ContentType :='application/json;charset=utf-8';// ''; // ���巢��mime����
  Result.Request.Connection :='Keep-Alive';
  Result.ProtocolVersion := pv1_1;
  if ATimeOut<=-1 then ATimeOut := C_HttpReadTimeOutDefault;
  Result.ReadTimeout:=1000*ATimeOut;
end;

function TRXTrans.GetPicName(const APicURL: string): string;
var
  URL: TIdURI;
begin
  URL := TIdURI.Create(APicURL);
  try
    Result := ExtractFileName(URL.Document);
  finally
    URL.Free;
  end;
end;

function TRXTrans.GetToken: string;
var json:TJSONValue;
  RetJson:string;
begin
  Result := '';
//  if not DYZH0001(RetJson) then Exit;
  json := json.ParseJSONValue(RetJson);
  try
    json.TryGetValue<string>('object',Result);
  finally
    json := nil;
  end;
end;

{ TQFHTTP }

function TQFHTTP.Post(AURL: string; const ASource: TStrings; FailedTryCount: Integer): string;
var
  i:Integer;
begin
  i:=0;
  while i<=FailedTryCount do
  begin
    try
      result:= Post(AURL,ASource);
      Break;
    except
      Inc(i);
    end;
  end;
end;

initialization


end.
