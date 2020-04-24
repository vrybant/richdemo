unit FormMain;

interface

uses
  {$ifdef windows} Windows, Printers, OSPrinters, {$endif}
  Classes, SysUtils, LazFileUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Menus, ExtCtrls, ComCtrls, IniFiles, LCLIntf, LCLType, LCLProc, ActnList, ClipBrd,
  StdActns, PrintersDlgs, Types, RichMemo, RichMemoUtils, UnitLib;

type

  { TMainForm }

  TMainForm = class(TForm)
    ActionSuper: TAction;
    ActionDecrease: TAction;
    ActionIncrease: TAction;
    ActionInterline: TAction;
    FontDialogNotes: TFontDialog;
    PrintDialog: TPrintDialog;
    FontDialog: TFontDialog;
    OpenDialog: TOpenDialog;
    RichMemo: TRichMemo;
    SaveDialog: TSaveDialog;
    ToolSeparator1: TToolButton;
    ActionList: TActionList;
    FileOpen1: TFileOpen;
    EditCut1: TEditCut;

    ActionAbout: THelpAction;
    ActionBold: TAction;
    ActionBullets: TAction;
    ActionCenter: TAction;
    ActionEditCopy: TAction;
    ActionEditCut: TAction;
    ActionEditDel: TAction;
    ActionEditFont: TAction;
    ActionEditPaste: TAction;
    ActionEditSelAll: TEditSelectAll;
    ActionEditUndo: TAction;
    ActionExit: TAction;
    ActionFileNew: TAction;
    ActionFileOpen: TAction;
    ActionFilePrint: TAction;
    ActionFileSave: TAction;
    ActionFileSaveAs: TAction;
    ActionFont: TAction;
    ActionItalic: TAction;
    ActionLeft: TAction;
    ActionLink: TAction;
    ActionOptions: TAction;
    ActionRight: TAction;
    ActionSearch: TAction;
    ActionUnderline: TAction;

    Ruler: TPanel;
    Splitter: TSplitter;
    StatusBar: TStatusBar;
    Images: TImageList;

    MainMenu: TMainMenu;
    miClear: TMenuItem;
    miCopy: TMenuItem;
    miCut: TMenuItem;
    miEdit: TMenuItem;
    miExit: TMenuItem;
    miHelp: TMenuItem;
    miAbout: TMenuItem;
    miHome: TMenuItem;
    miNew: TMenuItem;
    miOpen: TMenuItem;
    miFile: TMenuItem;
    miSave: TMenuItem;
    miSaveAs: TMenuItem;
    miOptions: TMenuItem;
    miPaste: TMenuItem;
    miPrint: TMenuItem;
    miSearch: TMenuItem;
    miSelectAll: TMenuItem;
    miUndo: TMenuItem;

    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N9: TMenuItem;

    PopupMenu: TPopupMenu;
    pmCut: TMenuItem;
    pmCopy: TMenuItem;
    pmPaste: TMenuItem;
    pmSelAll: TMenuItem;

    StandardToolBar: TToolBar;
    ToolButtonBold: TToolButton;
    ToolButtonBullets: TToolButton;
    ToolButtonCenter: TToolButton;
    ToolButtonCopy: TToolButton;
    ToolButtonCut: TToolButton;
    ToolButtonFont: TToolButton;
    ToolButtonItalic: TToolButton;
    ToolButtonLeft: TToolButton;
    ToolButtonLink: TToolButton;
    ToolButtonNew: TToolButton;
    ToolButtonOpen: TToolButton;
    ToolButtonPaste: TToolButton;
    ToolButtonPrint: TToolButton;
    ToolButtonRight: TToolButton;
    ToolButtonSave: TToolButton;
    ToolButtonSearch: TToolButton;
    ToolButtonUnderline: TToolButton;
    ToolButtonUndo: TToolButton;
    ToolSeparator2: TToolButton;
    ToolSeparator3: TToolButton;
    ToolSeparator4: TToolButton;
    ToolSeparator5: TToolButton;

    procedure CmdAbout(Sender: TObject);
    procedure CmdEdit(Sender: TObject);
    procedure CmdExit(Sender: TObject);
    procedure CmdFileNew(Sender: TObject);
    procedure CmdFileOpen(Sender: TObject);
    procedure CmdFilePrint(Sender: TObject);
    procedure CmdFileSave(Sender: TObject);
    procedure CmdFileSaveAs(Sender: TObject);
    procedure CmdLink(Sender: TObject);
    procedure CmdOptions(Sender: TObject);
    procedure CmdSearch(Sender: TObject);
    procedure CmdStyle(Sender: TObject);
    procedure CmdStyle2(Sender: TObject);

    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure miHomeClick(Sender: TObject);
    procedure RichMemoContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure RichMemoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure RichMemoMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure RichMemoSelectionChange(Sender: TObject);
    procedure StandardToolBarClick(Sender: TObject);
  private
    DefaultFont: TFont;
    NoteFileName: string;
    {$ifdef windows}
      function  GetModified: boolean;
      procedure SetModified(value: boolean);
      property Modified: boolean read GetModified write SetModified;
    {$else}
      Modified : boolean;
    {$endif}
    function SelAttributes: TFontParams;
    function SelParaAlignment: TParaAlignment;
    function SelParaNumbering: TParaNumbering;
    function isSelLink: boolean;
    function CanUndo: boolean;
    function CheckFileSave: boolean;
    procedure EnableButtons;
    procedure UpDownButtons;
    procedure PerformFileOpen(const FileName: string);
    procedure ReadConfig;
    procedure SaveConfig;
    procedure UpdateCaption(s: string);
    procedure UpdateStatus(s, Hint: string);
    procedure ShowPopup;
    procedure OnLinkAction(Sender: TObject; AAction: TLinkAction;
      const AMouseInfo: TLinkMouseInfo; StartChar, LenChars: Integer);
  end;

