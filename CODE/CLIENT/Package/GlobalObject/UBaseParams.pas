unit UBaseParams;

interface

uses
  System.Classes, UComDBStorable, System.SysUtils, Datasnap.DBClient, UComConst;

type
  /// <summary>
  /// ��ѯ����
  /// </summary>
  TBaseParam = class(TComponent)
  private
    FLocate: Boolean;
    FTitle: string;
    FMultSel: Boolean;
    FFullSel: Boolean;
    //FStorable: TStorable;
    FStorableDictionary: TStorableDictionary;
    FSearchString: string;
    FSearchHint: string;
    FParID: string;
    FBasicType: TBasicType;
  protected
    function GetStorable: TStorableClass;virtual;abstract;
    function GetStorableDictionary: TStorableDictionary;virtual;
  public
    constructor Create(ABasicType:TBasicType);overload;
    destructor Destroy; override;
    procedure GetBaseInfoDataSet(ADataSet:TClientDataSet);virtual;abstract;
    function Count:Integer;
    function First:TStorable;virtual;
    function GetBaseInfoSelect:Integer;overload;
    property BasicType:TBasicType read FBasicType;
    property Storable:TStorableClass read GetStorable;
    property Return:TStorableDictionary read GetStorableDictionary;
    class function CreateParam(ABasicType:TBasicType):TBaseParam;
  published
    property Locate: Boolean  read FLocate write FLocate;                       //��λ
    /// <summary>
    /// ȫѡ
    /// </summary>
    property FullSel: Boolean read FFullSel write FFullSel;                     //ȫѡ
    /// <summary>
    /// ��ѡ
    /// </summary>
    property MultSel: Boolean read FMultSel write FMultSel;                     //��ѡ
    /// <summary>
    /// ����
    /// </summary>
    property Title: string    read FTitle write FTitle;                         //����
    /// <summary>
    /// ��ѯ�����ַ���
    /// </summary>
    property SearchString: string read FSearchString write FSearchString;
    /// <summary>
    /// ˵��
    /// </summary>
    property SearchHint: string read FSearchHint write FSearchHint;
    /// <summary>
    /// ��ǰ���ڵ�
    /// </summary>
    property ParID: string read FParID write FParID;
  end;
  //��Ʒ��Ϣ
  TPTypeParam = class(TBaseParam)
  protected
    function GetStorable: TStorableClass;override;
  public
    constructor Create(AOwner: TComponent); overload;
    procedure GetBaseInfoDataSet(ADataSet:TClientDataSet);override;
  end;
  TBaseParamClass = class of TBaseParam;
  //������Ϣ
  TCSTypeParam = class(TBaseParam)
  protected
    function GetStorable: TStorableClass;override;
  public
    constructor Create(AOwner: TComponent); overload;
    procedure GetBaseInfoDataSet(ADataSet:TClientDataSet);override;
  end;
  //�ŵ���Ϣ
  TMTypeParam = class(TBaseParam)
  protected
    function GetStorable: TStorableClass;override;
  public
    constructor Create(AOwner: TComponent); overload;
    procedure GetBaseInfoDataSet(ADataSet:TClientDataSet);override;
  end;
  //ְԱ��Ϣ
  TETypeParam = class(TBaseParam)
  protected
    function GetStorable: TStorableClass;override;
  public
    constructor Create(AOwner: TComponent); overload;
    procedure GetBaseInfoDataSet(ADataSet:TClientDataSet);override;
  end;
  TKTypeParam = class(TBaseParam)
  protected
    function GetStorable: TStorableClass;override;
  public
    constructor Create(AOwner: TComponent); overload;
    procedure GetBaseInfoDataSet(ADataSet:TClientDataSet);override;
  end;
  TBTypeParam = class(TBaseParam)
  protected
    function GetStorable: TStorableClass;override;
  public
    constructor Create(AOwner: TComponent); overload;
    procedure GetBaseInfoDataSet(ADataSet:TClientDataSet);override;
  end;
  TVipCardParam = class(TBaseParam)
  protected
    function GetStorable: TStorableClass;override;
  public
    constructor Create(AOwner: TComponent); overload;
    procedure GetBaseInfoDataSet(ADataSet:TClientDataSet);override;
  end;
  TBillTypeParam = class(TBaseParam)
  protected
    function GetStorable: TStorableClass;override;
  public
    constructor Create(AOwner: TComponent); overload;
    procedure GetBaseInfoDataSet(ADataSet:TClientDataSet);override;
  end;


implementation

uses
  UComvar, Vcl.Controls, UParamList;

{ TBaseParam }

function TBaseParam.Count: Integer;
begin
  Result := Return.Count;
end;

constructor TBaseParam.Create(ABasicType: TBasicType);
begin
  Create(nil);
  FParID := EmptyStr;
  FBasicType := ABasicType;
end;

