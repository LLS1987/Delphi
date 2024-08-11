

IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='YBLSNo_CQ' AND XTYPE='U')
CREATE TABLE YBLSNo_CQ
(
  YbLSNo int not null default 0
)
GO

--- ����������ϴ��ɹ�/���۵��м��
IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='YB_BusinessLink' AND XTYPE='U')
CREATE TABLE [dbo].YB_BusinessLink 
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	UniqueBillid UNIQUEIDENTIFIER NOT NULL, --����UniqueBillid
	BillType INT NOT NULL ,--��������
	Flag INT NOT NULL DEFAULT 0,--�Ƿ��ϴ��ɹ� 1 = �ɹ���0 = ʧ��  ,2 = ����3507��ɾ��
	trandate datetime not null default getdate()
) 
GO
if exists(select * from sysindexes where name='IX_YB_BusinessLink_UniqueBillid' and id = object_id(N'[dbo].[YB_BusinessLink]'))
DROP INDEX YB_BusinessLink.IX_YB_BusinessLink_UniqueBillid
GO

if not exists(select * from syscolumns where id=object_id('YB_BusinessLink') and name='BillID')
begin
  alter table YB_BusinessLink add BillID INT 
end
GO
UPDATE YB_BusinessLink SET BillID = 0 WHERE BillID IS NULL 
GO 
if not exists(select * from syscolumns where id=object_id('YB_BusinessLink') and name='Ord')
begin
  alter table YB_BusinessLink add Ord INT 
end
GO
UPDATE YB_BusinessLink SET Ord = 0 WHERE Ord IS NULL 
GO 


if not exists(select * from syscolumns where id=object_id('YB_BusinessLink') and name='BillDate')
begin
  ALTER table YB_BusinessLink add BillDate DATETIME
end
GO

if NOT EXISTS(select * from sysindexes where name='IX_YB_BusinessLink_Billidord' and id = object_id(N'[dbo].[YB_BusinessLink]'))
 CREATE INDEX IX_YB_BusinessLink_Billidord ON [dbo].YB_BusinessLink(BillID,Ord) 
GO
if NOT EXISTS(select * from sysindexes where name='IX_YB_BusinessLink_Billtype' and id = object_id(N'[dbo].[YB_BusinessLink]'))
 CREATE INDEX IX_YB_BusinessLink_Billtype ON [dbo].YB_BusinessLink(BillType) 
GO
if NOT EXISTS(select * from sysindexes where name='IX_YB_BusinessLink_BillDate' and id = object_id(N'[dbo].[YB_BusinessLink]'))
 CREATE INDEX IX_YB_BusinessLink_BillDate ON [dbo].YB_BusinessLink(BillDate) 
GO

UPDATE a
  SET  billdate=b.BillDate
FROM  YB_BusinessLink a INNER JOIN dbo.vBillIndex_Query b ON  b.BillID = a.BillID AND b.BillType = a.BillType
WHERE  a.billdate IS NULL
GO
UPDATE a
  SET  billdate=b.BillDate
FROM  YB_BusinessLink a INNER JOIN dbo.vRetailBillIndex b ON  b.BillID = a.BillID AND b.BillType = a.BillType
WHERE  a.billdate IS NULL
GO


if not exists(select * from syscolumns where id=object_id('YB_BusinessLink') and name='fixmedins_bchno')
begin
  ALTER table YB_BusinessLink add fixmedins_bchno VARCHAR(100) DEFAULT ''
end
GO
UPDATE a
  SET  fixmedins_bchno=CONVERT(VARCHAR(10),a.BillDate,112)+CAST(a.BillID AS VARCHAR(10))+CAST(a.ord AS VARCHAR(10))
FROM  YB_BusinessLink a 
WHERE  a.fixmedins_bchno IS NULL
GO
if NOT EXISTS(select * from sysindexes where name='IX_YB_BusinessLink_fixmedins_bchno' and id = object_id(N'[dbo].[YB_BusinessLink]'))
 CREATE INDEX IX_YB_BusinessLink_fixmedins_bchno ON [dbo].YB_BusinessLink(fixmedins_bchno) 
GO

if not exists(select * from syscolumns where id=object_id('YB_BusinessLink') and name='Krec')
begin
  ALTER table YB_BusinessLink add Krec INT DEFAULT 0 
end
GO
UPDATE a
  SET  Krec=i.KRec
