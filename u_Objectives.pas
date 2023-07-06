unit u_Objectives;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.WinXCtrls,
  Vcl.Imaging.pngimage, Vcl.StdCtrls;

type
  TfrmObjectives = class(TForm)
    svSide: TSplitView;
    Button1: TButton;
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
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);

    // Fix for multi forums.
    procedure CreateParams(var Params: TCreateParams); override;
    procedure imgMenuClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmObjectives: TfrmObjectives;
  bShown: Boolean;

  // We don't know size, but we can use Length() to get elements.
  arrTitles: Array of string;
  arrViews: Array of Integer;
  // ** Parallel Arrays.

  // Added.
  arrPanels: TArray<TPanel>;
  arrImages: TArray<TImage>;

implementation

{$R *.dfm}

uses u_Functions, u_DatabaseConnection;

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
  TFunctions.disableSize(frmObjectives);
  TFunctions.makeRound(pnl1);
  TFunctions.makeRound(pnl2);
  TFunctions.makeRound(pnl3);
  TFunctions.makeRound(pnl4);
  TFunctions.makeRound(pnl5);
  TFunctions.makeRound(pnl6);
  TFunctions.makeRound(pnl7);
  TFunctions.makeRound(pnl8);
end;

procedure TfrmObjectives.FormShow(Sender: TObject);
var
  I: Integer;
begin

  // Always should be centre.
  TFunctions.sizeCentre(frmObjectives);
  // Set
  bShown := true;
  I := 0;

  imgView1.Hide;
  imgView2.Hide;
  imgView3.Hide;
  imgView4.Hide;
  imgView5.Hide;
  imgView6.Hide;
  imgView7.Hide;
  imgView8.Hide;

  // Lets now populate our arrays.
  // Ready.
  dmConnection.tblObjectives.First;
  while NOT(dmConnection.tblObjectives.Eof) do
  begin
    // Put into array
    SetLength(arrTitles, I + 1);
    SetLength(arrViews, I + 1);

    arrTitles[I] := dmConnection.tblObjectives['Title'];
    arrViews[I] := dmConnection.tblObjectives['ViewCount'];
    Inc(I);

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
    arrImages[I].Hint := arrImages[I].Hint + IntToStr(arrViews[I]);
    arrImages[I].Show;
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

end.