class function TBaseParam.CreateParam(ABasicType: TBasicType): TBaseParam;
begin
  case ABasicType of
    btBtype : Result := TBTypeParam.Create(nil);
    btPtype : Result := TPTypeParam.Create(nil);
    btEtype : Result := TETypeParam.Create(nil);
    btMtype : Result := TMTypeParam.Create(nil);
    btCSType: Result := TCSTypeParam.Create(nil);

    btVchType : Result := TBillTypeParam.Create(nil);
    btVipCard : Result := TVipCardParam.Create(nil);
  end;
  Result.FBasicType := ABasicType;
end;

destructor TBaseParam.Destroy;
begin
  //if Assigned(FStorable) then FreeAndNil(FStorable);
  if Assigned(FStorableDictionary) then FreeAndNil(FStorableDictionary);
  inherited;
end;

function TBaseParam.First: TStorable;
begin
   Result := Return.First;
end;

function TBaseParam.GetBaseInfoSelect: Integer;
var AParamList:TParamList;
begin
  Result := 0;
  AParamList := TParamList.Create;
  try
    AParamList.Add('@BaseParam_BaseInfoSelect',Self);
    Return.ClearAndFree;
    if not(goo.Reg.ShowModal('TBaseInfoSel',AParamList)=mrOk) then Exit;
    Result := Count;
  finally
    AParamList.Free;
  end;
end;
function TBaseParam.GetStorableDictionary: TStorableDictionary;
begin
  if not Assigned(FStorableDictionary) then FStorableDictionary:= TStorableDictionary.Create;
  Result := FStorableDictionary;
end;

{ TMTypeParam }

constructor TMTypeParam.Create(AOwner: TComponent);
begin
  inherited Create(btMtype);
  Title := '�ŵ�';
end;

procedure TMTypeParam.GetBaseInfoDataSet(ADataSet: TClientDataSet);
var ASQL:string;
begin
  ASQL:= 'select posid as rec,poscode as usercode,posname as fullname,* from posinfo where deleted=0';
  if SearchString.Trim<>EmptyStr then
  begin
    ASQL := ASQL + ' and (poscode like ''%' + SearchString + '%''';
    ASQL := ASQL + ' or    posname like ''%' + SearchString + '%''';
    ASQL := ASQL + ' or    pyzjm   like ''%' + SearchString + '%'')';
  end;
  Goo.DB.OpenSQL(ASQL,ADataSet);
end;

function TMTypeParam.GetStorable: TStorableClass;
begin
  //if not Assigned(FStorable) then FStorable:= TStorable_MType.Create;
  Result := TStorable_MType;
end;

{ TPTypeParam }

constructor TPTypeParam.Create(AOwner: TComponent);
begin
  inherited Create(btPtype);
  Title := '��Ʒ';
  ParID := '00000';
end;

procedure TPTypeParam.GetBaseInfoDataSet(ADataSet: TClientDataSet);
var ASQL:string;
begin
  ASQL:= 'select * from ptype where deleted=0';
  if SearchString.Trim<>EmptyStr then
  begin
    ASQL := ASQL + ' and sonnum=0 and (usercode like ''%' + SearchString + '%''';
    ASQL := ASQL + ' or    fullname like ''%' + SearchString + '%''';
    ASQL := ASQL + ' or    pyzjm   like ''%' + SearchString + '%'')';
  end
  else if ParID<>EmptyStr then ASQL := ASQL + Format(' and ParId = ''%s''',[ParID])
  else ASQL := ASQL + ' and sonnum=0';
  Goo.DB.OpenSQL(ASQL,ADataSet);
end;

function TPTypeParam.GetStorable: TStorableClass;
begin
  //if not Assigned(FStorable) then FStorable:= TStorable_PType.Create;
  Result := TStorable_PType;
end;

{ TETypeParam }

constructor TETypeParam.Create(AOwner: TComponent);
begin
  inherited Create(btEtype);
  Title := 'ְԱ';
end;

procedure TETypeParam.GetBaseInfoDataSet(ADataSet: TClientDataSet);
var ASQL:string;
begin
  ASQL := 'SELECT e.REC,e.typeId,e.Parid,e.leveal,e.soncount,e.sonnum,e.UserCode,e.FullName,d.Fullname AS Department,e.Tel,e.Sex,e.Posid,p.PosName '
        + 'FROM dbo.employee e LEFT JOIN dbo.Department d ON e.Department=d.Rec	LEFT JOIN dbo.PosInfo p ON e.Posid=p.PosId '
        + 'where e.deleted=0 AND e.sonnum=0 ';
  if SearchString.Trim<>EmptyStr then
  begin
    ASQL := ASQL + ' and (e.usercode like ''%' + SearchString + '%''';
    ASQL := ASQL + ' or   e.fullname like ''%' + SearchString + '%''';
    ASQL := ASQL + ' or   e.pyzjm    like ''%' + SearchString + '%'')';
  end;
  Goo.DB.OpenSQL(ASQL,ADataSet);
