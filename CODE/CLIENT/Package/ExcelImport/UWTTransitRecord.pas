unit UWTTransitRecord;

interface

uses
  System.Classes, System.SysUtils,UBaseQuery;

type

  TWTTransitRecord = class(TBaseQuery)
  private
    procedure OnViewBill(Sender: TObject);
    procedure OnBasicData(Sender: TObject);
    procedure OnImportBill(Sender: TObject);
    procedure OnThreadClick(Sender: TObject);
    procedure OnLinkBillCode(Sender: TObject);
  protected
    procedure OnIniButton(Sender: TObject); override;
  end;

implementation

uses
  UComvar, UExcelObject, Vcl.Grids, UComConst, UComDBStorable, UParamList,
  System.Win.ComObj, UWTTransitRecordBillCodeInput;

procedure TWTTransitRecord.OnBasicData(Sender: TObject);
begin
  //Goo.Msg.ShowMsg(Goo.Local.BasicData[btPtype].GetTypeID<TStorable_PType>('0000900005').FullName);
  Goo.Msg.ShowMsg(Goo.Local.GetRec<TStorable_BType>(RowData['BRec',MainView.DataController.FocusedRowIndex]).FullName);
//  for var i in Goo.Local.BasicData[btPtype] do
//    begin
//      Goo.Logger.Info('Rec=%d,FullName=%s',[i.Value.Rec,i.Value.FullName]);
//    end;
//  MainView.DataController.get
//  Goo.Msg.ShowMsg(RowData['BUnitType',ActiveRowIndex])
//  Goo.Msg.ShowMsg(MainView.DataController.GetDisplayText(ActiveRowIndex,7));
//  Goo.Msg.ShowMsg(RowData['SendDate',ActiveRowIndex]);
//  Goo.Msg.ShowMsg(GetRowText('BUnitType'));
end;

procedure TWTTransitRecord.OnImportBill(Sender: TObject);
var AParamList:TParamList;
begin
  var AExcel := Sender as TExcelObject;
  for var i := 1 to AExcel.RowCount-1 do
  begin
    AParamList := TParamList.Create;
    try
      AParamList.Assign(ParamList);
      AParamList.Add('@BillID',0);
      AParamList.Add('@BRec',Goo.Local.GetUserCode<TStorable_BType>(AExcel.AsString('��λ���',i)).Rec);
      AParamList.Add('@SendDate',AExcel.AsString('����ʱ�侭����',i));
      AParamList.Add('@StarDate',AExcel.AsString('����ʱ�侭����',i));
      AParamList.Add('@SendAddr',AExcel.AsString('������ַ',i));
      AParamList.Add('@AcceptAddr',Goo.Local.GetUserCode<TStorable_BType>(AExcel.AsString('��λ���',i)).WarehouseAddress);
      AParamList.Add('@BillCode',AExcel.AsString('������',i));
      AParamList.Add('@PackQty',AExcel.AsFloat('ҩƷ����',i));
      AParamList.Add('@TransWeway',AExcel.AsString('���䷽ʽ',i));
      AParamList.Add('@WtEName',AExcel.AsString('������',i));
      AParamList.Add('@Carrier',AExcel.AsString('���˵�λ',i));
      AParamList.Add('@CarNo',AExcel.AsString('���ƺ�',i));
      AParamList.Add('@Driver',AExcel.AsString('��ʻ��',i));
      AParamList.Add('@UniqueID',CreateClassID);
      AParamList.Add('@Flag',1);
      AParamList.Add('@TranTimeLimit',AExcel.AsInteger('����ʱ��',i));
      AParamList.Add('@TransWD',AExcel.AsString('�����¶�',i));
      AParamList.Add('@TransGJ',AExcel.AsString('���乤��',i));
      //AParamList.Add('@ReDate   DATETIME=NULL,
      AParamList.Add('@ArriveTemp',AExcel.AsString('�����¶�',i));
      Goo.DB.ExecProc('GSP_InsWTTransitRecord',AParamList);
    finally
      AParamList.Free;
    end;
  end;
  RefreshData;
end;

procedure TWTTransitRecord.OnIniButton(Sender: TObject);
begin
  inherited;
  //ButtonList.Add('Excel����',OnViewBill);
  //ButtonList.Add('Btype.Rec',OnBasicData);
  //ButtonList.Add('OnThreadClick',OnThreadClick);
  GridDblClickID := ButtonList.Add('�������۵�',OnLinkBillCode);
end;

procedure TWTTransitRecord.OnLinkBillCode(Sender: TObject);
var ABillCode:string;
begin
  Goo.Msg.CheckAndAbort(MainView.DataController.RowCount>0,'�����¼Ϊ�գ����ܽ��й���������');
  if not ShowWTTransitRecordBillCodeInput(ABillCode) then Exit;
  Goo.DB.ExecSQL('UPDATE GSP_WTTransitRecord SET BillCode=''%s'' WHERE BillID=%s',[ABillCode,RowData['BillID',MainView.DataController.FocusedRowIndex]]);
  RowData['BillCode',MainView.DataController.FocusedRowIndex] := ABillCode;
end;

procedure TWTTransitRecord.OnThreadClick(Sender: TObject);
begin
  TThread.CreateAnonymousThread(
    procedure
    begin
      Goo.Logger.Debug('���ͣ�btBtype  Count='+ Goo.Local.BasicData[btBtype].Count.ToString);
    end).Start;
  TThread.CreateAnonymousThread(
    procedure
    begin
      Goo.Logger.Debug('���ͣ�btPtype  Count='+ Goo.Local.BasicData[btPtype].Count.ToString);
    end).Start;
  TThread.CreateAnonymousThread(
    procedure
    begin
      Goo.Logger.Debug('���ͣ�btMtype  Count='+ Goo.Local.BasicData[btMtype].Count.ToString);
    end).Start;
end;

procedure TWTTransitRecord.OnViewBill(Sender: TObject);
var Excel:TExcelObject;
begin
  Excel := TExcelObject.Create('D:\LLS\Downloads\����ģ��.xlsx');
  try
    Excel.OnImportExcelEvent := OnImportBill;
    Excel.ExcelCellCheckList.UseCheckBUSerCode := True; //.Add('��λ���',CheckCell_BUserCode);
    Excel.ExcelCellCheckList.AddCheckEmpty('���˺�');
    Excel.ExcelCellCheckList.AddCheckEmpty(['������','ҩƷ����']);
    Excel.PreViewExcel;
  finally
    Excel.Free;
  end;
end;

initialization
  Goo.Reg.RegisterClass(TWTTransitRecord)

end.
