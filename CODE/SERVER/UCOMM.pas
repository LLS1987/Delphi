unit UCOMM;

interface

uses System.Variants,ULogger;

var
  //���ݿ����Ӳ�����Ϣ
  DataBaseAddress  : string;
  DataBaseUser     : string;
  DataBasePassword : string;
  //�������˿���Ϣ
  DataSnapPort :Integer;   //DataSnap�˿�
  HttpPort     :Integer;  //HTTP �˿�
  //�ͻ���������
  Connections  :Integer;
  _Logger:TLogger;
  function Logger:TLogger;
implementation

function Logger:TLogger;
begin
  if not Assigned(_Logger) then _Logger := TLogger.Create;
  Result := _Logger;
end;

initialization

finalization
  if Assigned(_Logger) then _Logger.Free;


end.
