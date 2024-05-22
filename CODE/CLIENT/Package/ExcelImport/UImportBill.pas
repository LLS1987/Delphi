unit UImportBill;

interface

uses
  UBaseQuery, System.SysUtils, UExcelObject, UParamList;

type
  TBaseImportBill = class(TBaseQuery)
  private
    FBillType: Integer;
    { Private declarations }
    procedure OnExcelPre(Sender:TObject);
    procedure OnImportExcel(Sender:TObject);
    procedure OnCreateBill(Sender:TObject);
    function CheckCell_Qty(AData:OleVariant;var AError:string): Boolean;
    function CheckCell_Date(AData:OleVariant;var AError:string): Boolean;
  protected
    procedure RefreshParamList;override;
    procedure OnIniButton(Sender: TObject); override;
    procedure BeforePreViewExcel(AExcel:TExcelObject);virtual;
    procedure GetExcelDataRow(AParam:TParamList;AExcel:TExcelObject;ARow:Integer); virtual;
    function ImportExcelToBill(AUid:string):Boolean;virtual;
  public
    ///����ĵ�������
    property BillType:Integer read FBillType write FBillType;
  end;
  //�ɹ���
  TImportBuyBill = class(TBaseImportBill)
  protected
    procedure iniForm;override;
    procedure GetExcelDataRow(AParam:TParamList;AExcel:TExcelObject;ARow:Integer); override;
  end;
  //���۵�
  TImportSaleBill = class(TBaseImportBill)
  protected
    procedure iniForm;override;
    procedure GetExcelDataRow(AParam:TParamList;AExcel:TExcelObject;ARow:Integer); override;
  end;

implementation

uses
  UComvar, UComDBStorable;

{ TBaseImportBill }

procedure TBaseImportBill.OnExcelPre(Sender: TObject);
var Excel:TExcelObject;
begin
  Excel := TExcelObject.Create('');
  try
    Excel.OnImportExcelEvent := OnImportExcel;
    Excel.ExcelCellCheckList.UseCheckBUSerCode := True;
    Excel.ExcelCellCheckList.UseCheckKUSerCode := True;
    Excel.ExcelCellCheckList.UseCheckPUSerCode := True;
    Excel.ExcelCellCheckList.Add('����',CheckCell_Qty);
    Excel.ExcelCellCheckList.Add('���',CheckCell_Qty);
    Excel.ExcelCellCheckList.Add('��������',CheckCell_Date);
    BeforePreViewExcel(Excel);
    Excel.PreViewExcel;
  finally
    Excel.Free;
  end;

end;

procedure TBaseImportBill.BeforePreViewExcel(AExcel: TExcelObject);
begin

end;

function TBaseImportBill.CheckCell_Date(AData: OleVariant; var AError: string): Boolean;
begin
  Result := AData<>EmptyStr;
  if not Result then
  begin
    AError := '����Ϊ��';
    Exit;
  end;
  var _date := StrToDateDef(AData,StrToDate('2000-01-01'));
  if _date <= StrToDate('2000-01-01') then
  begin
    Result := False;
    AError := '��ʽ����ȷ';
    Exit;
  end;
end;

function TBaseImportBill.CheckCell_Qty(AData: OleVariant; var AError: string): Boolean;
begin
  Result := StrToFloatDef(AData,0)>0;
  if not Result then AError := '������� 0';
end;

procedure TBaseImportBill.GetExcelDataRow(AParam:TParamList; AExcel:TExcelObject;ARow:Integer);
begin
  AParam.Add('@Comment',AExcel.AsString('��ע',ARow));
end;

function TBaseImportBill.ImportExcelToBill(AUid: string): Boolean;
begin
  Result := Goo.DB.ExecProc('GP_Excel_CreateBill',ParamList) >= 0;
end;

procedure TBaseImportBill.OnCreateBill(Sender:TObject);
begin
  Goo.Msg.CheckAndAbort(ParamList.AsString('@UniqueBillid')<>EmptyStr,'��ѡ��EXCEL');
  if ImportExcelToBill(ParamList.AsString('@UniqueBillid')) then
  begin
    Goo.Msg.ShowMsg('�������ɳɹ���');
    RefreshData;
  end;
