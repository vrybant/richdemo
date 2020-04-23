unit UnitLib;

interface

uses
  {$ifdef windows} Windirs, {$endif}
  {$ifdef linux} LazLogger, {$endif}
  {$ifdef darwin} Process, UTF8Process, {$endif}
  SysUtils, Classes, Graphics, Controls, ExtCtrls, Forms, Dialogs,
  LazUtf8, LCLProc, LCLVersion, ClipBrd;

const
  ApplicationName = 'RichMemo';
  DefaultFileName = 'Untitled';

// string's functions

function ToStr(value: longint): string;
function DoubleQuotedStr(s: string): string;
function Utf8ToRTF(const s: string): string;

// сlipboard's function

{$ifdef windows} procedure StringToClipboard(Source: string); {$endif}

// file's functions

function ExtractOnlyName(s: string): string;
function SharePath: string;
function DocumentsPath: string;
{$ifdef windows} function LocalAppDataPath: string; {$endif}
function TempFileName: string;
function ConfigFileName: string;
{$ifdef darwin} procedure PrintFile(FileName : string); {$endif}

implementation

// string's functions

function ToStr(value: longint): string;
begin
 System.Str(value, Result);
end;

function DoubleQuotedStr(s: string): string;
begin
  Result := '"' + s + '"';
end;

function Utf8ToRTF(const s: string): string;
var
  p: PChar;
  unicode: Cardinal;
  CharLen: integer;
const
  endchar = {$ifdef linux} ' ' {$else} '?' {$endif};
begin
  Result := '';
  p := PChar(s);
  repeat
    {$if lcl_major >= 2}
      unicode := UTF8CodepointToUnicode(p,CharLen);
    {$else}
      unicode := UTF8CharacterToUnicode(p,CharLen);
    {$endif}
    if unicode = 0 then Continue;
    if unicode < $80 then Result := Result + char(unicode)
                     else Result := Result + '\u' + ToStr(unicode) + endchar;

    inc(p,CharLen);
  until (CharLen=0) or (unicode=0);
end;

// сlipboard's function

{$ifdef windows}
procedure StreamToClipboard(Stream: TMemoryStream);
var
  Clipboard : TClipBoard;
     CF_RTF : Word;
begin
  Clipboard := TClipboard.Create ;
  CF_RTF := RegisterClipboardFormat('Rich Text Format');
  Clipboard.AddFormat(CF_RTF,Stream);
  Clipboard.Free ;
end;

procedure StringToClipboard(Source: string);
var
  Stream : TMemoryStream;
begin
  Source := Utf8ToRTF(Source) + LineEnding;
  Stream := TMemoryStream.Create;
  Stream.Seek(0,soFromBeginning);
  Stream.WriteBuffer(Pointer(Source)^, Length(Source));
  StreamToClipboard(Stream);
  Stream.Free;
end;
{$endif}

// file's functions

function ExtractOnlyName(s: string): string;
begin
  Result := ExtractFileName(ChangeFileExt(s,''));
end;

function SharePath: string;
begin
  Result := Application.Location;
  {$ifdef linux}
    if Pos('/usr',Result) = 1 then Result := '/usr/share/' + Application.Title + '/';
  {$endif}
end;

function DocumentsPath: string;
begin
  {$ifdef windows} Result := GetWindowsSpecialDir(CSIDL_PERSONAL); {$endif}
  {$ifdef unix} Result := GetUserDir + 'Documents'; {$endif}
end;

{$ifdef windows}
function LocalAppDataPath: string;
begin
  Result := GetWindowsSpecialDir(CSIDL_LOCAL_APPDATA);
end;
{$endif}

function TempFileName: string; // for printing
begin
  Result := GetTempDir + 'temp.rtf';
end;

function ConfigFileName: string;
begin
  {$ifdef windows} Result := LocalAppDataPath + ApplicationName + DirectorySeparator; {$endif}
  {$ifdef unix} Result := GetAppConfigDir(False); {$endif}
  Result += 'config.ini';
end;

{$ifdef darwin}
procedure PrintFile(filename : string);
begin
  with TProcessUTF8.Create(nil) do
  try
    CommandLine {%H-}:='lp "' + filename + '"';
    Options := [poUsePipes]; // poWaitOnExit
    try
      Execute;
    except
      on EProcess do ShowMessage('Oops! Looks like it can''t be printed.');
    end;
  finally
    Free;
  end;
end;
{$endif}

end.

