unit UGlobalObject_Lib;

interface

uses
  System.JSON,System.SysUtils,UComDB,UGlobalObject_Proxy, UGlobalInterface,
  UComObject, System.Generics.Collections, System.Rtti,UParamList, UCertManage,
  UCrypto, UPrintFunc, ULogger;

type
  TGlobalObject = class(TBaseCommObject)
  private
    FComVar: TParamList;
    FDBObject:TDataBaseCommObject;
    FFormatObject: TFormatCommObject;
    FLoginCommObject:TLoginCommObject;
    FRegisterClassFactory:TRegisterClassFactory;
    FMessageBoxObject:TMessageBoxObject;
    FLogger:TLogger;
    FCertManage:TCertManage;
    FPrintFuncObject:TPrintFuncObject;
    FCrypto: TCrypto;
    FThemeObject:TThemeObject;
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
  protected

  public
    constructor Create;
    destructor Destroy; override;
    ///ϵͳ·��
    property SystemPath: string read GetSystemPath;
    property SystemDataPath: string read GetSystemDataPath;
    ///��̬�ı����洢����JOSN�洢
    property ComVar: TParamList read GetComVar;
    ///��¼����
    property Login: TLoginCommObject read GetLogin;
    ///���ݿ���غ���
    property DB: TDataBaseCommObject read GetDB;
    ///����ת���ࡢ��ʽ��
    property Format: TFormatCommObject read GetFormat;
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
  end;

implementation

uses
  Vcl.Forms, LoggerPro.GlobalLogger, LoggerPro.FileAppender;

{ TGloBalObject }

constructor TGloBalObject.Create;
begin

end;

destructor TGloBalObject.Destroy;
begin
  if Assigned(FLoginCommObject) then FreeAndNil(FLoginCommObject);  
  if Assigned(FFormatObject) then FreeAndNil(FFormatObject);  
  if Assigned(FDBObject) then FreeAndNil(FDBObject);
  if Assigned(FComVar) then FreeAndNil(FComVar);
  if Assigned(FRegisterClassFactory) then FreeAndNil(FRegisterClassFactory);
  if Assigned(FMessageBoxObject) then FreeAndNil(FMessageBoxObject);
  if Assigned(FLogger) then FreeAndNil(FLogger);
  if Assigned(FCertManage) then FreeAndNil(FCertManage);
  if Assigned(FCrypto) then FreeAndNil(FCrypto);
  if Assigned(FPrintFuncObject) then FreeAndNil(FPrintFuncObject);
  if Assigned(FThemeObject) then FreeAndNil(FThemeObject);

  inherited;
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

function TGlobalObject.GetMessageBoxObject: TMessageBoxObject;
begin
  if not Assigned(FMessageBoxObject) then FMessageBoxObject:=TMessageBoxObject.Create(Self);
  Result := FMessageBoxObject;
end;

function TGlobalObject.GetPrint: TPrintFuncObject;
begin
  if not Assigned(FPrintFuncObject) then FPrintFuncObject := TPrintFuncObject.Create;
  Result := FPrintFuncObject;
end;

function TGlobalObject.GetRegisterClassFactory: TRegisterClassFactory;
begin
  if not Assigned(FRegisterClassFactory) then FRegisterClassFactory := TRegisterClassFactory.Create(Self);
  Result := FRegisterClassFactory;
end;

function TGlobalObject.GetSystemDataPath: string;
begin
  Result := SystemPath+'\data';
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

end.
