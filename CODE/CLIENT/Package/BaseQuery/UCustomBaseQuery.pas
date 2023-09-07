unit UCustomBaseQuery;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UBaseMdiForm, cxStyles, cxClasses,
  System.ImageList, Vcl.ImgList, System.Actions, Vcl.ActnList, Vcl.ExtCtrls,
  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit,
  cxNavigator, dxDateRanges, dxScrollbarAnnotations, Data.DB, cxDBData,
  cxGridLevel, cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, Vcl.StdCtrls, System.Generics.Collections,
  UParamList, Vcl.ComCtrls, UBaseControlManagerLayout, Datasnap.DBClient;

type
  TConditionManager = class;

  TCustomBaseQuery = class(TBaseMdiForm)
  private
    FCondition: TConditionManager;
    FButton: TButtonManager;
    FMainGrid: TcxGrid;
    FQueryDictionary: TDictionary<string, TDictionary<Integer,string>>;
    FGridDblClickID: Integer;
    function GetMainIndexView(index: Integer): TcxCustomGridView;
    function GetMainView: TcxGridDBTableView;
    function GetActiveRowIndex: Integer;
    function GetItemColumn(AFieldName: string): TcxGridDBColumn;
    function GetRowData(AFieldName: string; ARow: Integer): Variant;
    procedure SetRowData(AFieldName: string; ARow: Integer; const Value: Variant);
    function GetQueryDictionary: TDictionary<string, TDictionary<Integer, string>>;
    function GetActiveDataSet: TClientDataSet;
    function GetActiveGridView: TcxCustomGridView;
    { Private declarations }
  protected
    FCloseButtonRec:Integer;
    FPrintButtonRec:Integer;
    procedure DoReparePrintData; override;
    procedure DoShow; override;
    procedure SetGrid;virtual;   //�������ݶ�ȡ������
    procedure CustomGrid(AView :TcxCustomGridView);virtual;
    function AddGridView:TcxCustomGridView;virtual;
    procedure iniForm;virtual;
    procedure LoadFormLayout;virtual; //���ش�����ʽ����ѯ������
    procedure LoadData;virtual;       //����������װ������
    procedure OnIniButton(Sender: TObject); virtual;
    procedure OnGridViewDblClick(Sender:Tobject);virtual;
  public
    { Public declarations }
    destructor Destroy; override;
    procedure DoPrintHeader; override;
    procedure RefreshData;override;
    property Condition:TConditionManager read FCondition;
    property ButtonList:TButtonManager read FButton;
    property QueryDictionary:TDictionary<string,TDictionary<Integer,string>> read GetQueryDictionary;
    property MainGrid:TcxGrid read FMainGrid;
    property MainView:TcxGridDBTableView read GetMainView;
    property ItemView[index:Integer]:TcxCustomGridView read GetMainIndexView;
    property ActiveRowIndex:Integer read GetActiveRowIndex;
    property ActiveGridView: TcxCustomGridView read GetActiveGridView;
    property ActiveDataSet:TClientDataSet read GetActiveDataSet;
    property ItemColumn[AFieldName:string]: TcxGridDBColumn read GetItemColumn;
    property RowData[AFieldName:string;ARow:Integer]: Variant read GetRowData write SetRowData;
    property GridDblClickID:Integer read FGridDblClickID write FGridDblClickID;
  end;
  TConditionManager = class(TControlManagerLayout)
  private
    FFindButton:TButton;
    function GetFindButton: TButton;
  public
    destructor Destroy; override;
    procedure RefreshCondition; override;
    property FindButton:TButton read GetFindButton;
  end;

const C_QueryMode_OPENSQL  = 0;    //��ѯSQL
const C_QueryMode_OPENPROC = 1;    //��ѯ����

implementation

uses
  UComvar, System.JSON, System.IOUtils;

{$R *.dfm}

function TCustomBaseQuery.AddGridView: TcxCustomGridView;
begin
  Result:= CreatecxGridView(MainGrid);
  TcxGridDBTableView(Result).OnDblClick := OnGridViewDblClick;
  //�����Զ����ֶ�
  Result.BeginUpdate();
  try
    CustomGrid(Result);
  finally
    Result.EndUpdate;
  end;
end;