var
  MainForm: TMainForm;

implementation

uses
  {$ifdef windows} rmWinEx, {$endif} {$ifdef linux} rmGtk2ex, {$endif}
  UnitSearch, FormAbout;

{$R *.lfm}

//=================================================================================================
//                                     Create Main Form
//=================================================================================================

procedure TMainForm.FormCreate(Sender: TObject);
begin
  DefaultFont := TFont.Create;
  DefaultFont.Name := {$ifdef windows} 'Tahoma' {$else} 'default' {$endif};
  DefaultFont.Size := 12;

  SaveDialog.InitialDir := DocumentsPath;
  ReadConfig;

  NoteFileName := DefaultFileName;
  RichMemo.Lines.Clear;
  RichMemo.Font.Size := DefaultFont.Size;
  RichMemo.OnLinkAction := OnLinkAction;

  {$ifdef linux}
  StandardToolBar.ParentColor := True;
  ActionEditUndo.Visible := False;
  ActionFilePrint.Visible := False;
  Modified := False;
  {$endif}

  {$ifdef darwin} exit; {$endif}

  EnableButtons;
  UpDownButtons;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  SaveConfig;
  DefaultFont.Free;
end;

procedure TMainForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  {$ifdef linux} RichMemo.Clear {$endif}
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  try
    CanClose := CheckFileSave;
  except
    CanClose := False;
  end;
end;

{$ifdef windows}

function TMainForm.GetModified: boolean;
begin
  Result := SendMessage(RichMemo.Handle, EM_GETMODIFY,  0, 0) <> 0;
end;

procedure TMainForm.SetModified(value: boolean);
begin
  SendMessage(RichMemo.Handle, EM_SETMODIFY, Byte(value), 0);
end;

{$endif}

// стандартные функции GetTextAttributes, GetParaAlignment, GetParaNumbering и isLink используются
// в процедуре UpDownButtons и при перемещнии курсора по тексту вызывают перерисовку в Windows,
// в результате чего дергается текст и неправильно работает выделение слова двойным нажатием мыши

function TMainForm.SelAttributes: TFontParams;
begin
  {$ifdef windows}
  Result := GetSelectedTextAttributes(RichMemo.Handle);
  {$else}
  RichMemo.GetTextAttributes(RichMemo.SelStart, Result{%H-});
  {$endif}
end;