end;

function TETypeParam.GetStorable: TStorableClass;
begin
  //if not Assigned(FStorable) then FStorable:= TStorable_EType.Create;
  Result := TStorable_EType;
end;

{ TKTypeParam }

constructor TKTypeParam.Create(AOwner: TComponent);
begin
  inherited Create(btKtype);

end;

procedure TKTypeParam.GetBaseInfoDataSet(ADataSet: TClientDataSet);
begin

end;

function TKTypeParam.GetStorable: TStorableClass;
begin

end;

{ TBTypeParam }

constructor TBTypeParam.Create(AOwner: TComponent);
begin
  inherited Create(btBtype);
  Title := '����';
end;

procedure TBTypeParam.GetBaseInfoDataSet(ADataSet: TClientDataSet);
var ASQL:string;
begin
  ASQL:= 'select * from btype where deleted=0 AND sonnum=0 AND typeId NOT LIKE ''9%''';
  if SearchString.Trim<>EmptyStr then
  begin
    ASQL := ASQL + ' and (usercode like ''%' + SearchString + '%''';
    ASQL := ASQL + ' or    fullname like ''%' + SearchString + '%''';
    ASQL := ASQL + ' or    pyzjm    like ''%' + SearchString + '%'')';
  end;
  Goo.DB.OpenSQL(ASQL,ADataSet);
end;

function TBTypeParam.GetStorable: TStorableClass;
begin
  //if not Assigned(FStorable) then FStorable:= TStorable_BType.Create;
  Result := TStorable_BType;
end;

{ TCSTypeParam }

constructor TCSTypeParam.Create(AOwner: TComponent);
begin
  inherited Create(btCSType);
  Title := '����';
end;

procedure TCSTypeParam.GetBaseInfoDataSet(ADataSet: TClientDataSet);
var ASQL:string;
begin
  ASQL:= 'select * from cstype where deleted=0';
  if SearchString.Trim<>EmptyStr then
  begin
    ASQL := ASQL + ' and sonnum=0 and (usercode like ''%' + SearchString + '%''';
    ASQL := ASQL + ' or    fullname like ''%' + SearchString + '%''';
    ASQL := ASQL + ' or    pyzjm   like ''%' + SearchString + '%'')';
  end
  else if ParID<>EmptyStr then ASQL := ASQL + Format(' and ParId = ''%s''',[ParID])
  else ASQL := ASQL + ' and sonnum=0';
  Goo.DB.OpenSQL(ASQL,ADataSet);
end;

function TCSTypeParam.GetStorable: TStorableClass;
begin
  //if not Assigned(FStorable) then FStorable:= TStorable_CSType.Create;
  Result := TStorable_CSType;
end;

{ TVipCardParam }

constructor TVipCardParam.Create(AOwner: TComponent);
begin
  inherited Create(btBtype);
  Title := '��Ա��';
  SearchHint := '���ٲ�ѯ[Ctrl+F]�����š��������绰';
end;

procedure TVipCardParam.GetBaseInfoDataSet(ADataSet: TClientDataSet);
var ASQL:string;
begin
  ASQL:= 'SELECT top 100 ID as Rec,ID as Typeid,CardType as ParID,CardNo as UserCode,Name as FullName,Tel,Sex FROM dbo.VipCard';
  if SearchString.Trim<>EmptyStr then
  begin
    ASQL := ASQL + ' where (CardNo like ''%' + SearchString + '%''';
    ASQL := ASQL + ' or    Name like ''%' + SearchString + '%''';
    ASQL := ASQL + ' or    Tel  like ''%' + SearchString + '%'')';
  end;
  Goo.DB.OpenSQL(ASQL,ADataSet);
end;

function TVipCardParam.GetStorable: TStorableClass;
begin
  Result := TStorable_VipCard;
end;

{ TBillTypeParam }

constructor TBillTypeParam.Create(AOwner: TComponent);
begin
  inherited Create(btBtype);
  Title := '����';
  SearchHint := '���ٲ�ѯ[Ctrl+F]����������';
end;

procedure TBillTypeParam.GetBaseInfoDataSet(ADataSet: TClientDataSet);
var ASQL:string;
begin
  ASQL:= 'SELECT billtype as Rec,billtype as UserCode,billName as FullName FROM dbo.BillType where billtype>0';
  if SearchString.Trim<>EmptyStr then
  begin
    ASQL := ASQL + ' and (billName like ''%' + SearchString + '%''';
    ASQL := ASQL + ' or dbo.fGetPy(billName)  like ''%' + SearchString + '%'')';
  end;
  Goo.DB.OpenSQL(ASQL,ADataSet);
end;

function TBillTypeParam.GetStorable: TStorableClass;
begin
  Result := TStorable_VchType;
end;

initialization

end.
