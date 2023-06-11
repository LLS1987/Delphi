{ ******************************************************* }
{                                                         }
{ ��ӡ��������DLL�ӿ�                                     }
{                                                         }
{ �ɶ�����������ɷ����޹�˾                              }
{                                                         }
{ ******************************************************* }
unit crReportIntf;

interface

uses
  SysUtils, DB, Windows, Classes, Controls;

type
  // �ӿڸ�����
  TcrUtils = class
    // ����ˮӡ�����ô�ӡ������ʱ�Ǽ��ܽ��е�
    class procedure SetPrintWatermark(const AValue: string);
    // ���� 'PRINTWATERMARK'�������������exe��û�б�������ݵ�����
    class function GetPrintWatermarkKey: string;
  end;

  // ģ�����ƴ�
  ETemplateNameError = class(Exception);
  // ���ɱ����

  EPrepareError = class(Exception);

  TTemplateStoreType = (tstMDB, tstDBF);

  TRemoteDataFormat = ( // Զ���������ݸ�ʽ
    rdfXML, // XML��ʽ
    rdfZip // ѹ��XML��ʽ
);

  IcrReport = interface;

  IcrTemplateIntf = interface;

  IcrContentIntf = interface;

  IcrPrinterSetup = interface;

  TcrBeforeOutputEvent = procedure(AReportIntf: IcrReport) of object;

  IcrReport = interface
    ['{439E2B5A-479C-419C-88D0-3CA855B301BA}']
    procedure SetOwnerAppHandle(const Value: HWND);
    function GetTemplateStoreType: TTemplateStoreType;
    procedure SetTemplateStoreType(Value: TTemplateStoreType);
    function GetTemplateName: ShortString;
    procedure SetTemplateName(const Value: ShortString);
    function GetMasterData: OleVariant;
    procedure SetMasterData(Value: OleVariant);
    function GetDetailData: OleVariant;
    procedure SetDetailData(Value: OleVariant);
    function GetMasterDataSet: TDataSet;
    procedure SetMasterDataSet(Value: TDataSet);
    function GetDetailDataSet: TDataSet;
    procedure SetDetailDataSet(Value: TDataSet);
    function GetShowPrintDialog: Boolean;
    procedure SetShowPrintDialog(const Value: Boolean);
    function GetPrintedPageCount: Integer;
    function GetLastErrorCode: Integer;
    function GetLastErrorMessage: PChar;
    function GetPrinterSetup: IcrPrinterSetup;
    // ��ӡ
    procedure Print;
    // ��ӡԤ��
    procedure Preview;
    // ���
    procedure Design;
    // ��ʾ��ӡ�Ի���
    procedure Execute;
    // ��ʾ���ڶԻ���
    procedure ShowAboutBox;
    // ���ذ汾��Ϣ
    function VersionInfo: ShortString;
    function GetTemplateStyleIndex: Integer;
    procedure SetTemplateStyleIndex(const Value: Integer);
    function GetTemplateStyleNames: PChar;
    function CreateTemplate: IcrTemplateIntf;
    // SaveTemplate ���ٷ����쳣��ֱ����ʾ���󣬵��ú�Ӧ�����´������
    // if LastErrorCode <> 0 then Abort;
    procedure SaveTemplate(Template: IcrTemplateIntf);

    // ���ļ�װ���ͷ����
    procedure LoadMasterDataFile;
    // ���ļ�װ���������
    procedure LoadDetailDataFile;
    // ����ģ���Ż�ȡ����
    function GetTemplateNameByNumber(const Value: Integer): ShortString;
    // ��������
    procedure ExportData;
    // ����һ���Ѿ����ڵ���TemplateNameָ����ģ�岢������ӿ�
    function GetTemplate: IcrTemplateIntf; overload;
    // ����һ���Ѿ����ڵ�ģ�岢������ӿ�
    function GetTemplate(const TemplateName: string): IcrTemplateIntf; overload;

    // ��������ʵ��
    function CreateContentIntf: IcrContentIntf;
    // ��鵱ǰ�����Ƿ񳬹�һҳ��������ҳ
    procedure CheckContentPage;
    // �������һҳ����ǿ�л�ҳ
    procedure SaveContentPage;
    // ֱ��Ԥ������
    procedure PreviewContent;
    // ֱ�Ӵ�ӡ����
    procedure PrintContent;
    // ��������ʽ����
    procedure CheckUpdateTemplates;
    // ��Զ�̵�ַ������ϸ����
    procedure LoadDetailFromURL(const AURL: PChar; const ADataFormat: TRemoteDataFormat; const ASaveDataToFile: Boolean = False);

    // ����ģ�壩�洢����
    property TemplateStoreType: TTemplateStoreType read GetTemplateStoreType write SetTemplateStoreType;
    // ����ģ�壩���ļ�����
    property TemplateName: ShortString read GetTemplateName write SetTemplateName;
    // ����ģ�壩���ļ�����ǰ��ʽ����
    property TemplateStyleIndex: Integer read GetTemplateStyleIndex write SetTemplateStyleIndex;
    // ����ģ�壩���ļ����е���ʽ���Ÿ����б�
    property TemplateStyleNames: PChar read GetTemplateStyleNames;
    // ��������
    property MasterData: OleVariant read GetMasterData write SetMasterData;
    // ��ϸ����
    property DetailData: OleVariant read GetDetailData write SetDetailData;
    // �������ݼ�����ʱ��û֧��
    property MasterDataSet: TDataSet read GetMasterDataSet write SetMasterDataSet;
    // ��ϸ���ݼ�����ʱ��û֧��
    property DetailDataSet: TDataSet read GetDetailDataSet write SetDetailDataSet;

    // ��ӡʱ�Ƿ���ʾ���öԻ���Ĭ��ΪTrue��ΪFalseʱʹ���ϴ����û���PrinterSetup������
    property ShowPrintDialog: Boolean read GetShowPrintDialog write SetShowPrintDialog;

    // ����Ӧ��Exe�� Application.Handle ����ѡ����
    property OwnerAppHandle: HWND write SetOwnerAppHandle;
    // �Ѵ�ӡҳ����û��ӡʱ����  0
    property PrintedPageCount: Integer read GetPrintedPageCount;
    // �����ϴ�ִ�н��
    property LastErrorCode: Integer read GetLastErrorCode;
    // �����ϴδ�����Ϣ
    property LastErrorMessage: PChar read GetLastErrorMessage;
    // ��ӡ����
    property PrinterSetup: IcrPrinterSetup read GetPrinterSetup;
    function GetOnBeforeOutput: TcrBeforeOutputEvent;
    procedure SetOnBeforeOutput(AValue: TcrBeforeOutputEvent);
    // ���ɱ���ǰ���¼�����
    property OnBeforeOutput: TcrBeforeOutputEvent read GetOnBeforeOutput write SetOnBeforeOutput;

    // ��ʼ��
    procedure Init(AParams: OleVariant);

    // ��Carpa3��������
    procedure LoadDataFromCarpa3(AData: OleVariant; const ADataVersion: Integer; const ASaveDataToFile: Boolean = False);

    // ��������
    procedure ExportDataForOcx;
    // Carpa3ר�ã�������Ŀ¼��
    procedure SetDataDirName(const Value: ShortString);

    // ��Ӳ���������ϸ�ֶ�
    procedure AddNoExportDetailField(const AFieldName: ShortString);
    function GetPrintTimes: Integer;
    function GetExportTimes: Integer;
    // ��ӡ����
    property PrintTimes: Integer read GetPrintTimes;
    // ��������
    property ExportTimes: Integer read GetExportTimes;
    procedure SetPrintTimesLimit(const Value: Integer);
    function BeginBatchPrint: Boolean;
    procedure EndBatchPrint;
    procedure SetAllowExport(const Value: Boolean);
    procedure Invoke(const AMethodName, AParamsData: string);
    // ����ʾ�Ի����ӡ
    procedure PrintWithoutDialog;
    procedure SetAllowPrint(const Value: Boolean);
    procedure SetAllowPreviewEdit(const Value: Boolean);
    procedure SetIsUseServiceCall(const Value: Boolean);
    procedure ClearPageExpands;
    function ExpandPageRow(const ACellText, ACellItems: WideString; AExpandHeader, AExpandDetail, AExpandFooter: WordBool): Integer;
    function ExpandPageHeader(const ACellText: WideString; ACellArray: OleVariant): Integer;
    function ExpandPageDetail(const ACellText: WideString; ACellArray: OleVariant): Integer;
    procedure CreateBaseTemplate;
    procedure SaveBaseTemplate;
    function GetClientInfo(AType: Integer): WideString;
    function GetOrientation: Integer;
    procedure SetOrientation(const Value: Integer);
    // ֽ�ŷ��� 0 ���� 1 ����
    property Orientation: Integer read GetOrientation write SetOrientation;
    function ExpandPageRowEx(const APageIndex: Integer; const ACellText, ACellItems: WideString; AExpandHeader, AExpandDetail, AExpandFooter: WordBool): Integer;
    procedure AddTemplatePage; // ����ģ��ҳ->����ҳ����
    procedure AddTemplateTable;
    procedure AddTemplateRow;
    procedure AddTemplateCell(const AText: WideString; const ACellWidth, ADecimal: Integer);
    procedure SetTemplateCellLine(const ALeftLine, ATopLine, ArightLine, AbottomLine: Boolean; const ALeftLineWidth, ATopLineWidth, ARightLineWidth, AbottomLineWidth: Integer);
    procedure SetTemplateCellFont(const AFontName: WideString; AFontSize: Integer; AIsBold, AIsItalic, AIsUnderline, AIsStrikeOut: Boolean);
    procedure SetTemplateCellAlign(const AHorzAlign, AVertAlign: Integer);
    procedure SetTemplateRowHeight(const ARowHeight: Integer);
    function MergeTemplateTableCell(const aTopLeftRowIndex, aTopLeftCellIndex, aRightBottomRowIndex, aRightBottomCellIndex: Integer): Boolean;
    procedure SetReportMargin(const ALeft, ATop, ARight, ABottom: Integer);
    procedure SetRelationKeyField(AMasterField, ADetailField: string; AMasterKeyVisible, ADetailKeyVisible: Boolean);   //������ӡʱ�����ӱ�����ֶ�
    // ���ö������ϸ����  ����0��ʼ
    procedure SetDetailDataByIndex(Value: OleVariant; const AIndex: Integer);
    // ��ȡ���е�ģ������  �Զ��ŷָ�
    function GetTemplateNames: PChar;
    // ��ȡ��ʽ����
    function GetStyleNames(const ATemplateName: PWideChar): PWideChar; // �Զ��ŷָ�
    // ��ȡ��ʽ����
    procedure CreateBaseTemplateFromJson(aJson: OleVariant);
    procedure CloseAllForms;
    procedure SetIsBprint(Value: Boolean);
    procedure SetIsSaveDataSet(Value: Boolean);
    property IsBprint: Boolean write SetIsBprint;
    property IsSaveDataSet: Boolean write SetIsSaveDataSet;
    function GetTemplateFields: PWideChar; //��ȡ��ǰģ����ѡ����ֶ�
    procedure SetPrinterName(const APrinterName: PChar);  //���ô�ӡ������
    procedure SetShowErrorMessageBox(const aValue: Boolean); //�쳣ʱ���Ƿ񵯿�
    procedure SetTemplateNameStr(aName: OleVariant);
    procedure DoCallBackPrintExportTimes; //�ص�carpa3 �����ӡ���� ��������

    procedure DesignInParentControl(AParentHandle: THandle; aWidth, aHeight: Integer);
    procedure PreviewInParentControl(AParentHandle: THandle; aWidth, aHeight: Integer);
