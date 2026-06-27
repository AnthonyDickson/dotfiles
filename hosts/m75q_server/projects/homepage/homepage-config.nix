{ config, pkgs, lib, ... }:
let
  cfg = config.services.homepage-config;

  yamlFormat = pkgs.formats.yaml { };

  # Define your Homepage settings as Nix
  homepageSettings = {
    title = "Dashboard";
    theme = "dark";
    background = {
      image = "/images/queenstown_snow_blossoms.JPEG";
      blur = "md";
      opacity = 40;
      brightness = 50;
    };
    layout = [
      { "DateTime" = { style = "row"; columns = 2; }; }
      { "Weather" = { style = "row"; columns = 2; }; }
      { "Services" = { style = "row"; columns = 4; }; }
      { "Bookmarks" = { style = "row"; columns = 4; }; }
    ];
  };

  homepageServices = [
    {
      Infrastructure = [
        {
          Caddy = {
            icon = "sh-caddy";
            href = "https://homepage.s.anthonyd.co.nz";
            description = "Reverse proxy";
            widget = {
              type = "caddy";
              url = "http://localhost:2019";
            };
          };
        }
      ];
    }
    {
      Media = [
        {
          Sonarr = {
            icon = "sh-sonarr";
            href = "https://sonarr.anthonyd.co.nz";
            description = "TV series management";
          };
        }
        {
          Radarr = {
            icon = "sh-radarr";
            href = "https://radarr.anthonyd.co.nz";
            description = "Movie management";
          };
        }
        {
          Jackett = {
            icon = "sh-jackett";
            href = "https://jackett.anthonyd.co.nz";
            description = "Torrent indexer proxy";
          };
        }
        {
          Deluge = {
            icon = "sh-deluge";
            href = "https://deluge.anthonyd.co.nz";
            description = "Torrent client";
          };
        }
        {
          Kavita = {
            icon = "sh-kavita";
            href = "https://kavita.anthonyd.co.nz";
            description = "E-book and comic server";
          };
        }
      ];
    }
  ];

  homepageBookmarks = [
    {
      Productivity = [
        { Vikunja = [ { icon = "sh-vikunja"; href = "https://vikunja.anthonyd.co.nz"; } ]; }
        { Paperless = [ { icon = "sh-paperless-ngx"; href = "https://paperless.anthonyd.co.nz"; } ]; }
        { Forgejo = [ { icon = "sh-forgejo"; href = "https://forgejo.anthonyd.co.nz"; } ]; }
        { Vaultwarden = [ { icon = "sh-vaultwarden"; href = "https://vaultwarden.anthonyd.co.nz"; } ]; }
        { "Proton Mail" = [ { icon = "sh-proton-mail"; href = "https://mail.proton.me"; } ]; }
      ];
    }
    {
      Synology = [
        { DSM = [ { icon = "sh-synology"; href = "https://dsm.anthonyd.co.nz"; } ]; }
        { Photos = [ { icon = "sh-synology-photos"; href = "https://photos.anthonyd.co.nz?launchApp=SYNO.Foto.AppInstance"; } ]; }
        { Drive = [ { icon = "sh-drive-synology"; href = "https://drive.anthonyd.co.nz"; } ]; }
        { "File Station" = [ { icon = "sh-file-station"; href = "https://files.anthonyd.co.nz"; } ]; }
      ];
    }
    {
      Tools = [
        { "MDBG Dictionary" = [ { icon = "mdi-translate"; href = "https://www.mdbg.net/chinese/dictionary"; } ]; }
        { Jisho = [ { icon = "mdi-magnify"; href = "https://jisho.org"; } ]; }
        { GitHub = [ { icon = "sh-github"; href = "https://github.com"; } ]; }
        { "NixOS Search" = [ { icon = "sh-nixos"; href = "https://search.nixos.org"; } ]; }
      ];
    }
    {
      News = [
        { Metservice = [ { icon = "mdi-weather-cloudy"; href = "https://www.metservice.com/towns-cities/regions/auckland/locations/pakuranga-heights"; } ]; }
        { "1News" = [ { icon = "mdi-newspaper"; href = "https://www.1news.co.nz/new-zealand/"; } ]; }
        { "Al Jazeera" = [ { icon = "mdi-newspaper-variant"; href = "https://www.aljazeera.com/"; } ]; }
        { "Hacker News" = [ { icon = "mdi-alpha-y-box-#ff6600"; href = "https://news.ycombinator.com/news"; } ]; }
      ];
    }
    {
      Finance = [
        { ASB = [ { icon = "mdi-bank"; href = "https://www.asb.co.nz/"; } ]; }
        { KiwiBank = [ { icon = "mdi-bank"; href = "https://login.kiwibank.co.nz/"; } ]; }
      ];
    }
    {
      Shopping = [
        { "PB Tech" = [ { icon = "mdi-laptop"; href = "https://www.pbtech.co.nz/"; } ]; }
        { TradeMe = [ { icon = "mdi-cart"; href = "https://www.trademe.co.nz/"; } ]; }
      ];
    }
    {
      Web = [
        { YouTube = [ { icon = "sh-youtube"; href = "https://www.youtube.com/"; } ]; }
        { WaniKani = [ { icon = "mdi-school"; href = "https://www.wanikani.com/"; } ]; }
      ];
    }
  ];

  homepageWidgets = [
    {
      resources = { cpu = true; memory = true; disk = "/host"; cputemp = true; units = "metric"; };
    }
    {
      datetime = {
        text_size = "xl";
        format = {
          dateStyle = "long";
          timeStyle = "short";
          hourCycle = "h23";
        };
      };
    }
    {
      openmeteo = {
        label = "Auckland";
        latitude = -36.8485;
        longitude = 174.7633;
        timezone = "Pacific/Auckland";
        units = "metric";
        format = {
          maximumFractionDigits = 0;
        };
      };
    }
  ];

  homepageDocker = {
    local.socket = "/var/run/docker.sock";
  };

  # Write config directory
  configDir = pkgs.runCommand "homepage-config" { } ''
    mkdir -p $out/images
    cp ${./images/queenstown_snow_blossoms.JPEG} $out/images/queenstown_snow_blossoms.JPEG
    cp ${yamlFormat.generate "settings.yaml" homepageSettings} $out/settings.yaml
    cp ${yamlFormat.generate "services.yaml" homepageServices} $out/services.yaml
    cp ${yamlFormat.generate "bookmarks.yaml" homepageBookmarks} $out/bookmarks.yaml
    cp ${yamlFormat.generate "widgets.yaml" homepageWidgets} $out/widgets.yaml
    cp ${yamlFormat.generate "docker.yaml" homepageDocker} $out/docker.yaml
  '';
in
{
  options.services.homepage-config = {
    enable = lib.mkEnableOption "Homepage dashboard configuration";
  };

  config = lib.mkIf cfg.enable {
    # Populate /var/lib/homepage/config on activation
    system.activationScripts.homepage-config = ''
      mkdir -p /var/lib/homepage/config
      cp -r ${configDir}/* /var/lib/homepage/config/
      chown -R 1000:1000 /var/lib/homepage/config
    '';
  };
}
