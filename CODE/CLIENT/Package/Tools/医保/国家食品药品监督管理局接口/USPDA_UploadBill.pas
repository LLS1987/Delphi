unit USPDA_UploadBill;

interface

uses
  Datasnap.DBClient, System.SysUtils, UBaseQuery;

type

  TSpda_UploadBill = class(TBaseQuery)
  private
    procedure OnUpLoadOneClick(Sender: TObject);
  protected
    procedure OnIniButton(Sender: TObject); override;
  end;

implementation

uses
  UComvar, UBaseSPDABuss, USPDA_QingHai;

{ TSpda_UploadBill }

procedure TSpda_UploadBill.OnIniButton(Sender: TObject);
begin
  inherited;
  ButtonList.Add('�����ϴ�',OnUpLoadOneClick);
end;

procedure TSpda_UploadBill.OnUpLoadOneClick(Sender: TObject);
begin
  var _data := TClientDataSet(MainView.DataController.DataSet);
  if not _data.Active then Exit;
  if _data.RecordCount=0 then Exit;
  for var i := 0 to ActiveGridView.DataController.GetSelectedCount-1 do
  begin
    ActiveGridView.DataController.FocusedRowIndex  := ActiveGridView.DataController.GetSelectedRowIndex(i);
    if not TSPDA_Buss_QingHai(YBBuss).P_3503(_data) then Goo.Msg.ShowAlert('�� %d ���ϴ�����%s',[ActiveRowIndex,YBBuss.LastErrorMessage]);
  end;
  RefreshData;
end;

initialization
  Goo.Reg.RegisterClass(TSpda_UploadBill);

end.
