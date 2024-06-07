﻿// CodeGear C++Builder
// Copyright (c) 1995, 2022 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'FormSelectChart.pas' rev: 35.00 (Windows)

#ifndef FormselectchartHPP
#define FormselectchartHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member 
#pragma pack(push,8)
#include <System.hpp>
#include <SysInit.hpp>
#include <Winapi.Windows.hpp>
#include <Winapi.Messages.hpp>
#include <System.SysUtils.hpp>
#include <System.Variants.hpp>
#include <System.Classes.hpp>
#include <Vcl.Graphics.hpp>
#include <Vcl.Controls.hpp>
#include <Vcl.Forms.hpp>
#include <Vcl.Dialogs.hpp>
#include <Vcl.StdCtrls.hpp>

//-- user supplied -----------------------------------------------------------

namespace Formselectchart
{
//-- forward type declarations -----------------------------------------------
class DELPHICLASS TfrmSelectChart;
//-- type declarations -------------------------------------------------------
class PASCALIMPLEMENTATION TfrmSelectChart : public Vcl::Forms::TForm
{
	typedef Vcl::Forms::TForm inherited;
	
__published:
	Vcl::Stdctrls::TLabel* Label1;
	Vcl::Stdctrls::TComboBox* cbStyle;
	Vcl::Stdctrls::TButton* Button1;
	Vcl::Stdctrls::TButton* Button2;
	
public:
	int __fastcall Execute();
public:
	/* TCustomForm.Create */ inline __fastcall virtual TfrmSelectChart(System::Classes::TComponent* AOwner) : Vcl::Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrmSelectChart(System::Classes::TComponent* AOwner, int Dummy) : Vcl::Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TfrmSelectChart() { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrmSelectChart(HWND ParentWindow) : Vcl::Forms::TForm(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern DELPHI_PACKAGE TfrmSelectChart* frmSelectChart;
}	/* namespace Formselectchart */
#if !defined(DELPHIHEADER_NO_IMPLICIT_NAMESPACE_USE) && !defined(NO_USING_NAMESPACE_FORMSELECTCHART)
using namespace Formselectchart;
#endif
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FormselectchartHPP
