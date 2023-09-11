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
    FStorable: TStorable;
    FStorableDictionary: TStorableDictionary;
    FSearchString: string;
    FSearchHint: string;
    FParID: string;
  protected
    function GetStorable: TStorable;virtual;abstract;
    function GetStorableDictionary: TStorableDictionary;virtual;
  public
    constructor Create(ABasicType:TBasicType);overload;
    destructor Destroy; override;
    procedure GetBaseInfoDataSet(ADataSet:TClientDataSet);virtual;abstract;
    function Count:Integer;
    function First:TStorable;virtual;
    function GetBaseInfoSelect:Integer;overload;
    property Storable:TStorable read GetStorable;
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
    function GetStorable: TStorable;override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure GetBaseInfoDataSet(ADataSet:TClientDataSet);override;
  end;
  //�ŵ���Ϣ
  TMTypeParam = class(TBaseParam)
  protected
    function GetStorable: TStorable;override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure GetBaseInfoDataSet(ADataSet:TClientDataSet);override;
  end;
  //ְԱ��Ϣ
  TETypeParam = class(TBaseParam)
  protected
    function GetStorable: TStorable;override;
  public
    constructor Create(AOwner: TComponent); override;
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
end;

class function TBaseParam.CreateParam(ABasicType: TBasicType): TBaseParam;
begin
  case ABasicType of
    btPtype : Result := TPTypeParam.Create(nil);
    btEtype : Result := TETypeParam.Create(nil);
    btMtype : Result := TMTypeParam.Create(nil);
  end;
end;

destructor TBaseParam.Destroy;
begin
  if Assigned(FStorable) then FreeAndNil(FStorable);
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
  inherited Create(AOwner);
  Title := '�ŵ���Ϣѡ��';
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

function TMTypeParam.GetStorable: TStorable;
begin
  if not Assigned(FStorable) then FStorable:= TStorable_MType.Create;
  Result := FStorable as TStorable_MType;
end;

{ TPTypeParam }

constructor TPTypeParam.Create(AOwner: TComponent);
begin
  inherited;
  Title := '��Ʒ��Ϣѡ��';
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

function TPTypeParam.GetStorable: TStorable;
begin
  if not Assigned(FStorable) then FStorable:= TStorable_PType.Create;
  Result := FStorable as TStorable_PType;
end;

{ TETypeParam }

constructor TETypeParam.Create(AOwner: TComponent);
begin
  inherited;
  Title := 'ְԱ��Ϣѡ��';
end;

procedure TETypeParam.GetBaseInfoDataSet(ADataSet: TClientDataSet);
var ASQL:string;
begin
  ASQL:= 'select * from employee where deleted=0 AND sonnum=0';
  if SearchString.Trim<>EmptyStr then
  begin
    ASQL := ASQL + ' and (usercode like ''%' + SearchString + '%''';
    ASQL := ASQL + ' or    fullname like ''%' + SearchString + '%''';
    ASQL := ASQL + ' or    pyzjm    like ''%' + SearchString + '%'')';
  end;
  Goo.DB.OpenSQL(ASQL,ADataSet);
end;

function TETypeParam.GetStorable: TStorable;
begin
  if not Assigned(FStorable) then FStorable:= TStorable_EType.Create;
  Result := FStorable as TStorable_EType;
end;

end.
