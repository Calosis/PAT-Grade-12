unit u_View;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.WinXCtrls, Vcl.Imaging.pngimage, Vcl.ComCtrls, u_ObjectiveO;

type
  TfrmView = class(TForm)
    svSide: TSplitView;
    btnBack: TBitBtn;
    rpHold: TRelativePanel;
    stHeader: TStaticText;
    redBody: TRichEdit;
    stBody: TStaticText;
    imgMenu: TImage;
    lblCreated: TLabel;
    Shape1: TShape;
    imgSigCount: TImage;
    lblSigCount: TLabel;
    imgDonationAmount: TImage;
    lblDonations: TLabel;
    imgVictoryStatus: TImage;
    lblVictory: TLabel;
    btnSign: TBitBtn;
    stSign: TStaticText;
    btnDonate: TBitBtn;
    stDonate: TStaticText;
    redComments: TRichEdit;
    btnComment: TBitBtn;
    stComments: TStaticText;
    stName: TStaticText;
    btnEditTitle: TBitBtn;
    btnEditBody: TBitBtn;
    btnEditVictory: TBitBtn;
    lblCreatedBy: TLabel;
    btnEditDonationGoal: TBitBtn;
    stComment: TStaticText;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

    // Fix for multi forums.
    procedure CreateParams(var Params: TCreateParams); override;

    // Added.
    procedure resetPanel();
    procedure updatePanel();
    procedure loadComments();

    function isOwner(UserID: Integer; ObjectiveID: Integer): Boolean;

    procedure FormShow(Sender: TObject);
    procedure imgMenuClick(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
    procedure btnSignClick(Sender: TObject);
    procedure btnDonateClick(Sender: TObject);
    procedure btnEditTitleClick(Sender: TObject);
    procedure btnEditBodyClick(Sender: TObject);
    procedure btnEditVictoryClick(Sender: TObject);
    procedure btnCommentClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmView: TfrmView;
  bShown: Boolean;
  objLocal: TObjectiveO;
  tFile: TextFile;
  sName: String;

implementation

{$R *.dfm}

uses u_Functions, u_Objectives, u_DatabaseConnection, u_Login;

procedure TfrmView.btnBackClick(Sender: TObject);
begin
  // Move.
  frmView.Hide;
  frmObjectives.Show;
end;

procedure TfrmView.btnCommentClick(Sender: TObject);
var
  sUsername, sComment: String;
begin

  // Grab Comment from user.
  sComment := InputBox('Impactify:', 'Comment:', '');

  if (sComment = NullAsStringValue) then
  begin
    MessageDlg('Please enter a comment.', TMsgDlgType.mtError,
      [TMsgDlgBtn.mbOK], 0);
    Exit;
  end;

  // Get username.
  Functions.openSQL('SELECT Username FROM tblUsers WHERE U_ID = ' +
    IntToStr(frmLogin.iLoginUserID));
  sUsername := dmConnection.qrQuery.Fields[0].AsWideString;

  // Ready.
  Append(tFile);

  // Add to file.
  Writeln(tFile, sUsername + ': ' + sComment);

  // Notify.
  MessageDlg('Comment has been added.', TMsgDlgType.mtConfirmation,
    [TMsgDlgBtn.mbOK], 0);

  // Refresh.
  loadComments;

end;

procedure TfrmView.btnDonateClick(Sender: TObject);
var
  sTemp: String;
  rAmount: Real;
begin

  // Grab from user.
  sTemp := InputBox('Impactify donation:', 'Amount:', '');

  if (Functions.isNumber(sTemp) = false) then
  begin
    ShowMessage('Please enter a number.');
    Exit;
  end;

  // Safe to store in real.
  rAmount := Abs(StrToInt(sTemp));

  // Notify user.
  if MessageDlg('Are you sure you want to donate: ' + FloatToStrF(rAmount,
    ffCurrency, 8, 2), mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrNo then
  begin
    Exit;
  end
  else
  begin
    // Insert donation into DB.
    Functions.execSQL
      ('UPDATE tblObjectives SET DonationAmount = DonationAmount + ' +
      FloatToStr(rAmount) + ' WHERE O_ID = ' +
      IntToStr(frmObjectives.iSelectedObjectiveID));

    // Update
    objLocal.setDonationAmount(objLocal.getDonationAmount + rAmount);
    updatePanel;

    // Notify user;
    MessageDlg('You have successfully donated to this objective.',
      TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbOK], 0);

  end;
end;

procedure TfrmView.btnSignClick(Sender: TObject);
begin
  // Make sure we are working with the latest table.
  dmConnection.tblSignatures.Close;
  dmConnection.tblSignatures.Open;

  // Logic to add signature.

  // Check if the current login user has already signed this petition.
  dmConnection.tblSignatures.First;

  while NOT(dmConnection.tblSignatures.Eof) do
  begin

    if (dmConnection.tblSignatures['User'] = frmLogin.iLoginUserID) AND
      (dmConnection.tblSignatures['Objective']
      = frmObjectives.iSelectedObjectiveID) then
    begin
      MessageDlg('Sorry, you have already signed this petition.',
        TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
      Exit;
    end;
    // Move.
    dmConnection.tblSignatures.Next;
  end;

  // Add signature.
  Functions.execSQL('INSERT INTO tblSignatures VALUES(' +
    IntToStr(frmLogin.iLoginUserID) + ', ' +
    IntToStr(frmObjectives.iSelectedObjectiveID) + ')');
  Functions.execSQL
    ('UPDATE tblObjectives SET SignatureCount = SignatureCount + 1 WHERE O_ID = '
    + IntToStr(frmObjectives.iSelectedObjectiveID));

  // Update.
  objLocal.setSignatureCount(objLocal.getSignatureCount + 1);
  updatePanel;

  // Notify.
  MessageDlg('You have successfully signed this objective.',
    TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbOK], 0);

end;

procedure TfrmView.btnEditBodyClick(Sender: TObject);
var
  sTemp: String;
begin
  // Update title.
  sTemp := InputBox('Edit objective:', 'Body:', '');

  if MessageDlg('Are you sure you want to change the body to: ' + sTemp,
    mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrNo then
  begin
    Exit;
  end
  else
  begin
    // Update DB.
    Functions.execSQL('UPDATE tblObjectives SET Body = ' + '"' + sTemp + '"' +
      ' WHERE O_ID = ' + IntToStr(frmObjectives.iSelectedObjectiveID));

    // Update
    objLocal.setBody(sTemp);
    updatePanel;

    // Notify user;
    MessageDlg('You have successfully updated the body.',
      TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbOK], 0);
  end;
end;

procedure TfrmView.btnEditTitleClick(Sender: TObject);
var
  sTemp: String;
begin
  // Update title.
  sTemp := InputBox('Edit objective:', 'Title:', '');

  if MessageDlg('Are you sure you want to change the title to: ' + sTemp,
    mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrNo then
  begin
    Exit;
  end
  else
  begin
    // Update DB.
    Functions.execSQL('UPDATE tblObjectives SET Title = ' + '"' + sTemp + '"' +
      ' WHERE O_ID = ' + IntToStr(frmObjectives.iSelectedObjectiveID));

    // Update
    objLocal.setTitle(sTemp);
    updatePanel;

    // Notify user;
    MessageDlg('You have successfully updated the title.',
      TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbOK], 0);
  end;
end;

procedure TfrmView.btnEditVictoryClick(Sender: TObject);
var
  sTemp: String;
begin
  // Update title.
  sTemp := InputBox('Edit objective:', 'Victory Status (true/false):', '');

  if MessageDlg('Are you sure you want to change the victory status to: ' +
    sTemp, mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrNo then
  begin
    Exit;
  end
  else
  begin

    if (lowercase((sTemp)) = 'true') then
    begin
      // Update DB.
      Functions.execSQL
        ('UPDATE tblObjectives SET VictoryStatus = true WHERE O_ID = ' +
        IntToStr(frmObjectives.iSelectedObjectiveID));

      // Update
      objLocal.setVictoryStatus(true);
      updatePanel;

      // Notify user;
      MessageDlg('You have successfully updated the victory status.',
        TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbOK], 0);
      Exit;
    end;

    if (lowercase((sTemp)) = 'false') then
    begin
      // Update DB.
      Functions.execSQL
        ('UPDATE tblObjectives SET VictoryStatus = false WHERE O_ID = ' +
        IntToStr(frmObjectives.iSelectedObjectiveID));

      // Update
      objLocal.setVictoryStatus(false);
      updatePanel;

      // Notify user;
      MessageDlg('You have successfully updated the victory status.',
        TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbOK], 0);
      Exit;
    end;

    // Output.
    MessageDlg('Please only enter true or false.', TMsgDlgType.mtError,
      [TMsgDlgBtn.mbOK], 0);

  end;
