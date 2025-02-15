unit UUploadData_QingDao;

interface

uses
  UBaseQuery, System.SysUtils, Vcl.StdCtrls, Vcl.Forms, Vcl.Controls,
  Datasnap.DBClient, Vcl.ExtCtrls;

type
  TUploadData_QingDao = class(TBaseQuery)
  private
    FLogMemo:TMemo;
    FTimer:TTimer;
    FLastErrorMessage:string;
    procedure OnSignClick(Sender: TObject);
    procedure OnAutoClick(Sender: TObject);
    procedure OnCloseAutoTransClick(Sender: TObject);
    procedure OnUpLoadOneClick(Sender: TObject);
    procedure OnTimerClick(Sender: TObject);
    function UpLoadOneRecord_9948(ADataSet:TClientDataSet):Boolean;
    function UpLoadOneRecord_9949(ADataSet:TClientDataSet):Boolean;
    function UpLoadOneRecord_9950(ADataSet:TClientDataSet):Boolean;
    function UpLoadOneRecord_9951(ADataSet:TClientDataSet):Boolean;
    function UpLoadOneRecord_9952(ADataSet:TClientDataSet):Boolean;
    function UpLoadOneRecord_9953(ADataSet:TClientDataSet):Boolean;
    procedure AddLogMemo(AMsg:string);overload;
    procedure AddLogMemo(AMsg:string;const Args: array of const);overload;
  protected
    procedure OnIniButton(Sender: TObject); override;
    procedure RefreshParamList;override;
  public
    destructor Destroy; override;  
  end;

implementation

uses
  UComvar, UConfig_SPDA_QingDao, Vcl.Graphics, System.JSON, UJsonObjectHelper,
  UComDBStorable, System.IniFiles, UDbHelper;

{ TUploadData_QingDao }

procedure TUploadData_QingDao.AddLogMemo(AMsg: string);
begin
  if Assigned(FLogMemo) then FLogMemo.Lines.Add(FormatDateTime('yyyy-MM-dd HH:mm:ss',Now)+' '+AMsg);
end;

procedure TUploadData_QingDao.AddLogMemo(AMsg: string; const Args: array of const);
begin
  AddLogMemo(Format(AMsg,Args));
end;

destructor TUploadData_QingDao.Destroy;
begin
  if Assigned(FLogMemo) then FreeAndNil(FLogMemo);
  if Assigned(FTimer) then FreeAndNil(FTimer);  
  inherited;
end;

procedure TUploadData_QingDao.OnAutoClick(Sender: TObject);
begin
  if not Assigned(FLogMemo) then FLogMemo := TMemo.Create(nil);
  FLogMemo.Parent  := Self.Panel_Client;
  FLogMemo.Align   := alClient;
  FLogMemo.Color   := clBlack;
  FLogMemo.Font.Color := clWhite;
  FLogMemo.Font.Size  := 12;
  FLogMemo.Visible := True;  
  FLogMemo.Lines.Text := '开启自动传输 ... ';
  if not Assigned(FTimer) then FTimer := TTimer.Create(nil);
  FTimer.Interval:= 60000*5;
  FTimer.OnTimer := OnTimerClick;
  FTimer.Enabled := True;
end;

procedure TUploadData_QingDao.OnCloseAutoTransClick(Sender: TObject);
begin
  if Assigned(FLogMemo) then FLogMemo.Visible := False;
  if Assigned(FLogMemo) then FLogMemo.Enabled := False;
end;

procedure TUploadData_QingDao.OnIniButton(Sender: TObject);
begin
  inherited;
  ButtonList.Add('签到',OnSignClick);
  ButtonList.Add('开启自动传输',OnAutoClick);
  ButtonList.Add('关闭自动传输',OnCloseAutoTransClick);
  ButtonList.Add('单条上传',OnUpLoadOneClick);
end;

procedure TUploadData_QingDao.OnSignClick(Sender: TObject);
begin
  var ff := TCommAPI_SPDA_QingDao.Create;
  try
    if ff.SignNo<>EmptyStr then
    begin
      Goo.Msg.ShowMsg('签到成功：'+ff.SignNo);
    end else Goo.Msg.ShowError('签到异常：%s',[ff.YBDataInterface.LastErrorMessage]);
  finally
    ff.Free;
  end;
end;

