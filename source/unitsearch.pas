unit UnitSearch;

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  LCLType, LazUTF8, RichMemo;

type

  { TSearchForm }

  TSearchForm = class(TForm)
    MessageLabel: TLabel;
    SearchButton: TButton;
    CancelButton: TButton;
    CaseSensitiveBox: TCheckBox;
    WholeWordBox: TCheckBox;
    Edit: TEdit;
    procedure FormActivate(Sender: TObject);
    procedure EditChange(Sender: TObject);
    procedure EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SearchButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
  private
    found : boolean;
    procedure Search(const RichMemo: TRichMemo);
  end;

var
  SearchForm: TSearchForm;

implementation

uses FormMain, UnitLib;

{$R *.lfm}

procedure TSearchForm.FormActivate(Sender: TObject);
begin
  MessageLabel.Caption := '';
  found := false;
end;

procedure TSearchForm.EditChange(Sender: TObject);
begin
  MessageLabel.Caption := '';
  found := false;
end;

procedure TSearchForm.Search(const RichMemo: TRichMemo);
var
  Options : TSearchOptions;
  len : integer;
  st: integer;
  x : integer;
begin
  Options := [];

  st := RichMemo.SelStart;
  len := RichMemo.SelLength;

  if CaseSensitiveBox.Checked then Include(Options, soMatchCase);
  if WholeWordBox.Checked then Include(Options, soWholeWord);

  x := RichMemo.Search(Edit.Text, RichMemo.SelStart, RichMemo.GetTextLen, Options);

  if x>=0 then
    if (st=x) and (len=UTF8Length(Edit.Text)) then
      x := RichMemo.Search(Edit.Text, RichMemo.SelStart+1, RichMemo.GetTextLen, Options);

  if x>=0 then
    begin
      RichMemo.SelStart := x;
      RichMemo.SetSelLengthFor(Edit.text);
      found := true;
    end;

  if (x<0) and not found then
    begin
      MessageLabel.Caption := 'Can''t find the text ' + DoubleQuotedStr(Edit.Text);
      MessageLabel.Font.Color := clRed;
    end;

  if (x<0) and found then
    begin
      MessageLabel.Caption := 'The end of the document has been reached.';
      MessageLabel.Font.Color := clGreen;
    end;
end;

procedure TSearchForm.EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then Search(MainForm.RichMemo);
end;

procedure TSearchForm.SearchButtonClick(Sender: TObject);
begin
  Search(MainForm.RichMemo);
end;

procedure TSearchForm.CancelButtonClick(Sender: TObject);
begin
  Close
end;

end.

