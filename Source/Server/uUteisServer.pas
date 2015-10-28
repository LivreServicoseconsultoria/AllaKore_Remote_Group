unit uUteisServer;

interface
  uses IniFiles, SysUtils, Forms, Windows, Form_Config;

  //Marcones Freitas - 16/10/2015 -> Algumas Constantes Novas
 const
 cGeneral            = 'General';
 cHost               = 'Host';
 cPort               = 'Port';
 cGroup              = 'Group';
 cMachine            = 'Machine';
 cConnectTimeOut     = 'ConnectTimeOut';
 cStarterWithWindows = 'StarterWithWindows';
 cYes                = 'YES';
 cNO                 = 'NO';
 cLanguage           = 'Language';

 procedure SaveIni(Param, Value, ArqFile, Name: String; encrypted: Boolean);
 function GetIni(Path, Key, KeyValue : string; encrypted: Boolean): string;
 function EnDecryptString(StrValue : String; Key: Word) : String;
 function ActiveProcess(AValue: String = ''): Boolean;
 function GetPort : Integer;


var
  Port : Integer;
  Group, Machine: string;

 implementation

procedure SaveIni(Param, Value, ArqFile, Name: String; encrypted: Boolean);
var ArqIni : TIniFile;
begin
  ArqIni := TIniFile.Create(ArqFile);
  IF encrypted THEN
     Value := EnDecryptString(Value,250);

  ArqIni.WriteString(Name, Param, Value);
  ArqIni.Free;
end;

function GetIni(Path, Key, KeyValue : string; encrypted: Boolean): string;
var ArqIni : TIniFile;
    ValueINI : string;
begin
  ArqIni := TIniFile.Create(Path);

  ValueINI := ArqIni.ReadString(Key, KeyValue, ValueINI);
  if ValueINI = '' then
     ValueINI := '0'
  else
  IF encrypted THEN
     ValueINI := EnDecryptString(ValueINI,250);

  Result := ValueINI;
  ArqIni.Free;
end;


function EnDecryptString(StrValue : String; Key: Word) : String;
var I: Integer; OutValue : String;
begin
  OutValue := '';
  for I := 1 to Length(StrValue) do
      OutValue := OutValue + char(Not(ord(StrValue[I])-Key));

  Result := OutValue;
end;

function ActiveProcess(AValue: String = ''): Boolean;
begin
  if AnsiSameStr(AValue, EmptyStr) then
     AValue := ExtractFileName(Application.ExeName);

  CreateSemaphore(nil, 1, 1, PChar(AValue));
  Result := (GetLastError = ERROR_ALREADY_EXISTS);
end;

function GetPort : Integer;
begin
  if GetIni(ExtractFilePath(Application.ExeName) + Application.Title+'.ini', cGeneral, cPort, True) = '0' then
     begin
       frm_Config := Tfrm_Config.Create(Application);
       frm_Config.ShowModal;
       FreeAndNil(frm_Config);
     end;
  Result := StrToInt(GetIni(ExtractFilePath(Application.ExeName) + Application.Title+'.ini', cGeneral, cPort, True));
end;
end.