procedure TUploadData_QingDao.OnTimerClick(Sender: TObject);
begin
  RefreshParamList;
  var ds := TClientDataSet.Create(nil);
  try
    ParamList.Add('@BgnDate',FormatDateTime('yyyy-MM-dd',Now));
    ParamList.Add('@EndDate',FormatDateTime('yyyy-MM-dd',Now+1));
    ParamList.Add('@BillType','706,34');
    Goo.DB.OpenProc('GP_QingDao_GetInoutStockBill',ParamList,ds);
    while not ds.Eof do
    begin
      UpLoadOneRecord_9950(ds);
      ds.Next;
    end;
    ParamList.Add('@BillType','708,6');
    Goo.DB.OpenProc('GP_QingDao_GetInoutStockBill',ParamList,ds);
    while not ds.Eof do
    begin
      UpLoadOneRecord_9951(ds);
      ds.Next;
    end;
    Goo.DB.OpenProc('GP_QingDao_GetRetailIndex',ParamList,ds);
    while not ds.Eof do
    begin
      UpLoadOneRecord_9952(ds);
      ds.Next;
    end;
    Goo.DB.OpenProc('GP_QingDao_GetRetailBack',ParamList,ds);
    while not ds.Eof do
    begin
      UpLoadOneRecord_9953(ds);
      ds.Next;
    end;
  finally
    ds.Free;
  end;
end;

procedure TUploadData_QingDao.OnUpLoadOneClick(Sender: TObject);
var AJson:TJSONObject;
  i,succ:Integer;
  ADataSet : TClientDataSet;
begin
  succ := 0;
  ADataSet := TClientDataSet(MainView.DataController.DataSet);
  for i := 0 to ActiveGridView.DataController.GetSelectedCount-1 do
  begin
