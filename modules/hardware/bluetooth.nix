{
  flake.modules.nixos.bluetooth = {
    hardware.bluetooth = {
      enable = true;
      input = {
        General = {
          UserspaceHID = true;
          ClassicBondedOnly = false;
          FastConnectable = true;
        };
      };
    };
    services.blueman.enable = true;
  };
}