//    function SaveTemplateFromJson(aJson: string): Boolean; //����ʽJson��ȡ��ʽ������
    procedure DesignThenLoadTemplate;
    procedure UploadCurStyle(var aTemplateName: PAnsiChar; var aTemplate: OleVariant; var aStyleName: PWideChar);
    function DownLoadCloudStyle(aJson: OleVariant; aStyleName: PAnsiChar; aIsAdd: Boolean): Boolean;
    procedure UpdateV11Template(const aFilePath: OleVariant);
    procedure LoadDataFromJson(AData: OleVariant; const ASaveDataToFile: Boolean = False);
    function GetCurStyleIndex(const aTemplatName: PChar): Integer;
    function GetPrinterNames: PChar;
    procedure AppendStyle(const ATemplateName: PChar; const AStyleName: PChar; const AStyleContent: PChar);
    procedure RemotePrint(const AContent, APrinterName: PChar);
    function ExportPdf(const APdfPath: PChar): string;
  end;

  // ��ӡ����
  IcrPrinterSetup = interface
    ['{4B73A512-051C-4C97-99D0-26A3CE1C1E44}']
    function GetPages: PChar;
    procedure SetPages(const Value: PChar);
    function GetPageLimit: Integer;
    procedure SetPageLimit(const Value: Integer);
    function GetCopies: Integer;
    procedure SetCopies(const Value: Integer);
    function GetCollateCopies: Boolean;
    procedure SetCollateCopies(const Value: Boolean);
    function GetPrinterIndex: Integer;
    procedure SetPrinterIndex(const Value: Integer);
    function GetScaleFactor: Integer;
    procedure SetScaleFactor(const Value: Integer);
    function GetPageSizeIndex: Integer;
    procedure SetPageSizeIndex(const Value: Integer);
    function GetPageWidth: Integer;
    procedure SetPageWidth(const Value: Integer);
    function GetPageHeight: Integer;
    procedure SetPageHeight(const Value: Integer);
    function GetOffsetTop: Integer;
    procedure SetOffsetTop(const Value: Integer);
    function GetOffsetLeft: Integer;
    procedure SetOffsetLeft(const Value: Integer);

    // ҳ�뷶Χ
    property Pages: PChar read GetPages write SetPages;
    // ҳ���ӡ����{0=����ҳ��,1=����ҳ,2=ż��ҳ}
    property PageLimit: Integer read GetPageLimit write SetPageLimit;
    // ����
    property Copies: Integer read GetCopies write SetCopies;
    // �Ƿ���ݴ�ӡ
    property CollateCopies: Boolean read GetCollateCopies write SetCollateCopies;
    // ��ӡ��������
    property PrinterIndex: Integer read GetPrinterIndex write SetPrinterIndex;
    // ���ű���
    property ScaleFactor: Integer read GetScaleFactor write SetScaleFactor;
    // ��ӡֽ�Ŵ�С���
    property PageSizeIndex: Integer read GetPageSizeIndex write SetPageSizeIndex;
    // ֽ�ſ��
    property PageWidth: Integer read GetPageWidth write SetPageWidth;
    // ֽ�Ÿ߶�
    property PageHeight: Integer read GetPageHeight write SetPageHeight;
    // ��ƫ��
    property OffsetLeft: Integer read GetOffsetLeft write SetOffsetLeft;
    // ��ƫ��
    property OffsetTop: Integer read GetOffsetTop write SetOffsetTop;
  end;

  IcrLineIntf = interface;

  IcrCellIntf = interface;

  IcrModelIntf = interface
    ['{792D66D9-94E7-465F-BB0B-A936A70D856F}']
    function ToObject: TObject;
    function GetOrientation: Integer;
    procedure SetOrientation(const Value: Integer);
    function GetPageWidth: Integer;
    function GetPageHeight: Integer;
    function GetLeftMargin: Integer;
    procedure SetLeftMargin(const Value: Integer);
    function GetRightMargin: Integer;
    procedure SetRightMargin(const Value: Integer);
    function GetTopMargin: Integer;
    procedure SetTopMargin(const Value: Integer);
    function GetBottomMargin: Integer;
    procedure SetBottomMargin(const Value: Integer);
    function GetLineCount: Integer;
    function GetLineIntfs(const Index: Integer): IcrLineIntf;

    // �½���
    function CreateLineIntf: IcrLineIntf;
    // ��ģ�������һ��
    procedure AddLineIntf(Line: IcrLineIntf); overload;
    // ��������ģ�������һ��
    function AddLineIntf: IcrLineIntf; overload;
    // ָ�����ϽǺ����½ǵĵ�Ԫ������ �ϲ���Ԫ��
    function MergeCell(const ATopLeftLineIndex, aTopLeftCellIndex, ARightBottomLineIndex, aRightBottomCellIndex: Integer): Boolean;
    property LineCount: Integer read GetLineCount;
    property LineIntfs[const Index: Integer]: IcrLineIntf read GetLineIntfs;

    // ֽ�ŷ��� 0 ���� 1 ����
    property Orientation: Integer read GetOrientation write SetOrientation;
    // ҳ���ȣ���λ����Ļ���أ�
    property PageWidth: Integer read GetPageWidth;
    // ҳ��߶ȣ���λ����Ļ���أ�
    property PageHeight: Integer read GetPageHeight;
    // �������ұ߾࣬��λΪ����
    property LeftMargin: Integer read GetLeftMargin write SetLeftMargin;
    property RightMargin: Integer read GetRightMargin write SetRightMargin;
    property TopMargin: Integer read GetTopMargin write SetTopMargin;
    property BottomMargin: Integer read GetBottomMargin write SetBottomMargin;
    function GetFixLineCount: Integer;
    procedure SetFixLineCount(const AValue: Integer);
    // ��ӡ����ϸ����
    property FixLineCount: Integer read GetFixLineCount write SetFixLineCount;
  end;

  IcrTemplateIntf = interface(IcrModelIntf)
    ['{108F88F1-E8BB-46F5-B05B-3F88E55A6159}']
    function GetTemplateName: ShortString;
    procedure SetTemplateName(const Value: ShortString);
    function GetPageHeaderLineIntfs(const Index: Integer): IcrLineIntf;
    function GetPageDetailLineIntfs(const Index: Integer): IcrLineIntf;
    function GetPageFooterLineIntfs(const Index: Integer): IcrLineIntf;
    function GetReportFooterLineIntfs(const Index: Integer): IcrLineIntf;
    function GetLastPageHeaderLineIntf: IcrLineIntf;
    function GetFirstPageDetailLineIntf: IcrLineIntf;
    function GetPageHeaderLineCount: Integer;
    function GetPageDetailLineCount: Integer;
    function GetPageFooterLineCount: Integer;
    function GetReportFooterLineCount: Integer;
    property TemplateName: ShortString read GetTemplateName write SetTemplateName;

    // ��ȡģ��ı�ͷ��
    property PageHeaderLineIntfs[const Index: Integer]: IcrLineIntf read GetPageHeaderLineIntfs;
    // ��ȡģ��ı�����
    property PageDetailLineIntfs[const Index: Integer]: IcrLineIntf read GetPageDetailLineIntfs;
    // ��ȡģ��ı�β��
    property PageFooterLineIntfs[const Index: Integer]: IcrLineIntf read GetPageFooterLineIntfs;
    // ��ȡģ��ķ����
    property ReportFooterLineIntfs[const Index: Integer]: IcrLineIntf read GetReportFooterLineIntfs;

    // ��ȡģ��ı�ͷ���һ�У�һ����岿�ֶ��ɱ�ͷ���һ�к�һ�б��幹�ɣ�
    property LastPageHeaderLineIntf: IcrLineIntf read GetLastPageHeaderLineIntf;
    // ��ȡģ��ı����һ�У�һ����岿�ֶ��ɱ�ͷ���һ�к�һ�б��幹�ɣ�
    property FirstPageDetailLineIntf: IcrLineIntf read GetFirstPageDetailLineIntf;
    property PageHeaderLineCount: Integer read GetPageHeaderLineCount;
    property PageDetailLineCount: Integer read GetPageDetailLineCount;
    property PageFooterLineCount: Integer read GetPageFooterLineCount;
    property ReportFooterLineCount: Integer read GetReportFooterLineCount;

    // չ��ҳü��ACellArrayӦ������չ���ĵ�Ԫ���ı���
    procedure ExpandPageHeader(const ACellText: ShortString; ACellArray: OleVariant);
    // չ����ϸ
    procedure ExpandPageDetail(const ACellText: ShortString; ACellArray: OleVariant);
    // չ��ҳ��
    procedure ExpandPageFooter(const ACellText: ShortString; ACellArray: OleVariant);
  end;

  IcrContentIntf = interface(IcrModelIntf)
    ['{6FDB9F42-9846-4E56-9F8E-A64F6F52BCD6}']
  end;

  IcrLineIntf = interface
    ['{BD9F5BB6-2826-4C55-9939-997A38B6ACC6}']
    function ToObject: TObject;
    function GetLineWidth: Integer;
    function GetLineHeight: Integer;
    procedure SetLineHeight(const Value: Integer);
    function GetCellCount: Integer;
    function GetCellIntfs(const Index: Integer): IcrCellIntf;
    function CreateCellIntf: IcrCellIntf;
    procedure AddCellIntf(Cell: IcrCellIntf); overload;
    function AddCellIntf: IcrCellIntf; overload;

    // ������е�Ԫ��
    procedure ClearCells;
    property CellIntfs[const Index: Integer]: IcrCellIntf read GetCellIntfs;
    // �и�
    property LineHeight: Integer read GetLineHeight write SetLineHeight;
    // ��ǰ�п����е�Ԫ���Ⱥϼƣ�
    property LineWidth: Integer read GetLineWidth;
    // ��Ԫ����
    property CellCount: Integer read GetCellCount;
  end;

  IcrCellIntf = interface
    ['{ED2580ED-E11C-4535-9EE0-864523DD97B1}']
    function ToObject: TObject;
    function GetCellText: ShortString;
    procedure SetCellText(const Value: ShortString);
    function GetCellWordWrap: Boolean;
    procedure SetCellWordWrap(const Value: Boolean);
    function GetFontSize: Integer;
    procedure SetFontSize(const Value: Integer);
    function GetCellWidth: Integer;
    procedure SetCellWidth(const Value: Integer);
    function GetLeftLine: Boolean;
    procedure SetLeftLine(const Value: Boolean);
    function GetLeftLineWidth: Integer;
    procedure SetLeftLineWidth(const Value: Integer);
    function GetRightLine: Boolean;
    procedure SetRightLine(const Value: Boolean);
    function GetRightLineWidth: Integer;
    procedure SetRightLineWidth(const Value: Integer);
    function GetTopLine: Boolean;
    procedure SetTopLine(const Value: Boolean);
    function GetTopLineWidth: Integer;
    procedure SetTopLineWidth(const Value: Integer);
    function GetBottomLine: Boolean;
    procedure SetBottomLine(const Value: Boolean);
    function GetBottomLineWidth: Integer;
    procedure SetBottomLineWidth(const Value: Integer);
    function GetDecimal: Integer;
    procedure SetDecimal(const Value: Integer);
    function GetHorzAlign: Integer;
    procedure SetHorzAlign(const Value: Integer);
    function GetVertAlign: Integer;
    procedure SetVertAlign(const Value: Integer);
    function GetFontName: ShortString;
    procedure SetFontName(const Value: ShortString);
    procedure SetCellFont(const FontName: ShortString; const FontSize: Integer = 9; const IsBold: Boolean = False; const IsItalic: Boolean = False; const IsUnderline: Boolean = False; const IsStrikeOut: Boolean = False);

    // ��Ԫ���е�����
    property CellText: ShortString read GetCellText write SetCellText;
    // �Ƿ��Զ�����
    property CellWordWrap: Boolean read GetCellWordWrap write SetCellWordWrap;
    // �����С һ�����Ϊ����9����
    property FontSize: Integer read GetFontSize write SetFontSize;
    // �������� һ�����Ϊ����9����
    property FontName: ShortString read GetFontName write SetFontName;

    // ��Ԫ����
    property CellWidth: Integer read GetCellWidth write SetCellWidth;
    property LeftLine: Boolean read GetLeftLine write SetLeftLine;
    property LeftLineWidth: Integer read GetLeftLineWidth write SetLeftLineWidth;
    property RightLine: Boolean read GetRightLine write SetRightLine;
    property RightLineWidth: Integer read GetRightLineWidth write SetRightLineWidth;

    // �Ƿ����ϱ���
    property TopLine: Boolean read GetTopLine write SetTopLine;
    // �ϱ��߿�� һ������Ϊ1
    property TopLineWidth: Integer read GetTopLineWidth write SetTopLineWidth;
    property BottomLine: Boolean read GetBottomLine write SetBottomLine;
    property BottomLineWidth: Integer read GetBottomLineWidth write SetBottomLineWidth;

    // -1 ����Դ�������ݲ���ʽ�� 0 ��������С�� 1����һλ
    property Decimal: Integer read GetDecimal write SetDecimal;
    // ˮƽ���뷽ʽ 0 ����� 1 ˮƽ���� 2 ���Ҷ���
    property HorzAlign: Integer read GetHorzAlign write SetHorzAlign;
    // ��ֱ���뷽ʽ 0 �϶��� 1 ���ж��� 2 �¶���
    property VertAlign: Integer read GetVertAlign write SetVertAlign;
  end;