//    ActiveGridView.DataController.FocusSelectedRow(ActiveGridView.DataController.GetSelectedRowIndex(i));
    ActiveGridView.DataController.FocusedRowIndex  := ActiveGridView.DataController.GetSelectedRowIndex(i);
    var ff := TCommAPI_SPDA_QingDao.Create;
    AJson := TJSONObject.SO();
    try
      if MainGrid.ActiveLevel.Caption='商品盘存上传' then
      begin
        AJson.O['invinfo'] := TJSONObject.SO();
        AJson.O['invinfo'].S['med_list_codg']         := GetRowData<string>('med_list_codg');
        AJson.O['invinfo'].S['fixmedins_hilist_id']   := GetRowData<string>('fixmedins_hilist_id');
        AJson.O['invinfo'].S['fixmedins_hilist_name'] := GetRowData<string>('fixmedins_hilist_name');
        AJson.O['invinfo'].S['rx_flag']               := GetRowData<string>('rx_flag');
        AJson.O['invinfo'].S['invdate']               := GetRowData<string>('invdate');
        AJson.O['invinfo'].D['inv_cnt']               := GetRowData<Double>('inv_cnt');
        AJson.O['invinfo'].S['manu_lotnum']           := GetRowData<string>('manu_lotnum');
        AJson.O['invinfo'].S['fixmedins_bchno']       := GetRowData<string>('fixmedins_bchno');
        AJson.O['invinfo'].S['manu_date']             := GetRowData<string>('manu_date');
        AJson.O['invinfo'].S['expy_end']              := GetRowData<string>('expy_end');
        AJson.O['invinfo'].S['memo']                  := GetRowData<string>('memo');
        if ff.P9948(AJson) then Goo.Msg.ShowAlert('上传异常：%s',[ff.YBDataInterface.LastErrorMessage]) else Inc(succ);
      end
      else if MainGrid.ActiveLevel.Caption='商品库存变更' then
      begin
        if not UpLoadOneRecord_9949(ADataSet) then Goo.Msg.ShowAlert(FLastErrorMessage) else Inc(succ);
      end
      else if MainGrid.ActiveLevel.Caption='商品采购入库' then
      begin
        AJson.O['purcinfo'] := TJSONObject.SO();
        AJson.O['purcinfo'].S['med_list_codg']         := GetRowData<string>('med_list_codg');
        AJson.O['purcinfo'].S['fixmedins_hilist_id']   := GetRowData<string>('fixmedins_hilist_id');
        AJson.O['purcinfo'].S['fixmedins_hilist_name'] := GetRowData<string>('fixmedins_hilist_name');
        AJson.O['purcinfo'].S['dynt_no']               := GetRowData<string>('dynt_no');
        AJson.O['purcinfo'].S['fixmedins_bchno']       := GetRowData<string>('fixmedins_bchno');
        AJson.O['purcinfo'].S['spler_name']            := GetRowData<string>('spler_name');
        AJson.O['purcinfo'].S['spler_pmtno']           := GetRowData<string>('spler_pmtno');
        AJson.O['purcinfo'].S['manu_lotnum']           := GetRowData<string>('manu_lotnum');
        AJson.O['purcinfo'].S['prodentp_name']         := GetRowData<string>('prodentp_name');
        AJson.O['purcinfo'].S['aprvno']                := GetRowData<string>('aprvno');
        AJson.O['purcinfo'].S['manu_date']             := GetRowData<string>('manu_date');
        AJson.O['purcinfo'].S['expy_end']              := GetRowData<string>('expy_end');
        AJson.O['purcinfo'].D['finl_trns_pric']        := GetRowData<Double>('finl_trns_pric');
        AJson.O['purcinfo'].D['purc_retn_cnt']         := GetRowData<Double>('purc_retn_cnt');
        AJson.O['purcinfo'].S['purc_invo_codg']        := GetRowData<string>('purc_invo_codg');
        AJson.O['purcinfo'].S['purc_invo_no']          := GetRowData<string>('purc_invo_no');
        AJson.O['purcinfo'].S['rx_flag']               := GetRowData<string>('rx_flag');
        AJson.O['purcinfo'].S['purc_retn_stoin_time']  := GetRowData<string>('purc_retn_stoin_time');
        AJson.O['purcinfo'].S['purc_retn_opter_name']  := GetRowData<string>('purc_retn_opter_name');
        AJson.O['purcinfo'].S['prod_geay_flag']        := GetRowData<string>('prod_geay_flag');
        AJson.O['purcinfo'].S['memo']                  := GetRowData<string>('memo');
        if not ff.P9950(AJson) then Goo.Msg.ShowAlert(ff.YBDataInterface.LastErrorMessage)
        else
        begin
          Inc(succ);
          Goo.DB.ExecSQL('INSERT INTO dbo.YB_BusinessLink(UniqueBillid,BillType,Flag,trandate,BillID,Ord,BillDate) SELECT StockUniqueid,BillType,1,GETDATE(),BillID,Ord,BillDate FROM dbo.vInOutStockTable WHERE BillID=%d AND ord=%d',[ADataSet.I['BillID'],ADataSet.I['ord']]);
        end;
      end
      else if MainGrid.ActiveLevel.Caption='商品采购退货' then
      begin
        AJson.O['purcinfo'] := TJSONObject.SO();
        AJson.O['purcinfo'].S['med_list_codg']         := GetRowData<string>('med_list_codg');                   //med_list_codg	医疗目录编码
        AJson.O['purcinfo'].S['fixmedins_hilist_id']   := GetRowData<string>('fixmedins_hilist_id');             //fixmedins_hilist_id	定点医药机构目录编号
        AJson.O['purcinfo'].S['fixmedins_hilist_name'] := GetRowData<string>('fixmedins_hilist_name');           //fixmedins_hilist_name	定点医药机构目录名称
        //AJson.O['purcinfo'].S['dynt_no']               := GetRowData<string>('dynt_no');
        AJson.O['purcinfo'].S['fixmedins_bchno']       := GetRowData<string>('fixmedins_bchno');                 //fixmedins_bchno	定点医药机构批次流水号
        AJson.O['purcinfo'].S['spler_name']            := GetRowData<string>('spler_name');                      //spler_name	供应商名称
        AJson.O['purcinfo'].S['spler_pmtno']           := GetRowData<string>('spler_pmtno');                     //spler_pmtno	供应商许可证号
        AJson.O['purcinfo'].S['manu_lotnum']           := GetRowData<string>('manu_lotnum');
        AJson.O['purcinfo'].S['prodentp_name']         := GetRowData<string>('prodentp_name');
        AJson.O['purcinfo'].S['aprvno']                := GetRowData<string>('aprvno');
        AJson.O['purcinfo'].S['manu_date']             := GetRowData<string>('manu_date');                       //manu_date	生产日期
        AJson.O['purcinfo'].S['expy_end']              := GetRowData<string>('expy_end');                        //expy_end	有效期止
        AJson.O['purcinfo'].D['finl_trns_pric']        := GetRowData<Double>('finl_trns_pric');                  //finl_trns_pric	最终成交单价
        AJson.O['purcinfo'].D['purc_retn_cnt']         := GetRowData<Double>('purc_retn_cnt');                   //purc_retn_cnt	采购/退货数量
        AJson.O['purcinfo'].S['purc_invo_codg']        := GetRowData<string>('purc_invo_codg');                  //purc_invo_codg	采购发票编码
        AJson.O['purcinfo'].S['purc_invo_no']          := GetRowData<string>('purc_invo_no');                    //purc_invo_no	采购发票号
        AJson.O['purcinfo'].S['rx_flag']               := GetRowData<string>('rx_flag');                         //rx_flag	处方药标志
        AJson.O['purcinfo'].S['purc_retn_stoin_time']  := GetRowData<string>('purc_retn_stoin_time');            //purc_retn_stoin_time	采购/退货入库时间
        AJson.O['purcinfo'].S['purc_retn_opter_name']  := GetRowData<string>('purc_retn_opter_name');            //purc_retn_opter_name	采购/退货经办人姓名
        //AJson.O['purcinfo'].S['prod_geay_flag']        := GetRowData<string>('prod_geay_flag');
        AJson.O['purcinfo'].S['memo']                  := GetRowData<string>('memo');                            //memo	备注
        AJson.O['purcinfo'].S['medins_prod_purc_no']   := GetRowData<string>('medins_prod_purc_no');             //medins_prod_purc_no	商品采购流水号
        if not ff.P9951(AJson) then Goo.Msg.ShowAlert(ff.YBDataInterface.LastErrorMessage)
        else
        begin
          Inc(succ);
          Goo.DB.ExecSQL('INSERT INTO dbo.YB_BusinessLink(UniqueBillid,BillType,Flag,trandate,BillID,Ord,BillDate) SELECT StockUniqueid,BillType,1,GETDATE(),BillID,Ord,BillDate FROM dbo.vInOutStockTable WHERE BillID=%d AND ord=%d',[ADataSet.I['BillID'],ADataSet.I['ord']]);;
        end;
      end
      else if MainGrid.ActiveLevel.Caption='商品销售出库' then
      begin
        if not UpLoadOneRecord_9952(ADataSet) then Goo.Msg.ShowAlert(FLastErrorMessage) else Inc(succ);
        {AJson.O['selinfo'] := TClientDataSet(MainView.DataController.DataSet).ToJSONObject;
        AJson.O['selinfo'].RemovePairAndNil('BillID');

        //AJson.O['selinfo'] := TJSONObject.SO();
        AJson.O['selinfo'].S['fixmedins_hilist_id']   := ff.PosCode;  //	定点医药机构目录编号	ANS	30	Y
        AJson.O['selinfo'].S['fixmedins_hilist_name'] := ff.PosName;  //	定点医药机构目录名称	ANS	200	Y
        //药品明细
        var ds:TClientDataSet := TClientDataSet.Create(nil);
        try
          Goo.DB.OpenProc('GP_QingDao_GetRetailBill',['@BillID'],[GetRowData<Integer>('BillID')],ds);
          AJson.O['selinfo'].A['drugdetail'] := ds.ToJSONArray;
        finally
          ds.Free;
        end;
        //Goo.Msg.ShowMsg(AJson.ToString);
        if not ff.P9952(AJson) then Goo.Msg.ShowError(ff.YBDataInterface.LastErrorMessage); }
      end
      else if MainGrid.ActiveLevel.Caption='商品销售退货' then
      begin
        AJson.O['selinfo'] := TClientDataSet(MainView.DataController.DataSet).ToJSONObject;
        AJson.O['selinfo'].RemovePairAndNil('BillID');
        AJson.O['selinfo'].S['fixmedins_hilist_id']   := ff.PosCode;  //	定点医药机构目录编号	ANS	30	Y
        AJson.O['selinfo'].S['fixmedins_hilist_name'] := ff.PosName;  //	定点医药机构目录名称	ANS	200	Y
        if not ff.P9953(AJson) then Goo.Msg.ShowAlert(ff.YBDataInterface.LastErrorMessage) else Inc(succ);
      end;
    finally
      ff.Free;
      AJson.Free;
    end;
  end;
  Goo.Msg.ShowMsg('选择记录 %d 条，成功 %d 条',[ActiveGridView.DataController.GetSelectedCount,succ]);
  RefreshData;
