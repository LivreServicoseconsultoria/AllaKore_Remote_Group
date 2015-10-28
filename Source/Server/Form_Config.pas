unit Form_Config;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls,
  Buttons, ExtCtrls, registry,  acPNG,
  Spin;

type
  Tfrm_Config = class(TForm)
    sbSave: TSpeedButton;
    chkStarter: TCheckBox;
    tmrCheck: TTimer;
    lblPort: TLabel;
    sePort: TSpinEdit;
    TopBackground_Image: TImage;
    Label1: TLabel;
    PasswordIcon_Image: TImage;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure tmrCheckTimer(Sender: TObject);
    procedure sbSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frm_Config: Tfrm_Config;

implementation

{$R *.dfm}

uses Form_Main,
  uUteisServer;

procedure Tfrm_Config.FormCreate(Sender: TObject);
var Reg: TRegistry; S: string;
begin
 sePort.Text           := GetIni(ExtractFilePath(Application.ExeName) + Application.Title+'.ini', cGeneral, cPort, True);
 s                     := GetIni(ExtractFilePath(Application.ExeName) + Application.Title+'.ini', cGeneral, cStarterWithWindows, True);

 if s = cYes then
    chkStarter.Checked := True
 else
     chkStarter.Checked := False;
end;

procedure Tfrm_Config.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  //Marcones Freitas - 16/10/2015 -> Disable Alt + F4
  if (Key = VK_F4) or (Key = VK_ESCAPE) then
      Key := 0;
end;

procedure Tfrm_Config.FormKeyPress(Sender: TObject; var Key: Char);
begin
  //Marcones Freitas - 16/10/2015 -> Pula para o proximo campo com o ENTER
  IF Key = #13 THEN
    BEGIN
     Key := #0;
     Perform(Wm_NextDlgCtl,0,0);
    END;
end;

procedure Tfrm_Config.FormShow(Sender: TObject);
begin
 tmrCheck.Enabled := True;
end;

procedure Tfrm_Config.sbSaveClick(Sender: TObject);
var Reg: TRegistry; S: string;
begin
  Reg         := TRegistry.Create;
  S           :=ExtractFileDir(Application.ExeName)+'\'+ExtractFileName(Application.ExeName);
  Reg.rootkey :=HKEY_LOCAL_MACHINE;
  Reg.Openkey('SOFTWARE\MICROSOFT\WINDOWS\CURRENTVERSION\RUN',false);
  if chkStarter.Checked then
      begin
       Reg.WriteString(Caption, S);
       SaveIni(cStarterWithWindows, cYes, ExtractFilePath(Application.ExeName) + Application.Title+'.ini', cGeneral,True);
      end
  else
      begin
       Reg.DeleteValue(Caption);
       SaveIni(cStarterWithWindows, cNO, ExtractFilePath(Application.ExeName) + Application.Title+'.ini',cGeneral,True);
      end;

  SaveIni(cPort, sePort.Text, ExtractFilePath(Application.ExeName) + Application.Title+'.ini',cGeneral,True);
  Port  := sePort.Value;
  Close;
end;

procedure Tfrm_Config.tmrCheckTimer(Sender: TObject);
begin
  if (sePort.Value = 0)then
      sbSave.Enabled := False
  else
      sbSave.Enabled := True;
end;

end.
