unit u_Register;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  Vcl.WinXCtrls, Vcl.Mask, Vcl.Imaging.pngimage, ShellAPI;

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
    tOTP: TTimer;
    stQRCode: TStaticText;
    StaticText1: TStaticText;
    procedure FormCreate(Sender: TObject);

    // Fix for multi forums.
    procedure CreateParams(var Params: TCreateParams); override;

    procedure btnBackClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure imgHelpClick(Sender: TObject);
    procedure btnLoginClick(Sender: TObject);
    procedure btnRegisterClick(Sender: TObject);

    // Added.
    procedure isAllValid();
    function isPasswordValid(): Boolean;
    procedure tOTPTimer(Sender: TObject);
    procedure pbQRPaint(Sender: TObject);
    procedure imgPlaystoreClick(Sender: TObject);
    procedure imgiStoreClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmRegister: TfrmRegister;

  // isAllValid
  sUsername, sPassword, sPasswordConfirm, sKeySecret: String;
  bUsernameE, bPasswordE, bPasswordCE: Boolean;
  iTemp: Integer;
  QRCodeBitmap: TBitmap;

implementation

{$R *.dfm}

uses u_Functions, u_Application, u_Login, u_DatabaseConnection, u_Google2FA,
  u_QRCode;

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

procedure TfrmRegister.btnRegisterClick(Sender: TObject);
var
  sTemp, sSQL, sInput: String;
  bTaken: Boolean;
  I, iPass: Integer;
begin

  // Set.
  edtPassword.Font.Color := clBlack;
  edtPasswordConfirm.Font.Color := clBlack;
  edtUsername.Font.Color := clBlack;
  sInput := '0';

  // Grab data from user.
  sUsername := edtUsername.Text;
  sPassword := edtPassword.Text;
  sPasswordConfirm := edtPasswordConfirm.Text;

  // Run checks.
  isAllValid;

  if bUsernameE OR bPasswordE OR bPasswordCE = True then
  begin
    // Dont run anymore code.
    Exit;
  end;

  if (isPasswordValid = True) then
  begin

    // Run our register code.
    Functions.openSQL('SELECT Username FROM tblUsers WHERE Username = "' +
      sUsername + '"');

    // If not empty result from SQL. (Username found)
    if NOT((dmConnection.qrQuery.EOF)) then
    begin

      bTaken := True;
      MessageDlg('Username is already used.', TMsgDlgType.mtError,
        [TMsgDlgBtn.mbOK], 0);

      edtUsername.Focused;
      edtUsername.Font.Color := clRed;

    end;

    // Username not found, so we can register.
    if NOT(bTaken = True) then
    begin

      MessageDlg
        ('Please setup 2FA by scanning the QR code. If you have any trouble, please click the help image.',
        TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbOK], 0);

      while NOT(StrToInt(sInput) = iTemp) do
      begin

        // Grab input from user.
        sInput := InputBox('OTP Verification', 'OTP:', '');

        // Check if is number.
        if (Functions.isNumber(sInput) = false) then
        begin
          ShowMessage('Please enter a number.');
          sInput := '0';
        end;

      end;

      // Break out of loop.
      ShowMessage('OTP Verification successful.');

      // Register user into database.

      dmConnection.tblUsers.Open;
      dmConnection.tblUsers.Insert;

      dmConnection.tblUsers['Username'] := sUsername;
      dmConnection.tblUsers['Password'] := sPassword;
      dmConnection.tblUsers['2FAToken'] := sKeySecret;
      dmConnection.tblUsers['SuperUser'] := 'false';
      dmConnection.tblUsers['LastLogin'] := DateToStr(Now);

      dmConnection.tblUsers.Post;

      // Notify user.
      MessageDlg('Account successfully created.', TMsgDlgType.mtConfirmation,
        [TMsgDlgBtn.mbOK], 0);

    end;
  end;
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
  Functions.disableSize(frmRegister);
  Functions.makeRound(pnlHold);

  pnlHold.BevelInner := bvNone;
  pnlHold.BevelKind := bkTile;
  pnlHold.BevelOuter := bvRaised;

  edtPassword.PasswordChar := '*';
  edtPasswordConfirm.PasswordChar := '*';

end;

procedure TfrmRegister.FormShow(Sender: TObject);
var
  QRCode: TDelphiZXingQRCode;
  Row, Column: Integer;
begin

  // Always should be centre.
  Functions.sizeCentre(frmRegister);

  // Clear all junk.
  edtUsername.Clear;
  edtPassword.Clear;
  edtPasswordConfirm.Clear;

  // Generate new key.
  sKeySecret := GenerateOTPSecret(10);

  // Create bitmap.
  QRCodeBitmap := TBitmap.Create;

  // Create.
  QRCode := TDelphiZXingQRCode.Create;

  try
    // Generate auth string.
    QRCode.Data := 'otpauth://totp/Impactify' + '?secret=' + sKeySecret +
      '&issuer=' + 'Delphi';

    QRCode.Encoding := TQRCodeEncoding(0);
    QRCode.QuietZone := StrToIntDef('Auto', 4);
    QRCodeBitmap.SetSize(QRCode.Rows, QRCode.Columns);

    // Create QR code.
    for Row := 0 to QRCode.Rows - 1 do
    begin
      for Column := 0 to QRCode.Columns - 1 do
      begin
        if (QRCode.IsBlack[Row, Column]) then
        begin
          QRCodeBitmap.Canvas.Pixels[Column, Row] := clBlack;
        end
        else
        begin
          QRCodeBitmap.Canvas.Pixels[Column, Row] := clWhite;
        end;
      end;
    end;
  finally
    QRCode.Free;
  end;
  pbQR.Repaint;