end;

procedure TUploadData_QingDao.RefreshParamList;
begin
  inherited;
  Goo.Msg.CheckAndAbort(Goo.ComVar.AsInteger('@YB_QingDao_PosID')>0,'请先进行医保设置！');
  ParamList.Add('@KRec',Goo.Local.GetRec<TStorable_MType>(Goo.ComVar.AsInteger('@YB_QingDao_PosID')).KRec);
  if MainGrid.ActiveLevel.Caption='商品采购入库' then
  begin
    ParamList.Add('@BillType','706,34');   //采购入库+门店收货入库单
  end
  else if MainGrid.ActiveLevel.Caption='商品采购退货' then
  begin
    ParamList.Add('@BillType','708,6');
  end
  else if MainGrid.ActiveLevel.Caption='商品销售出库' then
  begin
    ParamList.Add('@BillType','151,11');
  end
  else if MainGrid.ActiveLevel.Caption='商品销售退货' then
  begin
    ParamList.Add('@BillType','152,45');
  end;
end;

function TUploadData_QingDao.UpLoadOneRecord_9948(ADataSet: TClientDataSet): Boolean;
begin
  if not ADataSet.Active then Exit;
  if ADataSet.RecordCount=0 then Exit;
  var ff := TCommAPI_SPDA_QingDao.Create;
  var AJson := TJSONObject.SO();
  try
    AJson.O['invinfo'] := ADataSet.ToJSONObject;
