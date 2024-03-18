///�������Ĵ�����
// Created by LLS the UGlobalObject_Proxy
// 2023-04-09 22:49:16
//

unit UGlobalObject_Proxy;

interface

uses
  UGlobalInterface, UComObject,UParamList, System.UITypes, Winapi.Windows,
  Vcl.Forms, Vcl.MPlayer, dxAlertWindow, Vcl.ComCtrls, Data.DB;

type
  TLoginCommObject = class(TBaseCommObject)
  private
    FLoginUserRec: Integer;
    FLoginUserName: string;
    FLoginUserCode: string;
    function GetLocalComputerName: string;
    function GetLocalIPAddress: string;
    function GetLocalMACAddress(idx: Integer): string;
    function GetHardDiskSN: string;
    function GetCPUPSN: string;
  public
    function LoginServer:Boolean;
    function LoginUser:Boolean;
    ///����IP
    property LocalIPAddress:string read GetLocalIPAddress;
    ///������
    property LocalComputerName: string read GetLocalComputerName;
    ///����MAC
    property LocalMACAddress[idx:Integer]:string read GetLocalMACAddress;
    ///����Ӳ�����к�
    property LocalHDSN: string read GetHardDiskSN;
    ///����CPU���к�
    property LocalCPUSN:string read GetCPUPSN;
  published
    ///ְԱ��¼��Ϣ
    property LoginUserRec:Integer read FLoginUserRec;
    property LoginUserCode:string read FLoginUserCode;
    property LoginUserName:string read FLoginUserName;
  end;
  TFormatCommObject = class(TBaseCommObject)
  public
    function iif(condtion: boolean; A: integer; B: integer): integer; overload;
    function iif(condtion: boolean; A: string; B: string): string; overload;
    function iif(condtion: Boolean; A: Boolean; B: Boolean): boolean; overload;
    function iif(condtion: boolean; A: Double; B: Double): Double; overload;
    function iif(condtion: boolean; A: OleVariant; B: OleVariant): OleVariant; overload;
    function IsNull(ACheckvalue,AReplaceValue:olevariant): olevariant;
    function HtmlToColor(const AHtmlColor: string): TColor;
    function ColorToHtml(AColor: TColor): string;
    function StringToChinese(const AStr: string): string;
    ///��ȡ��� Attribute
    function GetClassAttribute<T: TCustomAttribute>(AClass: TClass): T;
    ///DataSetΪTObject���Ը�ֵ
    function DataSetToObject<T:TCustomAttribute>(ADataSet:TDataSet;AObject:TObject):Boolean;
  end;
  {��ʽ}
  TThemeGrid = record
    GridItemHeight:Integer;     //=25;����и�
    GridRowFontSize:Integer;    //=10;������������С
    GridHeadHeight:Integer;     //=25;��ͷ�и�
    GridTitleFontSize:Integer;  //=10;��ͷ���������С
    GridFontColor:TColor;       //=#4B5053;���������ɫ
    GridHeadFontColor:TColor;   //=#023350;��ͷ������ɫ
    GridFooterFontColor:TColor; //=#4B5053;�ϼ���������ɫ
    GridBackColor:TColor;       //=#FFFFFF;��񱳾���ɫ
    GridHeadBackColor:TColor;   //=#F5F5F5;��ͷ������ɫ
    GridOneItemColor:TColor;    //=#FFFFFF;���������ɫ
    GridTwoItemColor:TColor;    //=#F5F5F5;���ż����ɫ
    GridSelectItemColor:TColor; //=#DDF2D0;���ѡ������ɫ
    GridFooterColor:TColor;     //=#FFFFFF;���ϼ�����ɫ
    GridFixBackBolor:TColor;    //=#F5F5F5;�����߹̶��б�����ɫ
    GridRowFocusColor:TColor;   //=#AEE18E;���ѡ�е�Ԫ����ɫ
  end;
  TThemeObject = class(TBaseCommObject)
  private
    FThemeGrid: TThemeGrid;
  public
    constructor Create(AOwner: TObject);
    class function HtmlToColor(const AHtmlColor: string): TColor;
    class function ColorToHtml(AColor: TColor): string;
    property Grid :TThemeGrid read FThemeGrid;
  end;
  {¼�봰����}
  TInputBoxFlags = class(TObject)
  private
    FMaxValue: Integer;
    FMinValue: Integer;
    FMaxLength: Integer;
  public
    property MaxValue:Integer read FMaxValue write FMaxValue;
    property MinValue:Integer read FMinValue write FMinValue;
    property MaxLength:Integer read FMaxLength write FMaxLength;
  end;
  {��Ϣ����}
  TMessageBoxObject = class(TBaseCommObject)
  private
    FMainThreadBarTick:Integer;
    FProgressBarForm:TForm;
    FdxAlertWindowManager:TdxAlertWindowManager;
  public
    constructor Create(AOwner: TObject);
    destructor Destroy; override;
    function MessageBox(const AMsg,ATitle:string;ADlgType:TMsgDlgType;ADlgButtons:TMsgDlgButtons):Integer;
    procedure ShowMsg(const AMsg:string);overload;
    procedure ShowMsg(const AMsg:string; Args:array of const);overload;
    procedure ShowError(Const AMsg:String); overload;
    procedure ShowError(Const AMsg:String;const Args: array of const); overload;
    procedure ShowErrorAndAbort(Const AMsg:String); overload;
    procedure ShowErrorAndAbort(Const AMsg:String;const Args: array of const); overload;
    function Question(Const AMsg:String;Const ATitle:string='��ʾ'): Boolean; overload;
    function Question(Const AMsg:String;const Args: array of const;Const ATitle:string='��ʾ'): Boolean; overload;
    //�ж���Ϣ
    procedure CheckAndAbort(AResult:Boolean); overload;
    procedure CheckAndAbort(AResult:Boolean;Const AMSG:String); overload;
    procedure CheckAndAbort(AResult:Boolean;Const AMSG:String; const Args: array of const); overload;
    ///������
    procedure ShowProgressBar(AMax:Integer=100;ATitle:string='');
    procedure StepBy(Delta: Integer=1;ATitle:string='');
    ///��������߳̽����������ؿ�ʼʱ��
    function ShowMainThreadBar(AMax:Integer=100;ATitle:string=''): Integer;
    ///��������߳̽�������������ʹ��ʱ��
    function StepByMainThreadBar(Delta: Integer=1;ATitle:string=''): Integer;
    ///������ʾ
    function ShowAlert(const AText: string;ACaption:string='��ʾ'): TdxAlertWindow;
    /// ͨ��¼�봰��
    function ShowInput(var AValue:Variant; const ATitle:string;ACaption:string='��ʾ'): Boolean; overload;
    function ShowInput<T>(const ATitle:string;ACaption:string='��ʾ'): T; overload;
    function ShowInput<T>(var AValue:T;const ATitle:string;ACaption:string='��ʾ';ADecimal:Integer=2): Boolean; overload;
  end;
  {��ý�岥��}
  TPlayMediaObject = class(TBaseCommObject)
  private
    FMediaPlayer: TMediaPlayer;
  public
    constructor Create(AOwner: TObject);
    destructor Destroy; override;
    procedure Play(AFile:string);
    procedure Close;
    property MediaPlayer : TMediaPlayer read FMediaPlayer;
  end;

