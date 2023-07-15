unit u_Application;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.WinXPanels,
  Vcl.WinXCtrls, Vcl.StdCtrls, Vcl.Buttons, Vcl.Imaging.pngimage, Vcl.ComCtrls,
  Data.DB, Vcl.Grids, Vcl.DBGrids, u_ObjectiveO;

type
  TfrmApplication = class(TForm)
    svSide: TSplitView;
    btnLogin: TBitBtn;
    btnRegister: TBitBtn;
    pnlApplication: TPanel;
    imgMenu: TImage;
    btnAdmin: TBitBtn;
    stName: TStaticText;
    redInform: TRichEdit;
    btnReset: TButton;
    procedure FormCreate(Sender: TObject);
    procedure imgMenuClick(Sender: TObject);
    procedure btnRegisterClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnLoginClick(Sender: TObject);
    procedure btnResetClick(Sender: TObject);
    procedure btnAdminClick(Sender: TObject);

  private
  public
    { Public declarations }
    bShown: Boolean;
  end;

var
  frmApplication: TfrmApplication;

implementation

{$R *.dfm}

uses u_Functions, u_Register, u_Login, u_DatabaseConnection, u_Admin;

procedure TfrmApplication.btnAdminClick(Sender: TObject);
var
  sUsername: String;
begin
  // Grab from user.
  sUsername := InputBox('Impactify Admin', 'Admin Username:', '');

  // Check.
  if (sUsername = NullAsStringValue) then
  begin
    MessageDlg('Please enter a username.', TMsgDlgType.mtError,
      [TMsgDlgBtn.mbOK], 0);
    Exit;
  end;

  // Find user in database.
  Functions.openSQL('SELECT Username FROM tblUsers WHERE Username = "' +
    sUsername + '"');

  // If not empty result from SQL. (Username found)
  if NOT((dmConnection.qrQuery.EOF)) then
  begin

    Functions.openSQL('SELECT SuperUser FROM tblUsers WHERE Username = "' +
      sUsername + '"');

    if (dmConnection.qrQuery.Fields[0].AsBoolean = true) then
    begin
      // Allow in.
      frmApplication.Hide;
      frmAdmin.Show;
    end
    else
    begin
      // Notify user they are not a superuser.
      MessageDlg('This user is not an admin.', TMsgDlgType.mtError,
        [TMsgDlgBtn.mbOK], 0);
      Exit;
    end;
  end
  else
  begin
    // Username not found.
    MessageDlg('This username does not exist.', TMsgDlgType.mtError,
      [TMsgDlgBtn.mbOK], 0);
  end;
end;

procedure TfrmApplication.btnLoginClick(Sender: TObject);
begin
  // Move form.
  frmApplication.Hide;
  frmLogin.Show;
end;

procedure TfrmApplication.btnRegisterClick(Sender: TObject);
begin
  // Move between forms.
  frmApplication.Hide;
  frmRegister.Show;
end;

procedure TfrmApplication.btnResetClick(Sender: TObject);
begin
  // Run db reset.
  Functions.resetDB;
end;

procedure TfrmApplication.FormCreate(Sender: TObject);
begin
  // Don't allow resize.
  Functions.disableSize(frmApplication);

  // Set some basics.
  redInform.Enabled := false;

  stName.Alignment := taCenter;
  redInform.Alignment := taCenter;
end;

procedure TfrmApplication.FormShow(Sender: TObject);
begin
  // New window should be centre.
  Functions.sizeCentre(frmApplication);

  // Set
  bShown := true;
end;

procedure TfrmApplication.imgMenuClick(Sender: TObject);
begin
  // Sliding panel logic.
  if (bShown = true) then
  begin
    svSide.Opened := false;

    pnlApplication.BevelInner := bvNone;
    pnlApplication.BevelKind := bkNone;
    pnlApplication.BevelOuter := bvNone;
    bShown := false;
  end
  else
  begin
    svSide.Opened := true;

    pnlApplication.BevelInner := bvNone;
    pnlApplication.BevelKind := bkNone;
    pnlApplication.BevelOuter := bvRaised;
    bShown := true;
  end;
end;

end.
