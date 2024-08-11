


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
