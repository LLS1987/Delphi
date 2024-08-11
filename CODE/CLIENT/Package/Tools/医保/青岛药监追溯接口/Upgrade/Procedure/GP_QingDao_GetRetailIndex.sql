if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GP_QingDao_GetRetailIndex]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[GP_QingDao_GetRetailIndex]
GO
CREATE PROCEDURE GP_QingDao_GetRetailIndex
(
	@KRec	ctInt=0,
	@PRec	ctInt=0,
	@BillType	ctShortStr='',
	@BgnDate	ctDate=NULL,
	@EndDate	ctDate=NULL,
	@BillID int=0
)
AS
DECLARE @DoctorCode	ctShortStr	--ҩʦ���
DECLARE @DoctorNo		ctShortStr	--�ʸ�֤���
DECLARE @DoctorName		ctShortStr	--
SET @EndDate=@EndDate+1

SELECT @DoctorCode=e.DoctorCode,@DoctorNo=e.DoctorNo,@DoctorName=e.FullName
FROM dbo.vemployee e 
WHERE IsContactMedical=1 AND EXISTS(SELECT * FROM dbo.PosInfo p WHERE p.PosId=e.Posid AND (ISNULL(@KRec,0)=0 OR p.KRec=@KRec))

IF @@ROWCOUNT=0 SELECT @DoctorCode=e.DoctorCode,@DoctorNo=e.DoctorNo,@DoctorName=e.FullName FROM dbo.vemployee e WHERE IsContactMedical=1

SELECT idx.BillID,mx.Ord,
	p.SS_DM AS med_list_codg,--med_list_codg	ҽ��Ŀ¼����	ANS	50	Y	
	p.UserCode AS fixmedins_hilist_id,	--fixmedins_hilist_id	����ҽҩ����Ŀ¼���	ANS	30	Y	
	p.FullName AS fixmedins_hilist_name,	--fixmedins_hilist_name	����ҽҩ����Ŀ¼����	ANS	200	Y	
	CONVERT(VARCHAR(10),idx.BillDate,112)+CAST(idx.BillID AS VARCHAR(10)) fixmedins_bchno,	--fixmedins_bchno	����ҽҩ����������ˮ��	ANS	30	Y	
	CAST('' AS VARCHAR(2)) prsc_dr_cert_type, --	����ҽʦ֤������ 
	CAST('' AS VARCHAR(2)) prsc_dr_certno,-- 	����ҽʦ֤������
	ISNULL(r.DoctorName,e.FullName) prsc_dr_name, 	--����ҽʦ���� 
	CAST('' AS VARCHAR(2)) phar_cert_type, 	--ҩʦ֤������	--phar_cert_type	ҩʦ֤������	ANS	6		������Ա֤������
	ISNULL(@DoctorCode,'') phar_certno,	--phar_certno	ҩʦ֤������	ANS	50		
	ISNULL(@DoctorName,'') phar_name, 	--phar_name	ҩʦ����	ANS	50	Y	
	ISNULL(@DoctorNo,'')  phar_prac_cert_no,	--phar_prac_cert_no	ҩʦִҵ�ʸ�֤��	ANS	50	Y	
	CAST('' AS VARCHAR(2)) hi_feesetl_type,	--hi_feesetl_type	ҽ�����ý�������	ANS	6		
	CAST('' AS VARCHAR(2))  setl_id,	--setl_id	����ID	ANS	30		ҽ�����˱���
	ISNULL(r.BillCode,idx.BillCode)  mdtrt_sn,	--mdtrt_sn	��ҽ��ˮ��	ANS	30	Y	����������Ψһ������ˮ
	CAST('' AS VARCHAR(2))  psn_no,	--psn_no	��Ա���	ANS	30		
	'01' AS  psn_cert_type, 	--psn_cert_type	��Ա֤������	ANS	6		
	CAST('' AS VARCHAR(2)) certno ,	--certno	֤������	ANS	50		
	ISNULL(idx.BuyerName,'') psn_name ,	--psn_name	��Ա����	ANS	50		
	mx.JobNumber AS manu_lotnum,	--manu_lotnum	��������	ANS	30	Y	
	CONVERT(VARCHAR(10),mx.OutFactoryDate,120) AS manu_date, --	��������	������		Y	yyyy-MM-dd
	CONVERT(VARCHAR(10),mx.validityPeriod,120) AS expy_end,	--	��Ч��ֹ	������			yyyy-MM-dd
	cast(CASE when p.RX  IN(2,3) then 0 else 1 end AS VARCHAR(3)) rx_flag ,	--rx_flag	����ҩ��־	ANS	3	Y	
	cast(CASE when mx.Unit=101 then 1 else 0 end AS VARCHAR(3)) trdn_flag ,	--trdn_flag	�����־	ANS	3	Y	0-��1-��
	mx.DiscountPrice AS finl_trns_pric,	--finl_trns_pric	���ճɽ�����	AN	16,6		
	ISNULL(r.BillCode,'') AS rxno,	--rxno	������	ANS	40		
	CAST('' AS VARCHAR(2)) rx_circ_flag ,	--rx_circ_flag	�⹺������־	ANS	3		
	idx.BillCode AS rtal_docno,	--rtal_docno	���۵��ݺ�	ANS	40	Y	
	CAST('' AS VARCHAR(2)) stoout_no,	--stoout_no	���۳��ⵥ�ݺ�	ANS	40		
	CAST('' AS VARCHAR(2)) bchno,	--bchno	���κ�	ANS	30		
	CAST('' AS VARCHAR(2)) drug_trac_codg,	--drug_trac_codg	ҩƷ׷����	ANS	30		
	p.barcode drug_prod_barc,	--drug_prod_barc	ҩƷ������	ANS	30		
	CAST('' AS VARCHAR(2))shelf_posi,	--shelf_posi	����λ	ANS	20		
	mx.AssQty AS sel_retn_cnt,	--sel_retn_cnt	����/�˻�����	AN	16,4	Y	
	CONVERT(VARCHAR(20),idx.billdate,120) sel_retn_time ,	--sel_retn_time	����/�˻�ʱ��	����ʱ����		Y	yyyy-MM-dd HH:mm:ss
	e.fullname sel_retn_opter_name,	--sel_retn_opter_name	����/�˻�����������	ANS	50	Y	
	CAST(idx.explain AS VARCHAR(2)) memo	--memo	��ע	ANS	500		
FROM  vRetailBillIndex idx WITH(NOLOCK) INNER JOIN employee e on e.rec=idx.erec
		INNER JOIN dbo.vRetailBill mx WITH(NOLOCK) ON mx.BillID = idx.BillID
		INNER JOIN dbo.ptype p ON p.Rec=mx.PRec AND p.SS_DM<>''
		LEFT JOIN dbo.ROtherBillIndex r ON mx.RxBillId = r.BillID
		LEFT JOIN dbo.Employee e2 ON r.CheckERec = e2.REC				
WHERE idx.draft=0 AND idx.BillType = 151   
				AND (ISNULL(@BillID,0)=0 OR idx.BillID=@billid)
				AND  (@BgnDate IS NULL OR @EndDate IS NULL OR idx.BillDate BETWEEN @BgnDate AND @EndDate)
				AND NOT EXISTS(SELECT * FROM YB_BusinessLink yb WHERE yb.BillID=idx.BillID AND idx.BillType=yb.BillType)
				AND (@KRec=0 OR @KRec IS NULL OR idx.KRec=@KRec)
				AND (@PRec=0 OR mx.PRec=@PRec)
ORDER BY idx.BillDate DESC	

GO