implementation

uses
  Vcl.Controls,UComvar, Vcl.Dialogs, System.SysUtils, System.Rtti,
  Vcl.Graphics, System.Variants, Winapi.WinSock, Winapi.Nb30, UComDBStorable,
  System.Math;

{ TLoginCommObject }

function TLoginCommObject.GetCPUPSN: string;
type
    TCPUID = array[1..4] of longint;
  function GetCPUID: TCPUID;
  asm
    PUSH    EBX
  ��PUSH    EDI
  ��MOV     EDI,EAX
  ��MOV     EAX,1
  ��DW      $A20F
  ��STOSD
  ��MOV     EAX,EBX
  ��STOSD
  ��MOV     EAX,ECX
  ��STOSD
  ��MOV     EAX,EDX
  ��STOSD
  ��POP     EDI
  ��POP     EBX
  end;
var
  Buffer: array[0..25] of Char; // ���CPU���кŵ��ַ���
begin
  Result := EmptyStr;
  try
    var aCpuId := GetCPUID;
    Result := IntToHex(aCpuId[4],8) + IntToHex(aCpuId[1],8)
  except
    on E: Exception do ;
  end;
end;

function TLoginCommObject.GetHardDiskSN: string;
const
  IDENTIFY_BUFFER_SIZE = 512;
