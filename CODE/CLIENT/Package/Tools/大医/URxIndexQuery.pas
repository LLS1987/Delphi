unit URxIndexQuery;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,UBaseQuery, cxStyles, cxClasses,
  System.ImageList, Vcl.ImgList, System.Actions, Vcl.ActnList, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls;

type
  TRxIndexQuery = class(TBaseQuery)
  private
    { Private declarations }
    procedure OnSelectClick(Sender:TObject);
    procedure OnParamClick(Sender:TObject);
    procedure OnSelectPtypeClick(Sender:TObject);
    procedure OnSelectEtypeClick(Sender:TObject);
  protected
    procedure OnIniButton(Sender: TObject); override;
    procedure LoadData;override;
  public
    { Public declarations }
  end;

var
  RxIndexQuery: TRxIndexQuery;

implementation

uses
  UComvar, UBaseParams, UComDBStorable;

{$R *.dfm}

{ TRxIndexQuery }

procedure TRxIndexQuery.LoadData;
begin
  //QueryDictionary.Items[ActiveGridView.Name].AddOrSetValue(C_QueryMode_OPENSQL,'select * from vbillindex_query');
  inherited;
end;

procedure TRxIndexQuery.OnIniButton(Sender: TObject);
begin
  inherited;
  //ParamList.Add('@Draft',0);
  ParamList.Add('@OrderBy','billdate');
  Condition.Memory := True;
  Condition.Add(1,'PREC','��Ʒ��Ϣ��Ʒ��Ϣ1��Ʒ��Ϣ11',True,True);
  Condition.Add(2,'Draft','�ݸ�',False,True);
  Condition.AddThin(1,'PREC2','��Ʒ��Ϣ�Ĳ���',False,True);
  Condition.AddFat(1,'PREC3','��Ʒ��Ϣ4',False,True);
  Condition.Add(3,'PREC4','��Ʒ��Ϣ5',True,True);
  Condition.Add(6,'PREC5','��Ʒ��Ϣ6',True,True);
  Condition.Add(1,'PREC6','��Ʒ��Ϣ7',False,True);
  Condition.Add(1,'PREC7','��Ʒ��Ϣ8',True,True);
  Condition.ConditionItem['PREC7'].LastCaption := 'β������';
  Condition.Add(1,'PREC8','��Ʒ��Ϣ9',False,True);
  Condition.AddDateBetween('@BeginDate,@EndDate','��ʼ����,��',False,True);
  Condition.Add(5,'PREC11','��Ʒ��Ϣ��Ʒ��Ϣ11',False,True);
  Condition.Add(3,'PREC12','��Ʒ��Ϣ12',False,True);
  ButtonList.Add('�ŵ�ѡ��',OnParamClick);
  ButtonList.Add('��Ʒѡ��',OnSelectPtypeClick);
  GridDblClickID :=  ButtonList.Add('��ѯ��ѯ��ѯ��ѯ��ѯ��ѯ��ѯ3',OnSelectClick);
  ButtonList.Add('ְԱѡ��',OnSelectEtypeClick);
  ButtonList.Add('��ѯ5',nil,True);
  ButtonList.Add('��ѯ6',nil,True);
  ButtonList.Add('���ѯ��ѯ��ѯ��ѯ��ѯ7',nil,True);
end;

procedure TRxIndexQuery.OnParamClick(Sender: TObject);
begin
  //Goo.Msg.ShowMsg(Self.ParamList.AsString('@PREC')+#13#10+Self.ParamList.AsString('@PREC9')+#13#10+Self.ParamList.AsString('@PREC11'));
//  Goo.Reg.ShowModal('TBaseInfoSel');
  var k  := TMTypeParam.Create(nil);
  try
    k.MultSel := True;
    k.GetBaseInfoSelect;
    goo.MSG.ShowMsg('Count=' + k.Return.Count.ToString + '   '+k.First.Rec.ToString+':'+ k.First.fullname)
  finally
    k .Free;
  end;
end;

procedure TRxIndexQuery.OnSelectClick(Sender: TObject);
begin
  Goo.Msg.ShowMsg(RowData['comment',ActiveRowIndex]);
end;

procedure TRxIndexQuery.OnSelectEtypeClick(Sender: TObject);
begin
  var k  := TETypeParam.Create(nil);
  try
    k.MultSel := True;
    k.GetBaseInfoSelect;
    goo.MSG.ShowMsg('Count=' + k.Count.ToString + '['+k.First.Rec.ToString+']'+ k.First.fullname + ':' + TStorable_EType(k.First).Sex)
  finally
    k .Free;
  end;
end;

procedure TRxIndexQuery.OnSelectPtypeClick(Sender: TObject);
begin
  var k  := TPTypeParam.Create(nil);
  try
    k.MultSel := True;
    k.GetBaseInfoSelect;
    goo.MSG.ShowMsg('Count=' + k.Return.Count.ToString + '   '+k.First.Rec.ToString+':'+ k.First.fullname)
  finally
    k .Free;
  end;
end;

initialization
  Goo.Reg.RegisterClass(TRxIndexQuery);
end.
