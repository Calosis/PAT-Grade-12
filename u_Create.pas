unit u_Create;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  Vcl.WinXCtrls, Vcl.CheckLst, Vcl.Mask, Vcl.Samples.Spin, Math;

type
  TfrmCreate = class(TForm)
    svSide: TSplitView;
    btnBack: TBitBtn;
    stName: TStaticText;
    pnlHold: TPanel;
    edtTitle: TLabeledEdit;
    edtBody: TLabeledEdit;
    cbxDonations: TCheckBox;
    edtDonationGoal: TLabeledEdit;
    spnSignatureCount: TSpinEdit;
    stSignatureCount: TStaticText;
    btnCreate: TBitBtn;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

    // Fix for multi forums.
    procedure CreateParams(var Params: TCreateParams); override;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
    procedure cbxDonationsClick(Sender: TObject);
    procedure spnSignatureCountChange(Sender: TObject);
    procedure btnCreateClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmCreate: TfrmCreate;

implementation

{$R *.dfm}

uses u_Functions, u_Objectives, u_ObjectiveO, u_DatabaseConnection, u_Login;

procedure TfrmCreate.btnBackClick(Sender: TObject);
begin
  // Move.
  frmCreate.Hide;
  frmObjectives.Show;
end;

procedure TfrmCreate.btnCreateClick(Sender: TObject);
var
  bReady, bDonation: Boolean;
  objLocal: TObjectiveO;
  sTitle, sBody: String;
  iSignatureCount, iID: Integer;
  rDonationGoal: Real;
begin

  // Make sure we are working with latest information.
  dmConnection.tblObjectives.Close;
  dmConnection.tblObjectives.Open;

  // Set.
  bReady := true;
  bDonation := false;

  // Validate everything.
  if (edtTitle.Text = NullAsStringValue) then
  begin
    MessageDlg('Please enter a title.', TMsgDlgType.mtError,
      [TMsgDlgBtn.mbOK], 0);
    edtTitle.SetFocus;
    bReady := false;
  end
  else
  begin
    if (Length(edtTitle.Text) > 30) then
    begin
      MessageDlg('Your title is longer than 30 characters, it will be cut off.',
        TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOK], 0);
    end;
  end;

  if (edtBody.Text = NullAsStringValue) then
  begin
    MessageDlg('Please enter text for the body.', TMsgDlgType.mtError,
      [TMsgDlgBtn.mbOK], 0);
    edtBody.SetFocus;
    bReady := false;
  end
  else
  begin
    if (Length(edtBody.Text) > 250) then
    begin
      MessageDlg('Your body is longer than 250 characters, it will be cut off.',
        TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOK], 0);
    end;
  end;

  if (cbxDonations.Checked = true) then
  begin

    if (edtDonationGoal.Text = NullAsStringValue) then
    begin
      MessageDlg('Please enter a donation goal.', TMsgDlgType.mtError,
        [TMsgDlgBtn.mbOK], 0);
      edtDonationGoal.SetFocus;
      bReady := false;
      Exit;
    end;

    if (Functions.isNumber(edtDonationGoal.Text) = false) then
    begin
      MessageDlg('Please only enter a number', TMsgDlgType.mtError,
        [TMsgDlgBtn.mbOK], 0);
      edtDonationGoal.SetFocus;
      bReady := false;
    end;
  end;

  if (bReady = true) then
  begin

    // Grab from user.
    sTitle := edtTitle.Text;
    sBody := edtBody.Text;
    iSignatureCount := Abs(spnSignatureCount.Value);
    rDonationGoal := Abs(StrToFloat(edtDonationGoal.Text));
    bDonation := cbxDonations.Checked;

    iID := dmConnection.tblObjectives.RecordCount + 1;

    // Create Objective and post to database.
    objLocal := TObjectiveO.Create(iID, sTitle, sBody, false, bDonation, Now,
      iSignatureCount, 0, rDonationGoal);

    // Add object into DB now.
    objLocal.updateDB;

    // Link current user to objective.
    Functions.execSQL('INSERT INTO tblLink VALUES(' +
      IntToStr(frmLogin.iLoginUserID) + ', ' + IntToStr(iID) + ')');

    // Notify user.
    MessageDlg('Objective successfully created.', TMsgDlgType.mtConfirmation,
      [TMsgDlgBtn.mbOK], 0);

    // Move.
    frmCreate.Hide;
    frmObjectives.Show;

  end;
end;

procedure TfrmCreate.cbxDonationsClick(Sender: TObject);
begin
  // Change status of editbox.
  if (cbxDonations.Checked = true) then
  begin
    edtDonationGoal.Enabled := true;
  end
  else
  begin
    edtDonationGoal.Enabled := false;
  end;
end;

procedure TfrmCreate.CreateParams(var Params: TCreateParams);
begin
  inherited;

  // Set style sheet so Windows knows its another "window".
  Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
  Params.WndParent := GetDesktopWindow;
end;

procedure TfrmCreate.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // Fix multi form issues.
  Application.Terminate;
end;

procedure TfrmCreate.FormCreate(Sender: TObject);
begin
  // Form setup.
  Functions.disableSize(frmCreate);
end;

procedure TfrmCreate.FormShow(Sender: TObject);
begin
  // Always should be centre.
  Functions.sizeCentre(frmCreate);

  // Set.
  edtTitle.Clear;
  edtBody.Clear;
  edtDonationGoal.Text := '0';
  spnSignatureCount.Value := 0;
  cbxDonations.Checked := false;
  edtDonationGoal.Enabled := false;
end;

procedure TfrmCreate.spnSignatureCountChange(Sender: TObject);
begin
  // Restrict user, we should not have negative views.
  if (spnSignatureCount.Value < 0) then
  begin
    spnSignatureCount.Value := 0;
  end;
end;

end.