type
   TIDERegs = packed record
    bFeaturesReg     : BYTE; // Used for specifying SMART "commands".
    bSectorCountReg  : BYTE; // IDE sector count register
    bSectorNumberReg : BYTE; // IDE sector number register
    bCylLowReg       : BYTE; // IDE low order cylinder value
    bCylHighReg      : BYTE; // IDE high order cylinder value
    bDriveHeadReg    : BYTE; // IDE drive/head register
    bCommandReg      : BYTE; // Actual IDE command.
    bReserved        : BYTE; // reserved for future use.  Must be zero.
  end;
  TSendCmdInParams = packed record
    // Buffer size in bytes
    cBufferSize  : DWORD;
    // Structure with drive register values.
    irDriveRegs  : TIDERegs;
    // Physical drive number to send command to (0,1,2,3).
    bDriveNumber : BYTE;
    bReserved    : Array[0..2] of Byte;
    dwReserved   : Array[0..3] of DWORD;
    bBuffer      : Array[0..0] of Byte;  // Input buffer.
  end;
  TIdSector = packed record
    wGenConfig                 : Word;
    wNumCyls                   : Word;
    wReserved                  : Word;
    wNumHeads                  : Word;
    wBytesPerTrack             : Word;
    wBytesPerSector            : Word;
    wSectorsPerTrack           : Word;
    wVendorUnique              : Array[0..2] of Word;
    sSerialNumber              : Array[0..19] of CHAR;
    wBufferType                : Word;
    wBufferSize                : Word;
    wECCSize                   : Word;
    sFirmwareRev               : Array[0..7] of Char;
    sModelNumber               : Array[0..39] of Char;
    wMoreVendorUnique          : Word;
    wDoubleWordIO              : Word;
    wCapabilities              : Word;
    wReserved1                 : Word;
    wPIOTiming                 : Word;
    wDMATiming                 : Word;
    wBS                        : Word;
    wNumCurrentCyls            : Word;
    wNumCurrentHeads           : Word;
    wNumCurrentSectorsPerTrack : Word;
    ulCurrentSectorCapacity    : DWORD;
    wMultSectorStuff           : Word;
    ulTotalAddressableSectors  : DWORD;
    wSingleWordDMA             : Word;
    wMultiWordDMA              : Word;
    bReserved                  : Array[0..127] of BYTE;
  end;
  PIdSector = ^TIdSector;
  TDriverStatus = packed record
    // ���������صĴ�����룬�޴��򷵻�0
    bDriverError : Byte;
    // IDE����Ĵ��������ݣ�ֻ�е�bDriverError Ϊ SMART_IDE_ERROR ʱ��Ч
    bIDEStatus   : Byte;
    bReserved    : Array[0..1] of Byte;
    dwReserved   : Array[0..1] of DWORD;
  end;
  TSendCmdOutParams = packed record
    // bBuffer�Ĵ�С
    cBufferSize  : DWORD;
    // ������״̬
    DriverStatus : TDriverStatus;
    // ���ڱ�������������������ݵĻ�������ʵ�ʳ�����cBufferSize����
    bBuffer      : Array[0..0] of BYTE;
  end;
  var hDevice : THandle;
      cbBytesReturned : DWORD;
      SCIP : TSendCmdInParams;
      aIdOutCmd : Array [0..(SizeOf(TSendCmdOutParams)+IDENTIFY_BUFFER_SIZE-1)-1] of Byte;
      IdOutCmd  : TSendCmdOutParams absolute aIdOutCmd;
  procedure ChangeByteOrder( var Data; Size : Integer );
  var ptr : PChar;
      i : Integer;
      c : Char;
  begin
    ptr := @Data;
    for i := 0 to (Size shr 1)-1 do begin
      c := ptr^;
      ptr^ := (ptr+1)^;
      (ptr+1)^ := c;
      Inc(ptr,2);
    end;
  end;
