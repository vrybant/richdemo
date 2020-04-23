program richdemo;

{$mode objfpc}{$H+}

uses
  {$ifdef unix}{$ifdef UseCThreads} cthreads, {$endif}{$endif}
  {$ifndef darwin} printer4lazarus, {$endif}
  Interfaces, Graphics, Forms, FormMain, FormAbout, UnitSearch;

{$R *.res}

begin
  Application.Title := 'RichDemo';
  Application.Initialize;
  Application.CreateForm(TMainForm,   MainForm);
  Application.CreateForm(TAboutBox,   AboutBox);
  Application.CreateForm(TSearchForm, SearchForm);
  Application.Run;
end.

