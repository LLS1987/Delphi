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