end;

procedure TfrmView.CreateParams(var Params: TCreateParams);
begin
  inherited;

  // Set style sheet so Windows knows its another "window".
  Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
  Params.WndParent := GetDesktopWindow;
end;

procedure TfrmView.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // Fix multi form issues.
  Application.Terminate;
end;

procedure TfrmView.FormCreate(Sender: TObject);
begin
  // Form setup.
  Functions.disableSize(frmView);
end;

procedure TfrmView.FormShow(Sender: TObject);
var
  iIndex, iCreatedID, iUserID: Integer;
begin
  // Always should be centre.
  Functions.sizeCentre(frmView);

  // Set.
  bShown := true;
  iIndex := Functions.findObjectArray(frmObjectives.arrObjects,
    frmObjectives.iSelectedObjectiveID);

  // Move object to local.
  objLocal := frmObjectives.arrObjects[iIndex];

  // Hide default.
  imgDonationAmount.Hide;
  lblDonations.Hide;
  stDonate.Hide;
  btnDonate.Hide;
  btnEditTitle.Hide;
  btnEditBody.Hide;
  btnEditVictory.Hide;
  btnEditDonationGoal.Hide;

  // Update view count.
  Functions.execSQL
    ('UPDATE tblObjectives SET ViewCount = ViewCount + 1 WHERE O_ID = ' +
    IntToStr(frmObjectives.iSelectedObjectiveID));

  // Reset
  resetPanel;

  // Update all values.
  updatePanel;

  // Load comments.
  sName := 'Comments' + IntToStr(frmObjectives.iSelectedObjectiveID) + '.txt';
  AssignFile(tFile, sName);

  loadComments;

  // Should we enabled edits?
  if (isOwner(frmLogin.iLoginUserID, frmObjectives.iSelectedObjectiveID) = true)
  then
  begin

    // Enable buttons.
    btnEditTitle.Show;
    btnEditBody.Show;
    btnEditVictory.Show;

    if (objLocal.getDonation = true) then
    begin
      btnEditDonationGoal.Show;
    end;
    lblCreatedBy.Caption := 'Created by: YOU';
  end;