procedure TCustomBaseQuery.CustomGrid(AView: TcxCustomGridView);
var Json:TJSONObject;
begin
  inherited;
  if not FileExists(LayoutFilePath) then Exit;
  Json := Json.ParseJSONValue(TFile.ReadAllText(LayoutFilePath)) as TJSONObject;
  try
    if not Assigned(Json) then Exit;
    if not Assigned(Json.Values['GridList']) then Exit;
    if not Assigned(TJSONObject(Json.Values['GridList']).Values[AView.Name]) then Exit;
    var _ProceName : string := EmptyStr;
    var _SQLText   : string := EmptyStr;
    TJSONObject(Json.Values['GridList']).Values[AView.Name].TryGetValue<string>('ProceName',_ProceName);
    TJSONObject(Json.Values['GridList']).Values[AView.Name].TryGetValue<string>('SQLText',_SQLText);
    var _Dic := TDictionary<Integer,string>.Create;
    _Dic.AddOrSetValue(C_QueryMode_OPENSQL,_SQLText);
    _Dic.AddOrSetValue(C_QueryMode_OPENPROC,_ProceName);
    QueryDictionary.AddOrSetValue(AView.Name,_Dic);
    if not Assigned(TJSONObject(TJSONObject(Json.Values['GridList']).Values[AView.Name]).Values['FieldList']) then Exit;
    if not (TJSONObject(TJSONObject(Json.Values['GridList']).Values[AView.Name]).Values['FieldList'] is TJSONArray) then Exit;
    for var item in TJSONObject(TJSONObject(Json.Values['GridList']).Values[AView.Name]).Values['FieldList'] as TJSONArray do
    begin
      var _Column := (AView as TcxGridDBTableView).CreateColumn;
      _Column.Name    := AView.Name + item.GetValue<string>('FieldName');
      _Column.Caption := item.GetValue<string>('Caption');
      _Column.DataBinding.FieldName := item.GetValue<string>('FieldName');
      _Column.Width   := item.GetValue<Integer>('Width',80);
      _Column.HeaderAlignmentHorz   := taCenter;
      _Column.Visible := item.GetValue<Boolean>('Visible',False);
      _Column.VisibleForCustomization := item.GetValue<Boolean>('VisibleForCustomization',Visible);
    end;
  finally
    Json.Free;
  end;
end;

destructor TCustomBaseQuery.Destroy;
begin
  if Assigned(FCondition) then FreeAndNil(FCondition);
  if Assigned(FButton) then FreeAndNil(FButton);
  if Assigned(MainGrid) then
  begin
    for var i := MainGrid.Levels.Count-1 downto 0 do
    begin
      var GridView := MainGrid.Levels[i].GridView;
      if Assigned(GridView) then
      begin
        if (GridView is TcxGridDBTableView) and Assigned(TcxGridDBTableView(GridView).DataController.DataSource) then
        begin
          //�ͷ� DataSet
          if Assigned(TcxGridDBTableView(GridView).DataController.DataSource.DataSet) then
            FreeAndNil(TcxGridDBTableView(GridView).DataController.DataSet);
          //�ͷ� DataSource
          FreeAndNil(TcxGridDBTableView(GridView).DataController.DataSource);
        end;
        FreeAndNil(GridView);
      end;
    end;
  end;
  if Assigned(FQueryDictionary) then
  begin
    for var dic in FQueryDictionary.Values do
      if Assigned(dic) then FreeAndNil(dic);
    FreeAndNil(FQueryDictionary);
  end;
  inherited;
end;

procedure TCustomBaseQuery.DoPrintHeader;
begin
  inherited;
  for var item in Condition do
  begin
    PrintItems.Add(item.Value.Caption,item.Value.ValueText);
  end;
end;

procedure TCustomBaseQuery.DoReparePrintData;
begin
  inherited;
  PrintDetailData := GetPrintData(ActiveGridView);
end;

procedure TCustomBaseQuery.DoShow;
begin
  iniForm;
  LoadFormLayout;
  SetGrid;
  inherited;
end;

function TCustomBaseQuery.GetActiveDataSet: TClientDataSet;
begin
  Result := TcxGridDBTableView(MainGrid.ActiveView).DataController.DataSet as TClientDataSet
end;

function TCustomBaseQuery.GetActiveGridView: TcxCustomGridView;
begin
  Result := MainGrid.ActiveView;
end;

function TCustomBaseQuery.GetActiveRowIndex: Integer;
begin
  Result := MainGrid.ActiveView.DataController.FocusedRowIndex;
end;

function TCustomBaseQuery.GetItemColumn(AFieldName: string): TcxGridDBColumn;
begin
  Result := MainView.GetColumnByFieldName(AFieldName);
end;

function TCustomBaseQuery.GetMainIndexView(index: Integer): TcxCustomGridView;
begin
  Result := MainGrid.Levels[index].GridView;
end;

function TCustomBaseQuery.GetMainView: TcxGridDBTableView;
begin
  var view := ItemView[0];
  if view is TcxGridDBTableView then
    Result := view as TcxGridDBTableView;
end;

function TCustomBaseQuery.GetQueryDictionary: TDictionary<string, TDictionary<Integer, string>>;
begin
  if not Assigned(FQueryDictionary) then FQueryDictionary := TDictionary<string,TDictionary<Integer,string>>.Create;
  Result := FQueryDictionary;
end;

function TCustomBaseQuery.GetRowData(AFieldName: string;  ARow: Integer): Variant;
begin
  Result := null;
  if not Assigned(MainGrid) then Exit;
  if not Assigned(MainGrid.ActiveView) then Exit;
  if (MainGrid.ActiveView.DataController.RowCount=0) or (ARow>=MainGrid.ActiveView.DataController.RowCount) or (ARow<0) then Exit;
  var _column := ItemColumn[AFieldName];
  if not Assigned(_column) then Exit;
  Result := MainGrid.ActiveView.DataController.Values[ARow,_column.Index];
