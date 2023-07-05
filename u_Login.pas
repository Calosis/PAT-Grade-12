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
    edtUsername: TLabeledEdit;
    edtPassword: TLabeledEdit;
    btnLogin: TBitBtn;
    tOTP: TTimer;
    // Fix for multi forums.
    procedure CreateParams(var Params: TCreateParams); override;

    // Added.
    function isEmpty(): Boolean;

    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnBackClick(Sender: TObject);
    procedure btnRegisterClick(Sender: TObject);
    procedure btnLoginClick(Sender: TObject);
    procedure tOTPTimer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmLogin: TfrmLogin;
  iOTP: Integer;
  sToken: String;

implementation

{$R *.dfm}

uses u_Application, u_Functions, u_Register, u_DatabaseConnection, u_Google2FA;

procedure TfrmLogin.btnBackClick(Sender: TObject);
begin

  frmLogin.Hide;
  frmApplication.Show;

end;

procedure TfrmLogin.btnLoginClick(Sender: TObject);
var
  bFound, bAuth: Boolean;
  sUsernameT, sPasswordT, sTemp, sSQL: String;
  iOTPUser: Integer;
begin

  // Set.
  bFound := false;
  bAuth := true;

  sUsername := edtUsername.Text;
  sPassword := edtPassword.Text;

  edtUsername.Font.Color := clBlack;
  edtPassword.Font.Color := clBlack;

  // Login logic.
  if NOT(isEmpty = true) then
  begin
    // Deny and stop all further code.
    Exit;
  end;

  // Find user in database.
  sSQL := 'SELECT Username FROM tblUsers WHERE Username = "' + sUsername + '"';

  // Query db.
  dmConnection.qrQuery.SQL.Clear;
  dmConnection.qrQuery.SQL.ADD(sSQL);
  dmConnection.qrQuery.Open;

  // If not empty result from SQL. (Username found)
  if NOT((dmConnection.qrQuery.EOF)) then
  begin

    // Set username found.
    bFound := true;

    // Lets get the password now + 2FAToken.
    TFunctions.openSQL('SELECT Password FROM tblUsers WHERE Username = "' +
      sUsername + '"');
    sPasswordT := dmConnection.qrQuery.Fields[0].AsString;
    ShowMessage('P:' + sPasswordT);

    // Token.
    TFunctions.openSQL('SELECT [2FAToken] FROM tblUsers WHERE Username = "' +
      sUsername + '"');
    sToken := dmConnection.qrQuery.Fields[0].AsString;
    ShowMessage('T:' + sToken);

  end;

  // Username is here, lets see if passwords match.
  if (bFound = true) then
  begin

    // Check password.
    if NOT(sPasswordT = sPassword) then
    begin
      MessageDlg('Password is incorrect, please retry.', TMsgDlgType.mtError,
        [TMsgDlgBtn.mbOK], 0);
      edtPassword.Font.Color := clRed;
      edtPassword.Focused;
      bAuth := false;

      // Dont allow any more code to run...
      Exit;
    end;
  end
  else
  begin
    // Username not found.
    MessageDlg('Username does not exist.', TMsgDlgType.mtError,
      [TMsgDlgBtn.mbOK], 0);
    edtUsername.Font.Color := clRed;
    Exit;
  end;

  // Password and username correct, lets verify 2FA now.
  if (bAuth = true) then
  begin

    // Grab OTP from user.
    sTemp := InputBox('Impactify Login:', 'OTP:', '');

    if TFunctions.isNumber(sTemp) = false then
    begin
      ShowMessage('Please enter a number.');
      Exit;
    end;

    // Safe to store in int.
    iOTPUser := StrToInt(sTemp);

    // Keep going until the person enters the otp.
    while (iOTPUser <> iOTP) do
    begin

      // Notify user.
      if MessageDlg('OTP Incorrect. Do you want to try again?', mtConfirmation,
        [mbYes, mbNo], 0, mbYes) = mrNo then
      begin
        Exit;
      end
      else
      begin

        // Grab OTP from user.
        sTemp := InputBox('Impactify Login:', 'OTP:', '');

        if TFunctions.isNumber(sTemp) = false then
        begin
          ShowMessage('Please enter a number.');
          Exit;
        end;

        // Safe to store in int.
        iOTPUser := StrToInt(sTemp);

      end;
    end;

    // Check again so we don't let past people.
    if iOTP = iOTPUser then
    begin

      // 2FA on account, login.

      // Cleanup.
      edtUsername.Clear;
      edtPassword.Clear;

      // Show.
      ShowMessage('Login here.');

      // Update last login data for user.
      TFunctions.execSQL('UPDATE tblUsers SET LastLogin = #' + DateToStr(Now) +
        '# WHERE Username = "' + sUsername + '"');

    end;
  end;
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

end;

function TfrmLogin.isEmpty: Boolean;
begin

  // Set.
  Result := true;

  // Check if everything is here.
  if (sUsername = NullAsStringValue) then
  begin

    // Deny + Notify
    Result := false;
    MessageDlg('Please input a username.', TMsgDlgType.mtError,
      [TMsgDlgBtn.mbOK], 0);

    edtUsername.Focused;
    edtUsername.Color := clRed;

  end;
  if (sPassword = NullAsStringValue) then
  begin

    // Deny + Notify
    Result := false;
    MessageDlg('Please input a password.', TMsgDlgType.mtError,
      [TMsgDlgBtn.mbOK], 0);

    edtPassword.Focused;
    edtPassword.Color := clRed;

  end;
end;

procedure TfrmLogin.tOTPTimer(Sender: TObject);
begin
  iOTP := CalculateOTP(sToken);
end;

end.
