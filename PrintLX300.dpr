program PrintLX300;

uses
  Forms,
  Main in 'Main.pas' {Form1},
  CharPrinter in 'CharPrinter.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
