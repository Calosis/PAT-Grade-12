unit u_ObjectiveO;

interface

uses SysUtils;

type
  // Define as object.
  TObjectiveO = class(TObject)

  private
  var
    // Fields here.
    fTitle, fBody: String;
    fVictoryStatus, fDonation: Boolean;
    fCreationDate: TDateTime;
    fSignatureCount, fViewCount: Integer;
    fDonationAmount, fDonationGoal: Real;

  public
    // Functions here.
    function getTitle(): String;
    function getBody(): String;
    function getVictoryStatus(): Boolean;
    function getDonation(): Boolean;
    function getCreationDate(): Boolean;
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

function TObjectiveO.getVictoryStatus: Boolean;
begin

end;

function TObjectiveO.getViewCount: Integer;
begin

end;

procedure TObjectiveO.setBody(Body: String);
begin

end;

procedure TObjectiveO.setDonationAmount(Money: Real);
begin

end;

procedure TObjectiveO.setDonationGoal(Money: Real);
begin

end;

procedure TObjectiveO.setSignatureCount(Amount: Integer);
begin

end;

procedure TObjectiveO.setTitle(Title: String);
begin

end;

procedure TObjectiveO.setVictoryStatus(Status: Boolean);
begin

end;

procedure TObjectiveO.setViewCount(Amount: Integer);
begin

end;

function TObjectiveO.getBody: String;
begin

end;

function TObjectiveO.getCreationDate: Boolean;
begin

end;

function TObjectiveO.getDonation: Boolean;
begin

end;

function TObjectiveO.getDonationAmount: Real;
begin

end;

function TObjectiveO.getDonationGoal: Real;
begin

end;

function TObjectiveO.getSignatureCount: Integer;
begin

end;

function TObjectiveO.getTitle: String;
begin

end;

end.
