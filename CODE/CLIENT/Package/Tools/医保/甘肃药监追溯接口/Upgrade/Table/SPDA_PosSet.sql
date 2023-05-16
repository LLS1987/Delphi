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
