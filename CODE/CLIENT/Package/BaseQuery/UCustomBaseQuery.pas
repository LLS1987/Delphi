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
  UParamList, Vcl.ComCtrls, UBaseControlManagerLayout;

type
  TConditionManager = class;

  TCustomBaseQuery = class(TBaseMdiForm)
  private
    FCondition: TConditionManager;
    FButton: TButtonManager;
    { Private declarations }
  protected
    procedure DoShow; override;
    procedure SetGrid;virtual;   //�������ݶ�ȡ������
    procedure CustomGrid(FieldList :TDataSet);virtual;
    procedure iniForm;virtual;
    procedure LoadData;virtual;    //����������װ������
    procedure OnIniButton(Sender: TObject); virtual;
  public
    { Public declarations }
    destructor Destroy; override;
    procedure RefreshData;override;
    property Condition:TConditionManager read FCondition;
    property ButtonList:TButtonManager read FButton;
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
var
  CustomBaseQuery: TCustomBaseQuery;
const Control_Border_Width = 10;

implementation

uses
  UComvar;

{$R *.dfm}

{ TCustomBaseQuery }

procedure TCustomBaseQuery.CustomGrid(FieldList: TDataSet);
begin

end;

destructor TCustomBaseQuery.Destroy;
begin
  if Assigned(FCondition) then FreeAndNil(FCondition);
  if Assigned(FButton) then FreeAndNil(FButton);
  inherited;
end;

procedure TCustomBaseQuery.DoShow;
begin
  iniForm;
  SetGrid;
  inherited;
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

  Condition.RefreshCondition;
  ButtonList.RefreshButton;
end;

procedure TCustomBaseQuery.LoadData;
begin

end;

procedure TCustomBaseQuery.OnIniButton(Sender: TObject);
begin
  ButtonList.Add(Action_Close,True);//�ر�
  ButtonList.Add(Action_Print,True);//��ӡ
end;

procedure TCustomBaseQuery.RefreshData;
begin
  inherited;
  Condition.RefreshParamList;
  LoadData;
end;

procedure TCustomBaseQuery.SetGrid;
begin

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
