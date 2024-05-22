unit UImportBuyBillAndSaleBill;

interface

uses
  UBaseQuery, System.SysUtils;

type
  TImportBuyBillAndSaleBill = class(TBaseQuery)
  private
    { Private declarations }
    procedure OnExcelPre(Sender:TObject);
    procedure OnImportExcel(Sender:TObject);
    procedure OnImportDB(Sender:TObject);
    procedure OnExpandAllNodes(Sender:TObject);
    function CheckCell_BFullName(AData:OleVariant;var AError:string): Boolean;
    function CheckCell_BSaleName(AData:OleVariant;var AError:string): Boolean;
    function CheckCell_PFullName(AData:OleVariant;var AError:string): Boolean;
    function CheckCell_Qty(AData:OleVariant;var AError:string): Boolean;
    function CheckCell_Date(AData:OleVariant;var AError:string): Boolean;
  protected
    procedure OnIniButton(Sender: TObject); override;
    procedure LoadData;override;
  public
    { Public declarations }
  end;

implementation

uses
  UComvar, UExcelObject, UComConst, UComDBStorable, UParamList,
  System.DateUtils, System.Variants;

{ TImportBuyBillAndSaleBill }

function TImportBuyBillAndSaleBill.CheckCell_BFullName(AData:OleVariant;var AError:string): Boolean;
begin
  Result := AData<>EmptyStr;
  if not Result then
  begin
    AError := '����������λ����Ϊ��';
    Exit;
  end;
  var n :Integer := 0;
  for var _item in Goo.Local.BasicData[btBtype] do
  begin
    if string.Compare(_item.Value.FullName,AData,True)=0 then Inc(n);
  end;
  Result := n=1;
  if n=0 then AError := '�޴˵�λ';
  if n>1 then AError := '������λ���ڶ����ͬ����������';
end;

function TImportBuyBillAndSaleBill.CheckCell_BSaleName(AData: OleVariant; var AError: string): Boolean;
begin
  Result := AData<>EmptyStr;
  if not Result then
  begin
    AError := '�������Ʋ���Ϊ��';
    Exit;
  end;
  var n :Integer := 0;
  for var _item in Goo.Local.BasicData[btBtype] do
  begin
    if string.Compare(_item.Value.FullName,AData,True)=0 then Inc(n);
  end;
  Result := n=1;
  if n=0 then AError := '�޴˵�λ';
  if n>1 then AError := '������λ���ڶ����ͬ�Ĺ�������';
end;

function TImportBuyBillAndSaleBill.CheckCell_PFullName(AData: OleVariant; var AError: string): Boolean;
begin
  Result := AData<>EmptyStr;
  if not Result then
  begin
    AError := '����ͺŲ���Ϊ��';
    Exit;
  end;
  var n :Integer := 0;
  for var _item in Goo.Local.BasicData[btPtype] do
  begin
    if string.Compare(TStorable_PType(_item.Value).Standard,AData,True)=0 then Inc(n);
  end;
  Result := n=1;
  if n=0 then AError := '�޴���Ʒ';
  if n>1 then AError := '���ڶ����ͬ������';
end;

function TImportBuyBillAndSaleBill.CheckCell_Qty(AData: OleVariant; var AError: string): Boolean;
begin
  Result := StrToFloatDef(AData,0)>0;
  if not Result then AError := '������� 0';  
end;

function TImportBuyBillAndSaleBill.CheckCell_Date(AData:OleVariant;var AError:string): Boolean;
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

procedure TImportBuyBillAndSaleBill.LoadData;
begin
  inherited;
end;

procedure TImportBuyBillAndSaleBill.OnExcelPre(Sender: TObject);
var Excel:TExcelObject;
begin
  Excel := TExcelObject.Create('');
  try
    Excel.OnImportExcelEvent := OnImportExcel;
    Excel.ExcelCellCheckList.Add('����',CheckCell_BFullName);
    Excel.ExcelCellCheckList.Add('��������',CheckCell_BSaleName);
    Excel.ExcelCellCheckList.Add('����ͺ�',CheckCell_PFullName);
    Excel.ExcelCellCheckList.Add('����',CheckCell_Qty);
    Excel.ExcelCellCheckList.Add('�ɹ����',CheckCell_Qty);
    Excel.ExcelCellCheckList.Add('���۽��',CheckCell_Qty);
    Excel.ExcelCellCheckList.Add('ǧ���ټ�����ϵͳ����',CheckCell_Date);
    Excel.ExcelCellCheckList.Add('�տ�����',CheckCell_Date);
    Excel.ExcelCellCheckList.Add('��������',CheckCell_Date);
    Excel.PreViewExcel;
  finally
    Excel.Free;
  end;
end;

