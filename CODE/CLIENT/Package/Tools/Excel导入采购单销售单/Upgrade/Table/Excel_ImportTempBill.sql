if not exists (select * from dbo.sysobjects where id = object_id(N'[Excel_ImportTempBill]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
CREATE TABLE Excel_ImportTempBill
(
	ID	ctInt PRIMARY KEY	IDENTITY(1,1),
	BuyDate	ctBillDate,
	BuyUnit	ctName,			--����	 
	BuyPrice	ctPrice,				--�ɹ����� 	 
	BuyTotal	ctTotal,				--�ɹ���� 
	BuyTax			ctTax,
	BuyTaxPrice	ctPrice,
	BuyTaxTotal	ctTotal,
	BuyComment	ctComment,--����Ʊ����	
	BuyExplain		ctComment,				
	SaleDate	ctBillDate,
	SaleUnit	ctName,			--��������	 
	SalePrice	ctPrice,				--���۵��� 	 
	SaleTotal	ctTotal,				--���۽�� 
	SaleTax			ctTax,
	SaleTaxPrice	ctPrice,
	SaleTaxTotal	ctTotal,
	SaleComment	ctComment,--����Ʊ����	
	SaleExplain		ctComment,						
	PFullName	ctName,			--�����Ӧ˰��������	
	PStandard	ctShortStr,			--����ͺ�	
	PUnit	ctShortStr,			--��λ	
	Qty	ctQty,			--����	
	Jobnumber	ctShortStr,	--����	
	OutFactoryDate	ctDate,--��������	
	ValidityPeriod	ctDate,		--��������		
	----�������ֶ�
	BillDate		DATETIME,
	ERec		ctInt,
	ErrorMessage	ctComment,
	BuyBillID	ctInt,
	SaleBillID	ctInt,
	UniqueBillid	ctUID	--ͬһ�ε��������
)
GO
if not exists (select * from dbo.sysindexes where name = N'IX_Excel_ImportTempBill_UniqueBillid' and id = object_id(N'[dbo].[Excel_ImportTempBill]'))
 CREATE  INDEX [IX_Excel_ImportTempBill_UniqueBillid] ON [dbo].Excel_ImportTempBill(UniqueBillid) 
go
