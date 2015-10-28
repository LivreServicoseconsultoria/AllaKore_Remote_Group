unit uUteis;

interface
  uses System.IniFiles, System.SysUtils, Vcl.Forms, Winapi.Windows, iwSystem, ULanguage, System.Win.ScktComp, uProxy;

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
 cProxy              = 'Proxy';
 cHostProxy          = 'HostProxy';
 cPortProxy          = 'PortProxy';

 procedure SaveIni(Param, Value, ArqFile, Name: String; encrypted: Boolean);
 function GetIni(Path, Key, KeyValue : string; encrypted: Boolean): string;
 function EnDecryptString(StrValue : String; Key: Word) : String;
 function ActiveProcess(AValue: String = ''): Boolean;
 procedure ReadCaptions(language : Integer);
 procedure SetHostPortGroupMach;
 procedure SetLanguage;
 procedure HideApplication;
 procedure ShowApplication;
 procedure CloseAplication;

var
 xLanguage : Integer;
 Languages : TLanguage;
 Host, vGroup, vMachine : string;
 Port, ConnectionTimeout : Integer;
 vParID, vParSenha: string;
 FirstExecute : Boolean;
 { |INICIO| Cleiton 20/10/2015 }
 Proxy: Boolean;
 HostProxy: String;
 PortProxy: integer;

implementation

uses Form_Main;

procedure SaveIni(Param, Value, ArqFile, Name: String; encrypted: Boolean);
var ArqIni : TIniFile;
    I: Integer;
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

procedure ReadCaptions(language : Integer);
Var
  IniFile : string;
begin
  IniFile := gsAppPath + 'Language';
  Languages.Free;
  Languages := TLanguage.Create();

  if(language = 0)then
   begin
     Languages.YourID_Label       := String(GetIni(IniFile +'\US.ini','CAPTIONS','YourID_Label',false));
     Languages.YourPassword_Label := String(GetIni(IniFile +'\US.ini','CAPTIONS','YourPassword_Label',false));
     Languages.TargetID_Label     := String(GetIni(IniFile +'\US.ini','CAPTIONS','TargetID_Label',false));
     Languages.Language_Label     := String(GetIni(IniFile +'\US.ini','CAPTIONS','Language_Label',false));
   end
  else
  if(language = 1)then
     begin
      Languages.YourID_Label       := String(GetIni(IniFile +'\Pt_Br.ini','CAPTIONS','YourID_Label',false));
      Languages.YourPassword_Label := String(GetIni(IniFile +'\Pt_Br.ini','CAPTIONS','YourPassword_Label',false));
      Languages.TargetID_Label     := String(GetIni(IniFile +'\Pt_Br.ini','CAPTIONS','TargetID_Label',false));
      Languages.Language_Label     := String(GetIni(IniFile +'\Pt_Br.ini','CAPTIONS','Language_Label',false));
     end

end;

