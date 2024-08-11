if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GP_QingDao_GetGoodsStockChange]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[GP_QingDao_GetGoodsStockChange]
GO
CREATE PROCEDURE GP_QingDao_GetGoodsStockChange
(
	@KRec	ctInt=0,
	@PRec	ctInt=0,
	@BillType	ctShortStr='',
	@BgnDate	ctDate=NULL,
	@EndDate	ctDate=NULL
)
AS
SELECT p.SS_DM AS med_list_codg,--med_list_codg	ҽ��Ŀ¼����	ANS	50	Y	
	t.billName AS inv_chg_type,--inv_chg_type	���������	ANS	6	Y	
	p.UserCode AS fixmedins_hilist_id,--fixmedins_hilist_id	����ҽҩ����Ŀ¼���	ANS	30	Y	
	p.FullName AS fixmedins_hilist_name,--fixmedins_hilist_name	����ҽҩ����Ŀ¼����	ANS	200	Y	
	CONVERT(VARCHAR(10),s.BillDate,112)+CAST(s.BillID AS VARCHAR(10))+CAST(s.ord AS VARCHAR(10)) fixmedins_bchno,--fixmedins_bchno	����ҽҩ����������ˮ��	ANS	30	Y	
	s.Price AS pric,--pric	����	AN	16,6	Y	
	s.Qty AS cnt,--cnt	����	AN	16,4	Y	����С�Ƽ۰�װ��λ
	CAST(p.RX AS VARCHAR(10))	rx_flag,--rx_flag	����ҩ��־	ANS	3	Y	
	CONVERT(VARCHAR(20),i.auditingdate,120) AS inv_chg_time,--inv_chg_time	�����ʱ��	����ʱ����		Y	yyyy-MM-dd HH:mm:ss
	e.FullName AS inv_chg_opter_name,--inv_chg_opter_name	���������������	ANS	50		
	CAST('' AS VARCHAR(6)) AS memo,--memo	��ע	ANS	500		
	CAST('0' AS VARCHAR(2)) AS trdn_flag,--trdn_flag	�����־	ANS	2		
	s.BillID,s.ord
FROM dbo.vInOutStockTable s WITH(NOLOCK) INNER JOIN dbo.vBillIndex_Query i WITH(NOLOCK) ON i.BillID = s.BillID 
	INNER JOIN dbo.ptype p ON s.PRec=p.Rec
	INNER JOIN dbo.BillType t ON t.billtype = s.BillType
	LEFT JOIN dbo.Employee e ON i.ERec=e.REC
WHERE (@KRec=0 OR s.KRec=@KRec)
AND (@PRec=0 OR PRec=@PRec)
AND p.SS_DM<>''
AND (@BgnDate IS NULL OR @EndDate IS NULL OR i.BillDate BETWEEN @BgnDate AND @EndDate)
AND (@BgnDate IS NULL OR @EndDate IS NULL OR s.BillDate BETWEEN @BgnDate AND @EndDate)
AND NOT EXISTS(SELECT * FROM dbo.YB_GoodsStockChange yb WHERE s.BillID=yb.BillID AND s.ord=yb.BillID)

GO
