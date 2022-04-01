unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  charPrinter;

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
const
  RESET = #27#64;
  PAGE_LENGTH = #27#67; // + n - where n is a number from 1 to 127;
  CR = #13;
  LF = #10;
  CRLF = CR + LF;
  FORM_FEED = #12;
  SELECT1_8_INCH_LINE_SPACING = #27#48;
  F_10CPI = #27#80;
  F_12CPI = #27#77;
  START_BOLD = #27#69;
  END_BOLD = #27#70;
  START_ITALIC = #27#52;
  END_ITALIC = #27#53;
  START_UNDERLINE = #27#45#49;
  END_UNDERLINE = #27#45#48;
  START_CONDENCED = #15;
  END_CONDENCED = #18;
var
  prn:TAdvancedPrinter;
  dlg : tPrintDialog;
begin
  dlg := tPrintDialog.Create(nil);
  if dlg.execute then
  begin
    prn := TAdvancedPrinter.Create;
    prn.Language := lngESCP2;
    prn.OpenDoc('Editor VI - Guia de Referência');//Equivale ao AssignFile

    prn.Write(RESET); // Reset
    prn.Write(#27#67#12); //A4

    prn.Write(START_UNDERLINE + START_BOLD + 'EDITOR VI - GUIA DE REFERENCIA'+ END_BOLD + END_UNDERLINE + CRLF);
//    prn.Write('------------------------------' + CRLF);

    prn.Write(CRLF);
    prn.Write(START_BOLD + 'Comandos de Arquivo'+ END_BOLD + CRLF);
    prn.Write(':wq'#9'Salva ateracoes e sai do VI' + CRLF);
    prn.Write(':q!'#9'Sai sem salvar' + CRLF);
    prn.Write(':w abc'#9'Grava arquivo com o nome ''abc''' + CRLF);
    prn.Write(':r abc'#9'Insere o conteudo do arquivo ''abc''' + CRLF);
    prn.Write(':e abc'#9'Edita o arquivo ''abc''' + CRLF);

    prn.Write(CRLF);
    prn.Write(START_BOLD + 'Modo de Insercao'+ END_BOLD + CRLF);
    prn.Write('i'#9'Entra no modo de Insercao' + CRLF);
    prn.Write('a'#9'Entra no modo de Insercao, apos o cursor' + CRLF);
    prn.Write('o'#9'Entra no modo de Insercao, em uma nova linha' + CRLF);
    prn.Write('<ESC>'#9'Sai do modo de Insercao' + CRLF);

    prn.Write(CRLF);
    prn.Write(START_BOLD + 'Copiar, Cortar e Colar'+ END_BOLD + CRLF);
    prn.Write('yy'#9'Copia a linha inteira' + CRLF);
    prn.Write('5yy'#9'Copia as 5 proximas linhas' + CRLF);
    prn.Write('dd'#9'Apaga a linha' + CRLF);
    prn.Write('5dd'#9'Apaga 5 linhas' + CRLF);
    prn.Write('x'#9'Apaga uma letra' + CRLF);
    prn.Write('5x'#9'Apaga 5 letras' + CRLF);
    prn.Write('p'#9'Cola o trecho copiado ou apagado' + CRLF);
    prn.Write('V'#9'Selecao visual de linhas' + CRLF);

    prn.Write(CRLF);
    prn.Write(START_BOLD + 'Pulos'+ END_BOLD + CRLF);
    prn.Write('gg'#9'Pula para a primeira linha' + CRLF);
    prn.Write('G'#9'Pula para a ultima linha' + CRLF);
    prn.Write('44G'#9'Pula para a linha numero 44' + CRLF);
    prn.Write('w'#9'Pula para a proxima palavra' + CRLF);
    prn.Write('b'#9'Pula para a palavra anterior' + CRLF);
    prn.Write('{'#9'Pula para o paragrafo anterior' + CRLF);
    prn.Write('}'#9'Pula para o proximo paragrafo' + CRLF);
    prn.Write('('#9'Pula para a frase anterior' + CRLF);
    prn.Write(')'#9'Pula para a proxima frase' + CRLF);
    prn.Write('f.'#9'Pula até o proximo ponto (.), na mesma linha' + CRLF);
    prn.Write('``'#9'Desfaz o pulo, volta' + CRLF);

    prn.Write(CRLF);
    prn.Write(START_BOLD + 'Apagando com esperteza'+ END_BOLD + CRLF);
    prn.Write('dgg'#9'Apaga ate o inicio do arquivo' + CRLF);
    prn.Write('d0'#9'Apaga ate o inicio da linha atual' + CRLF);
    prn.Write('dw'#9'Apaga a palavra' + CRLF);
    prn.Write('d4b'#9'Apaga as quatro palavras anteriores' + CRLF);
    prn.Write('df.'#9'Apaga ate o proximo ponto' + CRLF);
    prn.Write('d)'#9'Apaga ate o fim da frase' + CRLF);

    prn.Write(CRLF);
    prn.Write(START_BOLD + 'Outros'+ END_BOLD + CRLF);
    prn.Write('J'#9'Junta a proxima linha com a atual' + CRLF);
    prn.Write('u'#9'Desfaz o ultimo comando' + CRLF);
    prn.Write('Ctrl+R'#9'Refaz o ultimo comando desfeito' + CRLF);
    prn.Write('.'#9'Repete o comando anterior' + CRLF);
    prn.Write('hjkl'#9'Movimenta o cursor' + CRLF);
    prn.Write('/'#9'Pesquisa um texto' + CRLF);
    prn.Write('n'#9'Vai para o proximo resultado da pesquisa' + CRLF);
    prn.Write(':%s/a/b/g'#9'Troca ''a'' por ''b'' em todo o texto' + CRLF);
    prn.Write(':!cmd'#9'Executa o comando externo ''cmd''' + CRLF);
    prn.Write(':r!cmd'#9'Insere o resultado do comando externo ''cmd''' + CRLF);

    prn.closeDoc;//Libera para o Spool da impressora
    prn.Free;
  end;
  dlg.Free;
end;

end.