function TMainForm.SelParaAlignment: TParaAlignment;
begin
  {$ifdef windows}
  Result := GetSelectedParaAlignment(RichMemo.Handle);
  {$else}
  RichMemo.GetParaAlignment(RichMemo.SelStart, Result{%H-});
  {$endif}
end;

function TMainForm.SelParaNumbering: TParaNumbering;
begin
  {$ifdef windows}
  Result := GetSelectedParaNumbering(RichMemo.Handle);
  {$else}
  RichMemo.GetParaNumbering(RichMemo.SelStart, Result{%H-});
  {$endif}
end;

function TMainForm.isSelLink: boolean;
begin
  {$ifdef windows}
  Result := isSelectedTextLink(RichMemo.Handle);
  {$else}
  Result := RichMemo.isLink(RichMemo.SelStart);
  {$endif}
end;

function TMainForm.CanUndo: boolean;
begin
  {$ifdef windows}
  Result := SendMessage(RichMemo.Handle, EM_CANUNDO,  0, 0) <> 0;
  {$else}
  Result := True;
  {$endif}
end;

//-------------------------------------------------------------------------------------------------
//                                       Actions
//-------------------------------------------------------------------------------------------------

procedure TMainForm.CmdAbout(Sender: TObject);
begin
  AboutBox.ShowModal;
end;

procedure TMainForm.CmdStyle(Sender: TObject);
var
  fp: TFontParams;
begin
  RichMemo.GetTextAttributes(RichMemo.SelStart, fp{%H-});

  if Sender = ActionBold then
    if fsBold in fp.Style then fp.Style := fp.Style - [fsBold]
                          else fp.Style := fp.Style + [fsBold];

  if Sender = ActionItalic then
    if fsItalic in fp.Style then fp.Style := fp.Style - [fsItalic]
                            else fp.Style := fp.Style + [fsItalic];

  if Sender = ActionUnderline then
    if fsUnderline in fp.Style then fp.Style := fp.Style - [fsUnderline]
                               else fp.Style := fp.Style + [fsUnderline];

  if Sender = ActionLink then
    if fp.Color = clNavy then fp.Color := clBlack
                         else fp.Color := clNavy;

  if Sender = ActionSuper then
    if fp.vScriptPos = vpSuperscript then fp.vScriptPos := vpNormal
                                     else fp.vScriptPos := vpSuperscript;

  if Sender = ActionIncrease then fp.Size += 1;
  if Sender = ActionDecrease then fp.Size -= 1;

  if Sender = ActionFont then
    begin
      FontDialog.Font.Name  := fp.Name;
      FontDialog.Font.Size  := fp.Size;
      FontDialog.Font.Style := fp.Style;
      FontDialog.Font.Color := fp.Color;

      if FontDialog.Execute then
        begin
          fp.Name  := FontDialog.Font.Name;
          fp.Size  := FontDialog.Font.Size;
          fp.Style := FontDialog.Font.Style;
          fp.Color := FontDialog.Font.Color;
        end;
    end;

  RichMemo.SetTextAttributes(RichMemo.SelStart, RichMemo.SelLength, fp);
end;

procedure TMainForm.CmdStyle2(Sender: TObject);
var pn : TParaNumbering;
begin
  with RichMemo do
    begin
      if Sender = ActionLeft   then SetParaAlignment(SelStart, SelLength, paLeft  );
      if Sender = ActionCenter then SetParaAlignment(SelStart, SelLength, paCenter);
      if Sender = ActionRight  then SetParaAlignment(SelStart, SelLength, paRight );

      if Sender = ActionBullets then
        begin
          GetParaNumbering(SelStart, pn);
          if ToolButtonBullets.Down then pn.Style := pnBullet else pn.Style := pnNone;
          SetParaNumbering(SelStart, SelLength, pn);
        end;
    end;
end;

procedure TMainForm.CmdLink(Sender: TObject);
begin
  RichMemo.SetLink(RichMemo.SelStart, RichMemo.SelLength, not RichMemo.isLink(RichMemo.SelStart));
end;

