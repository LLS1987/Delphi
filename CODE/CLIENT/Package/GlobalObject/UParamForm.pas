unit UParamForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UParamList, UGlobalInterface;

type
  TParamForm = class(TForm,IBase)
  private
    FParamList: TParamList;
    function GetParamList: TParamList;virtual;
    function GetObject: TObject; virtual;
  protected
    procedure InitParamList; virtual; // ��Ʒ�����ڴ��ڴ���֮ǰ�ȶԲ������д���
    procedure CreateAfter;virtual;    // ���������ִ�У������������FormCreate����ͬЧ��
  public
    constructor Create(AOwner: TComponent; AParam: TParamList); overload;
    destructor Destroy; override;
    property ParamList: TParamList read GetParamList write FParamList;
  end;

TParamFormClass = class of TParamForm;

implementation

{$R *.dfm}

{ TParamForm }

constructor TParamForm.Create(AOwner: TComponent; AParam: TParamList);
begin
  FParamList := TParamList.Create;
  InitParamList;
  if Assigned(AParam) then FParamList.Assign(AParam);
  inherited Create(AOwner); // ��������ʵ�� MDIһ��������ʾ��
  CreateAfter;
end;

procedure TParamForm.CreateAfter;
begin

end;

destructor TParamForm.Destroy;
begin
  if Assigned(FParamList) then FParamList.Free;
  inherited;
end;

function TParamForm.GetObject: TObject;
begin
  Result := nil;
end;

function TParamForm.GetParamList: TParamList;
begin
  if not Assigned(FParamList) then
  begin
    FParamList := TParamList.Create;
    InitParamList;
  end;
  Result := FParamList;
end;

procedure TParamForm.InitParamList;
begin

end;

end.