end;

procedure TfrmRegister.imgHelpClick(Sender: TObject);
var
  sURL: String;
begin
  // Exec browser open.
  sURL := 'https://support.google.com/accounts/answer/1066447?hl=en&co=GENIE.Platform%3DAndroid';
  ShellExecute(self.WindowHandle, 'open', PChar(sURL), nil, nil, SW_SHOWNORMAL);
end;

procedure TfrmRegister.imgiStoreClick(Sender: TObject);
var
  sURL: String;
begin
  // Exec browser open.
  sURL := 'https://apps.apple.com/us/app/google-authenticator/id388497605';
  ShellExecute(self.WindowHandle, 'open', PChar(sURL), nil, nil, SW_SHOWNORMAL);
end;

procedure TfrmRegister.imgPlaystoreClick(Sender: TObject);
var
  sURL: String;
begin
  // Exec browser open.
  sURL := 'https://play.google.com/store/apps/details?id=com.google.android.apps.authenticator2&hl=en_ZA&gl=US';
  ShellExecute(self.WindowHandle, 'open', PChar(sURL), nil, nil, SW_SHOWNORMAL);
end;

procedure TfrmRegister.isAllValid;
begin

  // Set all.
  bUsernameE := false;
  bPasswordE := false;
  bPasswordCE := false;

  // Check edtBox is valid.
  if sUsername = NullAsStringValue then
  begin
    // Output.
    MessageDlg('Please input a username to use.', TMsgDlgType.mtError,
      [TMsgDlgBtn.mbOK], 0);

    // Notify.
    edtUsername.Focused;
    edtUsername.Font.Color := clRed;

    // Set.
    bUsernameE := True;

  end;

  if sPassword = NullAsStringValue then
  begin

    // Output.
    MessageDlg('Please input a password to use for your account.',
      TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);

    // Notify.
    edtPassword.Focused;
    edtPassword.Font.Color := clRed;

    // Set.
    bPasswordE := True;

  end;

  if sPasswordConfirm = NullAsStringValue then
  begin

    // Output.
    MessageDlg('Please re-input your password for your account.',
      TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);

    // Notify.
    edtPasswordConfirm.Focused;
    edtPasswordConfirm.Font.Color := clRed;

    // Set.
    bPasswordCE := True;
  end;
end;

function TfrmRegister.isPasswordValid: Boolean;
var
  I: Integer;
  bCapital, bNumber, bSpecial: Boolean;

begin

  // Set.
  bCapital := false;
  bNumber := false;
  bSpecial := false;

  if NOT(sPassword = sPasswordConfirm) then
  begin

    MessageDlg('Password do not match, please check them.', TMsgDlgType.mtError,
      [TMsgDlgBtn.mbOK], 0);

    edtPassword.Font.Color := clRed;
    edtPasswordConfirm.Font.Color := clRed;

    // Dont run any other code, exit function.
    Exit;

  end;

  // Check if password is valid.
  for I := 1 to Length(sPassword) do
    case sPassword[I] of
      'A' .. 'Z':
        bCapital := True;
      '0' .. '9':
        bNumber := True;
      '!', '#', '%', '&', '*', '@':
        bSpecial := True;
    end;

  // Result.
  if (bCapital AND bNumber AND bSpecial = True) then
  begin
    Result := True;
  end;

  // Notify User.
  if (bCapital = false) then
  begin
    MessageDlg('Password needs to contain 1 captial letter.',
      TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
  end;

  if (bNumber = false) then
  begin
    MessageDlg('Password needs to contain 1 number.', TMsgDlgType.mtError,
      [TMsgDlgBtn.mbOK], 0);
  end;

  if (bSpecial = false) then
  begin
    MessageDlg('Password needs to contain 1 special character.',
      TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
  end;

end;

procedure TfrmRegister.pbQRPaint(Sender: TObject);
var
  Scale: Double;
begin

  // Draw QR code.
  pbQR.Canvas.Brush.Color := clWhite;
  pbQR.Canvas.FillRect(Rect(0, 0, pbQR.Width, pbQR.Height));

  if ((QRCodeBitmap.Width > 0) and (QRCodeBitmap.Height > 0)) then
  begin

    if (pbQR.Width < pbQR.Height) then
    begin
      Scale := pbQR.Width / QRCodeBitmap.Width;
    end
    else
    begin
      Scale := pbQR.Height / QRCodeBitmap.Height;
    end;

    pbQR.Canvas.StretchDraw(Rect(0, 0, Trunc(Scale * QRCodeBitmap.Width),
      Trunc(Scale * QRCodeBitmap.Height)), QRCodeBitmap);

  end;

end;

procedure TfrmRegister.tOTPTimer(Sender: TObject);
begin
  // Calculate OTP.
  iTemp := CalculateOTP(sKeySecret);
end;

end.
