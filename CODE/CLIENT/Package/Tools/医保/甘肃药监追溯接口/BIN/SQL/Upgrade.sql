if NOT EXISTS(select * from sysobjects where name='SPDA_PosSet')
CREATE TABLE SPDA_PosSet	--�ֵ���Ϣ��
(
	PosID	INT,
	StoreName		ctName,
	StoreCode		ctShortStr,			--�˺�
	Password			ctComment,			--����
	AppKey			ctComment			--��Ȩ��
)
GO

if NOT EXISTS(select * from sysobjects where name='SPDA_TransBillRecord')
CREATE TABLE SPDA_TransBillRecord	--�ֵ���Ϣ��
(
	BillID	ctInt,
	Ord		ctInt	PRIMARY KEY(BillID,Ord),
	DoDate	DATETIME,
	out_code		INT ,
	out_msg		ctComment,
	out_data		VARCHAR(1000),
	TIME	int
)
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GP_SPDA_QueryBill]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].GP_SPDA_QueryBill
GO

CREATE PROC GP_SPDA_QueryBill
(
	@PosID	ctInt=0,
	@BgnDate	ctDate,
	@EndDate	ctDate,
	@Day INT=0
)
AS
SET @Day=ISNULL(@Day,0)
SELECT drugType= CASE WHEN p.RX=1 THEN 'YB' WHEN dbo.GetBitValue(p.Flags,23)=1 THEN 'YC' ELSE 'YD' END,	--ҩƷ����(YB����ҩ,YC����Ƽ�,YD���龫)
	drugName=p.FullName,
	quantity	= b.Qty,
	purchaserName = i.BuyerName,	--'��ҩ��'
	purchaserld	= buyer.BuyerNo, --���֤
	purchaserPhone=buyer.Phone,--�绰
	purchaserResidence=buyer.Adress,--סַ
	drugstoreName=pos.StoreName,--ҩ������
	pos.AppKey,pos.Password,b.billid,b.ord,i.BillCode,
	drugstoreTyshxydm=pos.StoreCode,--���ͳһ���ô���
	saleTime=i.BillDate,
	approvalNo=p.PermitNo,
	dataSource='1'				--������Դ��1 ERPϵͳ�Խӣ�2�������ɼ���3����)
FROM dbo.vRetailBillIndex i INNER JOIN dbo.vRetailBill b ON b.BillID = i.BillID
	INNER JOIN dbo.ptype p ON b.PRec=p.Rec
	INNER JOIN dbo.RetailBuyer buyer ON buyer.BillID = i.BillID AND buyer.RetailType=0
	INNER JOIN SPDA_PosSet pos ON i.Posid=pos.PosID
WHERE (@Day>0 OR i.BillDate BETWEEN @BgnDate AND @EndDate+1)
AND (@Day=0 OR DATEDIFF(DAY,BillDate,GETDATE())<@Day)
AND (@PosID=0 OR i.Posid=@PosID)
AND NOT EXISTS(SELECT * FROM SPDA_TransBillRecord r WHERE r.BillID=i.BillID AND r.Ord=b.ord)
ORDER BY i.BillDate,b.BillID
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GP_SPDA_SavePosInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].GP_SPDA_SavePosInfo
GO
CREATE PROC GP_SPDA_SavePosInfo
(
	@PosID	INT,
	@StoreName		ctName,
	@StoreCode		ctShortStr,			--�˺�
	@Password			ctComment,			--����
	@AppKey			ctComment			--��Ȩ��
)
AS
IF EXISTS(SELECT * FROM SPDA_PosSet WHERE PosID=@PosID)
	UPDATE SPDA_PosSet SET StoreName=@StoreName,StoreCode=@StoreCode,Password=@Password,AppKey=@AppKey WHERE PosID=@PosID
ELSE
	INSERT INTO dbo.SPDA_PosSet(PosID,StoreName,StoreCode,Password,AppKey)
	VALUES	( @PosID,@StoreName,@StoreCode,@Password,@AppKey)

GO
