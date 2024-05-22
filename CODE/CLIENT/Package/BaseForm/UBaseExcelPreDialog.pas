unit UBaseExcelPreDialog;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UBaseDialogForm, cxStyles, cxClasses,
  System.ImageList, Vcl.ImgList, System.Actions, Vcl.ActnList, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.Grids;

type
  TBaseExcelPreDialog = class(TBaseDialogForm)
    Panel_Button: TPanel;
    Button_OpenFile: TButton;
    Button_CheckData: TButton;
    Button_ImportData: TButton;
    StringGrid1: TStringGrid;
    OpenDialog1: TOpenDialog;
    Button1: TButton;
    pnl_Status: TPanel;
    pnl_Header: TPanel;
    procedure Button_CheckDataClick(Sender: TObject);
    procedure Button_ImportDataClick(Sender: TObject);
    procedure Button_OpenFileClick(Sender: TObject);
    procedure StringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
  private
    { Private declarations }
  protected
    procedure BeforeFormShow; override;
  public
    { Public declarations }
  end;

implementation

uses
  UExcelObject, UComvar, Winapi.ActiveX;

{$R *.dfm}

{ TBaseExcelPreDialog }

procedure TBaseExcelPreDialog.BeforeFormShow;
begin
  inherited;
  Self.Caption := 'Excel Ԥ��:' + TExcelObject(ParamList.AsObject('@InvokeObject')).FileName;
  for var _item in TExcelObject(ParamList.AsObject('@InvokeObject')).ExcelCellCheckList do
    pnl_Header.Caption := pnl_Header.Caption + _item.Key + '*| ';
  CoInitialize(nil);
  try
    TExcelObject(ParamList.AsObject('@InvokeObject')).ReadExcel(StringGrid1);
  finally
    CoUninitialize();
  end;
end;

procedure TBaseExcelPreDialog.Button_CheckDataClick(Sender: TObject);
begin
  inherited;
  TExcelObject(ParamList.AsObject('@InvokeObject')).CheckData(StringGrid1);
  pnl_Status.Caption := TExcelObject(ParamList.AsObject('@InvokeObject')).CheckStatusMessage;
end;

procedure TBaseExcelPreDialog.Button_ImportDataClick(Sender: TObject);
begin
  inherited;
  if not TExcelObject(ParamList.AsObject('@InvokeObject')).CheckData(StringGrid1) then
  begin
    pnl_Status.Caption := TExcelObject(ParamList.AsObject('@InvokeObject')).CheckStatusMessage;
    if not TExcelObject(ParamList.AsObject('@InvokeObject')).IgnoreException then Goo.Msg.ShowErrorAndAbort('����У���쳣��������һ�к�ɫΪ�쳣��Ϣ����');
    if not Goo.Msg.Question('�����쳣���ݣ��Ƿ�����쳣�������룿','') then Exit;
  end;
  if TExcelObject(ParamList.AsObject('@InvokeObject')).ImportExcel(StringGrid1) then ModalResult := mrOk;
end;

procedure TBaseExcelPreDialog.Button_OpenFileClick(Sender: TObject);
begin
  inherited;
  if not OpenDialog1.Execute then Exit;
  Self.Caption := 'Excel Ԥ��:' + OpenDialog1.FileName;
  pnl_Status.Caption := '  ����"���ݵ���"��ť�������쳣������Ϣ���ڱ�����һ�к�ɫ������ʾ��';
  TExcelObject(ParamList.AsObject('@InvokeObject')).FileName := OpenDialog1.FileName;
  TExcelObject(ParamList.AsObject('@InvokeObject')).ReadExcel(StringGrid1);
  StringGrid1.FixedRows := 1;
end;

procedure TBaseExcelPreDialog.StringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
  inherited;
  if (ACol=TExcelObject(ParamList.AsObject('@InvokeObject')).CheckDataColIndex) and (ARow>0) then
  begin
    StringGrid1.Canvas.Font.Color := clred; //������ɫΪ���
    //StringGrid1.Canvas.Brush.color:=clMoneyGreen; //����Ϊ ��Ԫ��ɫ
    StringGrid1.Canvas.FillRect(Rect);
    StringGrid1.Canvas.TextOut(Rect.Left+3,Rect.Top+3,StringGrid1.Cells[ACol,ARow]);
  end;
end;

initialization
  Goo.Reg.RegisterClass(TBaseExcelPreDialog);

end.
