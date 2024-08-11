if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GP_QingDao_GetRetailBill]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[GP_QingDao_GetRetailBill]
GO
CREATE PROCEDURE GP_QingDao_GetRetailBill
(
	@BillID INT=0,
	@Ord	 INT=0
)
AS
SELECT  
	p.SS_DM AS med_list_codg,		--	ҽ��Ŀ¼����	ANS	50	Y	ҩƷ�Ĺ����
	p.FullName AS med_list_name,	--	ҽ��Ŀ¼����	ANS	200	Y	ҩƷ������
	CAST(mx.Qty AS NUMERIC(16,4)) AS cnt,		--cnt	����	AN	16,4	Y	
	mx.DiscountPrice AS pric,--pric	����	AN	16,6	Y	
	mx.DiscountTotal AS amt,--amt	���	AN	16,6	Y	=����*����
	mx.JobNumber AS manu_lotnum, --manu_lotnum	��������	ANS	30	Y	
	CONVERT(VARCHAR(10),mx.OutFactoryDate,120) AS manu_date, --	��������	������		Y	yyyy-MM-dd
	CONVERT(VARCHAR(10),mx.validityPeriod,120) AS expy_end,	--	��Ч��ֹ	������			yyyy-MM-dd
	cast(CASE when p.RX  IN(2,3) then 0 else 1 end AS VARCHAR(3)) rx_flag ,--rx_flag	����ҩ��־	ANS	3	Y	
	cast(CASE when mx.Unit=101 then 1 else 0 end AS VARCHAR(3)) trdn_flag ,--trdn_flag	�����־	ANS	3	Y	0-��1-��
	mx.DiscountPrice AS finl_trns_pric,--finl_trns_pric	���ճɽ�����	AN	16,6		
	rx.BillCode AS rxno,--	������	ANS	40		
	CAST('' AS VARCHAR(2)) rx_circ_flag ,--rx_circ_flag	�⹺������־	ANS	3		
	idx.BillCode AS rtal_docno,--	���۵��ݺ�	ANS	40	Y	
	CAST('' AS VARCHAR(2)) stoout_no,--stoout_no	���۳��ⵥ�ݺ�	ANS	40		
	CAST('' AS VARCHAR(2)) bchno,--bchno	���κ�	ANS	30		
	CAST('' AS VARCHAR(2)) drug_trac_codg,--drug_trac_codg	ҩƷ׷����	ANS	30		
	p.barcode drug_prod_barc,--drug_prod_barc	ҩƷ������	ANS	30		
	CAST('' AS VARCHAR(2))shelf_posi,--shelf_posi	����λ	ANS	20		
	CAST('' AS VARCHAR(2)) AS used_frqu_dscr,--sin_dos_dscr	���μ�������	ANS	200		
	CAST('' AS VARCHAR(2)) AS used_frqu_dscr,--used_frqu_dscr	ʹ��Ƶ������	ANS	200		
	rx.Days AS prd_days,--prd_days	��������	AN	4,2		
	CAST('' AS VARCHAR(2)) AS medc_way_dscr,--medc_way_dscr	��ҩ;������	ANS	200		
	CAST('' AS VARCHAR(2)) AS tcmdrug_used_way--tcmdrug_used_way	��ҩʹ�÷�ʽ	ANS	6	Y	
FROM dbo.vRetailBillIndex idx WITH(NOLOCK) INNER JOIN dbo.vRetailBill mx WITH(NOLOCK) ON mx.BillID = idx.BillID
	INNER JOIN dbo.ptype p ON p.Rec=mx.PRec AND p.SS_DM<>''
	LEFT JOIN dbo.ROtherBillIndex rx ON rx.BillID=mx.RxBillId
WHERE idx.BillID=@BillID AND mx.Ord=@Ord
GO
