unit GradientProgressBar;

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

type
	TGPBColorOption = (coGradient, coChangingColor, coOneColor);
	TGPBDirection = (diHorizontal, diVertical);
	TGPBBorderStyle = (bsNone, bsRaised, bsLowered, bsFlat, bsSpace);
	TGradientProgressBar = class(TGraphicControl)
	private
		FPosition: Integer;
		FMin: Integer;
		FMax: Integer;
		FBackColor: TColor;
		FMinColor: TColor;
		FMaxColor: TColor;
		FStep: Integer;
		startR, startG, startB: Byte;
		endR, endG, endB: Byte;
		FColorOption: TGPBColorOption;
		FDirection: TGPBDirection;
		FBorderWidth: Integer;
		FBorderStyle: TGPBBorderStyle;
		FBorderColor: TColor;
		FBuffer: TBitmap;
		FBufferReady: Boolean;
		procedure SetMax(const Value: Integer);
		procedure SetMin(const Value: Integer);
		procedure SetPosition(const Value: Integer);
		procedure SetBackColor(const Value: TColor);
		procedure SetMaxColor(const Value: TColor);
		procedure SetMinColor(const Value: TColor);
		procedure SetStep(const Value: Integer);
		procedure InitRGB;
		procedure RenderBuffer;
		procedure Render2;
		procedure SetColorOption(const Value: TGPBColorOption);
		procedure SetDirection(const Value: TGPBDirection);
		procedure SetBorderStyle(const Value: TGPBBorderStyle);
		procedure SetBorderWidth(const Value: Integer);
		function GetRealClientRect: TRect;
		procedure SetBorderColor(const Value: TColor);
		function GetAbout: string;
		procedure SetAbout(const Value: string);
		{ Private declarations }
	protected
		procedure Paint; override;
	public
		constructor Create(AOwner: TComponent); override;
		destructor Destroy; override;
		procedure StepIt;
	published
		property About: string read GetAbout write SetAbout;
		property Align;
		property Anchors;
		property BackColor: TColor read FBackColor write SetBackColor default clBtnFace;
		property BorderColor: TColor read FBorderColor write SetBorderColor;
		property BorderStyle: TGPBBorderStyle read FBorderStyle write SetBorderStyle default bsLowered;
		property BorderWidth: Integer read FBorderWidth write SetBorderWidth default 1;
		property ColorOption: TGPBColorOption read FColorOption write SetColorOption default coGradient;
		property Constraints;
		property Direction: TGPBDirection read FDirection write SetDirection;
		property DragCursor;
		property DragKind;
		property DragMode;
		property Min: Integer read FMin write SetMin;
		property MinColor: TColor read FMinColor write SetMinColor default clBlue;
		property Max: Integer read FMax write SetMax;
		property MaxColor: TColor read FMaxColor write SetMaxColor default clRed;
		property ParentShowHint;
		property PopupMenu;
		property Position: Integer read FPosition write SetPosition;
		property ShowHint;
		property Step: Integer read FStep write SetStep;
		property Visible;
	end;

procedure Register;

implementation

procedure Register;
begin
	RegisterComponents('N.G.', [TGradientProgressBar]);
end;

{ TGradientProgressBar }

constructor TGradientProgressBar.Create(AOwner: TComponent);
begin
	inherited;
	FBuffer := TBitmap.Create;
	FBufferReady := False;
	Width := 153;
	Height := 16;
	FMin := 0;
	FMax := 100;
	FPosition := 0;
	FBackColor := clBtnFace;
	ControlStyle := ControlStyle + [csOpaque];
	FMinColor := clBlue;
	FMaxColor := clRed;
	FStep := 5;
	FBorderStyle := bsLowered;
	FBorderWidth := 1;
	InitRGB;
end;

destructor TGradientProgressBar.Destroy;
begin
	FBuffer.Free;
	inherited;

end;

function TGradientProgressBar.GetAbout: string;
begin
	Result := 'Nikolaos Georgiou. (C) 2002.';
end;

function TGradientProgressBar.GetRealClientRect: TRect;
begin
	if FBorderStyle = bsNone then
		Result := ClientRect
	else begin
		Result := ClientRect;
		Inc(Result.Left, 1 + FBorderWidth);
		Inc(Result.Top, 1 + FBorderWidth);
		Dec(Result.Right, 1 + FBorderWidth);
		Dec(Result.Bottom, 1 + FBorderWidth);
	end;
end;

procedure TGradientProgressBar.InitRGB;
begin
	startR := GetRValue(ColorToRGB(FMinColor));
	startG := GetGValue(ColorToRGB(FMinColor));
	startB := GetBValue(ColorToRGB(FMinColor));
	endR := GetRValue(ColorToRGB(FMaxColor));
	endG := GetGValue(ColorToRGB(FMaxColor));
	endB := GetBValue(ColorToRGB(FMaxColor));
end;

procedure TGradientProgressBar.Paint;
var
	Rt: TRect;
	w: Integer;
	r,g,b:Byte;
