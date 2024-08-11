if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GP_QingDao_GetInoutStockBill]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[GP_QingDao_GetInoutStockBill]
GO
CREATE PROCEDURE GP_QingDao_GetInoutStockBill
(
	@KRec	ctInt=0,
	@PRec	ctInt=0,
	@BillType	ctShortStr='',
	@BgnDate	ctDate=NULL,
	@EndDate	ctDate=NULL
)
AS
	SELECT i.BillID,s.ord,i.BillType,s.BillDate,s.PRec,
		p.SS_DM AS med_list_codg,	--ҽ��Ŀ¼����	ANS	50	Y	
		p.UserCode AS fixmedins_hilist_id,	--����ҽҩ����Ŀ¼���	ANS	30	Y	
		p.FullName AS fixmedins_hilist_name,--	����ҽҩ����Ŀ¼����	ANS	200	Y	
		i.BillCode AS dynt_no,	--	�������	ANS	50		
		CONVERT(VARCHAR(10),i.BillDate,112)+CAST(i.BillID AS VARCHAR(10))+CAST(s.ord AS VARCHAR(10))	AS fixmedins_bchno,		--	����ҽҩ����������ˮ��	ANS	30	Y	
		b.FullName AS spler_name,--	��Ӧ������	ANS	200	Y	
		b.AdmitLicenceNO spler_pmtno,--spler_pmtno	��Ӧ�����֤��	ANS	50		
		CASE WHEN ISNULL(s.jobnumber,'') = '' THEN '��' ELSE s.jobnumber END  manu_lotnum,--manu_lotnum	��������	ANS	30	Y	
		cs.fullname prodentp_name ,--prodentp_name	������������	ANS	200	Y	
		CASE WHEN ISNULL(p.permitno,'') = '' THEN '��' ELSE p.permitno END aprvno 	,--aprvno	��׼�ĺ�	ANS	100	Y	
		CONVERT(VARCHAR(10),s.OutFactoryDate,120) AS manu_date,	--	��������	������		Y	yyyy-MM-dd
		CONVERT(VARCHAR(10),s.ValidityPeriod,120) AS expy_end,			--expy_end	��Ч��ֹ	������		Y	yyyy-MM-dd
		cast(s.taxprice as numeric(18,6)) finl_trns_pric,--finl_trns_pric	���ճɽ�����	AN	16,6		
		s.qty purc_retn_cnt ,--purc_retn_cnt	�ɹ�/�˻�����	AN	16,4	Y	
		CAST('' AS VARCHAR(2))purc_invo_codg,--purc_invo_codg	�ɹ���Ʊ����	ANS	50		
		CAST('' AS VARCHAR(2))purc_invo_no ,--purc_invo_no	�ɹ���Ʊ��	ANS	50		
		cast(CASE when p.RX  IN(2,3) then 0 else 1 end AS VARCHAR(3)) rx_flag ,--	����ҩ��־ 
		CONVERT(VARCHAR(20),i.auditingdate,120) AS purc_retn_stoin_time, --purc_retn_stoin_time	�ɹ�/�˻����ʱ��	����ʱ����		Y	yyyy-MM-dd HH:mm:ss
		e.FullName AS purc_Retn_opter_name,--	�ɹ�/�˻�����������	ANS	50	Y	
		CAST('0' AS VARCHAR(2))prod_geay_flag,--prod_geay_flag	��Ʒ���ͱ�־	ANS	3		0-��1-��
		CAST('' AS VARCHAR(2)) memo,--memo	��ע	ANS	500		*/
		CAST('' AS VARCHAR(10)) medins_prod_purc_no	--�˻�����ԭ�����
	FROM dbo.vBillIndex_Query i INNER JOIN dbo.vInOutStockTable s ON s.BillID = i.BillID
		INNER JOIN dbo.GetBillTypeTable(@BillType) t ON i.BillType=t.ObjectID
		INNER JOIN dbo.ptype p ON s.PRec=p.Rec AND p.SS_DM<>''
		LEFT JOIN  cstype cs on p.area=cs.rec
		INNER JOIN dbo.vBType b ON s.ProviderId=b.Rec
		INNER JOIN employee e on e.rec=i.erec
        
	WHERE (@BgnDate IS NULL OR @EndDate IS NULL OR i.BillDate BETWEEN @BgnDate AND @EndDate)
	AND (@BgnDate IS NULL OR @EndDate IS NULL OR s.BillDate BETWEEN @BgnDate AND @EndDate)
	AND (@KRec=0 OR i.KRec=@KRec)
	AND (@PRec=0 OR s.PRec=@PRec)
	AND NOT EXISTS(SELECT * FROM YB_BusinessLink yb WHERE yb.BillID=i.BillID AND yb.Ord=s.ord)
GO
