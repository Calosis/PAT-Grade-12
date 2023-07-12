unit u_ObjectiveO;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.WinXPanels,
  Vcl.WinXCtrls, Vcl.StdCtrls, Vcl.Buttons, Vcl.Imaging.pngimage, Vcl.ComCtrls,
  Data.DB, Vcl.Grids, Vcl.DBGrids;

type
  // Define as object.
  TObjectiveO = class(TObject)

  private
  var
    // Fields here.
    fTitle, fBody: String;
    fVictoryStatus, fDonation: Boolean;
    fCreationDate: TDateTime;
    fID, fSignatureCount, fViewCount: Integer;
    fDonationAmount, fDonationGoal: Real;

  public

    // Create obj.
    constructor Create(ID: Integer; Title: String; Body: String;
      VictoryStatus: Boolean; Donation: Boolean; CreationDate: TDateTime;
      SignatureCount: Integer; DonationAmount: Real; DonationGoal: Real);

    procedure updateDB();

    // Functions here.
    function getID(): Integer;
    function getTitle(): String;
    function getBody(): String;
    function getVictoryStatus(): Boolean;
    function getDonation(): Boolean;
    function getCreationDate(): TDateTime;
    function getSignatureCount(): Integer;
    function getViewCount(): Integer;
    function getDonationAmount(): Real;
    function getDonationGoal(): Real;

    // Procedures here.
    procedure setTitle(Title: String);
    procedure setBody(Body: String);
    procedure setVictoryStatus(Status: Boolean);
    procedure setSignatureCount(Amount: Integer);
    procedure setViewCount(Amount: Integer);
    procedure setDonationAmount(Money: Real);
    procedure setDonationGoal(Money: Real);

  end;

implementation

{ TObjectiveO }

uses u_DatabaseConnection, u_Functions;

constructor TObjectiveO.Create(ID: Integer; Title, Body: String;
  VictoryStatus, Donation: Boolean; CreationDate: TDateTime;
  SignatureCount: Integer; DonationAmount, DonationGoal: Real);
begin
  // Set fields.
  fID := ID;
  fTitle := Title;
  fBody := Body;
  fVictoryStatus := VictoryStatus;
  fDonation := Donation;
  fCreationDate := CreationDate;
  fSignatureCount := SignatureCount;
  fDonationAmount := DonationAmount;
  fDonationGoal := DonationGoal;
end;

procedure TObjectiveO.setBody(Body: String);
begin
  fBody := Body;
end;

procedure TObjectiveO.setDonationAmount(Money: Real);
begin
  fDonationAmount := Money;
end;

procedure TObjectiveO.setDonationGoal(Money: Real);
begin
  fDonationGoal := Money;
end;

procedure TObjectiveO.setSignatureCount(Amount: Integer);
begin
  fSignatureCount := Amount;
end;

procedure TObjectiveO.setTitle(Title: String);
begin
  fTitle := Title;
end;

procedure TObjectiveO.setVictoryStatus(Status: Boolean);
begin
  fVictoryStatus := Status;
end;

procedure TObjectiveO.setViewCount(Amount: Integer);
begin
  fViewCount := Amount;
end;

procedure TObjectiveO.updateDB;
begin

  Functions.execSQL('UPDATE tblObjectives SET Title = ' + '"' + fTitle + '"' +
    ', ' + 'Body = ' + '"' + fBody + '"' + ', ' + 'VictoryStatus = ' + '"' +
    BoolToStr(fVictoryStatus) + '"' + ', ' + 'CreationDate = ' + '#' +
    DateToStr(fCreationDate) + '#' + ', ' + 'Donation = ' + '"' +
    BoolToStr(fDonation) + '"' + ', ' + 'SignatureCount = ' +
    IntToStr(fSignatureCount) + ', ' + 'ViewCount = ' + IntToStr(fViewCount) +
    ', ' + 'DonationAmount = ' + FloatToStr(fDonationAmount) + ', ' +
    'DonationGoal = ' + FloatToStr(fDonationGoal));

  // Notify user.
  MessageDlg('Objective successfully updated.', TMsgDlgType.mtConfirmation,
    [TMsgDlgBtn.mbOK], 0);

end;

function TObjectiveO.getVictoryStatus: Boolean;
begin
  Result := fVictoryStatus;
end;

function TObjectiveO.getViewCount: Integer;
begin
  Result := fViewCount;
end;

function TObjectiveO.getBody: String;
begin
  Result := fBody;
end;

function TObjectiveO.getCreationDate: TDateTime;
begin
  Result := fCreationDate;
end;

function TObjectiveO.getDonation: Boolean;
begin
  Result := fDonation;
end;

function TObjectiveO.getDonationAmount: Real;
begin
  Result := fDonationAmount;
end;

function TObjectiveO.getDonationGoal: Real;
begin
  Result := fDonationGoal;
end;

function TObjectiveO.getID: Integer;
begin
  Result := fID;
end;

function TObjectiveO.getSignatureCount: Integer;
begin
  Result := fSignatureCount;
end;

function TObjectiveO.getTitle: String;
begin
  Result := fTitle;
end;

end.