begin
	Rt := ClientRect;
	case FBorderStyle of
		bsLowered:
			DrawEdge(Canvas.Handle, Rt, BDR_SUNKENOUTER, BF_RECT);
		bsRaised:
			DrawEdge(Canvas.Handle, Rt, BDR_RAISEDINNER, BF_RECT);
		bsSpace:
			begin
				Canvas.Brush.Color := FBackColor;
				Canvas.FillRect(Rect(Rt.Left, Rt.Top, Rt.Right, Rt.Top + 1 + FBorderWidth));
				Canvas.FillRect(Rect(Rt.Left, Rt.Top, Rt.Left + 1 + FBorderWidth, Rt.Bottom));
				Canvas.FillRect(Rect(Rt.Left, Rt.Bottom - FBorderWidth - 1, Rt.Right, Rt.Bottom));
				Canvas.FillRect(Rect(Rt.Right - FBorderWidth -1, Rt.Top, Rt.Right, Rt.Bottom));
			end;
		bsFlat:
			begin
				Canvas.Brush.Color := FBorderColor;
				Canvas.FrameRect(Rt);
			end;
	end;
	if (FBorderWidth > 0) and (FBorderStyle <> bsNone) and (FBorderStyle <> bsSpace) then begin
		Canvas.Brush.Color := FBackColor;
		Canvas.FillRect(Rect(Rt.Left + 1, Rt.Top + 1, Rt.Right-1, Rt.Top + 1 + FBorderWidth));
		Canvas.FillRect(Rect(Rt.Left + 1, Rt.Top + 1, Rt.Left + 1 + FBorderWidth, Rt.Bottom-1));
		Canvas.FillRect(Rect(Rt.Left + 1, Rt.Bottom - FBorderWidth - 1, Rt.Right-1, Rt.Bottom-1));
		Canvas.FillRect(Rect(Rt.Right - FBorderWidth -1, Rt.Top + 1, Rt.Right-1, Rt.Bottom-1));
	end;

	Rt := GetRealClientRect;
	if (Rt.Right <= Rt.Left) or (Rt.Bottom <= Rt.Top) then
		Exit;
	case FColorOption of
		coGradient:
			begin
				Render2;
			end;
		coChangingColor,coOneColor:
			begin
				with Canvas do begin
					if FColorOption = coChangingColor then begin
						r := MulDiv(FPosition - FMin, endR - startR, FMax - FMin);
						g := MulDiv(FPosition - FMin, endG - startG, FMax - FMin);
						b := MulDiv(FPosition - FMin, endB - startB, FMax - FMin);
						Brush.Color := RGB(startR + r,startG+g,startB+b);
					end
					else
						Brush.Color := FMinColor;

					case FDirection of
						diHorizontal:
							begin
								w := MulDiv(FPosition - FMin, Rt.Right - Rt.Left, FMax - FMin);
								Rt.Right := Rt.Left + w;
								FillRect(Rt);
								Rt.Left := Rt.Right;
								Rt.Right := GetRealClientRect.Right;
							end;
						diVertical:
							begin
								w := MulDiv(FPosition - FMin, Rt.Bottom - Rt.Top, FMax - FMin);
								Rt.Top := Rt.Bottom - w;
								FillRect(Rt);
								Rt.Bottom := Rt.Top;
								Rt.Top := GetRealClientRect.Top;
							end
					end;
					Brush.Color := FBackColor;
					FillRect(Rt);
				end;
			end;
		end;
end;

procedure TGradientProgressBar.Render2;
var
	Rt: TRect;
	w: Integer;
begin
	Rt := GetRealClientRect;
	RenderBuffer;
	case FDirection of
		diHorizontal:
			begin
				w := MulDiv(FPosition - FMin, Rt.Right - Rt.Left, FMax - FMin);
				Rt.Right := Rt.Left + w;
				Canvas.CopyRect(Rt, FBuffer.Canvas, Rect(0,0,w,Rt.Bottom-Rt.Top));
				Rt.Left := Rt.Right;
				Rt.Right := GetRealClientRect.Right;
			end;
		diVertical:
			begin
				w := MulDiv(FPosition - FMin, Rt.Bottom - Rt.Top, FMax - FMin);
				Rt.Top := Rt.Bottom - w;
				Canvas.CopyRect(Rt, FBuffer.Canvas, Rect(0, FBuffer.Height - w, Rt.Right-Rt.Left, FBuffer.Height));
				Rt.Bottom := Rt.Top;
				Rt.Top := GetRealClientRect.Top;
			end
		end;
		Canvas.Brush.Color := FBackColor;
		Canvas.FillRect(Rt);
end;

procedure TGradientProgressBar.RenderBuffer;
var
	Rt, FillRt: TRect;
	r,g,b:Byte;
	i, lastI: Integer;
	oldColor, newColor: TColor;