//      AJson.O['invinfo'].S['med_list_codg']         := GetRowData<string>('med_list_codg');
    AJson.O['invinfo'].S['fixmedins_hilist_id']   := ff.PosCode;// GetRowData<string>('fixmedins_hilist_id');
    AJson.O['invinfo'].S['fixmedins_hilist_name'] := ff.PosName;// GetRowData<string>('fixmedins_hilist_name');
    AJson.O['invinfo'].RemovePairAndNil('GoodsId');
//      AJson.O['invinfo'].S['rx_flag']               := GetRowData<string>('rx_flag');
//      AJson.O['invinfo'].S['invdate']               := GetRowData<string>('invdate');
//      AJson.O['invinfo'].D['inv_cnt']               := GetRowData<Double>('inv_cnt');
//      AJson.O['invinfo'].S['manu_lotnum']           := GetRowData<string>('manu_lotnum');
//      AJson.O['invinfo'].S['fixmedins_bchno']       := GetRowData<string>('fixmedins_bchno');
//      AJson.O['invinfo'].S['manu_date']             := GetRowData<string>('manu_date');
//      AJson.O['invinfo'].S['expy_end']              := GetRowData<string>('expy_end');
//      AJson.O['invinfo'].S['memo']                  := GetRowData<string>('memo');
    Result := ff.P9948(AJson);
    FLastErrorMessage := ff.YBDataInterface.LastErrorMessage;
    AddLogMemo('商品盘存上传：'+Goo.Cast.iif(Result,'成功',ff.YBDataInterface.LastErrorMessage));
    //if Result then Goo.DB.ExecSQL('',[]);
  finally
   ff.Free;
   AJson.Free;
  end;
end;

function TUploadData_QingDao.UpLoadOneRecord_9949(ADataSet: TClientDataSet): Boolean;
begin
  if not ADataSet.Active then Exit;
  if ADataSet.RecordCount=0 then Exit;
  var ff := TCommAPI_SPDA_QingDao.Create;
  var AJson := TJSONObject.SO();
  try
    AJson.O['invinfo'] := ADataSet.ToJSONObject;
    AJson.O['invinfo'].S['fixmedins_hilist_id']   := ff.PosCode;
    AJson.O['invinfo'].S['fixmedins_hilist_name'] := ff.PosName;
    AJson.O['invinfo'].RemovePairAndNil('BillID');
    AJson.O['invinfo'].RemovePairAndNil('ord');
    Result := ff.P9949(AJson);
    FLastErrorMessage := ff.YBDataInterface.LastErrorMessage;
    AddLogMemo('商品库存变更：'+Goo.Cast.iif(Result,'成功',FLastErrorMessage));
    if Result then Goo.DB.ExecSQL('INSERT INTO dbo.YB_GoodsStockChange(BillID,Ord)VALUES(%d,%d)',[ADataSet.I['BillID'],ADataSet.I['ord']]);
  finally
   ff.Free;
   AJson.Free;
  end;
