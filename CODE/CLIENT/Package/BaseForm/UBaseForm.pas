unit UBaseForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.ImageList, Vcl.ImgList,
  System.Actions, Vcl.ActnList, UGlobalInterface, UParamList, Datasnap.DBClient,
  Vcl.ExtCtrls, UComConst, UPrintItem, cxClasses, cxStyles, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxCustomData, cxFilter,
  cxData, cxDataStorage, cxEdit, cxNavigator, dxDateRanges,
  dxScrollbarAnnotations, Data.DB, cxDBData, cxGridLevel, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid;

type
  TBaseForm = class(TForm,IForm)
    ActionList: TActionList;
    ImageList: TImageList;
    Action_Close: TAction;
    Action_Print: TAction;
    Action_Help: TAction;
    cxStyleRepository: TcxStyleRepository;
    cxStyle_GridView_Header: TcxStyle;
    cxStyle_GridView_Content: TcxStyle;
    cxStyle_GridView_ContentOdd: TcxStyle;
    cxStyle_GridView_ContentEven: TcxStyle;
    cxStyle_GridView_Selection: TcxStyle;
    cxStyle_GridView_Footer: TcxStyle;
    procedure FormCreate(Sender: TObject);
    procedure Action_CloseExecute(Sender: TObject);
    procedure Action_HelpExecute(Sender: TObject);
    procedure Action_PrintExecute(Sender: TObject);
  private
    FParamList: TParamList;
    FGridDataSet: TClientDataSet;
    FPrintTimes: Integer;
    FRefreshDataMessageID: Integer;
    FPrintItems: TPrintItems;
    FPrintName: string;
    FPrintDetailData: OleVariant;
    { Private declarations }
    function GetObject: TObject;virtual;
    function GetForm: TForm;
    function GetActionList:TActionList;
    function GetParamList: TParamList;
    procedure SetParamList(AParamList:TParamList);
    procedure ShowFindDialog(var Message: TMessage); message REFRESH_FIND_MESSAGE;
    procedure DealRefreshRefreshDataMessage(var Msg: TMessage); message WM_RefreshData;
  protected
    procedure DoShow; override;
    procedure BeforeFormShow; virtual;
    property GridDataSet: TClientDataSet read FGridDataSet;
    procedure InitParamList; virtual;//��Ʒ�����ڴ��ڴ���֮ǰ�ȶԲ������д���
    function Find(const Msg:string;Reverse,Whole,Match:Boolean):Boolean;virtual;
    procedure DoCloseBtnEvent; virtual;
    procedure DoHelpBtnEvent; virtual;
    procedure DoPrintBtnEvent; virtual;
    procedure DoPrintHeader; virtual;
    //ˢ���¼�
    procedure DoRefreshDataByMessage; virtual;
    //���
    procedure DoCustomDrawIndicatorCell(Sender: TcxGridTableView;ACanvas: TcxCanvas; AViewInfo: TcxCustomGridIndicatorItemViewInfo; var ADone: Boolean);virtual;
    procedure DoCustomDrawCell(Sender: TcxCustomGridTableView;ACanvas: TcxCanvas; AViewInfo: TcxGridTableDataCellViewInfo; var ADone:Boolean);virtual;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent; AParam: TParamList);overload;
    destructor Destroy; override;
    procedure IniComponent(AForm:TForm); overload;
    procedure IniComponent(AComponent: TComponent); overload;
    procedure IniComponent(APanel:TPanel); overload;
    ///��ʼ��cxGrid
    procedure IniComponent(AGrid:TcxGrid); overload;
    property ParamList:TParamList read GetParamList write FParamList;
    //���찴ť�Ĵ�ӡ����
    property PrintTimes:Integer read FPrintTimes;
    property PrintItems:TPrintItems read FPrintItems;
    property PrintName: string read FPrintName write FPrintName;
    property PrintDetailData: OleVariant read FPrintDetailData write FPrintDetailData;
    //ˢ������ID
    property RefreshDataMessageID: Integer read FRefreshDataMessageID write FRefreshDataMessageID;
    //����ҳ���ˢ����Ϣ
    procedure SendRefreshData(ARefreshID:integer);overload;
    procedure SendRefreshData(ARefreshClass:string);overload;
  end;

