unit u_Register;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  Vcl.WinXCtrls, Vcl.Mask, Vcl.Imaging.pngimage;

type
  TfrmRegister = class(TForm)
    svSide: TSplitView;
    btnLogin: TBitBtn;
    btnBack: TBitBtn;
    pnlApplication: TPanel;
    stHeader: TStaticText;
    edtUsername: TLabeledEdit;
    pnlHold: TPanel;
    edtPassword: TLabeledEdit;
    edtPasswordConfirm: TLabeledEdit;
    pbQR: TPaintBox;
    btnRegister: TBitBtn;
    imgHelp: TImage;
    procedure FormCreate(Sender: TObject);

    // Fix for multi forums.
    procedure CreateParams(var Params: TCreateParams); override;
    procedure btnBackClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure imgHelpClick(Sender: TObject);
    procedure btnLoginClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmRegister: TfrmRegister;

implementation

{$R *.dfm}

uses u_Functions, u_Application, u_Login;

procedure TfrmRegister.btnBackClick(Sender: TObject);
begin

  // Move forms.
  frmRegister.Hide;
  frmApplication.Show;

end;

procedure TfrmRegister.btnLoginClick(Sender: TObject);
begin

  // Move forms.
  frmRegister.Hide;
  frmLogin.Show;

end;

procedure TfrmRegister.CreateParams(var Params: TCreateParams);
begin
  inherited;

  // Set style sheet so Windows knows its another "window".
  Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
  Params.WndParent := GetDesktopWindow;

end;

procedure TfrmRegister.FormClose(Sender: TObject; var Action: TCloseAction);
begin

  // Fix multi form issues.
  Application.Terminate;

end;

procedure TfrmRegister.FormCreate(Sender: TObject);
begin

  // Form setup.
  TFunctions.disableSize(frmRegister);

  TFunctions.makeRound(pnlHold);

  pnlHold.BevelInner := bvNone;
  pnlHold.BevelKind := bkTile;
  pnlHold.BevelOuter := bvRaised;

  edtPassword.PasswordChar := '*';
  edtPasswordConfirm.PasswordChar := '*';

end;

procedure TfrmRegister.FormShow(Sender: TObject);
begin

  // Always should be centre.
  TFunctions.sizeCentre(frmRegister);

  // Clear all junk.
  edtUsername.Clear;
  edtPassword.Clear;
  edtPasswordConfirm.Clear;

  pbQR.Hide;

end;

procedure TfrmRegister.imgHelpClick(Sender: TObject);
begin

  // Add code for register help.

end;

end.
