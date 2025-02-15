unit UBaseInfoEdit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UBaseNormalForm, cxStyles, cxClasses,
  System.ImageList, Vcl.ImgList, System.Actions, Vcl.ActnList, Vcl.ExtCtrls,
  UBaseControlManagerLayout, Vcl.StdCtrls, System.Generics.Collections,
  Vcl.ControlList;

type
  TBaseInfoEdit = class(TBaseNormalForm)
    Action_Save: TAction;
    ScrollBox_Client: TScrollBox;
    Panel_Location: TPanel;
    procedure Action_SaveExecute(Sender: TObject);
  private
    FButtonList: TButtonManager;
    FConditionList: TControlManagerLayout;
    FList:TList<TPair<string,TLabel>>;
    procedure OnLocationClick(Sender: TObject);
    function GetPanel_Location_Visible: Boolean;
    procedure SetPanel_Location_Visible(const Value: Boolean);
  protected
    FCloseButtonRec:Integer;
    FPrintButtonRec:Integer;
    FSaveButtonRec:Integer;
    procedure CreateAfter;override;
    procedure OnIniButton(Sender: TObject); virtual;
    /// <summary>
    /// 初始化窗体
    /// </summary>
    procedure OnIniCondition(Sender: TObject); virtual;
    procedure BeforeFormShow; override;
    ///通过空间名称定位控件的位置
    procedure LocationCondition(AName:string);virtual;
    procedure DoPrintHeader; override;
  public
    destructor Destroy; override;
    property Condition:TControlManagerLayout read FConditionList;
    property ButtonList:TButtonManager read FButtonList;
    property Panel_Location_Visible:Boolean read GetPanel_Location_Visible write SetPanel_Location_Visible;
  end;

implementation

uses
  UComvar, System.JSON, System.IOUtils;

{$R *.dfm}

procedure TBaseInfoEdit.Action_SaveExecute(Sender: TObject);
begin
  inherited;
  if not Condition.RefreshParamList then Exit;
end;

{ TForm1 }

procedure TBaseInfoEdit.BeforeFormShow;
begin
  Condition.RefreshCondition;
  ButtonList.RefreshButton;
  inherited;
end;

procedure TBaseInfoEdit.CreateAfter;
begin
  inherited;
  if not Assigned(FConditionList) then FConditionList := TControlManagerLayout.Create(Self,ScrollBox_Client);
  if not Assigned(FButtonList) then FButtonList := TButtonManager.Create;
  ButtonList.Parent := Panel_Button;
  ButtonList.OWnerObject := Self;
  OnIniCondition(nil);
  OnIniButton(nil);
end;

destructor TBaseInfoEdit.Destroy;
begin
  if Assigned(FConditionList) then FreeAndNil(FConditionList);
  if Assigned(FButtonList) then FreeAndNil(FButtonList);
  if Assigned(FList) then FreeAndNil(FList);
  inherited;
end;

procedure TBaseInfoEdit.DoPrintHeader;
begin
  inherited;
  if Assigned(FConditionList) then
  begin
    for var i := 0 to Condition.Count-1 do
    begin
      PrintItems.Add(Condition.ConditionIndex[i].Caption,Condition.ConditionIndex[i].ValueText);
    end;
  end;
end;

function TBaseInfoEdit.GetPanel_Location_Visible: Boolean;
begin
  Result := Panel_Location.Visible;
end;

procedure TBaseInfoEdit.LocationCondition(AName: string);
begin
  var AControl := Condition.ControlItem[AName];
  if not Assigned(AControl) then Exit;
  ScrollBox_Client.VertScrollBar.Position := Condition.ConditionItem[AName].GroupParent.Top;
  AControl.SetFocus;
end;

procedure TBaseInfoEdit.OnIniButton(Sender: TObject);
begin
  FCloseButtonRec := ButtonList.Add(Action_Close,True);//关闭
  FSaveButtonRec  := ButtonList.Add(Action_Save,True);//关闭
  FPrintButtonRec := ButtonList.Add(Action_Print,True);//打印
  if FormStyle in [fsNormal,fsStayOnTop] then ButtonList.Button[FCloseButtonRec].Cancel := True;
end;

procedure TBaseInfoEdit.OnIniCondition(Sender: TObject);
  function ExistsGroupLabel(ACaption:string):Boolean;
  begin
    Result := False;
    for var i in FList do
    begin
      Result := SameText(i.Key,ACaption);
      if Result then Break;
    end;
  end;
begin
  if Assigned(LayoutJson) then Caption := LayoutJson.GetValue<string>('Caption',Caption);
  Condition.AddFromFile(LayoutFilePath);
  if not Panel_Location_Visible then Exit;
  if not Assigned(FList) then FList := TList<TPair<string,TLabel>>.Create;

  var ALeft:Integer := 10;
  for var item in Condition do
  begin
    if item.Value.GroupLabelCaption=EmptyStr then Continue;
    if ExistsGroupLabel(item.Value.GroupLabelCaption) then Continue;
    var _Pair:TPair<string,TLabel>;
    _Pair.Key   := item.Value.GroupLabelCaption;
    _Pair.Value := TLabel.Create(Panel_Location);
    with _Pair.Value do
    begin
      Caption := item.Value.GroupLabelCaption;
      Left    := ALeft;
      ALeft   := ALeft + Width + 10;
      Parent  := Panel_Location;
      Font.Style := Font.Style + [fsunderline];
      Cursor  := crHandPoint;
      Hint    := item.Value.Name;
      ShowHint:= False;
      OnClick := OnLocationClick;
    end;
    FList.Add(_Pair);
  end;
end;

procedure TBaseInfoEdit.OnLocationClick(Sender: TObject);
begin
  LocationCondition(TLabel(Sender).Hint);
end;

procedure TBaseInfoEdit.SetPanel_Location_Visible(const Value: Boolean);
begin
  Panel_Location.Visible := Value;
end;

initialization
  Goo.Reg.RegisterClass(TBaseInfoEdit);

end.
