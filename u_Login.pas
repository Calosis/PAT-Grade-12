unit u_Login;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  Vcl.WinXCtrls, Vcl.Mask, Vcl.Imaging.pngimage;

type
  TfrmLogin = class(TForm)
    svSide: TSplitView;
    btnRegister: TBitBtn;
    btnBack: TBitBtn;
    pnlApplication: TPanel;
    stHeader: TStaticText;
    pnlHold: TPanel;
    imgHelp: TImage;
    edtUsername: TLabeledEdit;
    edtPassword: TLabeledEdit;
    btnLogin: TBitBtn;
    edt2FA: TLabeledEdit;
    // Fix for multi forums.
    procedure CreateParams(var Params: TCreateParams); override;

    procedure imgHelpClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnBackClick(Sender: TObject);
    procedure btnRegisterClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmLogin: TfrmLogin;

implementation

{$R *.dfm}

uses u_Application, u_Functions, u_Register;

procedure TfrmLogin.btnBackClick(Sender: TObject);
begin

  frmLogin.Hide;
  frmApplication.Show;

end;

procedure TfrmLogin.btnRegisterClick(Sender: TObject);
begin

  // Move forms.
  frmLogin.Hide;
  frmRegister.Show;

end;

procedure TfrmLogin.CreateParams(var Params: TCreateParams);
begin
  inherited;

  // Set style sheet so Windows knows its another "window".
  Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
  Params.WndParent := GetDesktopWindow;
end;

procedure TfrmLogin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // Fix multi form issues.
  Application.Terminate;
end;

procedure TfrmLogin.FormCreate(Sender: TObject);
begin

  // Form setup.
  TFunctions.disableSize(frmLogin);

  TFunctions.makeRound(pnlHold);

  pnlHold.BevelInner := bvNone;
  pnlHold.BevelKind := bkTile;
  pnlHold.BevelOuter := bvRaised;

  edtPassword.PasswordChar := '*';

end;

procedure TfrmLogin.FormShow(Sender: TObject);
begin

  // Always should be centre.
  TFunctions.sizeCentre(frmLogin);

  // Clear all junk.
  edtUsername.Clear;
  edtPassword.Clear;
  edt2FA.Clear;

end;

procedure TfrmLogin.imgHelpClick(Sender: TObject);
begin

  // Add code here for help.

end;

end.
