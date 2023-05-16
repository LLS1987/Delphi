//
//���๫��������Ԫ
// Created by LLS the UComvar
// 2023-04-09 22:49:16
//
unit UComvar;

interface

uses UGlobalObject_Lib;

function Goo: TGlobalObject;
procedure FreeGlobalObject;
Function GetBitValue(Const nValue:Int64;nBit:Byte):Boolean;
function SetBitValue(nValue:Int64;nBit:Byte;Value:Boolean): Int64;

var
  HostIP:string;
  //���ݿ����Ӳ�����Ϣ
  DataBaseAddress  : string;
  DataBaseUser     : string;
  DataBasePassword : string;
  //�������˿���Ϣ
  DataSnapAddress  : string='127.0.0.1';
  DataSnapPort     :Integer=212;   //DataSnap�˿�
  HttpPort         :Integer=8080;  //HTTP �˿�
  //������Ϣ
  szAccountName    : string='';
  szDatabaseName   : string='';

implementation

uses SysUtils, System.Math;

var
  FGlobalObject: TGloBalObject=nil;

function Goo: TGlobalObject;
begin
  if not Assigned(FGlobalObject) then FGlobalObject:= TGloBalObject.Create;
  Result := FGlobalObject;
end;
procedure FreeGlobalObject;
begin
  if Assigned(FGlobalObject) then FreeAndNil(FGlobalObject);
end;

Function GetBitValue(Const nValue:Int64;nBit:Byte):Boolean;
begin
  if nBit>Sizeof(nValue)*8 then
    Result:=False
  else
    Result:=(nValue and StrToInt64(power(2,nBit-1).ToString))<>0;  //(1 shl (nBit-1))<>0;
end;
function SetBitValue(nValue:Int64;nBit:Byte;Value:Boolean): Int64;
var m : Int64;
begin
  m := 1;
  if nBit<=Sizeof(nValue)*8 then
  begin
//LWF_ALL
    if  Value then
      Result:=nValue OR  (m shl (nBit-1))
    else
      Result:=nValue and  (not  (m shl (nBit-1)))
  end
  else Result:=0
end;

initialization

finalization
  //FreeGlobalObject;

end.
