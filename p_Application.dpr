program p_Application;

uses
  Vcl.Forms,
  u_Application in 'u_Application.pas' {frmApplication},
  Vcl.Themes,
  Vcl.Styles,
  u_DatabaseConnection in 'u_DatabaseConnection.pas' {dmConnection: TDataModule},
  u_Functions in 'u_Functions.pas',
  u_Register in 'u_Register.pas' {frmRegister},
  u_QRCode in 'u_QRCode.pas',
  u_Login in 'u_Login.pas' {frmLogin},
  u_Base32 in 'u_Base32.pas',
  u_Google2FA in 'u_Google2FA.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Windows11 MineShaft');
  Application.CreateForm(TfrmApplication, frmApplication);
  Application.CreateForm(TdmConnection, dmConnection);
  Application.CreateForm(TfrmRegister, frmRegister);
  Application.CreateForm(TfrmLogin, frmLogin);
  Application.Run;
end.
