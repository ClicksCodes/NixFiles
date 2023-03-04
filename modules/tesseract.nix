{ pkgs, ... }: {
  environment.systemPackages = [ pkgs.tesseract5 ];
}
