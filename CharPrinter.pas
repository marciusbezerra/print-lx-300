//---------------------------------------------------------------
// CharPrinter.pas - Tratamento de impressoras em modo caractere
//---------------------------------------------------------------
// Autor : Fernando Allen Marques de Oliveira
//         Dezembro de 2000.
//
// TPrinterStream : classe derivada de TStream para enviar dados
//                  diretamente para o spool da impressora sele-
//                  cionada.
//
// TCharPrinter : Classe base para implementa??o de impressoras.
//                n?o inclui personaliza??o para nenhuma impres-
//                sora espec?fica, envia dados sem formata??o.
//
// Modificado em 20/05/2003 - Compatibiliza??o com diretivas padr?o do Delphi 7

unit CharPrinter;

interface

uses
 Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
 Printers, WinSpool;

type
 { Stream para enviar caracteres ? impressora atual }
 TPrinterStream = class (TStream)
 private
   fPrinter : TPrinter;
   fHandle  : THandle;
   fTitle   : String;
   procedure  CreateHandle;
   procedure  FreeHandle;
 public
   constructor Create (aPrinter: TPrinter; aTitle : String);
   destructor  Destroy; override;
   function    Write (const Buffer; Count : Longint): Longint; override;
   property    Handle : THandle read fHandle;
 end;

 TCharPrinter = class(TObject)
 private
   { Private declarations }
   fStream   : TStream;
 protected
   { Protected declarations }
 public
   { Public declarations }
 published
   { Published declarations }
   constructor Create; virtual;
   destructor  Destroy; override;
   procedure   OpenDoc (aTitle : String); virtual;
   procedure   SendData (aData : String);
   procedure   CloseDoc; virtual;
   property    PrintStream : TStream read fStream;
 end;

 // Defini??es para TAdvancedPrinter //

 TprtLang = (lngEPFX,lngESCP2,lngHPPCL);
 TprtFontSize = (pfs5cpi,pfs10cpi,pfs12cpi,pfs17cpi,pfs20cpi);
 TprtTextStyle = (psBold,psItalic,psUnderline);
 TprtTextStyles = set of TprtTextStyle;

 TAdvancedPrinter = class (TCharPrinter)
 private
   fLang : TprtLang;
   fFontSize : TprtFontSize;
   fTextStyle : TprtTextStyles;
   procedure SetLang (lang : TprtLang);
   function  GetLang : TprtLang;
   procedure SetFontSize (size : TprtFontSize);
   function  GetFontSize : TprtFontSize;
   procedure SetTextStyle (styles : TprtTextStyles);
   function  GetTextStyle : TprtTextStyles;
   procedure UpdateStyle;
   procedure Initialize;
   function  Convert (s : string) : string;
 published
   constructor Create; override;
   procedure   OpenDoc (aTitle : String); override;
   property Language : TprtLang read GetLang write SetLang;
   property FontSize : TprtFontSize read GetFontSize write SetFontSize;
   property TextStyle : TprtTextStyles read GetTextStyle write SetTextStyle;
 public
   procedure CR;
   procedure LF; overload;
   procedure LF (Lines : integer); overload;
   procedure CRLF;
   procedure FF;
   procedure Write (txt : string);
   procedure WriteLeft  (txt, fill : string; size : integer);
   procedure WriteRight (txt, fill : string; size : integer);
   procedure WriteCenter(txt, fill : string; size : integer);
   procedure WriteRepeat(txt : string; quant : integer);
 end;

procedure Register;

implementation

procedure Register;
begin
{  RegisterComponents('AeF', [TCharPrinter]);}
end;

{ =================== }
{ =  TPrinterStream = }
{ =================== }

constructor TPrinterStream.Create (aPrinter : TPrinter; aTitle : String);
begin
 inherited Create;
 fPrinter := aPrinter;
 fTitle   := aTitle;
 CreateHandle;
end;

