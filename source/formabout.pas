unit FormAbout;

interface

uses Classes, Graphics, Forms, Controls, StdCtrls, Buttons, ExtCtrls, SysUtils, LCLIntf;

type

  { TAboutBox }

  TAboutBox = class(TForm)
    LabelGPL: TLabel;
    LabelName: TLabel;
  end;

var
  AboutBox: TAboutBox;

implementation

{$R *.lfm}

end.

