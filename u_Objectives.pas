unit u_Objectives;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.WinXCtrls,
  Vcl.Imaging.pngimage, Vcl.StdCtrls, Vcl.Buttons, u_ObjectiveO;

type
  TfrmObjectives = class(TForm)
    svSide: TSplitView;
    rpHold: TRelativePanel;
    imgMenu: TImage;
    gpTop: TGridPanel;
    gpBottom: TGridPanel;
    pnl1: TPanel;
    pnl2: TPanel;
    pnl3: TPanel;
    pnl4: TPanel;
    pnl5: TPanel;
    pnl6: TPanel;
    pnl7: TPanel;
    pnl8: TPanel;
    imgView1: TImage;
    imgView2: TImage;
    imgView4: TImage;
    imgView5: TImage;
    imgView6: TImage;
    imgView7: TImage;
    imgView8: TImage;
    imgView3: TImage;
    stName: TStaticText;
    btnBack: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);

    // Fix for multi forums.
    procedure CreateParams(var Params: TCreateParams); override;

    procedure resetPanels();
    procedure showObjective(Panel: TPanel);

    procedure imgMenuClick(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
    procedure pnl1Click(Sender: TObject);
    procedure pnl2Click(Sender: TObject);
    procedure pnl3Click(Sender: TObject);
    procedure pnl4Click(Sender: TObject);
    procedure pnl5Click(Sender: TObject);
    procedure pnl6Click(Sender: TObject);
    procedure pnl7Click(Sender: TObject);
    procedure pnl8Click(Sender: TObject);
  private
    { Private declarations }

  public
    { Public declarations }

    // Public vars for other forms.
    iSelectedObjectiveID: Integer;

    // All our objective objects.
    arrObjects: Array of TObjectiveO;
  end;

var
  frmObjectives: TfrmObjectives;

  // Added.
  bShown: Boolean;
  iPanelAmount: Integer;

  // We don't know size, but we can use Length() to get elements.
  arrTitles: Array of string;
  arrViews: Array of Integer;
  // ** Parallel Arrays.

  // Added.
  arrPanels: TArray<TPanel>;
  arrImages: TArray<TImage>;

implementation

{$R *.dfm}

uses u_Functions, u_DatabaseConnection, u_Application, u_View, u_Create;

procedure TfrmObjectives.btnBackClick(Sender: TObject);
begin
  // Move.
  frmObjectives.Hide;
  frmApplication.Show;
end;

procedure TfrmObjectives.CreateParams(var Params: TCreateParams);
begin
  inherited;

  // Set style sheet so Windows knows its another "window".
  Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
  Params.WndParent := GetDesktopWindow;
end;

procedure TfrmObjectives.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // Fix multi form issues.
  Application.Terminate;
end;

procedure TfrmObjectives.FormCreate(Sender: TObject);
begin
  // Form setup.
  Functions.disableSize(frmObjectives);
  Functions.makeRound(pnl1);
  Functions.makeRound(pnl2);
  Functions.makeRound(pnl3);
  Functions.makeRound(pnl4);
  Functions.makeRound(pnl5);
  Functions.makeRound(pnl6);
  Functions.makeRound(pnl7);
  Functions.makeRound(pnl8);
end;

procedure TfrmObjectives.FormShow(Sender: TObject);
var
  I: Integer;
  objObjective: TObjectiveO;

  // Object vars.
  ID, SignatureCount: Integer;
  Title, Body: String;
  VictoryStatus, Donation: Boolean;
  CreationDate: TDateTime;
  DonationAmount, DonationGoal: Real;

begin

  // Make sure we are working with latest.
  dmConnection.tblObjectives.close;
  dmConnection.tblObjectives.open;

  // Always should be centre.
  Functions.sizeCentre(frmObjectives);
  // Set
  bShown := true;
  iPanelAmount := 0;

  // Safe reset dynamic array.
  SetLength(arrViews, 0);
  SetLength(arrTitles, 0);
  SetLength(arrObjects, 0);

  Finalize(arrViews);
  Finalize(arrTitles);
  Finalize(arrObjects);

  arrViews := nil;
  arrTitles := nil;
  arrObjects := nil;

  // Default everything.
  resetPanels;

  // Lets now populate our arrays.
  // Ready.
  dmConnection.tblObjectives.Sort := 'O_ID ASC';
  dmConnection.tblObjectives.First;

  while NOT(dmConnection.tblObjectives.Eof) do
  begin

    // Deny if panel amount is 8.
    if (iPanelAmount = 8) then
    begin
      Break;
    end;

    // Put into array
    SetLength(arrTitles, iPanelAmount + 1);
    SetLength(arrViews, iPanelAmount + 1);
    SetLength(arrObjects, iPanelAmount + 1);

    arrTitles[iPanelAmount] := dmConnection.tblObjectives['Title'];
    arrViews[iPanelAmount] := dmConnection.tblObjectives['ViewCount'];

    Inc(iPanelAmount);

    // Move
    dmConnection.tblObjectives.Next;
  end;

  // Create arrays.
  arrPanels := TArray<TPanel>.create(pnl1, pnl2, pnl3, pnl4, pnl5, pnl6,
    pnl7, pnl8);
  arrImages := TArray<TImage>.create(imgView1, imgView2, imgView3, imgView4,
    imgView5, imgView6, imgView7, imgView8);

  // Populate our objectives.
  for I := 0 to Length(arrTitles) - 1 do
  begin
    arrPanels[I].Caption := arrTitles[I];
    arrImages[I].Hint := 'Views: ' + IntToStr(arrViews[I]);
    arrImages[I].Show;
  end;

  // Create Objects and put into array.
  for I := 0 to Length(arrTitles) - 1 do
  begin

    // Ready all vars.
    ID := Functions.findID(arrTitles[I]);
    Title := arrTitles[I];
    Body := Functions.findBody(ID);
    VictoryStatus := Functions.findVictoryStatus(ID);
    Donation := Functions.findDonation(ID);
    CreationDate := Functions.findCreationDate(ID);
    SignatureCount := Functions.findSignatureCount(ID);
    DonationAmount := Functions.findDonationAmount(ID);
    DonationGoal := Functions.findDonationGoal(ID);

    // Finally, create object and add to array.
    objObjective := TObjectiveO.create(ID, Title, Body, VictoryStatus, Donation,
      CreationDate, SignatureCount, DonationAmount, DonationGoal);

    arrObjects[I] := objObjective;

  end;

end;

procedure TfrmObjectives.imgMenuClick(Sender: TObject);
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
    rpHold.Alignment := taCenter;
    rpHold.Align := alRight;

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

procedure TfrmObjectives.pnl1Click(Sender: TObject);
begin
  showObjective(pnl1);
end;

procedure TfrmObjectives.pnl2Click(Sender: TObject);
begin
  showObjective(pnl2);
end;

procedure TfrmObjectives.pnl3Click(Sender: TObject);
begin
  showObjective(pnl3);
end;

procedure TfrmObjectives.pnl4Click(Sender: TObject);
begin
  showObjective(pnl4);
end;

procedure TfrmObjectives.pnl5Click(Sender: TObject);
begin
  showObjective(pnl5);
end;

procedure TfrmObjectives.pnl6Click(Sender: TObject);
begin
  showObjective(pnl6);
end;

procedure TfrmObjectives.pnl7Click(Sender: TObject);
begin
  showObjective(pnl7);
end;

procedure TfrmObjectives.pnl8Click(Sender: TObject);
begin
  showObjective(pnl8);
end;

procedure TfrmObjectives.resetPanels;
begin
  // Reset all panels to default.
  pnl1.Caption := 'Click to create an objective';
  pnl2.Caption := 'Click to create an objective';
  pnl3.Caption := 'Click to create an objective';
  pnl4.Caption := 'Click to create an objective';
  pnl5.Caption := 'Click to create an objective';
  pnl6.Caption := 'Click to create an objective';
  pnl7.Caption := 'Click to create an objective';
  pnl8.Caption := 'Click to create an objective';

  imgView1.Hide;
  imgView2.Hide;
  imgView3.Hide;
  imgView4.Hide;
  imgView5.Hide;
  imgView6.Hide;
  imgView7.Hide;
  imgView8.Hide;
end;

procedure TfrmObjectives.showObjective(Panel: TPanel);
begin
  // Should we show the objective?
  if (Panel.Caption <> 'Click to create an objective') then
  begin

    // Get ID.
    dmConnection.tblObjectives.First;

    while NOT(dmConnection.tblObjectives.Eof) do
    begin
      if (dmConnection.tblObjectives['Title'] = Panel.Caption) then
      begin
        iSelectedObjectiveID := dmConnection.tblObjectives['O_ID'];
        // Stop.
        Break;
      end;
      // Move.
      dmConnection.tblObjectives.Next;
    end;
    // Move to new form (show).
    frmObjectives.Hide;
    frmView.Show;
  end
  else
  begin
    // Move to new form (create).
    frmObjectives.Hide;
    frmCreate.Show;
  end;
end;

end.
