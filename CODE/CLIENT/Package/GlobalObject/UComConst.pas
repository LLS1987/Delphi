unit UComConst;

interface

uses
  Winapi.Messages;

type
              //ȫ��,   ������    ���Ͱ�   �ŵ�  ��ѯ    ����     ����     �ռ�   ʵʱ��Ӫ�ŵ�  ������Ӫ��   �������˵�   ʵʱ���˵�
  TLimitVer  =(lvAll,lvWholeSale,lvCenter,lvPos,lvQuery,lvSingle,lvInCome,lvPJB,lvPosRealTime,lvPosSelf,lvPosJoined,lvPosRealJoined);
  TLimitVers = set of TLimitVer;
  TRegisterType = (rmtForm,rmtBill,rmtRepot,rmtMethod,rmtFile,rmtURL);

  //�Զ�����Ϣ
const  REFRESH_FIND_MESSAGE = WM_USER + 100;
       WM_RefreshData = WM_USER + 101;

implementation

end.
