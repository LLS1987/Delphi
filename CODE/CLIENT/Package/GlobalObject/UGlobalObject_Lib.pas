unit UGlobalObject_Lib;

interface

uses
  System.JSON,System.SysUtils,UComDB,UGlobalObject_Proxy, UGlobalInterface,
  UComObject, System.Generics.Collections, System.Rtti,UParamList, UCertManage,
  UCrypto, UPrintFunc, ULogger, UComDBStorable, System.Classes, UBaseParams,
  UComConst;

type
  TGlobalObject = class(TBaseCommObject)
  private
    FComVar: TParamList;
    FDBObject,FThreadDB:TDataBaseCommObject;
    FFormatObject: TFormatCommObject;
    FLoginCommObject:TLoginCommObject;
    FRegisterClassFactory:TRegisterClassFactory;
    FMessageBoxObject:TMessageBoxObject;
    FLogger:TLogger;
    FCertManage:TCertManage;
    FPrintFuncObject:TPrintFuncObject;
    FCrypto: TCrypto;
    FThemeObject:TThemeObject;
    FPlayMediaObject:TPlayMediaObject;
    FStorableManage:TStorableManage;
    FBaseParam:TBaseParam;
    function GetComVar: TParamList;
    function GetDB: TDataBaseCommObject;
    function GetFormat: TFormatCommObject;
    function GetLogin: TLoginCommObject;
    function GetRegisterClassFactory: TRegisterClassFactory;
    function GetMessageBoxObject: TMessageBoxObject;
    function GetSystemPath: string;
    function GetSystemDataPath: string;
    function GetLogger: TLogger;
    function GetCertManage: TCertManage;
    function GetCrypto: TCrypto;
    function GetPrint: TPrintFuncObject;
    function GetTheme: TThemeObject;
    function GetPlayMediaObject: TPlayMediaObject;
    function GetStorableManage: TStorableManage;
    function GetThreadDB: TDataBaseCommObject;
  protected

  public
    constructor Create;
    destructor Destroy; override;
    ///ϵͳ·��
    property SystemPath: string read GetSystemPath;
    property SystemDataPath: string read GetSystemDataPath;
    ///��ȡMAC��ַ�б�
    function GetMacAddressList: TStringList;
    ///��ȡmac��ַ �ų���������
    function GetRealMacAddress: string;
    //��ȡӲ�����к�
    function GetHardDiskSerialNumber: string;
    ///GetGUIDString
    function GetGUIDString:string;
    ///��̬�ı����洢����JOSN�洢
    property ComVar: TParamList read GetComVar;
    ///��¼����
    property Login: TLoginCommObject read GetLogin;
    ///���ݿ���غ���
    property DB: TDataBaseCommObject read GetDB;
    ///�߳����ݿ⣻������DB�ֿ����߳�DB��������Lock
    property ThreadDB :TDataBaseCommObject read GetThreadDB;
    ///����ת���ࡢ��ʽ��
    property Cast: TFormatCommObject read GetFormat;
    ///�๤��
    property Reg: TRegisterClassFactory read GetRegisterClassFactory;
    ///��ʾ��Ϣ��
    property Msg: TMessageBoxObject read GetMessageBoxObject;
    ///��־��
    property Logger :TLogger read GetLogger;
    ///ע����֤
    property Cert:TCertManage read GetCertManage;
    ///�ӽ���
    property Crypto:TCrypto read GetCrypto;
    ///��ӡ
    property Print:TPrintFuncObject read GetPrint;
    ///��ʽ
    property Theme:TThemeObject read GetTheme;
    ///ý���
    property Media :TPlayMediaObject read GetPlayMediaObject;
    ///������
    property Local: TStorableManage read GetStorableManage;
    ///������Ϣѡ����
    function GetBaseinfo<T:TBaseParam>(AMult:Boolean=False):TStorableDictionary;overload;
    function GetBaseinfo(ABaseParam:TBaseParamClass;AMult:Boolean=False):TStorableDictionary;overload;
    function GetBaseinfo(ABaseType:TBasicType;AMult:Boolean=False):TStorableDictionary;overload;
  end;

implementation

uses
  Vcl.Forms, LoggerPro.GlobalLogger, LoggerPro.FileAppender, winapi.Nb30,
  Winapi.Windows, System.TypInfo;

{ TGloBalObject }

constructor TGloBalObject.Create;
begin
  FThreadDB := nil;
end;

destructor TGloBalObject.Destroy;
begin
  if Assigned(FLoginCommObject) then FreeAndNil(FLoginCommObject);  
  if Assigned(FFormatObject) then FreeAndNil(FFormatObject);  
  if Assigned(FDBObject) then FreeAndNil(FDBObject);
  if Assigned(FThreadDB) then FreeAndNil(FThreadDB);  
  if Assigned(FComVar) then FreeAndNil(FComVar);
  if Assigned(FRegisterClassFactory) then FreeAndNil(FRegisterClassFactory);
  if Assigned(FMessageBoxObject) then FreeAndNil(FMessageBoxObject);
  if Assigned(FLogger) then FreeAndNil(FLogger);
  if Assigned(FCertManage) then FreeAndNil(FCertManage);
  if Assigned(FCrypto) then FreeAndNil(FCrypto);
  if Assigned(FPrintFuncObject) then FreeAndNil(FPrintFuncObject);
  if Assigned(FThemeObject) then FreeAndNil(FThemeObject);
  if Assigned(FPlayMediaObject) then FreeAndNil(FPlayMediaObject);
  if Assigned(FStorableManage) then FreeAndNil(FStorableManage);
  if Assigned(FBaseParam) then FreeAndNil(FBaseParam);
  inherited;
