if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GP_Excel_InsertTempBill]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].GP_Excel_InsertTempBill
GO
CREATE PROC GP_Excel_InsertTempBill
(
	@BuyDate	ctDate,
	@BuyUnit	ctName,			--����	 
	@BuyPrice	ctPrice,				--�ɹ����� 	 
	@BuyTotal	ctTotal,				--�ɹ���� 
	@BuyTax			ctTax,
	@BuyTaxPrice	ctPrice,
	@BuyTaxTotal	ctTotal,
	@BuyComment	ctComment,--����Ʊ����	
	@BuyExplain		ctComment,				
	@SaleDate	ctDate,
	@SaleUnit	ctName,			--��������	 
	@SalePrice	ctPrice,				--���۵��� 	 
	@SaleTotal	ctTotal,				--���۽�� 
	@SaleTax			ctTax,
	@SaleTaxPrice	ctPrice,
	@SaleTaxTotal	ctTotal,
	@SaleComment	ctComment,--����Ʊ����	
	@SaleExplain		ctComment,						
	@PFullName	ctName,			--�����Ӧ˰��������	
	@PStandard	ctShortStr,			--����ͺ�	
	@PUnit	ctShortStr,			--��λ	
	@Qty	ctQty,			--����	
	@Jobnumber	ctShortStr,	--����	
	@OutFactoryDate	DATETIME,--��������	
	@ValidityPeriod		DATETIME,		--��������		
	----�������ֶ�
	@ERec		ctInt,
	@UniqueBillid	ctUID	--ͬһ�ε��������
)
AS
	SET @OutFactoryDate = NULLIF(@OutFactoryDate,'1899-12-30')
	SET @ValidityPeriod	 = NULLIF(@ValidityPeriod,'1899-12-30')
	--�ɹ�
	SET @BuyTax  = 13
	SET @BuyTaxPrice = @BuyTaxTotal/@Qty
	SET @BuyTotal = @BuyTaxTotal/(100+@BuyTax)*100
	SET @BuyPrice = @BuyTotal/@Qty
	--����
	SET @SaleTax  = 13
	SET @SaleTaxPrice = @SaleTaxTotal/@Qty
	SET @SaleTotal = @SaleTaxTotal/(100+@SaleTax)*100
	SET @SalePrice = @SaleTotal/@Qty
	INSERT INTO dbo.Excel_ImportTempBill(BuyDate,BuyUnit,BuyPrice,BuyTotal,BuyTax,BuyTaxPrice,BuyTaxTotal,BuyComment,BuyExplain,
		SaleDate,SaleUnit,SalePrice,SaleTotal,SaleTax,SaleTaxPrice,SaleTaxTotal,SaleComment,SaleExplain,
		PFullName,PStandard,PUnit,Qty,Jobnumber,OutFactoryDate,ValidityPeriod,
		BillDate,ERec,ErrorMessage,BuyBillID,SaleBillID,UniqueBillid)
	VALUES(@BuyDate,@BuyUnit,@BuyPrice,@BuyTotal,@BuyTax,@BuyTaxPrice,@BuyTaxTotal,@BuyComment,@BuyExplain,
		@SaleDate,@SaleUnit,@SalePrice,@SaleTotal,@SaleTax,@SaleTaxPrice,@SaleTaxTotal,@SaleComment,@SaleExplain,
		@PFullName,@PStandard,@PUnit,@Qty,@Jobnumber,@OutFactoryDate,@ValidityPeriod,
		GETDATE(),@ERec,'',0,0,@UniqueBillid)

GO