var
  BaseForm: TBaseForm;
const Default_Color = clWhite;

implementation

uses
  UComvar, System.TypInfo;

{$R *.dfm}

procedure TBaseForm.BeforeFormShow;
begin
  IniComponent(Self);
end;

constructor TBaseForm.Create(AOwner: TComponent; AParam: TParamList);
begin
  FParamList := TParamList.Create;
  InitParamList;
  if Assigned(AParam) then FParamList.Assign(AParam);
  inherited Create(AOwner); //��������ʵ�� MDIһ��������ʾ��
end;

procedure TBaseForm.DealRefreshRefreshDataMessage(var Msg: TMessage);
var AClassName:string;
begin
  if Msg.WParam>0 then AClassName := string(Pointer(Msg.WParam)^);
  if ((FRefreshDataMessageID>0) and (msg.LParam=FRefreshDataMessageID)) or SameText(AClassName,ClassName) then DoRefreshDataByMessage;
end;

destructor TBaseForm.Destroy;
begin
  if Assigned(FParamList) then FParamList.Free;
  if Assigned(FGridDataSet) then FreeAndNil(FGridDataSet);
  if Assigned(FPrintItems) then FreeAndNil(FPrintItems);
  
  inherited;
end;

procedure TBaseForm.Action_CloseExecute(Sender: TObject);
begin
  DoCloseBtnEvent;
end;

procedure TBaseForm.Action_HelpExecute(Sender: TObject);
begin
  DoHelpBtnEvent;
end;

procedure TBaseForm.Action_PrintExecute(Sender: TObject);
begin
  DoPrintBtnEvent;
end;

procedure TBaseForm.DoCloseBtnEvent;
begin
  if Self.BorderStyle = bsDialog then ModalResult := mrCancel else Close;
end;

procedure TBaseForm.DoCustomDrawCell(Sender: TcxCustomGridTableView; ACanvas: TcxCanvas; AViewInfo: TcxGridTableDataCellViewInfo; var ADone: Boolean);
begin
  if AViewInfo.Focused then
  begin
    ACanvas.Canvas.Brush.Color := Goo.Theme.Grid.GridRowFocusColor;
    //ACanvas.Font.Color := clred; //��ɫ����
    //ACanvas.Font.Style := [fsUnderline];//���»���
  end;
end;

procedure TBaseForm.DoCustomDrawIndicatorCell(Sender: TcxGridTableView; ACanvas: TcxCanvas; AViewInfo: TcxCustomGridIndicatorItemViewInfo; var ADone: Boolean);
var
AIndicatorViewInfo: TcxGridIndicatorRowItemViewInfo;
  ATextRect: TRect;
  aCV: TcxCanvas;