end;

function TGlobalObject.GetBaseinfo(ABaseParam: TBaseParamClass; AMult: Boolean): TStorableDictionary;
begin
  Result := nil;
  if Assigned(FBaseParam) then FreeAndNil(FBaseParam);
  FBaseParam := ABaseParam.Create(nil);
  FBaseParam.GetBaseInfoSelect;
  Result := FBaseParam.Return;
end;

function TGlobalObject.GetBaseinfo(ABaseType: TBasicType; AMult: Boolean): TStorableDictionary;
begin
  case ABaseType of
    btPtype : Result := GetBaseinfo(TPTypeParam,AMult);
    btBtype : Result := GetBaseinfo(TBTypeParam,AMult);
    btMtype : Result := GetBaseinfo(TMTypeParam,AMult);
  end;
end;

function TGlobalObject.GetBaseinfo<T>(AMult: Boolean): TStorableDictionary;
begin
  Result := nil;
  if Assigned(FBaseParam) then FreeAndNil(FBaseParam);
  var AClass := GetClass(PTypeInfo(System.TypeInfo(T))^.Name);
  if Assigned(AClass) and AClass.InheritsFrom(TBaseParam) then
  begin
    FBaseParam := TBaseParam(AClass).Create(nil);
    FBaseParam.GetBaseInfoSelect;
    Result := FBaseParam.Return;
  end;
end;

function TGlobalObject.GetCertManage: TCertManage;
begin
  if not Assigned(FCertManage) then FCertManage:=TCertManage.Create;
  Result := FCertManage;
end;

function TGloBalObject.GetComVar: TParamList;
begin
  if not Assigned(FComVar) then FComVar := TParamList.Create;
  Result := FComVar;
end;

function TGlobalObject.GetCrypto: TCrypto;
begin
  if not Assigned(FCrypto) then FCrypto := TCrypto.Create;
  Result := FCrypto;
end;

function TGloBalObject.GetDB: TDataBaseCommObject;
begin
  if not Assigned(FDBObject) then FDBObject := TDataBaseCommObject.Create;
  Result := FDBObject;
end;

function TGloBalObject.GetFormat: TFormatCommObject;
begin
  if not Assigned(FFormatObject) then FFormatObject:= TFormatCommObject.Create(Self);
  Result := FFormatObject;
end;

function TGlobalObject.GetGUIDString: string;
begin
  var LTep:TGUID;
  CreateGUID(LTep);
  Result := GUIDToString(LTep);
end;

function TGlobalObject.GetHardDiskSerialNumber: string;
var
  VolumeSerialNumber: DWORD;
  MaximumComponentLength: DWORD;
  FileSystemFlags: DWORD;
  VolumeNameSize: array[0..MAX_PATH] of Char;
  FileSystemNameSize: array[0..MAX_PATH] of Char;