end;

procedure TfrmView.imgMenuClick(Sender: TObject);
begin
  // Sliding panel logic.
  if (bShown = true) then
  begin
    svSide.Opened := false;

    rpHold.BevelInner := bvNone;
    rpHold.BevelKind := bkNone;
    rpHold.BevelOuter := bvNone;
    bShown := false;

    // Set new size
    rpHold.Width := 950;
    rpHold.Alignment := taLeftJustify;
    rpHold.Align := alLeft;
  end
  else
  begin
    svSide.Opened := true;

    rpHold.BevelInner := bvNone;
    rpHold.BevelKind := bkNone;
    rpHold.BevelOuter := bvRaised;
    bShown := true;

    // Set old size
    rpHold.Width := 600;
    rpHold.Alignment := taCenter;
    rpHold.Align := alClient;
  end;
end;

function TfrmView.isOwner(UserID, ObjectiveID: Integer): Boolean;
begin
  // Logic to determine if the user logged in created the objective.

  // Make sure we are using latest.
  dmConnection.tblLink.Close;
  dmConnection.tblLink.Open;

  // Ready.
  dmConnection.tblLink.First;

  while NOT(dmConnection.tblLink.Eof) do
  begin

    if (UserID = dmConnection.tblLink['User']) AND
      (ObjectiveID = dmConnection.tblLink['Objective']) then
    begin
      // Return.
      Result := true;
      Exit;
    end;
    // Move.
    dmConnection.tblLink.Next;
  end;
end;

procedure TfrmView.loadComments;
var
  sTemp: String;
begin

  // Create File if not exists.
  if NOT(FileExists(sName)) then
  begin
    ReWrite(tFile);
  end;

  // Clear.
  redComments.Lines.Clear;

  // Ready.
  Reset(tFile);

  // Load comments logic here.
  while NOT(Eof(tFile)) do
  begin
    Readln(tFile, sTemp);
    redComments.Lines.Add(sTemp);
  end;

  // Finish.
  CloseFile(tFile);

end;

procedure TfrmView.resetPanel;
begin
  // Clear all old stuff.
  redBody.Clear;
  lblCreated.Caption := 'Created on: ';
  lblSigCount.Caption := 'Signatures: ';
  lblDonations.Caption := '';
  lblVictory.Caption := 'Victory Status: Pending';

  imgDonationAmount.Hide;
  lblDonations.Hide;
  stDonate.Hide;
  btnDonate.Hide;
end;

procedure TfrmView.updatePanel;
var
  iCreatedID, iUserID: Integer;
begin

  // Grab from obj.
  stHeader.Caption := UpperCase(objLocal.getTitle);

  redBody.Clear;
  redBody.Lines.Add(objLocal.getBody);

  lblCreated.Caption := 'Created on: ' + DateToStr(objLocal.getCreationDate);

  // Created by logic.
  iCreatedID := objLocal.getID;

  dmConnection.tblLink.First;
  while NOT(dmConnection.tblLink.Eof) do
  begin
    if (dmConnection.tblLink['Objective'] = iCreatedID) then
    begin
      iUserID := dmConnection.tblLink['User'];
      Break;
    end;
    // Move.
    dmConnection.tblLink.Next;
  end;

  Functions.openSQL('SELECT Username FROM tblUsers WHERE U_ID = ' +
    IntToStr(iUserID));
  lblCreatedBy.Caption := 'Created by: ' + dmConnection.qrQuery.Fields[0]
    .AsWideString;

  lblSigCount.Caption := 'Signatures: ' + IntToStr(objLocal.getSignatureCount);

  // We should only show if objective allows donations.
  if (objLocal.getDonation = true) then
  begin
    lblDonations.Caption := FloatToStrF(objLocal.getDonationAmount, ffCurrency,
      8, 2) + ' (Goal: ' + FloatToStrF(objLocal.getDonationGoal, ffCurrency,
      8, 2) + ')';

    imgDonationAmount.Show;
    lblDonations.Show;
    btnDonate.Show;
    stDonate.Show;
  end;

  // Change status of victory.
  if (objLocal.getVictoryStatus = true) then
  begin
    lblVictory.Caption := 'Victory Status: Complete';
  end
  else
  begin
    lblVictory.Caption := 'Victory Status: Pending';
  end;
end;

end.