procedure SetHostPortGroupMach;
{ |INICIO| CLEITON EM 20/10/2015 }
var
  s: string;
  Code: integer;
  I: integer;

  procedure ApplyProxy(pSocket: TClientSocket);
  begin
    pSocket.Open;
    SockWriteLn(pSocket.Socket.SocketHandle,
      format('CONNECT %s:%d HTTP/1.1'#13#10, [Host, Port]));
    s := SockReadLn(pSocket.Socket.SocketHandle);
    if Length(s) = 0 then
      raise Exception.Create('Bad HTTP respond');
    Fetch(s, ' '); // to remove the http/1.0 or http/1.1
    Code := StrToIntDef(Fetch(s, ' '), 200);
    // if invalid response then we assume it succeeded
    if Code <> 200 then
      raise Exception.CreateFmt('Bad HTTP status code: %d %s', [Code, s]);
    I := 128;
    repeat
      Dec(I)
    until (SockReadLn(pSocket.Socket.SocketHandle) = '') or (I <= 0);
    if I <= 0 then
      raise Exception.Create('Too many headers or wrong protocol');
    // SockWriteLn(pSocket.Socket.SocketHandle,format('Proxy-Authorization: %s'#13#10,[BasicAuthentication(Username,Password)]));
  end;
 { |FIM| CLEITON EM 20/10/2015 }
begin
//  frm_Main.Main_Socket.Host     := Host;
//  frm_Main.Main_Socket.Port     := Port;
//  frm_Main.Desktop_Socket.Host  := Host;
//  frm_Main.Desktop_Socket.Port  := Port;
//  frm_Main.Keyboard_Socket.Host := Host;
//  frm_Main.Keyboard_Socket.Port := Port;
//  frm_Main.Files_Socket.Host    := Host;
//  frm_Main.Files_Socket.Port    := Port;


 frm_Main.Main_Socket.Active     := false;
 frm_Main.Desktop_Socket.Active  := false;
 frm_Main.Keyboard_Socket.Active := false;
 frm_Main.Files_Socket.Active    := false;

 if Proxy then  { |PROXY| CLEITON EM 20/10/2015 }
  begin
    frm_Main.Main_Socket.Active     := false;
    frm_Main.Main_Socket.ClientType := ctBlocking;
    frm_Main.Main_Socket.Host       := HostProxy;
    frm_Main.Main_Socket.Port       := PortProxy;
    ApplyProxy(frm_Main.Main_Socket);

    frm_Main.Desktop_Socket.ClientType := ctBlocking;
    frm_Main.Desktop_Socket.Host       := HostProxy;
    frm_Main.Desktop_Socket.Port       := PortProxy;
    ApplyProxy(frm_Main.Desktop_Socket);

    frm_Main.Desktop_Socket.ClientType := ctBlocking;
    frm_Main.Desktop_Socket.Host       := HostProxy;
    frm_Main.Desktop_Socket.Port       := PortProxy;
    ApplyProxy(frm_Main.Desktop_Socket);

    frm_Main.Keyboard_Socket.ClientType := ctBlocking;
    frm_Main.Keyboard_Socket.Host       := HostProxy;
    frm_Main.Keyboard_Socket.Port       := PortProxy;
    ApplyProxy(frm_Main.Keyboard_Socket);

    frm_Main.Files_Socket.ClientType := ctBlocking;
    frm_Main.Files_Socket.Host       := HostProxy;
    frm_Main.Files_Socket.Port       := PortProxy;
    ApplyProxy(frm_Main.Files_Socket);

  end
 else
  begin
    frm_Main.Main_Socket.Host       := Host;
    frm_Main.Main_Socket.Port       := Port;
    frm_Main.Main_Socket.ClientType := ctNonBlocking;

    frm_Main.Desktop_Socket.Host       := Host;
    frm_Main.Desktop_Socket.Port       := Port;
    frm_Main.Desktop_Socket.ClientType := ctBlocking;

    frm_Main.Keyboard_Socket.Host       := Host;
    frm_Main.Keyboard_Socket.Port       := Port;
    frm_Main.Keyboard_Socket.ClientType := ctBlocking;

    frm_Main.Files_Socket.Host       := Host;
    frm_Main.Files_Socket.Port       := Port;
    frm_Main.Files_Socket.ClientType := ctBlocking;
  end;

end;

procedure SetLanguage;
begin
  xLanguage := strtoint(GetIni(ExtractFilePath(Application.ExeName) + Application.Title + '.ini', cGeneral, cLanguage, true));
  ReadCaptions(xLanguage);
  frm_Main.YourID_Label.Caption       := Languages.YourID_Label;
  frm_Main.YourPassword_Label.Caption := Languages.YourPassword_Label;
  frm_Main.TargetID_Label.Caption     := Languages.TargetID_Label;
end;

procedure HideApplication;
begin
  frm_Main.Hide;
end;

procedure ShowApplication;
begin
  frm_Main.Show;
  frm_Main.WindowState := wsNormal;
end;

procedure CloseAplication;
begin
 Application.ProcessMessages;
 if Application.MessageBox(PChar('Confirm close the Application?'), PChar(frm_Main.Caption), mb_YesNo + mb_DefButton2 + mb_IconQuestion) = IdYes then
    Halt;
end;

end.