procedure TMainForm.CmdEdit(Sender: TObject);
begin
  {$ifdef linux}
    if Sender = ActionEditCut then Gtk2Copy(RichMemo.Handle);
    if Sender = ActionEditCopy then Gtk2Copy(RichMemo.Handle);
    if Sender = ActionEditPaste then Gtk2Paste(RichMemo.Handle);
  {$else}
    if Sender = ActionEditCut then RichMemo.CopyToClipboard;
    if Sender = ActionEditCopy then RichMemo.CopyToClipboard;
    if Sender = ActionEditPaste then RichMemo.PasteFromClipboard;
  {$endif}

  if Sender = ActionEditCut then RichMemo.ClearSelection;
  if Sender = ActionEditDel then RichMemo.ClearSelection;
  if Sender = ActionEditUndo then RichMemo.Undo;

  if Sender = ActionEditSelAll then
    begin
      RichMemo.SelStart := 0;
      RichMemo.SelLength := MaxInt;
    end;

  EnableButtons;
end;

procedure TMainForm.CmdSearch(Sender: TObject);
begin
  SearchForm.Show;
end;

procedure TMainForm.CmdFileNew(Sender: TObject);
begin
  if not CheckFileSave then Exit;
  NoteFileName := DefaultFileName;
  RichMemo.Lines.Clear;
  Modified := False;
  UpdateCaption(NoteFileName);
end;

procedure TMainForm.CmdFileOpen(Sender: TObject);
begin
  if not CheckFileSave then Exit;
  if OpenDialog.Execute then
  begin
    PerformFileOpen(OpenDialog.FileName);
    RichMemo.ReadOnly := ofReadOnly in OpenDialog.Options;
  end;
end;

procedure TMainForm.CmdFileSave(Sender: TObject);
begin
  if not Modified then Exit;
  if NoteFileName = DefaultFileName then
    CmdFileSaveAs(Sender)
  else
    begin
      SaveRTFFile(RichMemo, NoteFileName);
      Modified := False;
    end;
end;

procedure TMainForm.CmdFileSaveAs(Sender: TObject);
begin
  if NoteFileName = DefaultFileName
    then SaveDialog.InitialDir := DocumentsPath
    else SaveDialog.InitialDir := ExtractFilePath(NoteFileName);

  if SaveDialog.Execute then
  begin
    if Pos('.rtf', SaveDialog.FileName) = 0 then
      SaveDialog.FileName := SaveDialog.FileName + '.rtf';

    if FileExists(SaveDialog.FileName) then
      if MessageDlg(Format('OK to overwrite %s?', [SaveDialog.FileName]),
        mtConfirmation, mbYesNoCancel, 0) <> idYes then Exit;

    SaveRTFFile(RichMemo, SaveDialog.FileName);
    NoteFileName := SaveDialog.FileName;

    Modified := False;
    UpdateCaption(ExtractOnlyName(NoteFileName));
  end;
end;

procedure TMainForm.CmdFilePrint(Sender: TObject);
var
  Params : TPrintParams;
begin
  InitPrintParams(Params{%H-});
  if PrintDialog.Execute then RichMemo.Print(Params);
end;


procedure TMainForm.CmdExit(Sender: TObject);
begin
  Close
end;

//-------------------------------------------------------------------------------------------------
//                                        RichMemo's events
//-------------------------------------------------------------------------------------------------

procedure TMainForm.RichMemoMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin
  if Button = mbRight then ShowPopup;
end;

procedure TMainForm.RichMemoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  {$ifdef unix} Modified := True; {$endif}
end;

procedure TMainForm.RichMemoSelectionChange(Sender: TObject);
begin
  EnableButtons;
  UpDownButtons;
end;

procedure TMainForm.StandardToolBarClick(Sender: TObject);
begin

end;

procedure TMainForm.RichMemoContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
begin
  Handled := True; // disable system popup menu
end;

procedure TMainForm.UpdateCaption(s: string);
begin
  Caption := ApplicationName + ' - ' + s;
end;

procedure TMainForm.UpdateStatus(s, Hint: string);
begin
  StatusBar.SimpleText := ' ' + s;
  StatusBar.Hint := Hint;
end;

procedure TMainForm.ShowPopup;
var
  CursorPos: TPoint;
begin
  GetCursorPos(CursorPos);
  PopupMenu.Popup(CursorPos.X, CursorPos.Y);
end;