function CreateReport: IcrReport;

procedure SetDllPath(const AValue: string);

procedure UnloadDll;

implementation

const
  cDll = 'CPrint.Dll';

var
  HDll: THandle = 0;

procedure UnloadDll;
begin
  if HDll <> 0 then
  begin
    FreeLibrary(HDll);
    HDll := 0;
  end;
end;

var
  FDllPath: string = '';

procedure SetDllPath(const AValue: string);
begin
  FDllPath := AValue;
end;

procedure RaiseErrorFmt(const AMsg: string; AArgs: array of const);
begin
  raise Exception.CreateFmt(AMsg, AArgs);
end;

function GetProc(const AProcName: string): Pointer;
begin
  if HDll = 0 then
  begin
    if (FDllPath <> '') and (not FileExists(FDllPath + cDll)) then
      RaiseErrorFmt('�޷����� %s��%s', [FDllPath + cDll, '�ļ�������']);

    HDll := LoadLibrary(PChar(FDllPath + cDll));
    if HDll = 0 then
      HDll := LoadLibraryEx(PChar(FDllPath + cDll), 0, LOAD_WITH_ALTERED_SEARCH_PATH);
    if HDll = 0 then
      RaiseErrorFmt('�޷����� %s��%s', [FDllPath + cDll, SysErrorMessage(GetLastError)]);
  end;
{$WARNINGS OFF}
  Result := GetProcAddress(HDll, PChar(AProcName));
  if Result = nil then
    RaiseErrorFmt('%s �޷���ȡ %s �������', [FDllPath + cDll, AProcName]);
{$WARNINGS ON}
end;