end;

function TUploadData_QingDao.UpLoadOneRecord_9950(ADataSet: TClientDataSet): Boolean;
begin
  if not ADataSet.Active then Exit;
  if ADataSet.RecordCount=0 then Exit;
  var ff := TCommAPI_SPDA_QingDao.Create;
  var AJson := TJSONObject.SO();
  try
    AJson.O['selinfo'] := ADataSet.ToJSONObject;
    AJson.O['selinfo'].RemovePairAndNil('BillID');
    AJson.O['selinfo'].RemovePairAndNil('BillType');
    AJson.O['selinfo'].RemovePairAndNil('BillDate');
    AJson.O['selinfo'].RemovePairAndNil('PRec');
    AJson.O['selinfo'].RemovePairAndNil('ord');
    AJson.O['selinfo'].S['fixmedins_hilist_id']   := ff.PosCode;  //	定点医药机构目录编号	ANS	30	Y
    AJson.O['selinfo'].S['fixmedins_hilist_name'] := ff.PosName;  //	定点医药机构目录名称	ANS	200	Y
    Result := ff.P9950(AJson);
    FLastErrorMessage := ff.YBDataInterface.LastErrorMessage;
    AddLogMemo('商品采购入库：'+Goo.Cast.iif(Result,'成功',ff.YBDataInterface.LastErrorMessage));
    if Result then
      Goo.DB.ExecSQL('INSERT INTO dbo.YB_BusinessLink(UniqueBillid,BillType,Flag,trandate,BillID,Ord,BillDate) SELECT StockUniqueid,BillType,1,GETDATE(),BillID,Ord,BillDate FROM dbo.vInOutStockTable WHERE BillID=%d AND ord=%d',[ADataSet.I['BillID'],ADataSet.I['ord']]);
  finally
   ff.Free;
   AJson.Free;
  end;
end;

function TUploadData_QingDao.UpLoadOneRecord_9951(ADataSet: TClientDataSet): Boolean;
begin
  if not ADataSet.Active then Exit;
  if ADataSet.RecordCount=0 then Exit;
  var ff := TCommAPI_SPDA_QingDao.Create;
  var AJson := TJSONObject.SO();
  try
    AJson.O['selinfo'] := ADataSet.ToJSONObject;
    AJson.O['selinfo'].RemovePairAndNil('BillID');
    AJson.O['selinfo'].RemovePairAndNil('BillType');
    AJson.O['selinfo'].RemovePairAndNil('BillDate');
    AJson.O['selinfo'].RemovePairAndNil('PRec');
    AJson.O['selinfo'].RemovePairAndNil('ord');
    AJson.O['selinfo'].S['fixmedins_hilist_id']   := ff.PosCode;  //	定点医药机构目录编号	ANS	30	Y
    AJson.O['selinfo'].S['fixmedins_hilist_name'] := ff.PosName;  //	定点医药机构目录名称	ANS	200	Y
    Result := ff.P9951(AJson);
    FLastErrorMessage := ff.YBDataInterface.LastErrorMessage;
    AddLogMemo('商品采购退货：'+Goo.Cast.iif(Result,'成功',ff.YBDataInterface.LastErrorMessage));
    if Result then Goo.DB.ExecSQL('INSERT INTO dbo.YB_BusinessLink(UniqueBillid,BillType,Flag,trandate,BillID,Ord,BillDate) SELECT StockUniqueid,BillType,1,GETDATE(),BillID,Ord,BillDate FROM dbo.vInOutStockTable WHERE BillID=%d AND ord=%d',[ADataSet.I['BillID'],ADataSet.I['ord']]);
  finally
   ff.Free;
   AJson.Free;
  end;
end;

