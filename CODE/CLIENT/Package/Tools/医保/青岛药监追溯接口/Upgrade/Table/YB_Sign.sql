

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