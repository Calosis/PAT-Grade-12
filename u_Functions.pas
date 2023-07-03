unit u_Functions;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls;

type
  TFunctions = class(TObject)

    // Allow public acesss to all functions.

  public
    class procedure sizeCentre(Form: TForm);
    class procedure disableSize(Form: TForm);
    class procedure makeRound(Control: TWinControl);
    class function isNumber(Input: String): Boolean;

  end;

implementation

{ TFunctions }

// Source - https://stackoverflow.com/users/1062933/please-dont-bully-me-so-lords
class procedure TFunctions.disableSize(Form: TForm);
begin

  // Disable window resize.
  Form.BorderStyle := bsDialog;
  Form.BorderIcons := Form.BorderIcons;

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

class procedure TFunctions.sizeCentre(Form: TForm);
begin

  // Centre window based on monitor size.
  Form.Left := (Form.Monitor.Width - Form.Width) div 2;
  Form.Top := (Form.Monitor.Height - Form.Height) div 2;

end;

end.