FROM  YB_BusinessLink a  INNER JOIN dbo.vInOutStockTable i ON  i.BillID = a.BillID AND i.ord = a.Ord
WHERE  a.Krec IS NULL AND a.BillType not IN (151,152)
GO
UPDATE a
  SET  Krec=i.KRec
FROM  YB_BusinessLink a  INNER JOIN dbo.vRetailBill i ON  i.BillID = a.BillID AND i.ord = a.Ord
WHERE  a.Krec IS NULL AND a.BillType  IN (151,152)
GO
if NOT EXISTS(select * from sysindexes where name='IX_YB_BusinessLink_Krec' and id = object_id(N'[dbo].[YB_BusinessLink]'))
 CREATE INDEX IX_YB_BusinessLink_Krec ON [dbo].YB_BusinessLink(Krec) 
GO

--��������������ϴ����䶯���м��
IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='YB_Other_BusinessLink' AND XTYPE='U')
CREATE TABLE [dbo].YB_Other_BusinessLink 
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	UniqueBillid UNIQUEIDENTIFIER NOT NULL, --����UniqueBillid
	BillType INT NOT NULL ,--��������
	Flag INT NOT NULL DEFAULT 0,--�Ƿ��ϴ��ɹ� 1 = �ɹ���0 = ʧ��  ,2 = ����3507��ɾ��
	trandate datetime not null default getdate(),
	BillId INT  NOT NULL DEFAULT 0,
	Ord INT  NOT NULL DEFAULT 0	
) 
GO
if exists(select * from sysindexes where name='IX_YB_Other_BusinessLink_UniqueBillid' and id = object_id(N'[dbo].[YB_Other_BusinessLink]'))
DROP INDEX YB_Other_BusinessLink.IX_YB_Other_BusinessLink_UniqueBillid
GO

if exists(select * from sysindexes where name='IX_YB_Other_BusinessLink_UniqueBillidord' and id = object_id(N'[dbo].[YB_Other_BusinessLink]'))
DROP INDEX YB_Other_BusinessLink.IX_YB_Other_BusinessLink_UniqueBillidord
GO

if not exists(select * from syscolumns where id=object_id('YB_Other_BusinessLink') and name='BillDate')
begin
  ALTER table YB_Other_BusinessLink add BillDate DATETIME
end
GO

if NOT EXISTS(select * from sysindexes where name='IX_YB_Other_BusinessLink_Billidord' and id = object_id(N'[dbo].[YB_Other_BusinessLink]'))
 CREATE INDEX IX_YB_Other_BusinessLink_Billidord ON [dbo].YB_Other_BusinessLink(BillID,Ord) 
GO
if NOT EXISTS(select * from sysindexes where name='IX_YB_Other_BusinessLink_Billtype' and id = object_id(N'[dbo].[YB_Other_BusinessLink]'))
 CREATE INDEX IX_YB_Other_BusinessLink_Billtype ON [dbo].YB_Other_BusinessLink(BillType) 
GO
if NOT EXISTS(select * from sysindexes where name='IX_YB_Other_BusinessLink_BillDate' and id = object_id(N'[dbo].[YB_Other_BusinessLink]'))
 CREATE INDEX IX_YB_Other_BusinessLink_BillDate ON [dbo].YB_Other_BusinessLink(BillDate) 
GO

UPDATE a
  SET  billdate=b.BillDate
FROM  YB_Other_BusinessLink a INNER JOIN dbo.vBillIndex_Query b ON  b.BillID = a.BillID AND b.BillType = a.BillType
WHERE  a.billdate IS NULL
GO
UPDATE a
  SET  billdate=b.BillDate
FROM  YB_Other_BusinessLink a INNER JOIN dbo.vRetailBillIndex b ON  b.BillID = a.BillID AND b.BillType = a.BillType
WHERE  a.billdate IS NULL
GO

if not exists(select * from syscolumns where id=object_id('YB_Other_BusinessLink') and name='fixmedins_bchno')
begin
  ALTER table YB_Other_BusinessLink add fixmedins_bchno VARCHAR(100) DEFAULT ''
end
GO
UPDATE a
  SET  fixmedins_bchno=CONVERT(VARCHAR(10),a.BillDate,112)+CAST(a.BillID AS VARCHAR(10))+CAST(a.ord AS VARCHAR(10))
FROM  YB_Other_BusinessLink a 
WHERE  a.fixmedins_bchno IS NULL
GO
if NOT EXISTS(select * from sysindexes where name='IX_YB_Other_BusinessLink_fixmedins_bchno' and id = object_id(N'[dbo].[YB_Other_BusinessLink]'))
 CREATE INDEX IX_YB_Other_BusinessLink_fixmedins_bchno ON [dbo].YB_Other_BusinessLink(fixmedins_bchno) 