function TMainForm.CheckFileSave: boolean;
var
  Response : integer;
begin
  Result := True;
  if not Modified then Exit;

  Response := MessageDlg('Save changes?', mtConfirmation, mbYesNoCancel, 0);

  // remake!!
  case Response of
    idYes:
    begin
      CmdFileSave(self);
      Result := not Modified;
    end;
    idNo: {Nothing};
    idCancel: Result := False; // Abort;
  end;
end;

procedure TMainForm.OnLinkAction(Sender: TObject; AAction: TLinkAction;
  const AMouseInfo: TLinkMouseInfo; StartChar, LenChars: Integer);
begin
  if AMouseInfo.button = mbLeft then OpenURL(RichMemo.GetText(StartChar, LenChars));
end;

procedure TMainForm.EnableButtons;
begin
  ActionEditCopy.Enabled  := RichMemo.SelLength > 0;
  ActionEditCut.Enabled   := RichMemo.SelLength > 0;
  ActionEditDel.Enabled   := RichMemo.SelLength > 0;
  ActionEditPaste.Enabled := RichMemo.CanPaste;
  ActionEditUndo.Enabled  := RichMemo.CanUndo;
end;

procedure TMainForm.UpDownButtons;
var
  fp : TFontParams;
begin
  fp := SelAttributes;

  ToolButtonBold.Down := fsBold in fp.Style;
  ToolButtonItalic.Down := fsItalic in fp.Style;
  ToolButtonUnderline.Down := fsUnderline in fp.Style;
  ToolButtonLink.Down := isSelLink;

  UpdateStatus(fp.Name + '; ' + ToStr(fp.Size), '');

  case SelParaAlignment of
    paLeft: ToolButtonLeft.Down := True;
    paRight: ToolButtonRight.Down := True;
    paCenter: ToolButtonCenter.Down := True;
  end;

  ToolButtonBullets.Down := SelParaNumbering.Style = pnBullet;
end;

procedure TMainForm.PerformFileOpen(const FileName: string);
begin
  if not FileExists(FileName) then Exit;
  LoadRTFFile(RichMemo, FileName);
  NoteFileName := FileName;
  RichMemo.SetFocus;
  Modified := False;
  UpdateCaption(ExtractOnlyName(NoteFileName));
end;

procedure TMainForm.miHomeClick(Sender: TObject);
begin
  OpenURL('https://github.com/vrybant/richdemo');
end;

procedure TMainForm.CmdOptions(Sender: TObject);
begin
  FontDialog.Font.Assign(DefaultFont);
  if FontDialog.Execute then
  begin
    DefaultFont.Assign(FontDialog.Font);
//  FormPaint(self);
    Invalidate;
  end;
end;

//----------------------------------------------------------------------------------------
//                                       config
//----------------------------------------------------------------------------------------

procedure TMainForm.SaveConfig;
var
  IniFile: TIniFile;
begin
  IniFile := TIniFile.Create(ConfigFileName);

  IniFile.WriteString( 'Application', 'FontName', DefaultFont.Name);
  IniFile.WriteInteger('Application', 'FontSize', DefaultFont.Size);

  if WindowState = wsNormal then
  begin
    IniFile.WriteInteger('Window', 'Left',   Left);
    IniFile.WriteInteger('Window', 'Top',    Top);
    IniFile.WriteInteger('Window', 'Width',  Width);
    IniFile.WriteInteger('Window', 'Height', Height);
  end;

  IniFile.Free;
end;

procedure TMainForm.ReadConfig;
var
  IniFile: TIniFile;
begin
  IniFile := TIniFile.Create(ConfigFileName);

  DefaultFont.Name := IniFile.ReadString( 'Application', 'FontName', DefaultFont.Name);
  DefaultFont.Size := IniFile.ReadInteger('Application', 'FontSize', DefaultFont.Size);

  Height := IniFile.ReadInteger('Window', 'Height', Screen.Height - 300);
  Width := IniFile.ReadInteger('Window', 'Width', Screen.Width - 700);
  Left := IniFile.ReadInteger('Window', 'Left', 300);
  Top := IniFile.ReadInteger('Window', 'Top', 100);

  IniFile.Free;
end;

end.

