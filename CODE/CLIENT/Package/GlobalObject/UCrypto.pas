unit UCrypto;

interface

uses
  System.Classes, Windows, System.SysUtils, System.RTLConsts;

type

  TCrypto = class(TObject)
  private
    class function crypto_sm4(encdectype: Integer; inputstr, key, outsing: PAnsiChar): Integer;
  public
    ///����
    class function Encrypt_SM4(AInput: string; AKey: string): string;overload; virtual;  //����
    ///����
    class function Decrypt_SM4(AInput: string; AKey: string): string;overload; virtual;  //����
  end;

  Tcrypto_sm4 = function(encdectype: Integer; inputstr: PAnsiChar; key: PAnsiChar; outsing: PAnsiChar): Integer; stdcall;

implementation

uses
  UComvar;

{ TCrypto }

class function TCrypto.crypto_sm4(encdectype: Integer; inputstr, key, outsing: PAnsiChar): Integer;
var
  vdll: THandle;
  FPointer: Pointer;
  Myfun: Tcrypto_sm4;
begin
  Result:=0;
  vdll := LoadLibrary(PChar(Goo.SystemPath+'\cryptodll.dll'));
  try
    FPointer := GetProcAddress(vdll, PAnsiChar('crypto_sm4base64')); //ȡ�����ĵ�ַ��
    if FPointer <> nil then //����������ھ͵���
    begin
      Myfun := Tcrypto_sm4(FPointer);
      Result := Myfun(encdectype, inputstr, key, outsing);
    end;
  finally
    FreeLibrary(vdll);
  end;
end;

class function TCrypto.Decrypt_SM4(AInput, AKey: string): string;
const
  RETLEN = 1024 * 1024 * 5;
var
  rstpchar: PAnsiChar;
begin
  rstpchar := AllocMem(RETLEN);
  try
    TCrypto.crypto_sm4(0, PAnsiChar(AnsiString(AInput)), PAnsiChar(AnsiString(AKey)), rstpchar);
    Result := StrPas(rstpchar);
  finally
    FreeMem(rstpchar);
  end;
end;

class function TCrypto.Encrypt_SM4(AInput, AKey: string): string;
const
  RETLEN = 1024 * 1024 * 5;
var
  rstpchar: PAnsiChar;
begin
  rstpchar := AllocMem(RETLEN);
  try
    TCrypto.crypto_sm4(1, PAnsiChar(AnsiString(AInput)), PAnsiChar(AnsiString(AKey)), rstpchar);
    Result := StrPas(rstpchar);
  finally
    FreeMem(rstpchar);
  end;
end;

end.