destructor TPrinterStream.Destroy;
begin
 FreeHandle;
 inherited;
end;

procedure TPrinterStream.FreeHandle;
begin
 if fHandle <> 0 then
 begin
   EndPagePrinter (fHandle);
   EndDocPrinter  (fHandle);
   ClosePrinter   (Handle);
   fHandle := 0;
 end;
end;

procedure TPrinterStream.CreateHandle;
type
 DOC_INFO_1 = packed record
   pDocName    : PChar;
   pOutputFile : PChar;
   pDataType   : PChar;
 end;
var
 aDevice,
 aDriver,
 aPort    : array[0..255] of Char;
 aMode    : Cardinal;
 DocInfo : DOC_INFO_1;
begin
 DocInfo.pDocName := nil;
 DocInfo.pOutputFile := nil;
 DocInfo.pDataType := 'RAW';

 FreeHandle;
 if fHandle = 0 then
 begin
   fPrinter.GetPrinter (aDevice, aDriver, aPort, aMode);
   if OpenPrinter (aDevice, fHandle, nil)
   then begin
     DocInfo.pDocName := PChar(fTitle);
     if StartDocPrinter (fHandle, 1, @DocInfo) = 0
     then begin
       ClosePrinter (fHandle);
       fHandle := 0;
     end else
     if not StartPagePrinter (fHandle)
     then begin
       EndDocPrinter (fHandle);
       ClosePrinter  (fHandle);
       fHandle := 0;
     end;
   end;
 end;
end;

function TPrinterStream.Write (const Buffer; Count : Longint) : Longint;
var
 Bytes : Cardinal;
begin
 WritePrinter (Handle, @Buffer, Count, Bytes);
 Result := Bytes;
end;

{ ================= }
{ =  TCharPrinter = }
{ ================= }

constructor TCharPrinter.Create;
begin
 inherited Create;
 fStream := nil;
end;

destructor TCharPrinter.Destroy;
begin
 if fStream <> nil
 then fStream.Free;
 inherited;
end;

procedure TCharPrinter.OpenDoc (aTitle : String);
begin
 if fStream = nil
 then fStream := TPrinterStream.Create (Printer, aTitle);
end;

procedure   TCharPrinter.CloseDoc;
begin
 if fStream <> nil
 then begin
   fStream.Free;
   fStream := nil;
 end;
end;

procedure   TCharPrinter.SendData (aData : String);
var
 Data : array[0..255] of char;
 cnt  : integer;
begin
 for cnt := 0 to length(aData) - 1
 do Data[cnt] := aData[cnt+1];

 fStream.Write (Data, length(aData));
end;

{ ===================== }
{ =  TAdvancedPrinter = }
{ ===================== }

procedure TAdvancedPrinter.SetLang (lang : TprtLang);
begin
 fLang := lang;
end;

function  TAdvancedPrinter.GetLang : TprtLang;
begin
 result := fLang;
end;

procedure TAdvancedPrinter.SetFontSize (size : TprtFontSize);
begin
 fFontSize := size;
 UpdateStyle;
end;

function  TAdvancedPrinter.GetFontSize : TprtFontSize;
begin
 result := fFontSize;
 UpdateStyle;
end;

procedure TAdvancedPrinter.SetTextStyle (styles : TprtTextStyles);
begin
 fTextStyle := styles;
 UpdateStyle;
end;

function  TAdvancedPrinter.GetTextStyle : TprtTextStyles;
begin
 result := fTextStyle;
 UpdateStyle;
end;

procedure TAdvancedPrinter.UpdateStyle;
var
 cmd : string;
 i : byte;
