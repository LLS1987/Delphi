unit USaleToMoney;

interface

uses
  System.Classes, System.SysUtils,UBaseQuery, cxGridTableView, cxGridCustomTableView, Vcl.Controls;

type

  TSaleToMoney = class(TBaseQuery)
  private
    procedure OnCreateBill(Sender: TObject);
    procedure OnUpStreamConnection(Sender: TObject);
    procedure OnDBTableView1SelectionChanged(Sender: TcxCustomGridTableView);
  protected
    procedure SetGrid;override;
    procedure OnIniButton(Sender: TObject); override;
  end;

implementation

uses
  UComvar;

procedure TSaleToMoney.OnCreateBill(Sender: TObject);
var ARow,ACount:Integer;
  Atotalqty,Atotalmoney:Double;
begin
  ACount := 0;
  Atotalmoney := 0;
  Atotalqty := 0;
  for var i := 0 to ActiveGridView.DataController.GetSelectedCount-1 do
  begin
    ARow := ActiveGridView.DataController.GetSelectedRowIndex(i);
    if Goo.DB.ExecProc('GP_ConvertBill',['@BillID','@BillType','@DescBill','@ERec'],[RowData['BillID',ARow],RowData['BillType',ARow],4,Goo.Login.LoginUserRec])>0 then
    begin
      Inc(ACount);
      Atotalqty := Atotalqty + RowData['totalqty',ARow];
      Atotalmoney := Atotalmoney + RowData['totalmoney',ARow];
    end;
  end;
  if ACount>0 then
  begin
    Goo.Msg.ShowMsg('�տ�ɹ����� %d �����ϼ����� %f ���ϼƽ�� %f Ԫ',[ACount,Atotalqty,Atotalmoney]);
    RefreshData;
  end;
end;

procedure TSaleToMoney.OnDBTableView1SelectionChanged(Sender: TcxCustomGridTableView);
var ARow,ACount:Integer;
  Atotalqty,Atotalmoney:Double;
begin
  ACount := 0;
  Atotalmoney := 0;
  Atotalqty := 0;
  for var i := 0 to ActiveGridView.DataController.GetSelectedCount-1 do
  begin
    ARow := ActiveGridView.DataController.GetSelectedRowIndex(i);
    Inc(ACount);
    Atotalqty := Atotalqty + RowData['totalqty',ARow];
    Atotalmoney := Atotalmoney + RowData['totalmoney',ARow];
  end;
  Condition.ConditionItem['SelectTotal'].Value := Format('%d ��  ������%f  ��%f',[ACount,Atotalqty,Atotalmoney]);
end;

procedure TSaleToMoney.OnIniButton(Sender: TObject);
begin
  inherited;
  ButtonList.Add('�����տ',OnCreateBill);
  //ButtonList.Add('�������ݿ�',OnUpStreamConnection);
end;

procedure TSaleToMoney.OnUpStreamConnection(Sender: TObject);
begin
  //Goo.Reg.ShowModal('TUpstreamConnect')
  Goo.Media.Play('D:\LLS\Downloads\�µĶ�������_������_[����ID��35825].mp3');
end;

procedure TSaleToMoney.SetGrid;
begin
  inherited;
  MultSel := True;
  MainView.OnSelectionChanged := OnDBTableView1SelectionChanged;
end;

initialization
  Goo.Reg.RegisterClass(TSaleToMoney);

end.
