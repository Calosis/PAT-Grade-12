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
  u_Google2FA in 'u_Google2FA.pas',
  u_Objectives in 'u_Objectives.pas' {frmObjectives},
  u_ObjectiveO in 'u_ObjectiveO.pas',
  u_View in 'u_View.pas' {frmView},
  u_Create in 'u_Create.pas' {frmCreate},
  u_Admin in 'u_Admin.pas' {frmAdmin};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Windows11 MineShaft');
  Application.CreateForm(TfrmApplication, frmApplication);
  Application.CreateForm(TdmConnection, dmConnection);
  Application.CreateForm(TfrmRegister, frmRegister);
  Application.CreateForm(TfrmLogin, frmLogin);
  Application.CreateForm(TfrmObjectives, frmObjectives);
  Application.CreateForm(TfrmView, frmView);
  Application.CreateForm(TfrmCreate, frmCreate);
  Application.CreateForm(TfrmAdmin, frmAdmin);
  Application.Run;
end.