begin
 cmd := '';
 case fLang of
   lngESCP2, lngEPFX : begin
     i := 0;
     Case fFontSize of
       pfs5cpi  : i := 32;
       pfs10cpi : i := 0;
       pfs12cpi : i := 1;
       pfs17cpi : i := 4;
       pfs20cpi : i := 5;
     end;
     if psBold in fTextStyle then i := i + 8;
     if psItalic in fTextStyle then i := i + 64;
     if psUnderline in fTextStyle then i := i + 128;
     cmd := #27'!'+chr(i);
   end;
   lngHPPCL : begin
     Case fFontSize of
       pfs5cpi  : cmd := #27'(s5H';
       pfs10cpi : cmd := #27'(s10H';
       pfs12cpi : cmd := #27'(s12H';
       pfs17cpi : cmd := #27'(s17H';
       pfs20cpi : cmd := #27'(s20H';
     end;
     if psBold in fTextStyle
       then cmd := cmd + #27'(s3B'
       else cmd := cmd + #27'(s0B';
     if psItalic in fTextStyle
       then cmd := cmd + #27'(s1S'
       else cmd := cmd + #27'(s0S';
     if psUnderline in fTextStyle
       then cmd := cmd + #27'&d0D'
       else cmd := cmd + #27'&d@';
   end;
 end;
 SendData(cmd);
end;

