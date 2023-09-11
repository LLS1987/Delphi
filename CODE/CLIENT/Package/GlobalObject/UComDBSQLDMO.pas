unit UComDBSQLDMO;
{
  ���ܣ��������ݿ�ű�����
  ���ߣ�LLS
}
interface

uses
  System.SysUtils ,Data.DB, System.Classes;

type
  TSQLDMO = class
  private
    FConnection: TCustomConnection;
    FLastErrorCode: Integer;
    FLastErrorMsg: string;
  public
    constructor Create(AConn:TCustomConnection);
    ///���ݿⱸ��
    function Backup(szDatabaseName, szFileName : String): Boolean;
    function Restore(szDatabaseName, szFileName, szDataFilePath: String): Boolean;
    ///ִ�����ݿ��ļ�
    function ExecSQLScriptFile(szSQLScript : String) : Boolean;
    function ExecSQLScriptPath(szSQLPath   : String) : Boolean;
    ///ִ�����ݿ�ű�
    function ExecSQLScript(szSQLScript : String) : Boolean; overload;
    function ExecSQLScript(AScriptList : TStrings) : Boolean; overload;
    //property Connection: TCustomConnection read FConnection write FConnection;
    property LastErrorCode: Integer read FLastErrorCode;
    property LastErrorMessage: string read FLastErrorMsg;
  end;

implementation

uses
  Data.SqlExpr, Data.Win.ADODB, UComvar;

{ TSQLDMO }

function TSQLDMO.Backup(szDatabaseName, szFileName: String): Boolean;
begin
  Result := False;

  if Trim(szFileName) = '' then
  begin
    FLastErrorCode := -1001;
    FLastErrorMsg  := '�����ļ�������Ϊ�գ�';
    Exit;
  end;
  if not DirectoryExists(ExtractFilePath(szFileName)) then ForceDirectories(ExtractFilePath(szFileName));

  var szSQL:='BACKUP DATABASE ['+szDatabaseName+'] TO DISK = N'+QUOTEDSTR(szFileName)
          +' WITH  NOINIT ,  NOUNLOAD ,  NOSKIP ,  STATS = 10,  NOFORMAT';
  Result:=ExecSQLScript(szSQL);
end;

constructor TSQLDMO.Create(AConn: TCustomConnection);
begin
  FConnection := AConn;
end;

function TSQLDMO.ExecSQLScript(AScriptList: TStrings): Boolean;
var szSQLScript:string;
begin
  szSQLScript := EmptyStr;
  if (UpperCase(Trim(AScriptList[(AScriptList.Count - 1)])) <> 'GO') then AScriptList.Add('GO');
  for var i := 0 to AScriptList.Count-1 do
  begin
    if UpperCase(Trim(AScriptList[i]))='GO' then
    begin
      if Trim(szSQLScript)=EmptyStr then Continue;
      Result := ExecSQLScript(szSQLScript);
      if not Result then Break;
      szSQLScript := EmptyStr;
    end else szSQLScript := szSQLScript + AScriptList[i] + #13#10;
  end;
end;

function TSQLDMO.ExecSQLScriptFile(szSQLScript: String): Boolean;
var AList:TStrings;
begin
  AList := TStringList.Create;
  try
    AList.Add(szSQLScript);
    Result := ExecSQLScript(AList);
  finally
    AList.Free;
  end;
end;

function TSQLDMO.ExecSQLScriptPath(szSQLPath: String): Boolean;
var AList:TStrings;
begin
  AList := TStringList.Create;
  try
    AList.LoadFromFile(szSQLPath);
    Result := ExecSQLScript(AList);
  finally
    AList.Free;
  end;
end;

function TSQLDMO.Restore(szDatabaseName, szFileName, szDataFilePath: String): Boolean;
begin
  Result := False;

  if Trim(szFileName) = '' then
  begin
    FLastErrorCode := -1001;
    FLastErrorMsg  := '��������Ҫ�ָ��ı����ļ�����';
    Exit;
  end;

  if Trim(szDataFilePath) = '' then
  begin
    FLastErrorCode := -1002;
    FLastErrorMsg  := '�������������ļ�·����';
    Exit;
  end;

  if not FileExists(szFileName) then
  begin
    FLastErrorCode := -1003;
    FLastErrorMsg  := 'Ҫ�ָ��ı����ļ������ڣ�';
    Exit;
  end;

  if not DirectoryExists(szDataFilePath) then
    if not ForceDirectories(szDataFilePath) then
    begin
      FLastErrorCode := -1004;
      FLastErrorMsg  := '���������ļ�Ŀ¼ʧ�ܣ������Ƿ��������ļ���';
      Exit;
    end;

  if not szDataFilePath.EndsWith('\') then szDataFilePath := szDataFilePath + '\';

  var szSQL:='RESTORE DATABASE ['+szDatabaseName+'] FROM '
          +' DISK = N'+QUOTEDSTR(szFileName)+
          ' WITH MOVE ''guion_Data'' TO '+QuotedStr(szDataFilePath+szDatabaseName+'.mdf')+','+
          ' MOVE ''guion_Log'' TO '+QuotedStr(szDataFilePath+szDatabaseName+'.ldf')+
          ' ,REPLACE ';

  Result:=ExecSQLScript(szSQL);
end;

function TSQLDMO.ExecSQLScript(szSQLScript: String): Boolean;
begin
  Result := False;
  if Trim(szSQLScript)=EmptyStr then Exit;
  if Trim(szSQLScript)='GO' then Exit;
  try
    FLastErrorMsg := EmptyStr;
    if FConnection is TSQLConnection then
      FLastErrorCode := (FConnection as TSQLConnection).ExecuteDirect(szSQLScript)
    else if FConnection is TADOConnection then
      (FConnection as TADOConnection).Execute(szSQLScript,FLastErrorCode);
    Result := True;
  except on E: Exception do
    begin
      FLastErrorMsg := e.Message;
      Goo.Logger.Error('�������ݿ�ű�����%s',LastErrorMessage);
    end;
  end;
end;

end.