GO

if not exists(select * from syscolumns where id=object_id('YB_Other_BusinessLink') and name='Krec')
begin
  ALTER table YB_Other_BusinessLink add Krec INT DEFAULT 0 
end
GO
UPDATE a
  SET  Krec=i.KRec
FROM  YB_Other_BusinessLink a  INNER JOIN dbo.vInOutStockTable i ON  i.BillID = a.BillID AND i.ord = a.Ord
WHERE  a.Krec IS NULL AND a.BillType not IN (151,152)
GO
UPDATE a
  SET  Krec=i.KRec
FROM  YB_Other_BusinessLink a  INNER JOIN dbo.vRetailBill i ON  i.BillID = a.BillID AND i.ord = a.Ord
WHERE  a.Krec IS NULL AND a.BillType  IN (151,152)
GO
if NOT EXISTS(select * from sysindexes where name='IX_YB_Other_BusinessLink_Krec' and id = object_id(N'[dbo].[YB_Other_BusinessLink]'))
 CREATE INDEX IX_YB_Other_BusinessLink_Krec ON [dbo].YB_Other_BusinessLink(Krec) 
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='YB_GoodsStockChange' AND XTYPE='U')
CREATE TABLE [dbo].YB_GoodsStockChange
(
	BillID	ctInt,
	Ord	ctInt	PRIMARY KEY(BillID,Ord)
)

GO
-- ҽ������һ���ϴ��󣬼�¼ԭʼ�Աȿ������
IF NOT exists(select * from  sysobjects where name='YB_Ori_GoodsStock' and xtype='u')
CREATE TABLE YB_Ori_GoodsStock
(
	PRec CTINT , --��ƷREC
	KRec ctInt , -- �ֿ�REC
	jobNumber ctShortStr, --����
	Qty ctQty, -- �������
	validityPeriod ctDate, -- ��Ч��	
	StockUniqueid ctUID PRIMARY KEY(StockUniqueid),
	fixmedins_bchno VARCHAR(30) ,--����ҽҩ����������ˮ�ţ�StockUniqueid ȥ��-��ȥ��ͷβ������
	Field1 ctShortStr,  -- �ϴ��ɹ���־ 1 =�ɹ���0=δ�ϴ���2=����3507ɾ���ϴ�
	Field2 ctShortStr, --
	Field3 ctShortStr -- 
)
GO

-- ��������
if exists(select *
	from dbo.sysobjects
	where xtype = 'PK'
	and parent_obj = (Select id 
	from dbo.sysobjects where id = OBJECT_ID('YB_Ori_GoodsStock') 
	and OBJECTPROPERTY(id, N'IsUserTable') = 1))