begin
  Result := ''; // ��������򷵻ؿմ�
  if Win32Platform=VER_PLATFORM_WIN32_NT then begin// Windows NT, Windows 2000
      // ��ʾ! �ı����ƿ���������������������ڶ����������� '\\.\PhysicalDrive1\'
      hDevice := CreateFile( '\\.\PhysicalDrive0', GENERIC_READ or GENERIC_WRITE,
        FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0 );
  end else // Version Windows 95 OSR2, Windows 98
    hDevice := CreateFile( '\\.\SMARTVSD', 0, 0, nil, CREATE_NEW, 0, 0 );
    if hDevice=INVALID_HANDLE_VALUE then Exit;
   try
    FillChar(SCIP,SizeOf(TSendCmdInParams)-1,#0);
    FillChar(aIdOutCmd,SizeOf(aIdOutCmd),#0);
    cbBytesReturned := 0;
    // Set up data structures for IDENTIFY command.
    with SCIP do begin
      cBufferSize  := IDENTIFY_BUFFER_SIZE;
//      bDriveNumber := 0;
      with irDriveRegs do
      begin
        bSectorCountReg  := 1;
        bSectorNumberReg := 1;
//      if Win32Platform=VER_PLATFORM_WIN32_NT then bDriveHeadReg := $A0
//      else bDriveHeadReg := $A0 or ((bDriveNum and 1) shl 4);
        bDriveHeadReg    := $A0;
        bCommandReg      := $EC;
      end;
    end;
    if not DeviceIoControl( hDevice, $0007c088, @SCIP, SizeOf(TSendCmdInParams)-1,
      @aIdOutCmd, SizeOf(aIdOutCmd), cbBytesReturned, nil ) then Exit;
  finally
    CloseHandle(hDevice);
  end;
  with PIdSector(@IdOutCmd.bBuffer)^ do
  begin
    ChangeByteOrder( sSerialNumber, SizeOf(sSerialNumber) );
    (PAnsiChar(@sSerialNumber)+SizeOf(sSerialNumber))^ := #0;
    Result := Trim(PAnsiChar(@sSerialNumber));
  end;
end;

function TLoginCommObject.GetLocalComputerName: string;
var
  Buffer: array[0..MAX_COMPUTERNAME_LENGTH + 1] of Char;
  Size: DWORD;
begin
  Size := MAX_COMPUTERNAME_LENGTH + 1;
  if GetComputerName(Buffer, Size) then
    Result := Buffer
  else
    Result := '';
end;

function TLoginCommObject.GetLocalIPAddress: string;
var
  WSData: TWSAData;
  P: PHostEnt;
  HostName: array[0..255] of AnsiChar;
begin
  Result := '127.0.0.1';
  if WSAStartup($101, WSData) = 0 then
  begin
    try
      if GetHostName(@HostName, SizeOf(HostName)) = 0 then
      begin
        P := GetHostByName(@HostName);
        if P <> nil then
        begin
          Result := string(inet_ntoa(PInAddr(P^.h_addr_list^)^));
        end;
      end;
    finally
      WSACleanup;
    end;
  end;

end;

function TLoginCommObject.GetLocalMACAddress(idx: Integer): string;
var
  NCB: TNCB;
  ADAPTER: TADAPTERSTATUS;
  LANAENUM: TLANAENUM;
  intidx: integer;
  crc: AnsiChar;
  strtemp: string;
begin
  result := '';
  try
    zeromemory(@NCB, sizeof(NCB));
    NCB.ncb_command := chr(NCBENUM);
    netbios(@NCB);
    NCB.ncb_buffer := @LANAENUM;
    NCB.ncb_length := sizeof(LANAENUM);
    crc := netbios(@NCB);
    if ord(crc) <> 0 then exit;
    zeromemory(@NCB, sizeof(NCB));
    NCB.ncb_command := chr(NCBRESET);
    NCB.ncb_lana_num := LANAENUM.lana[idx];
    crc := netbios(@NCB);
    if ord(crc) <> 0 then exit;
    zeromemory(@NCB, sizeof(NCB));
    NCB.ncb_command := chr(NCBASTAT);
    NCB.ncb_lana_num := LANAENUM.lana[idx];
    strpcopy(NCB.ncb_callname, '*');
    NCB.ncb_buffer := @ADAPTER;
    NCB.ncb_length := sizeof(ADAPTER);
    netbios(@NCB);
    strtemp := '';
    for intidx := 0 to 5 do
      strtemp := strtemp + inttohex(integer(ADAPTER.adapter_address[intidx]), 2);
    result := strtemp;
  finally
    zeromemory(@NCB, sizeof(NCB));
  end;
end;

function TLoginCommObject.LoginServer: Boolean;
begin
  Result := Goo.Reg.ShowModal('TLoginServer') = mrOk;
end;

function TLoginCommObject.LoginUser: Boolean;
var AParamList:TParamList;
begin
  AParamList := TParamList.Create;
  try
    Result := Goo.Reg.ShowModal('TLoginUser',AParamList) = mrOk;
    if Result then
    begin
      FLoginUserRec := AParamList.AsInteger('@LoginUserRec');
      FLoginUserCode := AParamList.AsString('@LoginUserCode');
      FLoginUserName := AParamList.AsString('@LoginUserName');
    end;
  finally
    AParamList.Free;
  end;
end;

{ TMessageBoxObject }

procedure TMessageBoxObject.ShowMsg(const AMsg:string);
begin
  MessageBox(AMsg,'��ʾ',mtWarning,[mbOK]);
end;

procedure TMessageBoxObject.CheckAndAbort(AResult: Boolean; const AMSG: String);
begin
  if Not AResult then ShowErrorAndAbort(AMSG);
end;

procedure TMessageBoxObject.CheckAndAbort(AResult: Boolean);
begin
  if Not AResult then Abort;
end;

procedure TMessageBoxObject.CheckAndAbort(AResult: Boolean; const AMSG: String; const Args: array of const);
begin
  CheckAndAbort(AResult,Format(AMSG,Args));
end;

constructor TMessageBoxObject.Create(AOwner: TObject);
begin
  inherited ;
  FProgressBarForm := nil;
  FdxAlertWindowManager := TdxAlertWindowManager.Create(nil);
  FdxAlertWindowManager.OptionsSize.Width := 400;
  FdxAlertWindowManager.OptionsMessage.Caption.Font.Size  := 9;
  //FdxAlertWindowManager.OptionsMessage.Caption.Font.Style := [];
  FdxAlertWindowManager.OptionsMessage.Text.Font.Color    := clHotLight;
end;

destructor TMessageBoxObject.Destroy;
begin
  if Assigned(FProgressBarForm) then FreeAndNil(FProgressBarForm);
  if Assigned(FdxAlertWindowManager) then FreeAndNil(FdxAlertWindowManager);  
  inherited;
end;

function TMessageBoxObject.MessageBox(const AMsg, ATitle: string; ADlgType: TMsgDlgType; ADlgButtons: TMsgDlgButtons): Integer;
var AParam:TParamList;
begin
  AParam := TParamList.Create;
  try
    AParam.Add('@Caption',ATitle);
    AParam.Add('@Message',AMsg);
    AParam.Add('@DlgType',ADlgType);
    AParam.AddOrSetValue('@Buttons',TValue.From<TMsgDlgButtons>(ADlgButtons));
    Result := Goo.Reg.ShowModal('TMessageBoxDialog',AParam);
  finally
    AParam.Free;
  end;

end;

function TMessageBoxObject.Question(const AMsg: String; const Args: array of const; const ATitle: string): Boolean;
begin
  Result := Question(Format(AMsg,Args),ATitle);
end;

function TMessageBoxObject.Question(const AMsg, ATitle: string): Boolean;
begin
  Result := MessageBox(AMsg,'��ȷ�ϣ�����',mtConfirmation,[mbOK,TMsgDlgBtn.mbCancel]) = mrOk;
end;

procedure TMessageBoxObject.ShowError(const AMsg: String; const Args: array of const);
begin
  ShowError(Format(AMsg,Args));
end;

procedure TMessageBoxObject.ShowErrorAndAbort(const AMsg: String; const Args: array of const);
begin
  ShowErrorAndAbort(Format(AMsg,Args));
end;

function TMessageBoxObject.ShowInput(var AValue: Variant; const ATitle: string; ACaption: string): Boolean;
begin
  Result := ShowInput<Variant>(AValue,ATitle,ACaption);
end;

function TMessageBoxObject.ShowInput<T>(var AValue: T; const ATitle: string; ACaption: string;ADecimal:Integer): Boolean;
var AParam:TParamList;
begin
  Result := False;
  AValue := Default(T);
  AParam := TParamList.Create;
  try
    AParam.Add('@Caption',ACaption);
    AParam.Add('@Title',ATitle);
    //AParam.Add('@InputTypeInfo',TypeInfo(T));
    if TypeInfo(T) = TypeInfo(Integer) then AParam.Add('@Integer',True);
    if (TypeInfo(T) = TypeInfo(Double)) or (TypeInfo(T) = TypeInfo(Currency)) then
    begin
      AParam.Add('@Double',True);
      AParam.Add('@Decimal',ADecimal);
    end;
    Result := Goo.Reg.ShowModal('TInputBoxDialog',AParam)=mrOk;
    if Result then AValue := AParam.AsValue<T>('@RestultInput');
  finally
    AParam.Free;
  end;
end;

function TMessageBoxObject.ShowInput<T>(const ATitle: string; ACaption: string): T;
begin
  ShowInput<T>(Result,ATitle,ACaption);
end;

procedure TMessageBoxObject.ShowErrorAndAbort(const AMsg: String);
begin
  ShowError(AMsg);
  Abort;
end;

procedure TMessageBoxObject.ShowError(const AMsg: String);
begin
  MessageBox(AMsg,'��ʾ',mtError,[mbOK]);
end;

function TMessageBoxObject.ShowMainThreadBar(AMax:Integer=100; ATitle:string=''): Integer;
var AProBar:TProgressBar;
begin
  FMainThreadBarTick := GetTickCount;
  AProBar := Goo.ComVar.AsObject('@AppMainForm_ProgressBar') as TProgressBar;
  if not Assigned(AProBar) then Exit;
  AProBar.Visible := True;
  AProBar.Max     := AMax;
  AProBar.Position:=0;
  if Assigned(Goo.ComVar.AsObject('@AppMainForm_StutasMessageBar')) then (Goo.ComVar.AsObject('@AppMainForm_StutasMessageBar') as TStatusPanel).Text := ATitle;
  Result := FMainThreadBarTick;
end;

procedure TMessageBoxObject.ShowMsg(const AMsg:string; Args: array of const);
begin
  ShowMsg(Format(AMsg,Args));
end;

procedure TMessageBoxObject.ShowProgressBar(AMax: Integer; ATitle: string);
var AParam:TParamList;
begin
  AParam := TParamList.Create;
  try
    AParam.Add('@Title',ATitle);
    AParam.Add('@Max',AMax);
    if not Assigned(FProgressBarForm) then FProgressBarForm := Goo.Reg.CreateFormClass('TProgressBarDialog',AParam);
    (FProgressBarForm as IProgressBarFormInt).ShowProgressBar(FProgressBarForm);
  finally
    AParam.Free;
  end;
end;

function TMessageBoxObject.ShowAlert(const AText: string;ACaption:string='��ʾ'):
    TdxAlertWindow;
begin
  Result := FdxAlertWindowManager.Show(ACaption,AText);
end;

procedure TMessageBoxObject.StepBy(Delta: Integer; ATitle: string);
begin
  if Assigned(FProgressBarForm) then
  begin
    SendMessage(FProgressBarForm.Handle,$8001,Delta,Integer(@ATitle));
  end;
end;

function TMessageBoxObject.StepByMainThreadBar(Delta: Integer=1; ATitle:string=''): Integer;
var AProBar:TProgressBar;
begin
  Result  := GetTickCount - FMainThreadBarTick;
  ATitle  := ATitle + Format('������ʱ��%d ��',[Ceil(Result/1000)]);
  AProBar := Goo.ComVar.AsObject('@AppMainForm_ProgressBar') as TProgressBar;
  if not Assigned(AProBar) then Exit;
  AProBar.Position := AProBar.Position+Delta;
  if AProBar.Position=AProBar.Max then AProBar.Visible := False;
  if not AProBar.Visible then ATitle := '��ϣ�';
  if Assigned(Goo.ComVar.AsObject('@AppMainForm_StutasMessageBar')) then (Goo.ComVar.AsObject('@AppMainForm_StutasMessageBar') as TStatusPanel).Text := ATitle;
end;

{ TThemeObject }

class function TThemeObject.ColorToHtml(AColor: TColor): string;
begin
  Result := Format('#%.2x%.2x%.2x', [GetRValue(AColor), GetGValue(AColor), GetBValue(AColor)]);
end;

constructor TThemeObject.Create(AOwner: TObject);
begin
    inherited Create(AOwner);
    FThemeGrid.GridItemHeight       := 25;     //=25;����и�
    FThemeGrid.GridRowFontSize      := 10;     //=10;������������С
    FThemeGrid.GridHeadHeight       := 25;     //=25;��ͷ�и�
    FThemeGrid.GridTitleFontSize    := 10;     //=10;��ͷ���������С
    FThemeGrid.GridFontColor        := HtmlToColor('#4B5053'); //;���������ɫ
    FThemeGrid.GridHeadFontColor    := HtmlToColor('#023350'); //=;��ͷ������ɫ
    FThemeGrid.GridFooterFontColor  := HtmlToColor('#4B5053'); //=;�ϼ���������ɫ
    FThemeGrid.GridBackColor        := HtmlToColor('#FFFFFF'); //=;��񱳾���ɫ
    FThemeGrid.GridHeadBackColor    := HtmlToColor('#F5F5F5'); //=;��ͷ������ɫ
    FThemeGrid.GridOneItemColor     := HtmlToColor('#FFFFFF'); //=;���������ɫ
    FThemeGrid.GridTwoItemColor     := HtmlToColor('#F5F5F5'); //=;���ż����ɫ
    FThemeGrid.GridSelectItemColor  := HtmlToColor('#DDF2D0'); //=;���ѡ������ɫ
    FThemeGrid.GridFooterColor      := HtmlToColor('#FFFFFF'); //=;���ϼ�����ɫ
    FThemeGrid.GridFixBackBolor     := HtmlToColor('#F5F5F5'); //=;�����߹̶��б�����ɫ
    FThemeGrid.GridRowFocusColor    := HtmlToColor('#AEE18E'); //=;���ѡ�е�Ԫ����ɫ
end;

class function TThemeObject.HtmlToColor(const AHtmlColor: string): TColor;
var
  R, G, B: Byte;
begin
  Result := clNone;
  if Length(AHtmlColor) = 7 then
  begin
    R := StrToInt('$' + Copy(AHtmlColor, 2, 2));
    G := StrToInt('$' + Copy(AHtmlColor, 4, 2));
    B := StrToInt('$' + Copy(AHtmlColor, 6, 2));
    Result := RGB(R, G, B);
  end;
end;

{ TFormatCommObject }

function TFormatCommObject.ColorToHtml(AColor: TColor): string;
begin
  Result := Format('#%.2x%.2x%.2x', [GetRValue(AColor), GetGValue(AColor), GetBValue(AColor)]);
end;

function TFormatCommObject.DataSetToObject<T>(ADataSet: TDataSet; AObject: TObject): Boolean;
var Context:TRttiContext;
  Prop:TRttiProperty;
  typ:TRttiType;
  AFieldName:string;
begin
  Result := False;
  Context := TRttiContext.Create;
  try
    typ := Context.GetType(AObject.ClassType);
    for Prop in typ.GetProperties do
    begin
      if not Prop.IsWritable then Continue;
      AFieldName := Prop.Name;
      //��ȡ���Զ�Ӧ�����ݿ��ֶ�
      if Prop.HasAttribute<T> then AFieldName := (Prop.GetAttribute<T> as TFieldInfo).FieldName;
      if AFieldName.IsEmpty then AFieldName := Prop.Name;
      if not Assigned(ADataSet.FindField(AFieldName)) then Continue;
      if VarIsNull(ADataSet.FieldValues[AFieldName]) then Continue;
      try
        case Prop.PropertyType.TypeKind of
          tkInteger,tkInt64: Prop.SetValue(AObject,TValue.From<Integer>(ADataSet.FieldByName(AFieldName).AsInteger));
          tkFloat: Prop.SetValue(AObject,TValue.From<Double>(ADataSet.FieldByName(AFieldName).AsFloat));
          tkString,tkUString: Prop.SetValue(AObject,TValue.From<string>(ADataSet.FieldByName(AFieldName).AsString));
          else Prop.SetValue(AObject,TValue.FromVariant(ADataSet.FieldValues[AFieldName]));
        end;
        Result := True;
      except on E: Exception do Goo.Logger.Error('DataSetToObject��%s����ת������',[AObject.ClassName]);
      end;
    end;
  finally
    Context.Free;
  end;
end;

function TFormatCommObject.GetClassAttribute<T>(AClass: TClass): T;
var
  Context: TRttiContext;
  ObjType: TRttiType;
begin
  Result := Default(T);
  Context := TRttiContext.Create;
  try
    Result := Context.GetType(AClass).GetAttribute<T>;
  finally
    Context.Free;
  end;
end;

function TFormatCommObject.HtmlToColor(const AHtmlColor: string): TColor;
var
  R, G, B: Byte;
begin
  Result := clNone;
  if Length(AHtmlColor) = 7 then
  begin
    R := StrToInt('$' + Copy(AHtmlColor, 2, 2));
    G := StrToInt('$' + Copy(AHtmlColor, 4, 2));
    B := StrToInt('$' + Copy(AHtmlColor, 6, 2));
    Result := RGB(R, G, B);
  end;
end;

function TFormatCommObject.iif(condtion: boolean; A, B: integer): integer;
begin
  if condtion then Result := A else Result := B;  
end;

function TFormatCommObject.iif(condtion: boolean; A, B: string): string;
begin
  if condtion then Result := A else Result := B;
end;

function TFormatCommObject.iif(condtion, A, B: Boolean): boolean;
begin
  if condtion then Result := A else Result := B;
end;

function TFormatCommObject.iif(condtion: boolean; A, B: Double): Double;
begin
  if condtion then Result := A else Result := B;
end;

function TFormatCommObject.iif(condtion: boolean; A, B: OleVariant): OleVariant;
begin
  if condtion then Result := A else Result := B;
end;

function TFormatCommObject.IsNull(ACheckvalue, AReplaceValue: olevariant): olevariant;
begin
  if ACheckvalue=Null then
    Result := AReplaceValue
  else
    Result := ACheckvalue;
end;

function TFormatCommObject.StringToChinese(const AStr: string): string;
var
  Encoding: TEncoding;
begin
  Encoding := TEncoding.GetEncoding('GB18030');
  try
    Result := Encoding.GetString(TEncoding.Default.GetBytes(AStr));
  finally
    Encoding.Free;
  end;
end;

{ TPlayMediaObject }

procedure TPlayMediaObject.Close;
begin
  if Assigned(FMediaPlayer) then FMediaPlayer.Close;
end;

constructor TPlayMediaObject.Create(AOwner: TObject);
begin
  inherited Create(AOwner);
end;

destructor TPlayMediaObject.Destroy;
begin
  if Assigned(FMediaPlayer) then
  begin
    FMediaPlayer.Close;
    FMediaPlayer.Free;
  end;
  inherited;
end;

procedure TPlayMediaObject.Play(AFile: string);
begin
  if not FileExists(AFile) then Exit;
  if not Assigned(FMediaPlayer) then
  begin
    FMediaPlayer := TMediaPlayer.Create(nil);
    FMediaPlayer.Visible := False;
    FMediaPlayer.Parent  := Application.MainForm;
  end;
  FMediaPlayer.Close;
  FMediaPlayer.FileName := AFile;
  FMediaPlayer.Open;
  FMediaPlayer.Play;
end;

end.