end;

procedure TBaseImportBill.OnImportExcel(Sender: TObject);
var AParam:TParamList;
begin
  var Excel:TExcelObject := Sender as TExcelObject;
  //var dc := MainView.DataController;
  AParam := TParamList.Create;
  try
    var _guid :string := Goo.GetGUIDString;
    for var i := 1 to Excel.RowCount - 1 do
    begin
      AParam.Clear;
      AParam.Add('@SourcePath',Excel.Filename);
      AParam.Add('@BillType',BillType);
      AParam.Add('@BillDate',DateTimeToStr(Excel.AsDateTime('��������',i)));
      AParam.Add('@BRec',Goo.Local.GetUserCode<TStorable_BType>(Excel.AsString('��λ���',i)).Rec);
      AParam.Add('@KRec',Goo.Local.GetUserCode<TStorable_KType>(Excel.AsString('�ֿ���',i)).Rec);
		  AParam.Add('@ERec',Goo.Login.LoginUserRec);
      AParam.Add('@UniqueBillid',_guid);
      GetExcelDataRow(AParam,Excel,i);
      var _BillID := Goo.DB.ExecProc('GP_Excel_InsertIndex',AParam);
      if _BillID>0 then
      begin
        AParam.Add('@BillID',_BillID);
        AParam.Add('@Ord',i);
        AParam.Add('@PRec',Goo.Local.GetUserCode<TStorable_PType>(Excel.AsString('��Ʒ���',i)).Rec);
        AParam.Add('@Qty',Excel.AsFloat('����',i));
        AParam.Add('@Price',Excel.AsFloat('����',i));
        AParam.Add('@Total',Excel.AsFloat('���',i));
        AParam.Add('@Jobnumber',Excel.AsString('����',i));
        AParam.Add('@JobCode',Excel.AsString('������',i));
        if Excel.FieldExists('��������') and (Excel.AsDateTime('��������',i)>0) then AParam.Add('@OutFactoryDate',Excel.AsDateTime('��������',i));
        if Excel.FieldExists('��Ч����') and (Excel.AsDateTime('��Ч����',i)>0) then AParam.Add('@ValidityPeriod',Excel.AsDateTime('��Ч����',i));
        AParam.Add('@GermJobNumber',Excel.AsString('�������',i));
        AParam.Add('@CheckReportNo',Excel.AsString('���鱨���',i));
        Goo.DB.ExecProc('GP_Excel_InsertBill',AParam);
      end;
    end;
    ParamList.Add('@UniqueBillid',_guid);
  finally
    AParam.Free;
  end;
  RefreshData;
end;

procedure TBaseImportBill.OnIniButton(Sender: TObject);
begin
  inherited;
  ButtonList.Add('��Excel',OnExcelPre);
  ButtonList.Add('���ɵ���',OnCreateBill);
end;

procedure TBaseImportBill.RefreshParamList;
begin
  inherited;
  ParamList.Add('@BillType',BillType);
end;

{ TImportBuyBill }

procedure TImportBuyBill.GetExcelDataRow(AParam:TParamList;AExcel:TExcelObject; ARow:Integer);
begin
  inherited;
  if AExcel.FieldExists('��������') then AParam.Add('@MoneyDate',DateTimeToStr(AExcel.AsDateTime('��������',ARow)));
  AParam.Add('@Eligible',AExcel.AsString('����״��',ARow));
  AParam.Add('@Checkresult',AExcel.AsString('���ս���',ARow));
end;

procedure TImportBuyBill.iniForm;
begin
  inherited;
  BillType := 34;
end;

{ TImportSaleBill }

procedure TImportSaleBill.GetExcelDataRow(AParam:TParamList; AExcel:TExcelObject;ARow:Integer);
begin
  inherited;
  if AExcel.FieldExists('�տ�����') then AParam.Add('@MoneyDate',DateTimeToStr(AExcel.AsDateTime('�տ�����',ARow)));
end;

procedure TImportSaleBill.iniForm;
begin
  inherited;
  BillType := 11;
end;

initialization
  Goo.Reg.RegisterClass(TImportBuyBill);
  Goo.Reg.RegisterClass(TImportSaleBill);

end.