begin
	DECLARE @Name varchar(128)
	select @Name = name
	from dbo.sysobjects
	where xtype = 'PK'
	and parent_obj = (Select id 
	from dbo.sysobjects where id = OBJECT_ID('YB_Ori_GoodsStock') 
	and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	--ɾ������
	exec('alter table YB_Ori_GoodsStock drop constraint ' + @name)
END


if Not exists(select * from dbo.sysindexes where name=N'YB_Ori_GoodsStock_Index' and id=OBJECT_ID(N'[dbo].[YB_Ori_GoodsStock]'))
begin
	create  clustered  index YB_Ori_GoodsStock_Index on YB_Ori_GoodsStock(StockUniqueid,jobNumber,validityPeriod)	
END
GO 
--

----- ��������������ϴ����䶯���м��
IF NOT exists(select * from  sysobjects where name='YB_Other_Ori_GoodsStock' and xtype='u')
CREATE TABLE YB_Other_Ori_GoodsStock
(
	PRec CTINT , --��ƷREC
	KRec ctInt , -- �ֿ�REC
	jobNumber ctShortStr, --����
	Qty ctQty, -- �������
	validityPeriod ctDate, -- ��Ч��	
	StockUniqueid ctUID ,
	fixmedins_bchno VARCHAR(30) ,--����ҽҩ����������ˮ�ţ�StockUniqueid ȥ��-��ȥ��ͷβ������
	Field1 ctShortStr,  -- �ϴ��ɹ���־ 1 =�ɹ���0=δ�ϴ���2=����3507ɾ���ϴ�
	Field2 ctShortStr, --
	Field3 ctShortStr -- 
)
GO

if Not exists(select * from dbo.sysindexes where name=N'YB_Other_Ori_GoodsStock_Index' and id=OBJECT_ID(N'[dbo].[YB_Other_Ori_GoodsStock]'))
begin
	create  clustered  index YB_Other_Ori_GoodsStock_Index on YB_Other_Ori_GoodsStock(StockUniqueid,jobNumber,validityPeriod)	
END
GO 

--�۸�
if not exists(select * from syscolumns where id=object_id('YB_Other_Ori_GoodsStock') and name='Price')
begin
  alter table YB_Other_Ori_GoodsStock add Price  numeric(18, 8) 
end
GO
--������
if not exists(select * from syscolumns where id=object_id('YB_Other_Ori_GoodsStock') and name='trdn_flag')
begin
  alter table YB_Other_Ori_GoodsStock add trdn_flag VARCHAR(2) NOT NULL DEFAULT '0'
end
GO
--������
if not exists(select * from syscolumns where id=object_id('YB_Ori_GoodsStock') and name='trdn_flag')
begin
  alter table YB_Ori_GoodsStock add trdn_flag VARCHAR(2) NOT NULL DEFAULT '0'
end
GO

--��Ϊ50
if  exists(select * from syscolumns where id=object_id('YB_Other_Ori_GoodsStock') and name='fixmedins_bchno')
begin
  alter TABLE YB_Other_Ori_GoodsStock 
  ALTER COLUMN fixmedins_bchno  VARCHAR(100)
end
GO

--��Ϊ50
if  exists(select * from syscolumns where id=object_id('YB_Ori_GoodsStock') and name='fixmedins_bchno')
begin
  alter TABLE YB_Ori_GoodsStock 
  ALTER COLUMN fixmedins_bchno  VARCHAR(100)
end
GO

if not exists(select * from syscolumns where id=object_id('YB_Other_Ori_GoodsStock') and name='OutFactoryDate')
begin
  alter table YB_Other_Ori_GoodsStock add OutFactoryDate DATETIME
end
GO

if Not exists(select * from dbo.sysindexes where name=N'YB_Other_Ori_GoodsStock_Krec_Index' and id=OBJECT_ID(N'[dbo].[YB_Other_Ori_GoodsStock]'))
begin
	create   index YB_Other_Ori_GoodsStock_Krec_Index on YB_Other_Ori_GoodsStock(KRec)	
END
GO 


--ǩ����
IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='YB_Sign' AND XTYPE='U')
CREATE TABLE YB_Sign
(	
  Erec int not null, --��Ա���
  SignNo varchar(100) Not null default '',  --ǩ�����	
  QdDate ctDate, --ǩ������
  QdFlag int not null default 0  -- ǩ����־
  primary key(erec,qddate)
)
GO



if  exists(select * from sysobjects where xtype='p' and name='GP_InsertYBSign')
  DROP PROC GP_InsertYBSign
GO

CREATE PROC GP_InsertYBSign
   @Erec int, --��Ա���
   @SignNo VARCHAR(100), --ǩ�����	
   @QdDate ctDate, --ǩ������
   @QdFlag int --ǩ����־
 
AS

if exists(select * from YB_Sign where Erec=@Erec and QdDate=@QdDate ) DELETE dbo.YB_Sign WHERE Erec=@Erec and QdDate=@QdDate

	  INSERT INTO YB_Sign
	       (Erec,
	        SignNo,
	        QdDate,
	        QdFlag)
	  VALUES(   
			@Erec , --��Ա���
			@SignNo , --ǩ�����	
			@QdDate,  --ǩ������
			@QdFlag)  --ǩ����־
     
GO   
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
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GP_QingDao_GetLSH]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GP_QingDao_GetLSH]
GO
CREATE PROCEDURE GP_QingDao_GetLSH
AS
if not Exists(select 1 from YBLSNo_CQ) 	insert into YBLSNo_CQ(YbLSNo) values(1)	
IF EXISTS(SELECT * FROM YBLSNo_CQ WHERE YbLSNo>9990) UPDATE YBLSNo_CQ SET YbLSNo=1
declare @YbLSNo int

UPDATE YBLSNo_CQ SET @YbLSNo=YbLSNo,YbLSNo=YbLSNo+1 

RETURN @YbLSNo
GO
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
ORDER BY idx.BillDate DESC
GO
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
ORDER BY idx.BillDate DESC	

GO
