unit UQuery_TransRecord;

interface

uses
  UBaseQuery;

type
  TQuery_TransRecord = class(TBaseQuery)
  protected
    procedure OnIniButton(Sender: TObject); override;
  end;

implementation

uses
  UComVar;

{ TQuery_TransRecord }

procedure TQuery_TransRecord.OnIniButton(Sender: TObject);
begin
  inherited;
  ParamList.Add('@OnlyTrans',1);
  Condition.Add(6,'@PosID','�ŵ�',False,True);
  Condition.Add(2,'@OnlyTrans','����ʾ���ϴ�����',False,True);
  Condition.AddDateBetween('@BgnDate,@EndDate','��ʼ����,��',False,True);
end;

initialization
  Goo.Reg.RegisterClass(TQuery_TransRecord);

end.
