if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GP_QingHai_GetOutStockBill]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[GP_QingHai_GetOutStockBill]
GO
CREATE PROCEDURE GP_QingHai_GetOutStockBill
(
	@BgnDate	ctDate,
	@EndDate	ctDate,
	@BillType	ctComment=''
)
AS
DECLARE @SelfUnitRec	ctInt,@SelfUnitName	ctName
SELECT @SelfUnitRec = CAST(SubValue AS INT) FROM dbo.sysdata WHERE SubName = 'SelfUnitRec' AND ISNUMERIC(SubValue)=1
SELECT @SelfUnitName=FullName FROM dbo.btype WHERE Rec=@SelfUnitRec
IF @BillType IS NULL SET @BillType='151,152,11,34'
SELECT	i.BillID,o.ord,YZMC = b.FullName,		--ҵ������  Y �ຣʡ��ҩ�����޹�˾
	KPSJ = CONVERT(VARCHAR(10),i.BillDate,120),	--��Ʊʱ��
	YWDJBH = i.BillCode,		--ҵ�񵥾ݱ��
	CFDBH	   = i.BillCode,		--��ֵ����
	FPDBH		= i.BillCode,		--���䵥��� 
	DDLX		= '����',					--�������� 
	DJXFSJ		=  CONVERT(VARCHAR(10),i.BillDate,120),	--�����·�ʱ�� 
	JSSJ			=	CONVERT(VARCHAR(10),i.AuditingDate,120),	--����ʱ�� 
	DWBH		= b.UserCode,			--��λ��� 
	DWMC		= b.FullName,			--��λ���� 
	EJDWMC	= b.FullName,			--������λ���� 
	EJDWBH	=b.UserCode,			--������λ��� 
	ZGSYWZGBM	= '',					--�ӹ�˾ҵ�����ܲ��� 
	SPJTZGBM		= '',					--��Ʒ�������ܲ���  
	KHYWLB	= '',		--�ͻ�ҵ����� 
	SPMC   = p.FullName,		--��Ʒ����  string Y ��Ī���� 
	SPBM	= p.UserCode,		--��Ʒ����  string Y ��ҩ202402020000001
	TYMC	= p.Name,			--ͨ������  string Y ��Ī���� 
	SPLX		=	p.Type,				--����  string Y �ڷ�
	SPGG	=	p.Standard,		--��Ʒ��� SPGG string Y �� 
	BZDW	= p.Unit1,	--��װ��λ  string Y ��
	BZSL		= o.Qty,	--��װ���� BZSL string Y 2000 
	SJSL		= o.Qty,	--ʵ������ ZJS string Y 100 
	JE			= o.TaxTotal,	--���
	KB		= '',	--��� 
	KFBH	= k.FullName,	--�ⷿ��� 
	QYBH	= '',					--������ 
	XSHW	= g.fullname,	--��ʾ��λ 
	CLJHY	= '',					--������Ա 
	CLSQSJ='',					--������ȡʱ�� 
	CLQRSJ='',					--����ȷ��ʱ�� 
	NFHY	='',					--�ڸ���Ա 
	NFHSQSJ='',				--�ڸ�����ȡʱ�� 
	NFHQRSJ='',				--�ڸ���ȷ��ʱ�� 
	PXH	='',						--ƴ��� 
	ZZXBH='',					--��ת���� 
	ZJJHY='',						--�������Ա 
	ZJSQSJ='',					--������ȡʱ�� 
	ZJQRSJ='',					--����ȷ��ʱ�� 
	TPTM='',						--�������� 
	WFHY='',						--�⸴��Ա 
	WFHSQSJ='',				--�⸴����ȡʱ��  datetime Y 2024 �� 05 �� 05�� 
	WFHQRSJ='',				--�⸴��ȷ��ʱ��  datetime Y 2024 �� 05 �� 05��
	YWLX='',	--ҵ������  string Y 
	ZYLB='',	--��ҵ���  string Y 
	ZYFS ='',	--��ҵ��ʽ string Y 
	XSLX='',	--��������  string Y ���� 
	THFS='',	--�����ʽ  string Y ��ȡ
	FHTZCWBH='',		--����̨�ݴ�λ��� 
	ZCQZZH='',			--�ݴ�����ֹ��
	ZHSJJS=o.Qty,		--�ۺ�ʵ�ʼ��� 
	JHSL=o.Qty,			--�ƻ����� 
	JHLSS=0,				--�ƻ���ɢ�� 
	TJJHZT='',			--��ǰ���״̬ 
	BHIDH='',				--���� ID �� 
	JXLBH='',				--��ѡ����� 
	DHBH='',				--���б�� 
	SCQY=cs.FullName,		--������ҵ 
	DDY='',						--����Ա 
	BZ	= i.Comment,		--��ע 
	TMLSH=p.BarCode,		--������ˮ�� 
	ZLSCSJ='',					--ָ������ʱ�� 
	LCPBS='',						--���Ʒ��ʶ 
	ZTH='',							--վ̨�� 
	TMS='',						--��Ŀ�� 
	ZHJHJS='',					--�ۺϼƻ����� 
	YZBH='',						--ҵ����� 
	ZCQQSH='',					--�ݴ�����ʼ�� 
	RWZT='',						--����״̬ 
	SCRQ=o.OutFactoryDate,		--�������� 
	YXQZ=o.ValidityPeriod,			--��Ч���� 
	YWY=e.FullName,					--ҵ��Ա 
	DJ=o.TaxPrice,								--���� 
	PZWH=p.PermitNo,				--��׼�ĺ� 	
	SJID     = CONVERT(VARCHAR(10),i.BillDate,112)+'_'+CAST(o.BillID AS VARCHAR(10))+'_'+CAST(o.ord AS VARCHAR(10)),	--�¼� ID
	SJLY		=	ISNULL(@SelfUnitName,''),	--������Դ
	SJTSSJ = CONVERT(VARCHAR(10),GETDATE(),120),	--��������ʱ��
	SJLX		= 'I',	--�¼�����:I��������������U�������޸ģ���D������ɾ����
	SSJDGLJ = '�ຣʡҩƷ�ල�����'	--�����ල�����
FROM dbo.vInOutStockTable o INNER JOIN dbo.vBillIndex_Query i ON i.BillID = o.BillID
	INNER JOIN dbo.btype b ON i.BRec=b.Rec
	INNER JOIN dbo.ptype p ON o.PRec=p.Rec
	INNER JOIN dbo.Stock k ON i.KRec=k.Rec LEFT JOIN dbo.klocation g ON o.GRec=g.Rec
	LEFT JOIN dbo.cstype cs ON p.Area=cs.Rec
	LEFT JOIN dbo.cstype cl ON p.LicenseHolder=cl.Rec
	INNER JOIN dbo.employee e ON e.REC=i.ERec
	INNER JOIN dbo.employee ec ON i.checke=ec.REC
	INNER JOIN dbo.GetBillTypeTable(@BillType) t ON i.BillType=t.ObjectID
WHERE i.BillDate BETWEEN @BgnDate AND @EndDate
AND o.BillDate BETWEEN @BgnDate AND @EndDate
AND NOT EXISTS(SELECT * FROM QingHai_UploadBillRecord r WHERE r.BillID=o.BillID AND r.Ord=o.ord)
GO