procedure TImportBuyBillAndSaleBill.OnExpandAllNodes(Sender: TObject);
begin
//  for var I := 0 to MainView.DataController.RecordCount - 1 do
//  begin
//    if TcxGridTableView(MainView).DataController.Records[I] is TcxGridMasterDataRow then
//    begin
//      var AMasterRow := TcxGridMasterDataRow(MainView.DataController.Records[I]);
//      if AMasterRow.Level = ALevel then
//        AMasterRow.Expand(True);
//    end;
//  end;
end;

procedure TImportBuyBillAndSaleBill.OnImportDB(Sender: TObject);
begin
  Goo.Msg.CheckAndAbort(ParamList.AsString('@UniqueBillid')<>EmptyStr,'��ѡ��EXCEL');
  var _succ := Goo.DB.ExecProc('GP_Excel_ImportBill',ParamList);
  var _msg : string := EmptyStr;
  case _succ of
    -1 : _msg := 'û���ҵ��ܵ���ĵ���';
    -2 : _msg := '�����ظ�����EXCEL';
    -3 : _msg := '�ļ��д���Ч�ڴ������ʱ�������';
    -19 .. -10 : _msg := '�ɹ���ⵥ���벻�ɹ�';
    -29 .. -20 : _msg := '���۵������벻�ɹ�';
    else _msg := '����ǧ�������쳣��';
  end;
  Goo.Msg.CheckAndAbort(_succ>0,_msg);
  Goo.Msg.ShowMsg('����ɹ�');
  RefreshData;
end;

procedure TImportBuyBillAndSaleBill.OnImportExcel(Sender: TObject);
var AParam:TParamList;
begin
  var Excel:TExcelObject := Sender as TExcelObject;
  //var dc := MainView.DataController;
  var _succ :Boolean := True;
  var _guid :string := Goo.GetGUIDString;
  AParam := TParamList.Create;
  try
    for var i := 1 to Excel.RowCount - 1 do
    begin
      AParam.Clear;
      //var ARow := dc.AppendRecord;
      AParam.Add('@BuyDate',DateTimeToStr(Excel.AsDateTime('ǧ���ټ�����ϵͳ����',i)));
      AParam.Add('@BuyUnit',Excel.AsString('����',i));
      AParam.Add('@BuyPrice',Excel.AsFloat('�ɹ�����',i));
      AParam.Add('@BuyTotal',Excel.AsFloat('�ɹ����',i));
      AParam.Add('@BuyTax',13);
      AParam.Add('@BuyTaxPrice',Excel.AsFloat('�ɹ�����',i));
      AParam.Add('@BuyTaxTotal',Excel.AsFloat('�ɹ����',i));
      AParam.Add('@BuyComment',EmptyStr);
      AParam.Add('@BuyExplain',Excel.AsString('����Ʊ����',i));
		  AParam.Add('@SaleDate',DateTimeToStr(Excel.AsDateTime('�տ�����',i)));
      AParam.Add('@SaleUnit',Excel.AsString('��������',i));
      AParam.Add('@SalePrice',Excel.AsFloat('���۵���',i));
      AParam.Add('@SaleTotal',Excel.AsFloat('���۽��',i));
      AParam.Add('@SaleTax',13);
      AParam.Add('@SaleTaxPrice',Excel.AsFloat('���۵���',i));
      AParam.Add('@SaleTaxTotal',Excel.AsFloat('���۽��',i));
      AParam.Add('@SaleComment',EmptyStr);
      AParam.Add('@SaleExplain',Excel.AsString('����Ʊ����',i));
		  AParam.Add('@PFullName',Excel.AsString('�����Ӧ˰��������',i));
      AParam.Add('@PStandard',Excel.AsString('����ͺ�',i));
      AParam.Add('@PUnit',Excel.AsString('��λ',i));
      AParam.Add('@Qty',Excel.AsFloat('����',i));
      AParam.Add('@Jobnumber',Excel.AsString('����',i));
      AParam.Add('@OutFactoryDate',DateTimeToStr(Excel.AsDateTime('��������',i)));
      AParam.Add('@ValidityPeriod',DateTimeToStr(Excel.AsDateTime('��������',i)));
		  AParam.Add('@ERec',Goo.Login.LoginUserRec);
      AParam.Add('@UniqueBillid',_guid);
      _succ := _succ and (Goo.DB.ExecProc('GP_Excel_InsertTempBill',AParam)>=0);
      if not _succ then Break;
    end;
  finally
    AParam.Free;
  end;
  if not _succ then Exit;
  ParamList.Add('@UniqueBillid',_guid);
  RefreshData;
end;

procedure TImportBuyBillAndSaleBill.OnIniButton(Sender: TObject);
begin
  inherited;
  ButtonList.Add('��Excel',OnExcelPre);
  ButtonList.Add('���ɵ���',OnImportDB);
  //ButtonList.Add('ȫ��չ��',OnExpandAllNodes);
end;

initialization
  Goo.Reg.RegisterClass(TImportBuyBillAndSaleBill);

end.