begin
	Rt := GetRealClientRect;
	if (Rt.Right - Rt.Left = FBuffer.Width) and (Rt.Bottom - Rt.Top = FBuffer.Height) and FBufferReady then Exit;

	if (Rt.Right > Rt.Left) and (Rt.Bottom > Rt.Top) then begin
		FBuffer.Width := Rt.Right - Rt.Left;
		FBuffer.Height := Rt.Bottom - Rt.Top;
		lastI := 0;
		case FDirection of
			diHorizontal:
				begin
					oldColor := ColorToRGB(FMinColor);
					FillRt.Top := 0;
					FillRt.Bottom := FBuffer.Height;
					for i:= 0 to FBuffer.Width - 1 do begin
						r := MulDiv(i, endR - startR, FBuffer.Width);
						g := MulDiv(i, endG - startG, FBuffer.Width);
						b := MulDiv(i, endB - startB, FBuffer.Width);
						newColor := RGB(startR+r,startG+g,startB+b);
						if newColor = oldColor then
							Continue;
						oldColor := newColor;
						FillRt.Left := lastI;
						FillRt.Right := i;
						FBuffer.Canvas.Brush.Color := newColor;
						FBuffer.Canvas.FillRect(FillRt);
						lastI := i;
					end;
					FillRt.Left := lastI;
					FillRt.Right := FBuffer.Width;
					FBuffer.Canvas.Brush.Color := FMaxColor;
					FBuffer.Canvas.FillRect(FillRt);
				end;
			diVertical:
				begin
					oldColor := ColorToRGB(FMaxColor);
					FillRt.Left := 0;
					FillRt.Right := FBuffer.Width;
					for i:= 0 to FBuffer.Height - 1 do begin
						r := MulDiv(i, endR - startR, FBuffer.Height);
						g := MulDiv(i, endG - startG, FBuffer.Height);
						b := MulDiv(i, endB - startB, FBuffer.Height);
						newColor := RGB(endR-r,endG-g,endB-b);
						if newColor = oldColor then
							Continue;
						oldColor := newColor;
						FillRt.Top := lastI;
						FillRt.Bottom := i;
						FBuffer.Canvas.Brush.Color := newColor;
						FBuffer.Canvas.FillRect(FillRt);
						lastI := i;
					end;
					FillRt.Top := lastI;
					FillRt.Bottom := FBuffer.Height;
					FBuffer.Canvas.Brush.Color := FMinColor;
					FBuffer.Canvas.FillRect(FillRt);
				end;
		end;
	end;
end;

procedure TGradientProgressBar.SetAbout(const Value: string);
begin
	//
end;

procedure TGradientProgressBar.SetBackColor(const Value: TColor);
begin
	FBackColor := Value;
	Repaint;
end;

procedure TGradientProgressBar.SetBorderColor(const Value: TColor);
begin
	if FBorderColor <> Value then begin
		FBorderColor := Value;
		if FBorderStyle=bsFlat then Repaint;
	end;
end;

procedure TGradientProgressBar.SetBorderStyle(
	const Value: TGPBBorderStyle);
begin
	FBorderStyle := Value;
	FBufferReady := false;
	Repaint;
end;

procedure TGradientProgressBar.SetBorderWidth(const Value: Integer);
begin
	FBorderWidth := Value;
	FBufferReady := false;
	Repaint;
end;

procedure TGradientProgressBar.SetColorOption(
	const Value: TGPBColorOption);
begin
	FColorOption := Value;
	Repaint;
end;

procedure TGradientProgressBar.SetDirection(const Value: TGPBDirection);
begin
	FDirection := Value;
	FBufferReady := false;
	Repaint;
end;

procedure TGradientProgressBar.SetMax(const Value: Integer);
begin
	if Value <= FMin then
		raise Exception.Create('GradientProgressBar Max value must be greater than Min value');
	if FMax <> Value then begin
		FMax := Value;
		if (FPosition > FMax) then
			FPosition := FMax;
		Repaint;
	end;
end;

procedure TGradientProgressBar.SetMaxColor(const Value: TColor);
begin
	FMaxColor := Value;
	InitRGB;
	FBufferReady := false;
	Repaint;
end;

procedure TGradientProgressBar.SetMin(const Value: Integer);
begin
	if Value >= FMax then
		raise Exception.Create('GradientProgressBar Min value must be less than Max value');
	if FMin <> Value then begin
		FMin := Value;
		if FPosition < FMin then
			FPosition := FMin;
		Repaint;
	end;
end;

procedure TGradientProgressBar.SetMinColor(const Value: TColor);
begin
	FMinColor := Value;
	InitRGB;
	FBufferReady := false;
	Repaint;
end;

procedure TGradientProgressBar.SetPosition(const Value: Integer);
begin
	if FPosition <> Value then begin
		if (Value >= FMin) and (Value <= FMax) then begin
			FPosition := Value;
			Repaint;
		end
		else
			raise Exception.Create('GradientProgressBar Position out of range');
	end;
end;

procedure TGradientProgressBar.SetStep(const Value: Integer);
begin
	FStep := Value;
end;

procedure TGradientProgressBar.StepIt;
var i : Integer;
begin
	i := FPosition + FStep;
	while i > FMax do
		i := i - FMax + FMin - 1;
	while i < FMin do
		i := i + FMax - FMin + 1;
	Position := i;
end;

end.
