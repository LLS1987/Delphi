program DClient;

uses
  Vcl.Forms,
  UMainClient in 'UMainClient.pas' {MainClient},
  UPackageManage in 'UPackageManage.pas',
  System.SysUtils,
  UAbout in 'UAbout.pas' {About};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'ǧ���ͻ���';
  QFPackage := TPackageManage.Create;
  try
    QFPackage.APPRun;
  finally
     FreeAndNil(QFPackage);
  end;
end.