function TUploadData_QingDao.UpLoadOneRecord_9952(ADataSet: TClientDataSet): Boolean;
begin
  if not ADataSet.Active then Exit;
  if ADataSet.RecordCount=0 then Exit;
  var ff := TCommAPI_SPDA_QingDao.Create;
  var AJson := TJSONObject.SO();
  try
    AJson.O['selinfo'] := ADataSet.ToJSONObject;
    AJson.O['selinfo'].RemovePairAndNil('BillID');
    AJson.O['selinfo'].RemovePairAndNil('Ord');
    AJson.O['selinfo'].S['fixmedins_hilist_id']   := ff.PosCode;  //	定点医药机构目录编号	ANS	30	Y
    AJson.O['selinfo'].S['fixmedins_hilist_name'] := ff.PosName;  //	定点医药机构目录名称	ANS	200	Y
    //药品明细
    {var ds:TClientDataSet := TClientDataSet.Create(nil);
    try
      Goo.DB.OpenProc('GP_QingDao_GetRetailBill',['@BillID','@Ord'],[ADataSet.I['BillID'],ADataSet.I['ord']],ds);
      AJson.O['selinfo'].A['drugdetail'] := ds.ToJSONArray;
    finally
      ds.Free;
    end;}
    //Goo.Msg.ShowMsg(AJson.ToString);
    Result := ff.P9952(AJson);
    FLastErrorMessage := ff.YBDataInterface.LastErrorMessage;
    AddLogMemo('商品销售出库：'+Goo.Cast.iif(Result,'成功',ff.YBDataInterface.LastErrorMessage));
    if Result then Goo.DB.ExecSQL('INSERT INTO dbo.YB_BusinessLink(UniqueBillid,BillType,Flag,trandate,BillID,Ord,BillDate)'
      +' SELECT UniqueBillid,BillType,1,GETDATE(),b.BillID,Ord,BillDate FROM dbo.vRetailBillIndex i INNER JOIN dbo.vRetailBill b ON b.BillID = i.BillID '
      +' WHERE b.BillID=%d AND b.ord=%d',[ADataSet.I['BillID'],ADataSet.I['ord']]);
  finally
   ff.Free;
   AJson.Free;
  end;
end;

function TUploadData_QingDao.UpLoadOneRecord_9953(ADataSet: TClientDataSet): Boolean;
begin
  if not ADataSet.Active then Exit;
  if ADataSet.RecordCount=0 then Exit;
  var ff := TCommAPI_SPDA_QingDao.Create;
  var AJson := TJSONObject.SO();
  try
    AJson.O['selinfo'] := ADataSet.ToJSONObject;
    AJson.O['selinfo'].RemovePairAndNil('BillID');
    AJson.O['selinfo'].RemovePairAndNil('ord');
    AJson.O['selinfo'].S['fixmedins_hilist_id']   := ff.PosCode;  //	定点医药机构目录编号	ANS	30	Y
    AJson.O['selinfo'].S['fixmedins_hilist_name'] := ff.PosName;  //	定点医药机构目录名称	ANS	200	Y
    Result := ff.P9953(AJson);
    FLastErrorMessage := ff.YBDataInterface.LastErrorMessage;
    AddLogMemo('商品销售退货：'+Goo.Cast.iif(Result,'成功',ff.YBDataInterface.LastErrorMessage));
    if Result then Goo.DB.ExecSQL('INSERT INTO dbo.YB_BusinessLink(UniqueBillid,BillType,Flag,trandate,BillID,Ord,BillDate)'
      +' SELECT UniqueBillid,BillType,1,GETDATE(),b.BillID,Ord,BillDate FROM dbo.vRetailBillIndex i INNER JOIN dbo.vRetailBill b ON b.BillID = i.BillID '
      +' WHERE b.BillID=%d AND b.ord=%d',[ADataSet.I['BillID'],ADataSet.I['ord']]);
  finally
   ff.Free;
   AJson.Free;
  end;
end;

initialization
  Goo.Reg.RegisterClass(TUploadData_QingDao);
  Goo.Reg.FirstRunClass := 'TUploadData_QingDao';
  var ini := TIniFile.Create(Goo.SystemDataPath+'\Config_SPDA_QingDao.ini');
  try
    Goo.ComVar.Add('@YB_QingDao_PosID',ini.ReadInteger('Config','PosID',0));
  finally
    ini.Free;
  end;

end.
