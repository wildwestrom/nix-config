# PipeWire, tuned for low latency, plus the codecs and mixer that go with it.
{ user, ... }:
{
  flake.modules.nixos.audio =
    { pkgs, ... }:
    {
      services.pipewire = {
        enable = true;
        audio.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
        wireplumber = {
          enable = true;
          extraConfig = {
            bluetoothEnhancements = {
              "monitor.bluez.properties" = {
                # seems like if I set this to false, it's a bit too quiet
                # but I can always boost it above 0dB if I need to
                "bluez5.enable-hw-volume" = true;
              };
            };
            "60-hdmi-no-suspend" = {
              "monitor.alsa.rules" = [
                {
                  matches = [ { "api.alsa.path" = "hdmi:.*"; } ];
                  actions = {
                    update-props = {
                      "session.suspend-timeout-seconds" = 60;
                    };
                  };
                }
              ];
            };
          };
        };
        extraConfig.pipewire."10-clock" = {
          "context.properties" = {
            "default.clock.rate" = 44100;
            "default.clock.allowed-rates" = [
              44100
              48000
              88200
              96000
              192000
            ];
            "default.clock.quantum" = 32;
            "default.clock.min-quantum" = 16;
            "default.clock.max-quantum" = 512;
          };
        };
      };

      users.users.${user.name}.extraGroups = [ "audio" ];

      environment.systemPackages = with pkgs; [
        ldacbt
        libfreeaptx
        pwvucontrol
      ];
    };
}
