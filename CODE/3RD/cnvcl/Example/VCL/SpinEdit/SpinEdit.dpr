program SpinEdit;

uses
  Forms,
  SpinEditUnit in 'SpinEditUnit.pas' {FormSpin},
  CnSpin in '..\..\..\Source\Graphics\CnSpin.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFormSpin, FormSpin);
  Application.Run;
end.
