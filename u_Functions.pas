unit u_Functions;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.WinXPanels,
  Vcl.WinXCtrls, Vcl.StdCtrls, Vcl.Buttons, Vcl.Imaging.pngimage, Vcl.ComCtrls,
  Data.DB, Vcl.Grids, Vcl.DBGrids, u_ObjectiveO;

type
  Functions = class(TObject)

    // Allow public acesss to all functions.

  public
    class procedure sizeCentre(Form: TForm);
    class procedure disableSize(Form: TForm);
    class procedure makeRound(Control: TWinControl);
    class procedure openSQL(sSQL: String);
    class procedure execSQL(sSQL: String);
    class procedure resetDB();
    class function isNumber(Input: String): Boolean;

    // Object stuff.
    class function findID(Title: String): Integer;
    class function findBody(ID: Integer): String;
    class function findVictoryStatus(ID: Integer): Boolean;
    class function findDonation(ID: Integer): Boolean;
    class function findCreationDate(ID: Integer): TDateTime;
    class function findSignatureCount(ID: Integer): Integer;
    class function findDonationAmount(ID: Integer): Real;
    class function findDonationGoal(ID: Integer): Real;
    class function findObjectArray(ArrayName: Array of TObjectiveO;
      ID: Integer): Integer;
  end;

implementation

{ TFunctions }

uses u_DatabaseConnection;

// Source - https://stackoverflow.com/users/1062933/please-dont-bully-me-so-lords

class procedure Functions.disableSize(Form: TForm);
begin
  // Disable window resize.
  Form.BorderStyle := bsSingle;
  Form.BorderIcons := Form.BorderIcons - [biMaximize];

end;

class procedure Functions.execSQL(sSQL: String);
begin
  // Query db.
  dmConnection.qrQuery.SQL.Clear;
  dmConnection.qrQuery.SQL.ADD(sSQL);
  dmConnection.qrQuery.execSQL;
end;

class function Functions.findBody(ID: Integer): String;
begin
  // SQL.
  openSQL('SELECT Body FROM tblObjectives WHERE O_ID = ' + IntToStr(ID));
  Result := dmConnection.qrQuery.Fields[0].AsString;
end;

class function Functions.findCreationDate(ID: Integer): TDateTime;
begin
  // SQL.
  openSQL('SELECT CreationDate FROM tblObjectives WHERE O_ID = ' +
    IntToStr(ID));
  Result := StrToDate(dmConnection.qrQuery.Fields[0].AsString);
end;

class function Functions.findDonation(ID: Integer): Boolean;
begin
  // SQL.
  openSQL('SELECT Donation FROM tblObjectives WHERE O_ID = ' + IntToStr(ID));
  Result := StrToBool(dmConnection.qrQuery.Fields[0].AsString);
end;

class function Functions.findDonationAmount(ID: Integer): Real;
begin
  // SQL.
  openSQL('SELECT DonationAmount FROM tblObjectives WHERE O_ID = ' +
    IntToStr(ID));
  Result := StrToFloat(dmConnection.qrQuery.Fields[0].AsString);
end;

class function Functions.findDonationGoal(ID: Integer): Real;
begin
  // SQL.
  openSQL('SELECT DonationGoal FROM tblObjectives WHERE O_ID = ' +
    IntToStr(ID));
  Result := StrToFloat(dmConnection.qrQuery.Fields[0].AsString);
end;

class function Functions.findID(Title: String): Integer;
begin

  // Find O_ID based on Title input.
  // Ready.
  dmConnection.tblObjectives.First;

  while NOT(dmConnection.tblObjectives.Eof) do
  begin
    if (dmConnection.tblObjectives['Title'] = Title) then
    begin

      // Get U_ID and break.
      Result := dmConnection.tblObjectives['O_ID'];
      Exit;
    end;
    // Move.
    dmConnection.tblObjectives.Next;
  end;
end;

class function Functions.findObjectArray(ArrayName: Array of TObjectiveO;
  ID: Integer): Integer;
var
  I: Integer;
begin
  // Finds object in array based on O_ID.
  for I := 0 to Length(ArrayName) - 1 do
  begin
    if (ArrayName[I].getID = ID) then
    begin
      Result := I;
      Exit;
    end;
  end;
end;

class function Functions.findSignatureCount(ID: Integer): Integer;
begin
  // SQL.
  openSQL('SELECT SignatureCount FROM tblObjectives WHERE O_ID = ' +
    IntToStr(ID));
  Result := StrToInt(dmConnection.qrQuery.Fields[0].AsString);
end;

class function Functions.findVictoryStatus(ID: Integer): Boolean;
begin
  // SQL.
  openSQL('SELECT VictoryStatus FROM tblObjectives WHERE O_ID = ' +
    IntToStr(ID));
  Result := StrToBool(dmConnection.qrQuery.Fields[0].AsString);
end;

class function Functions.isNumber(Input: String): Boolean;
var
  iTemp, iStatus: Integer;
begin
  // Check
  Val(Input, iTemp, iStatus);
  if iStatus = 0 then
  begin
    Result := true;
  end
  else
  begin
    Result := false;
  end;
end;

class procedure Functions.makeRound(Control: TWinControl);
var
  Rect: TRect;
  Rgn: HRGN;
begin
  with Control do
  begin
    Rect := ClientRect;

    Rgn := CreateRoundRectRgn(Rect.Left, Rect.Top, Rect.Right,
      Rect.Bottom, 10, 10);
    Perform(EM_GETRECT, 0, lParam(@Rect));

    InflateRect(Rect, -4, -4);
    Perform(EM_SETRECTNP, 0, lParam(@Rect));
    SetWindowRgn(Handle, Rgn, true);
    Invalidate;
  end;
end;

class procedure Functions.openSQL(sSQL: String);
begin
  // Query db.
  dmConnection.qrQuery.SQL.Clear;
  dmConnection.qrQuery.SQL.ADD(sSQL);
  dmConnection.qrQuery.Open;
end;

class procedure Functions.resetDB;
begin

  // Clean up database.
  if (MessageDlg('Are you sure you want to reset the database?', mtConfirmation,
    [mbYes, mbNo], 0) = mrYes) then
  begin
    try
      // Indicate to the user that we are performing something.
      Screen.Cursor := crHourGlass;

      try
        // Ready.
        dmConnection.tblUsers.Close;
        dmConnection.tblObjectives.Close;
        dmConnection.tblLink.Close;
        dmConnection.tblSignatures.Close;

        // Copy backup before we do anything
        CopyFile('dbmApplication.mdb', 'dbmApplication.mdb.bak', false);

        Functions.execSQL('DELETE * FROM tblLink');
        Functions.execSQL('DELETE * FROM tblUsers');
        Functions.execSQL('DELETE * FROM tblSignatures');
        Functions.execSQL('DELETE * FROM tblObjectives');

        // Reopen.
        dmConnection.tblLink.Open;
        dmConnection.tblUsers.Open;
        dmConnection.tblSignatures.Open;
        dmConnection.tblObjectives.Open;

        // Catch and show any error.
      except
        on E: Exception do
        begin
          ShowMessage(E.Message);
        end;
      end;
    finally
      // Reset cursor after complete.
      Screen.Cursor := crDefault;
    end;
    // Notify user.
    MessageDlg('Database reset complete.', mtInformation, [mbOk], 0);
  end;
end;

class procedure Functions.sizeCentre(Form: TForm);
begin
  // Centre window based on monitor size.
  Form.Left := (Form.Monitor.Width - Form.Width) div 2;
  Form.Top := (Form.Monitor.Height - Form.Height) div 2;
end;

end.