end;

procedure TCustomBaseQuery.iniForm;
begin
  if not Assigned(FCondition) then FCondition := TConditionManager.Create;
  Condition.Parent := Panel_Top;
  Condition.OWnerObject := Self;
  if not Assigned(FButton) then FButton := TButtonManager.Create;
  ButtonList.Parent := Panel_Button;
  ButtonList.OWnerObject := Self;
  //����̳���Ӱ�ť
  OnIniButton(nil);
end;

procedure TCustomBaseQuery.LoadData;
begin

end;

procedure TCustomBaseQuery.LoadFormLayout;
var Json:TJSONObject;
begin
  if FileExists(LayoutFilePath) then
  begin
    JSON := TJSONObject.ParseJSONValue(TFile.ReadAllText(LayoutFilePath)) as TJSONObject;
    try
      if not Assigned(JSON) then Exit;
      self.Caption := JSON.GetValue<string>('Caption',Caption);
      if not(JSON.Values['Condition'] is TJSONArray) then Exit;
      for var item in JSON.Values['Condition'] as TJSONArray do
      begin
        var _ControlType:Integer := 0;
        var _Name:string := EmptyStr;
        var _Caption:string := EmptyStr;
        var _TextHint:string := EmptyStr;
        var _MustField:Boolean := False;
        var _Visible:Boolean := True;

        if not item.TryGetValue<Integer>('ControlType',_ControlType) then Continue;
        item.TryGetValue<string>('Name',_Name);
        item.TryGetValue<string>('Caption',_Caption);
        item.TryGetValue<string>('TextHint',_TextHint);
        item.TryGetValue<Boolean>('MustField',_MustField);
        item.TryGetValue<Boolean>('Visible',_Visible);
        case _ControlType of
          17:Condition.AddDateBetween(_Name.TrimLeft(['@']),_Caption.Trim,_MustField,_Visible);   //ʱ���
        else
          Condition.Add(_ControlType,_Name.TrimLeft(['@']),_Caption.Trim,_MustField,_Visible,_TextHint);
        end;
      end;
    finally
      JSON.Free;
    end;
  end;
end;

procedure TCustomBaseQuery.OnGridViewDblClick(Sender: Tobject);
begin
  if Assigned(ItemColumn['TypeID']) and not VarIsNull(RowData['Sonnum',ActiveRowIndex]) and (RowData['Sonnum',ActiveRowIndex]>0) then
  begin
    Self.ParamList.Add('@ParID',RowData['TypeID',ActiveRowIndex]);
    RefreshData;
  end
  else if (GridDblClickID>0) and Assigned(ButtonList.Button[GridDblClickID]) then ButtonList.Button[GridDblClickID].OnClick(Sender);
end;

procedure TCustomBaseQuery.OnIniButton(Sender: TObject);
begin
  FCloseButtonRec := ButtonList.Add(Action_Close,True);//�ر�
  FPrintButtonRec := ButtonList.Add(Action_Print,True);//��ӡ
  if FormStyle in [fsNormal,fsStayOnTop] then ButtonList.Button[FCloseButtonRec].Cancel := True;
end;

procedure TCustomBaseQuery.RefreshData;
begin
  inherited;
  Condition.RefreshParamList;
  LoadData;
end;

procedure TCustomBaseQuery.SetGrid;
begin
  Condition.RefreshCondition;
  ButtonList.RefreshButton;
  {�������}
  FMainGrid := CreatecxGrid('MaincxGrid',Panel_Client);
  {�������ݲ�}
  AddGridView;
end;

procedure TCustomBaseQuery.SetRowData(AFieldName: string; ARow: Integer; const Value: Variant);
begin
  if not Assigned(MainGrid) then Exit;
  if not Assigned(MainGrid.ActiveView) then Exit;
  if (MainGrid.ActiveView.DataController.RowCount=0) or (ARow>=MainGrid.ActiveView.DataController.RowCount) then Exit;
  var _column := ItemColumn[AFieldName];
  if not Assigned(_column) then Exit;
  MainGrid.ActiveView.DataController.Values[ARow,_column.Index] := Value;
end;

destructor TConditionManager.Destroy;
begin
  if Assigned(FFindButton) then FreeAndNil(FFindButton);
  inherited;
end;

function TConditionManager.GetFindButton: TButton;
begin
  if not Assigned(FFindButton) then FFindButton := TButton.Create(Parent);
  Result := FFindButton;
end;

procedure TConditionManager.RefreshCondition;
begin
  Self.Width := Self.Width-400;
  inherited;
  //����ˢ�²�ѯ��ť
  FindButton.Parent  := self.Parent;
  FindButton.Caption := '��ѯ';
  FindButton.Top     := Control_Border_Width;
  FindButton.Left    := Parent.Width - FindButton.Width - 20;
  FindButton.Anchors := [TAnchorKind.akRight,TAnchorKind.akTop];
  FindButton.OnClick := TCustomBaseQuery(OWnerObject).DoRefreshDataByMessage;
end;

end.
