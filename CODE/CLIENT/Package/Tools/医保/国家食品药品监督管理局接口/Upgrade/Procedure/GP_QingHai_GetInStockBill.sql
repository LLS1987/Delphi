if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GP_QingHai_GetInStockBill]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[GP_QingHai_GetInStockBill]
GO
CREATE PROCEDURE GP_QingHai_GetInStockBill
(
	@BgnDate	ctDate,
	@EndDate	ctDate,
	@BillType	ctComment=''
)
AS
DECLARE @SelfUnitRec	ctInt,@SelfUnitName	ctName
SELECT @SelfUnitRec = CAST(SubValue AS INT) FROM dbo.sysdata WHERE SubName = 'SelfUnitRec' AND ISNUMERIC(SubValue)=1
SELECT @SelfUnitName=FullName FROM dbo.btype WHERE Rec=@SelfUnitRec

SELECT	i.BillID,o.ord,DHRQ = CONVERT(VARCHAR(10),i.BillDate,120),	--�������� DHRQ datetime Y 2024 �� 05 �� 05�� ����ʾ����2024�� 5 �� 5 ��
	GHDW = b.FullName,		--������λ GHDW string Y �ຣʡ��ҩ�����޹�˾
	SPMC   = p.FullName,		--��Ʒ����  string Y ��Ī���� 
	SPBM	= p.UserCode,		--��Ʒ����  string Y ��ҩ202402020000001
	TYMC	= p.Name,			--ͨ������  string Y ��Ī���� 
	JX			=	p.Type,				--����  string Y �ڷ�
	SPGG	=	p.Standard,		--��Ʒ��� SPGG string Y �� 
	BZDW	= p.Unit1,	--��װ��λ  string Y ��
	RKLX	= '',	--������� RKLX string Y 
	BZSL		= o.Qty,	--��װ���� BZSL string Y 2000 
	ZJS		= o.Qty,	--������ ZJS string Y 100 
	SCQY	= cs.FullName,	--������ҵ SCQY string Y �ຣʡ��ҩ�����޹�˾
	PZWH  = p.PermitNo,
	CPPH	=	o.JobNumber,				--��Ʒ���� 
	SCRQ	= o.OutFactoryDate,		--��������
	YXQZ	= o.ValidityPeriod,			--��Ч����
	ZYCD	=	p.ProArea,					--��ҩ����
	JSYY		= '',									--����ԭ�� 
	ZLZK    = '��',								--����״��
	YSJG		= '�ϸ�',							--���ս��
	YSY		= ec.FullName,				--����Ա 
	YSHGSL = o.Qty,							--���պϸ�����
	CYR		= cl.FullName,					--������/ע����/������
	KHBH	= '',									--�ͻ����
	DJBH	= i.BillCode,						--���ݱ��
	JYJM	= '',									--��Ӫ����
	SJID     = CONVERT(VARCHAR(10),i.BillDate,112)+'_'+CAST(o.BillID AS VARCHAR(10))+'_'+CAST(o.ord AS VARCHAR(10)),	--�¼� ID
	SJLY		=	ISNULL(@SelfUnitName,''),	--������Դ
	SJTSSJ = CONVERT(VARCHAR(10),GETDATE(),120),	--��������ʱ��
	SJLX		= 'I',	--�¼�����:I��������������U�������޸ģ���D������ɾ����
	SSJDGLJ = '�ຣʡҩƷ�ල�����'	--�����ල�����
FROM dbo.vInOutStockTable o INNER JOIN dbo.vBillIndex_Query i ON i.BillID = o.BillID
	INNER JOIN dbo.btype b ON i.BRec=b.Rec
	INNER JOIN dbo.ptype p ON o.PRec=p.Rec
	LEFT JOIN dbo.cstype cs ON p.Area=cs.Rec
	LEFT JOIN dbo.cstype cl ON p.LicenseHolder=cl.Rec
	INNER JOIN dbo.employee ec ON i.checke=ec.REC
	INNER JOIN dbo.GetBillTypeTable(@BillType) t ON i.BillType=t.ObjectID
WHERE i.BillDate BETWEEN @BgnDate AND @EndDate
AND o.BillDate BETWEEN @BgnDate AND @EndDate
AND NOT EXISTS(SELECT * FROM QingHai_UploadBillRecord r WHERE r.BillID=o.BillID AND r.Ord=o.ord)
GO