begin
  GetVolumeInformation('C:\', VolumeNameSize, DWORD(MAX_PATH), @VolumeSerialNumber, MaximumComponentLength, FileSystemFlags, FileSystemNameSize, DWORD(MAX_PATH));
  Result := IntToHex(VolumeSerialNumber, 8);
end;

function TGlobalObject.GetLogger: TLogger;
begin
  if not Assigned(FLogger) then FLogger := TLogger.Create;
  Result := FLogger;
end;

function TGloBalObject.GetLogin: TLoginCommObject;
begin
  if not Assigned(FLoginCommObject) then FLoginCommObject:= TLoginCommObject.Create(Self);
  Result := FLoginCommObject;
end;

function TGlobalObject.GetMacAddressList: TStringList;
var
  NCB: PNCB;
  Adapter: PAdapterStatus;
  URetCode: PChar;
  RetCode: char;
  I: integer;
  Lenum: PlanaEnum;
  _SystemID: string;
  TMPSTR: string;
begin
  Result    := TStringList.create();
  _SystemID := '';
  Getmem(NCB, SizeOf(TNCB));
  Fillchar(NCB^, SizeOf(TNCB), 0);
  Getmem(Lenum, SizeOf(TLanaEnum));
  Fillchar(Lenum^, SizeOf(TLanaEnum), 0);
  Getmem(Adapter, SizeOf(TAdapterStatus));
  Fillchar(Adapter^, SizeOf(TAdapterStatus), 0);
  Lenum.Length    := chr(0);
  NCB.ncb_command := chr(NCBENUM);
  NCB.ncb_buffer  := Pointer(Lenum);
  NCB.ncb_length  := SizeOf(Lenum);
  RetCode         := Char(Netbios(NCB));
  try
    i := 0;
    repeat
      Fillchar(NCB^, SizeOf(TNCB), 0);
      Ncb.ncb_command  := chr(NCBRESET);
      Ncb.ncb_lana_num := lenum.lana[I];
      RetCode          := Char(Netbios(Ncb));
      Fillchar(NCB^, SizeOf(TNCB), 0);
      Ncb.ncb_command  := chr(NCBASTAT);
      Ncb.ncb_lana_num := lenum.lana[I];
      // Must be 16
      Ncb.ncb_callname := '*';
      Ncb.ncb_buffer := Pointer(Adapter);
      Ncb.ncb_length := SizeOf(TAdapterStatus);
      RetCode        := Char(Netbios(Ncb));
      //---- calc _systemId from mac-address[2-5] XOR mac-address[1]...
      if (RetCode = chr(0)) or (RetCode = chr(6)) then
      begin
        _SystemId := IntToHex(Ord(Adapter.adapter_address[0]), 2) + '-' +
          IntToHex(Ord(Adapter.adapter_address[1]), 2) + '-' +
          IntToHex(Ord(Adapter.adapter_address[2]), 2) + '-' +
          IntToHex(Ord(Adapter.adapter_address[3]), 2) + '-' +
          IntToHex(Ord(Adapter.adapter_address[4]), 2) + '-' +
          IntToHex(Ord(Adapter.adapter_address[5]), 2);
        if (_SystemID <> '00-00-00-00-00-00') and (Result.IndexOf(_SystemID)=-1) then Result.add(_SystemId);
      end;
    Inc(i);
    until (I >= Ord(Lenum.Length));
  finally
   FreeMem(NCB);
   FreeMem(Adapter);
   FreeMem(Lenum);
  end;
end;

function TGlobalObject.GetMessageBoxObject: TMessageBoxObject;
begin
  if not Assigned(FMessageBoxObject) then FMessageBoxObject:=TMessageBoxObject.Create(Self);
  Result := FMessageBoxObject;
end;

function TGlobalObject.GetPlayMediaObject: TPlayMediaObject;
begin
  if not Assigned(FPlayMediaObject) then FPlayMediaObject := TPlayMediaObject.Create(self);
  Result := FPlayMediaObject;
end;

function TGlobalObject.GetPrint: TPrintFuncObject;
begin
  if not Assigned(FPrintFuncObject) then FPrintFuncObject := TPrintFuncObject.Create;
  Result := FPrintFuncObject;
end;

function TGlobalObject.GetRealMacAddress: string;
var
  MacList: TStringList;
  I: Integer;
begin
  Result := '';
  MacList := GetMacAddressList;
  try
    for I := 0 to MacList.Count - 1 do
    begin
      // Exclude virtual network cards
      if not (Pos('00-00-00-00-00-00-00-E0', MacList[I]) > 0) and
         not (Pos('00-50-56-C0-00-08', MacList[I]) > 0) and
         not (Pos('00-50-56-C0-00-01', MacList[I]) > 0) and
         not (Pos('00-03-FF', MacList[I]) > 0) and
         not (Pos('00-0C-29', MacList[I]) > 0) and
         not (Pos('00-05-69', MacList[I]) > 0) and
         not (Pos('00-1C-14', MacList[I]) > 0) and
         not (Pos('00-0F-4B', MacList[I]) > 0) and
         not (Pos('00-16-3E', MacList[I]) > 0) then
      begin
        Result := MacList[I];
        Break;
      end;
    end;
  finally
    MacList.Free;
  end;
end;

function TGlobalObject.GetRegisterClassFactory: TRegisterClassFactory;
begin
  if not Assigned(FRegisterClassFactory) then FRegisterClassFactory := TRegisterClassFactory.Create(Self);
  Result := FRegisterClassFactory;
end;

function TGlobalObject.GetStorableManage: TStorableManage;
begin
  if not Assigned(FStorableManage) then FStorableManage := TStorableManage.Create;
  Result := FStorableManage;
end;

function TGlobalObject.GetSystemDataPath: string;
begin
  Result := SystemPath+'\Data';
end;

function TGlobalObject.GetSystemPath: string;
begin
  Result := ExtractFilePath(Application.ExeName).TrimRight(['\']);
end;

function TGlobalObject.GetTheme: TThemeObject;
begin
  if not Assigned(FThemeObject) then FThemeObject := TThemeObject.Create(Self);  
  Result := FThemeObject;
end;

function TGlobalObject.GetThreadDB: TDataBaseCommObject;
begin
  if not Assigned(FThreadDB) and DB.Connected then
  begin
    FThreadDB := TDataBaseCommObject.Create;
    FThreadDB.ConnectType := DB.ConnectType;
    FThreadDB.HostName    := DB.HostName;
    FThreadDB.Port        := DB.Port;
    FThreadDB.UserName    := DB.UserName; //�����������DB����
    FThreadDB.Password    := DB.Password;
    FThreadDB.Connected := True;
    if FThreadDB.Connected then FThreadDB.ChangeDataBase(DB.DatabaseName);
  end;
  if FThreadDB.CheckConnected then Result := FThreadDB else Result := DB;
end;

end.
