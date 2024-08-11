if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GP_QingDao_GetGoodsStock]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[GP_QingDao_GetGoodsStock]
GO
CREATE PROCEDURE GP_QingDao_GetGoodsStock
(
	@KRec	ctInt=0,
	@PRec	ctInt=0
)
AS
SELECT p.SS_DM med_list_codg,	--ҽ��Ŀ¼����	ANS	50	Y	
	p.UserCode	fixmedins_hilist_id,	--����ҽҩ����Ŀ¼���	ANS	30	Y	
	p.FullName	fixmedins_hilist_name,	--����ҽҩ����Ŀ¼����	ANS	200	Y	
	CAST(p.RX AS VARCHAR(10))	rx_flag,	--����ҩ��־	ANS	3	Y	
	CONVERT(VARCHAR(10),GETDATE(),120) invdate,	--�̴�����	������		Y	yyyy-MM-dd
	s.Qty	inv_cnt,	--�������	AN	16,2	Y	����С�Ƽ۰�װ��λͳ��
	s.JobNumber	manu_lotnum,	--��������	ANS	30		
	RIGHT(REPLACE(s.StockUniqueid,'-','')+CAST(s.GoodsId AS VARCHAR(10)),30) fixmedins_bchno,	--����ҽҩ����������ˮ��	ANS	30	Y	ҽҩ�����Զ������κ�
	CONVERT(VARCHAR(10),s.OutFactoryDate,120) manu_date,	--��������	������		Y	yyyy-MM-dd
	CONVERT(VARCHAR(10),s.ValidityPeriod,120) expy_end,	--��Ч��ֹ	������		Y	yyyy-MM-dd
	p.Comment memo	--��ע	ANS	500		
FROM dbo.GoodsStocks s INNER JOIN dbo.ptype p ON s.PRec=p.Rec
WHERE (@KRec=0 OR KRec=@KRec)
AND (@PRec=0 OR PRec=@PRec)
AND p.SS_DM<>''

GO