procedure TAdvancedPrinter.Initialize;
begin
 case fLang of
   lngEPFX  : SendData (#27'@'#27'2'#27'P'#18);
   lngESCP2 : SendData (#27'@'#27'O'#27'2'#27'C0'#11#27'!'#0);
   lngHPPCL : SendData (#27'E'#27'&l2A'#27'&l0O'#27'&l6D'#27'(s4099T'#27'(s0P'#27'&k0S'#27'(s0S');
 end;
end;

function  TAdvancedPrinter.Convert (s : string) : string;
const
 accent   : string = '??????????????????????????????????????????????';
 noaccent : string = 'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC';
var
 i : integer;
begin
 for i := 1 to length(accent) do
   While Pos(accent[i],s) > 0 do s[Pos(accent[i],s)] := noaccent[i];
 result := s;
end;

constructor TAdvancedPrinter.Create;
begin
 inherited Create;
 fLang := lngESCP2;
 fFontSize := pfs10cpi;
 fTextStyle := [];
end;

procedure   TAdvancedPrinter.OpenDoc (aTitle : String);
begin
 inherited OpenDoc (aTitle);
 Initialize;
end;

procedure TAdvancedPrinter.CR;
begin
 SendData (#13);
end;

procedure TAdvancedPrinter.LF;
begin
 SendData (#10);
end;

procedure TAdvancedPrinter.LF (Lines : integer);
begin
 while lines > 0 do begin
   SendData(#10); dec(lines);
 end;
end;

procedure TAdvancedPrinter.CRLF;
begin
 SendData (#13#10);
end;

procedure TAdvancedPrinter.FF;
begin
 SendData(#12);
end;

procedure TAdvancedPrinter.Write (txt : string);
begin
 txt := Convert (txt);
 SendData (txt);
end;

procedure TAdvancedPrinter.WriteLeft  (txt, fill : string; size : integer);
begin
 txt := Convert(txt);
 while Length(txt) < size do txt := txt + fill;
 SendData (Copy(txt,1,size));
end;

procedure TAdvancedPrinter.WriteRight (txt, fill : string; size : integer);
begin
 txt := Convert(txt);
 while Length(txt) < size do txt := fill + txt;
 SendData (Copy(txt,Length(txt)-size+1,size));
end;

procedure TAdvancedPrinter.WriteCenter(txt, fill : string; size : integer);
begin
 txt := Convert(txt);
 while Length(txt) < size do txt := fill + txt + fill;
 SendData (Copy(txt,(Length(txt)-size) div 2 + 1,size));
end;

procedure TAdvancedPrinter.WriteRepeat(txt : string; quant : integer);
var
 s : string;
begin
 s := '';
 txt := Convert(txt);
 while quant > 0 do begin
   s := s + txt;
   dec(quant);
 end;
 SendData (s);
end;


end.

Fernando Allen08-May-2003, 22:10
Para quem n?o entendeu como utilizar a biblioteca acima, segue abaixo um c?digo de exemplo para a utiliza??o desta biblioteca. Anexe este c?digo ao evento OnClick de um bot?o qualquer em seu formul?rio e teste.

N?o se esque?a de acrescentar CharPrinter na cl?usula Uses de seu formul?rio

CODE
procedure TForm1.Button1Click (Sender : TObject);
var
 Prn : TCharPrinter;
begin
 // Cria o objeto de impressora e abre o documento para impress?o
 Prn := TCharPrinter.Create;
 Prn.OpenDoc ('Nome do seu relat?rio que aparecer? no spool do windows');

 // Inicializa a impressora
 Prn.SendData (#27'@');

 // Envia seu texto #13#10 = CR+LF (Retorno de carro mas avan?o de linha = pula para pr?xima linha)
 Prn.SendData ('Escreva seu texto aqui'#13#10);
 Prn.SendData (#13#10);
 Prn.SendData (#15'Esta linha esta com os caracteres condensados'#18#13#10);

 // Avan?o de p?gina
 Prn.SendData (#12);

 // Fecha o relat?rio, manda para o spool e destroy o objeto
 Prn.CloseDoc;
 Prn.Free;
end;


O objeto TAdvancedPrinter, descendente de TCharPrinter foi personalizado para reconhecer a linguagem das impressoras Epson LX/FX/ESCP2 e ainda HPPCL para escrever em Deskjets e Laserjets.

Tamb?m inclui m?todos para controlar o tamanho dos caracteres, avan?ar linhas e escrever textos com tamanho fixo e alinhados ? direita, ? esquerda e centralizados.

qualquer d?vida na utiliza??o, mande mensagem particular para mim. 
Fernando Allen08-July-2003, 09:29
Amigos,

Como estou recebendo muitas d?vidas na utiliza??o desta classe, criei um pequeno projeto em delphi para melhor exemplificar. Voc?s podem fazer o download deste arquivo atrav?s deste link:

http://www.devmind.kit.net/demo_charprinter.zip

Se voc? obsevarem o c?digo fonte, ver?o que na TAdvancedPrinter eu acrescentei alguns m?todos adicionais muito ?teis e a capacidade de trabalhar com tr?s padr?es de comandos de impress?o: EpsonFX, EpsonESC/P2 e HPPCL podendo escolher os tamanhos mais comuns de caracteres nas matriciais:

// Determina qual a linguagem (c?digo de controle) de impressora ser? utilizado
property Language : TprtLang read GetLang write SetLang;

// Muda o tamanho da fonte padr?o da impressora (em CPI - Caracteres por polegada)
property FontSize : TprtFontSize read GetFontSize write SetFontSize;

// Conjunto de atributos que combinados definem o estilo de texto (Bold, It?lico, Sublinhado, etc)
property TextStyle : TprtTextStyles read GetTextStyle write SetTextStyle;

// Promove o retorno de carro
procedure CR;

// Promove o avan?o de linha
procedure LF; overload;

// Faz avan?ar n linhas
procedure LF (Lines : integer); overload;

// Retorno de carro + avan?o de linha = come?o da pr?xima linha
procedure CRLF;

// Avan?o de formul?rio - pr?xima p?gina
procedure FF;

// Envia uma string para a impressora - sem pular linha
procedure Write (txt : string);

// Envia uma string (txt) alinhada ? esquerda com tamanho m?ximo = size e
// com o espa?o restante preenchido com a string fill (sim, pode ser mais de um caractere)
procedure WriteLeft (txt, fill : string; size : integer);

// O mesmo que o m?todo anterior, mas alinhando ? direita
procedure WriteRight (txt, fill : string; size : integer);

// Alinhamento centralizado
procedure WriteCenter(txt, fill : string; size : integer);

// Para quem quiser repetir uma string ou caracteres uma determinada quantidade de vezes
procedure WriteRepeat(txt : string; quant : integer);
