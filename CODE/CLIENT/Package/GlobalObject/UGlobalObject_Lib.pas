unit UGlobalObject_Lib;

interface

uses
  System.JSON,System.SysUtils,UComDB,UGlobalObject_Proxy, UGlobalInterface,
  UComObject, System.Generics.Collections, System.Rtti,UParamList, LoggerPro;

type
  TGlobalObject = class(TBaseCommObject)
  private
    FComVar: TParamList;
    FDBObject:TDataBaseCommObject;
    FFormatObject: TFormatCommObject;
    FLoginCommObject:TLoginCommObject;
    FRegisterClassFactory:TRegisterClassFactory;
    FMessageBoxObject:TMessageBoxObject;
    FLogger:ILogWriter;
    _Lock: TObject;
    function GetComVar: TParamList;
    function GetDB: TDataBaseCommObject;
    function GetFormat: TFormatCommObject;
    function GetLogin: TLoginCommObject;
    function GetRegisterClassFactory: TRegisterClassFactory;
    function GetMessageBoxObject: TMessageBoxObject;
    function GetSystemPath: string;
    function GetSystemDataPath: string;
    function GetLogger: ILogWriter;
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
    property Logger :ILogWriter read GetLogger;
  end;

implementation

uses
  Vcl.Forms, LoggerPro.GlobalLogger, LoggerPro.FileAppender;

{ TGloBalObject }

constructor TGloBalObject.Create;
begin
  _Lock := TObject.Create;
end;

destructor TGloBalObject.Destroy;
begin
  if Assigned(FLoginCommObject) then FreeAndNil(FLoginCommObject);  
  if Assigned(FFormatObject) then FreeAndNil(FFormatObject);  
  if Assigned(FDBObject) then FreeAndNil(FDBObject);
  if Assigned(FComVar) then FreeAndNil(FComVar);
  if Assigned(FRegisterClassFactory) then FreeAndNil(FRegisterClassFactory);
  if Assigned(FMessageBoxObject) then FreeAndNil(FMessageBoxObject);
  if Assigned(_Lock) then FreeAndNil(_Lock);
  
  inherited;
end;

function TGloBalObject.GetComVar: TParamList;
begin
  if not Assigned(FComVar) then FComVar := TParamList.Create;
  Result := FComVar;
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

function TGlobalObject.GetLogger: ILogWriter;
begin
  if FLogger = nil then
  begin
      System.TMonitor.Enter(_Lock);
      try
        if FLogger = nil then // double check
        begin
          FLogger := BuildLogWriter([TLoggerProFileAppender.Create(5,1000,'',[],'%0:s.%1:2.2d.%2:s.log','%0:s [TID %1:-6d][%2:-8s] %3:s')]);
        end;
      finally
        System.TMonitor.Exit(_Lock);
      end;
  end;
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

end.