begin
  aCV := ACanvas;
  ATextRect := AViewInfo.ContentBounds;
  if (AViewInfo is TcxGridIndicatorHeaderItemViewInfo) then begin
    ATextRect := AViewInfo.Bounds;
    InflateRect(ATextRect, -1, -1);
    Sender.LookAndFeelPainter.DrawHeader(ACanvas, AViewInfo.Bounds,
      ATextRect, [], cxBordersAll, cxbsNormal, taCenter, TcxAlignmentVert.vaCenter,
      False, False, '���', acv.Font, acv.font.Color, acv.Brush.color);
    ADone := True;
  end else if (AViewInfo is TcxGridIndicatorFooterItemViewInfo) then
  begin
    ATextRect := AViewInfo.Bounds;
    InflateRect(ATextRect, -1, -1);
    Sender.LookAndFeelPainter.DrawHeader(ACanvas, AViewInfo.Bounds,
      ATextRect, [], cxBordersAll, cxbsNormal, taCenter, TcxAlignmentVert.vaCenter,
      False, False, '�ϼ�', acv.Font, acv.font.Color, acv.Brush.color);
    ADone := True;
  end else if (AViewInfo is TcxGridIndicatorRowItemViewInfo) then
  begin
    AIndicatorViewInfo := AViewInfo as TcxGridIndicatorRowItemViewInfo;
    InflateRect(ATextRect, -2, -1);
    if AIndicatorViewInfo.GridRecord.Selected then //���if����Ϊ�����кŴ��Ѱ�ѡ�е��кŸ�������ֿ����ɲ���
    begin
      aCV.Font.Style := Canvas.Font.Style + [fsBold];
      //aCV.Font.Name := '����';
      //aCV.Font.Size := 12;
      aCV.Font.Color := clRed;
    end
    else
    begin
      aCV.Font.Style := Canvas.Font.Style - [fsBold];
      acv.Font.Color := Canvas.Font.Color;
    end;
    Sender.LookAndFeelPainter.DrawHeader(ACanvas, AViewInfo.ContentBounds, ATextRect, [], cxBordersAll, cxbsNormal, taCenter, vaCenter,
        False, False, IntToStr(AIndicatorViewInfo.GridRecord.Index + 1),acv.Font, acv.font.Color, acv.Brush.color);
    ADone := True;
    //����ǰ�е�������
    ATextRect.Left := ATextRect.Width - 3;
    Sender.LookAndFeelPainter.DrawIndicatorImage(ACanvas,ATextRect, AIndicatorViewInfo.IndicatorKind);
  end;
end;

procedure TBaseForm.DoHelpBtnEvent;
begin

end;

procedure TBaseForm.DoPrintBtnEvent;
begin
  try
    //DoReparePrintData;
    //if PrintName='' then PrintName:=Title;
    if PrintName='' then PrintName:=Caption;
    if PrintDetailData=Null then PrintDetailData := GridDataSet.Data;
    DoPrintHeader;
    FPrintTimes := Goo.Print.RunPrintManage(PrintName,PrintItems,PrintDetailData);
  except
    on e: EAbort do
    else raise;
  end;
end;

procedure TBaseForm.DoPrintHeader;
begin

end;

procedure TBaseForm.DoRefreshDataByMessage;
begin

end;

procedure TBaseForm.DoShow;
begin
  inherited;
  BeforeFormShow;
end;

function TBaseForm.Find(const Msg: string; Reverse, Whole, Match: Boolean): Boolean;
begin
  Result := False;
end;

procedure TBaseForm.ShowFindDialog(var Message: TMessage);
var strMSG: string;
  AFlag:Integer;
begin
  strMSG := string(Pointer(Message.WParam)^);
  AFlag  := Message.LParam;
  Find(strMSG,GetBitValue(AFlag,1),GetBitValue(AFlag,2),GetBitValue(AFlag,3));
end;

procedure TBaseForm.FormCreate(Sender: TObject);
begin
  FGridDataSet := TClientDataSet.Create(Self);
  FPrintTimes := 0;
  FRefreshDataMessageID := 0;
  FPrintItems := TPrintItems.Create;
  PrintDetailData := Null;
end;

function TBaseForm.GetActionList: TActionList;
begin
  Result := ActionList;
end;

function TBaseForm.GetForm: TForm;
begin
  Result := Self;
end;

function TBaseForm.GetObject: TObject;
begin
  Result := Self;
end;

function TBaseForm.GetParamList: TParamList;
begin
  if not Assigned(FParamList) then
  begin
    FParamList := TParamList.Create;
    InitParamList;
  end;
  Result := FParamList;
end;

procedure TBaseForm.IniComponent(AForm: TForm);
var APropInfo:PPropInfo;
begin
  AForm.Color := Default_Color;
  for var i := 0 to AForm.ComponentCount - 1 do
  begin
    if AForm.Components[i] is TWinControl then
    begin
      IniComponent(TWinControl(AForm.Components[i]));
      //������뷨
      APropInfo:=GetPropInfo(AForm.Components[i], 'IMENAME');
      if Assigned(APropInfo) then SetStrProp(AForm.Components[i],APropInfo,'');
    end;
  end;
