if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GP_QingDao_GetRetailBack]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[GP_QingDao_GetRetailBack]
GO
CREATE PROCEDURE GP_QingDao_GetRetailBack
(
	@KRec	ctInt=0,
	@PRec	ctInt=0,
	@BillType	ctShortStr='',
	@BgnDate	ctDate=NULL,
	@EndDate	ctDate=NULL
)
AS
SELECT 
	p.SS_DM AS med_list_codg,--med_list_codg	ҽ��Ŀ¼����	ANS	50	Y	
	p.UserCode AS fixmedins_hilist_id,--fixmedins_hilist_id	����ҽҩ����Ŀ¼���	ANS	30	Y	
	p.FullName AS fixmedins_hilist_name,--fixmedins_hilist_name	����ҽҩ����Ŀ¼����	ANS	200	Y	
	CONVERT(VARCHAR(10),idx.BillDate,112)+CAST(idx.BillID AS VARCHAR(10))+CAST(mx.Ord AS VARCHAR(10))	AS fixmedins_bchno,--fixmedins_bchno	����ҽҩ����������ˮ��	ANS	30	Y	
	CAST('' AS VARCHAR(2)),--setl_id	����ID	ANS	30		
	CAST('' AS VARCHAR(2)),--psn_no	��Ա���	ANS	30		
	CAST('01' AS VARCHAR(2)),--psn_cert_type	��Ա֤������	ANS	6		
	CAST('' AS VARCHAR(2)),--certno	֤������	ANS	50		
	idx.BuyerName,--psn_name	��Ա����	ANS	50		
	mx.JobNumber,--manu_lotnum	��������	ANS	30	Y	
	CONVERT(VARCHAR(10),mx.OutFactoryDate,120),--manu_date	��������	������		Y	yyyy-MM-dd
	CONVERT(VARCHAR(10),mx.validityPeriod,120),--expy_end	��Ч��ֹ	������			yyyy-MM-dd
	cast(CASE when p.RX  IN(2,3) then 0 else 1 end AS VARCHAR(3)) rx_flag,--rx_flag	����ҩ��־	ANS	3	Y	
	cast(CASE when mx.Unit=101 then 1 else 0 end AS VARCHAR(3)) trdn_flag,--trdn_flag	�����־	ANS	3	Y	0-��1-��
	mx.DiscountPrice AS 	finl_trns_pric,--finl_trns_pric	���ճɽ�����	AN	16,6		
	mx.Qty AS sel_retn_cnt,--sel_retn_cnt	����/�˻�����	AN	16,4	Y	
	CONVERT(VARCHAR(20),idx.billdate,120) sel_retn_time ,--sel_retn_time	����/�˻�ʱ��	����ʱ����		Y	yyyy-MM-dd HH:mm:ss
	e.fullname sel_retn_opter_name,--sel_retn_opter_name	����/�˻�����������	ANS	50	Y	
	CAST('' AS VARCHAR(2)) memo,--memo	��ע	ANS	500		
	idx.explain AS medins_prod_sel_no,--medins_prod_sel_no	��Ʒ������ˮ��	ANS	50		
	idx.BillID,mx.Ord
FROM  vRetailBillIndex idx WITH(NOLOCK) INNER JOIN employee e on e.rec=idx.erec
		INNER JOIN dbo.vRetailBill mx WITH(NOLOCK) ON mx.BillID = idx.BillID
		INNER JOIN dbo.ptype p ON mx.PRec=p.Rec AND p.SS_DM<>''
		LEFT JOIN dbo.ROtherBillIndex r ON mx.RxBillId = r.BillID
		LEFT JOIN dbo.Employee e2 ON r.CheckERec = e2.REC				
WHERE idx.draft=0 AND idx.BillType = 152  
	AND  (@BgnDate IS NULL OR @EndDate IS NULL OR idx.BillDate BETWEEN @BgnDate AND @EndDate+1)
	AND NOT EXISTS(SELECT * FROM YB_BusinessLink yb WHERE yb.BillID=idx.BillID AND yb.Ord=mx.Ord AND idx.BillType=yb.BillType)
	AND (@KRec=0 OR @KRec IS NULL OR idx.KRec=@KRec)
	AND (@PRec=0 OR mx.PRec=@PRec)
ORDER BY idx.BillDate DESC
GO