type
  TCreateReportMethod = function: IcrReport; stdcall;

function CreateReport: IcrReport;
var
  CreateReportMethod: TCreateReportMethod;
begin
  CreateReportMethod := GetProc('CreateReport');
  Result := CreateReportMethod;
end;

{ TcrUtils }

{ TcrUtils }

function Encode(const AText: string): string;
var
  i, iRandomKey, iStartKey, iMultKey, iAddKey, iChar: Integer;
begin
  Result := '';
  if AText = '' then
    Exit;
  Randomize;
  iRandomKey := Random(100);
  iStartKey := $03 + iRandomKey;
  iMultKey := $07 + iRandomKey;
  iAddKey := $16 + iRandomKey;
  Result := Format('%1.2X', [iRandomKey]);
  for i := 1 to Length(AText) do
  begin
    iChar := Byte(Byte(AText[i]) xor (iStartKey shr 8));
    Result := Result + Format('%1.2X', [iChar]);
    iStartKey := (iChar + iStartKey) * iMultKey + iAddKey;
  end;
end;

function Decode(const AText: string): string;
var
  i, iRandomKey, iStartKey, iMultKey, iAddKey, iChar: Integer;
begin
  Result := '';
  if AText = '' then
    Exit;
  iRandomKey := StrToIntDef('$' + Copy(AText, 1, 2), -1);
  if iRandomKey = -1 then
    raise Exception.CreateFmt('��%s������', [AText]);
  iStartKey := $03 + iRandomKey;
  iMultKey := $07 + iRandomKey;
  iAddKey := $16 + iRandomKey;
  for i := 1 to Length(AText) div 2 - 1 do
  begin
    iChar := StrToInt('$' + Copy(AText, i * 2 + 1, 2));
    Result := Result + Char(iChar xor (iStartKey shr 8));
    iStartKey := (iChar + iStartKey) * iMultKey + iAddKey;
  end;
end;

class function TcrUtils.GetPrintWatermarkKey: string;
begin
  Result := Decode('2F5049AE91669C446D671A76FB2964'); // PRINTWATERMARK
end;

class procedure TcrUtils.SetPrintWatermark(const AValue: string);
var
  Params: OleVariant;
begin
  with CreateReport do
  begin
    Params := Encode(GetPrintWatermarkKey + '=' + AValue);
    Init(Params);
  end;
end;

end.

