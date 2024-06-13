procedure TForm1.Timer1Timer(Sender: TObject);
var j:tjpegimage;
begin
  if time>0 then
begin
  time:=time-1;
   label1.Caption:=inttostr(time);

  end
else
begin
  timer1.Enabled:=False;
  //Timer1.Interval := Edit2.Text;
         ScreenShot(Image1.Picture.BitMap);
         j:=TJpegImage.Create;
         j.CompressionQuality:=100;
         j.Assign(image1.Picture.Bitmap);
         j.SaveToFile(Edit2.Text);
         Application.MessageBox('Файл создан', 'F10', MB_OK) ;
         j.Destroy;
         //KillTimer(Handle, TIMER_SET_KEY);
    end;
end

