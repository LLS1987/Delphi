unit UComConst;

interface

uses
  Winapi.Messages;

type
              //ȫ��,   ������    ���Ͱ�   �ŵ�  ��ѯ    ����     ����     �ռ�   ʵʱ��Ӫ�ŵ�  ������Ӫ��   �������˵�   ʵʱ���˵�
  TLimitVer  =(lvAll,lvWholeSale,lvCenter,lvPos,lvQuery,lvSingle,lvInCome,lvPJB,lvPosRealTime,lvPosSelf,lvPosJoined,lvPosRealJoined);
  TLimitVers = set of TLimitVer;
  ///�˵�������    0       1       2        3         4       5
  TRegisterType = (rmtForm,rmtBill,rmtRepot,rmtMethod,rmtFile,rmtURL);
  //������Ϣ����
  TBasicType = (btNo,btAtype,btPtype,btBtype,btEtype,btKtype,btGtype, btDtype,btRtype,btVchType,btMtype,btNType,btCSType, btLBType,btOtype,btFType);

  //�Զ�����Ϣ
const  REFRESH_FIND_MESSAGE = WM_USER + 100;
       WM_RefreshData = WM_USER + 101;

implementation

end.