end;

procedure TBaseForm.IniComponent(APanel: TPanel);
begin
  APanel.Color := Default_Color;
end;

procedure TBaseForm.IniComponent(AComponent: TComponent);
begin
  if AComponent is TPanel then
    IniComponent(TPanel(AComponent))
  else if AComponent is TcxGrid then IniComponent(TcxGrid(AComponent))
end;

procedure TBaseForm.InitParamList;
begin

end;

procedure TBaseForm.SendRefreshData(ARefreshID: integer);
begin
  FOR var i:=0 TO Screen.FormCount-1 DO
    SendMessage(Screen.Forms[I].Handle,WM_RefreshData,0,ARefreshID);
end;

procedure TBaseForm.SendRefreshData(ARefreshClass: string);
begin
  FOR var i:=0 TO Screen.FormCount-1 DO
    SendMessage(Screen.Forms[I].Handle,WM_RefreshData,Integer(@ARefreshClass),0);
end;

procedure TBaseForm.SetParamList(AParamList: TParamList);
begin
  Self.ParamList.Assign(AParamList);
end;

procedure TBaseForm.IniComponent(AGrid: TcxGrid);
begin
  if AGrid.Levels.Count>1 then AGrid.RootLevelOptions.DetailTabsPosition := dtpTop;
  for var i := 0 to AGrid.Levels.Count-1 do
  begin
    var GridView := AGrid.Levels[i].GridView;
    if GridView is TcxGridTableView then     //TcxGridTableView
    begin
      TcxGridTableView(GridView).Styles.Header      := cxStyle_GridView_Header;         //��ͷ��ʽ
      TcxGridTableView(GridView).Styles.Content     := cxStyle_GridView_Content;        //���Ĭ��
      TcxGridTableView(GridView).Styles.ContentEven := cxStyle_GridView_ContentEven;    //������
      TcxGridTableView(GridView).Styles.ContentOdd  := cxStyle_GridView_ContentOdd;     //ż����
      TcxGridTableView(GridView).Styles.Selection   := cxStyle_GridView_Selection;      //ѡ������ʽ
      TcxGridTableView(GridView).Styles.Footer      := cxStyle_GridView_Footer;         //��β��ʽ
      TcxGridTableView(GridView).OptionsData.Editing   := False;
      TcxGridTableView(GridView).OptionsView.DataRowHeight  := Goo.Theme.Grid.GridItemHeight; //����߶�
      //��ͷ
      TcxGridTableView(GridView).OptionsView.HeaderHeight   := Goo.Theme.Grid.GridHeadHeight; //�и�
      TcxGridTableView(GridView).OptionsView.Indicator := True;                            //��ʾ�к�
      TcxGridTableView(GridView).OptionsView.IndicatorWidth := 60;                         //�кſ��
      TcxGridTableView(GridView).Styles.Header.Color      := Goo.Theme.Grid.GridHeadBackColor;
      //��ɫ
      TcxGridTableView(GridView).Styles.ContentEven.Color := Goo.Theme.Grid.GridOneItemColor;             //��������ɫ
      TcxGridTableView(GridView).Styles.ContentOdd.Color  := Goo.Theme.Grid.GridTwoItemColor;             //ż������ɫ
      //SelectRow
      TcxGridTableView(GridView).Styles.Selection.Color   := Goo.Theme.Grid.GridSelectItemColor;          //ѡ������ɫ
      TcxGridTableView(GridView).Styles.Selection.TextColor := cxStyle_GridView_Selection.TextColor;        //ѡ����������ɫ
      TcxGridTableView(GridView).OnCustomDrawIndicatorCell  := DoCustomDrawIndicatorCell;
      TcxGridTableView(GridView).OnCustomDrawCell           := DoCustomDrawCell;
      //��ȡ������Ϣ
      var layoutpath := Goo.SystemPath + Format('\layout\%s.%s.ini',[Self.Name,GridView.Name]);
      if FileExists(layoutpath) then GridView.RestoreFromIniFile(layoutpath);
    end;
  end;
end;

end.
