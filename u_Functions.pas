unit u_Functions;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.WinXPanels,
  Vcl.WinXCtrls, Vcl.StdCtrls, Vcl.Buttons, Vcl.Imaging.pngimage, Vcl.ComCtrls,
  Data.DB, Vcl.Grids, Vcl.DBGrids;

type
  TFunctions = class(TObject)

    // Allow public acesss to all functions.

  public
    class procedure sizeCentre(Form: TForm);
    class procedure disableSize(Form: TForm);
    class procedure makeRound(Control: TWinControl);
    class function isNumber(Input: String): Boolean;
    class procedure openSQL(sSQL: String);
    class procedure execSQL(sSQL: String);
    class procedure resetDB();

  end;

implementation

{ TFunctions }

uses u_DatabaseConnection;

// Source - https://stackoverflow.com/users/1062933/please-dont-bully-me-so-lords
class procedure TFunctions.disableSize(Form: TForm);
begin

  // Disable window resize.
  Form.BorderStyle := bsDialog;
  Form.BorderIcons := Form.BorderIcons;

end;

class procedure TFunctions.execSQL(sSQL: String);
begin
  // Query db.
  dmConnection.qrQuery.SQL.Clear;
  dmConnection.qrQuery.SQL.ADD(sSQL);
  dmConnection.qrQuery.execSQL;
end;

class function TFunctions.isNumber(Input: String): Boolean;
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

class procedure TFunctions.makeRound(Control: TWinControl);
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

class procedure TFunctions.openSQL(sSQL: String);
begin
  // Query db.
  dmConnection.qrQuery.SQL.Clear;
  dmConnection.qrQuery.SQL.ADD(sSQL);
  dmConnection.qrQuery.Open;
end;

class procedure TFunctions.resetDB;
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

        // Copy backup before we do anything
        CopyFile('dbmApplication.mdb', 'dbmApplication.mdb.bak', false);

        TFunctions.execSQL('DELETE * FROM tblLink');
        TFunctions.execSQL('DELETE * FROM tblUsers');
        TFunctions.execSQL('DELETE * FROM tblObjectives');

        // Reopen.
        dmConnection.tblLink.Open;
        dmConnection.tblUsers.Open;
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

class procedure TFunctions.sizeCentre(Form: TForm);
begin
  // Centre window based on monitor size.
  Form.Left := (Form.Monitor.Width - Form.Width) div 2;
  Form.Top := (Form.Monitor.Height - Form.Height) div 2;
end;

end.
