{
  description = "Tauri mobile template";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    naersk.url = "github:nmattia/naersk";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, naersk, fenix }:
    let
      mytauri = { pkgs }: pkgs.callPackage ./my-tauri.nix { };
      mycargomobile = { pkgs }: pkgs.callPackage ./my-cargo-mobile.nix { };
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pname = "MyApp";
        pkgs = import nixpkgs {
          config.android_sdk.accept_license = true;
          config.allowUnfree = true;
          system = "${system}";
        };

        my-tauri = mytauri { inherit pkgs; };
        my-cargo-mobile = mycargomobile { inherit pkgs; };

        # fenix stuff for adding other compile targets
        mkToolchain = fenix.packages.${system}.combine;
        toolchain = fenix.packages.${system}.stable;
        target1 = fenix.packages.${system}.targets."aarch64-linux-android".stable;
        target2 = fenix.packages.${system}.targets."armv7-linux-androideabi".stable;
        target3 = fenix.packages.${system}.targets."i686-linux-android".stable;
        target4 = fenix.packages.${system}.targets."x86_64-linux-android".stable;

        mobileTargets = mkToolchain (with toolchain; [
          cargo
          rustc
          target1.rust-std
          target2.rust-std
          target3.rust-std
          target4.rust-std
        ]);


      in
      rec {
        inherit pname;

        androidEnv = pkgs.androidenv.override { licenseAccepted = true; };
        androidComposition = androidEnv.composeAndroidPackages {
          includeNDK = true;
          includeEmulator = true;
          platformToolsVersion = "35.0.1";
          buildToolsVersions = [ "34.0.0" ];
          platformVersions = [ "34"];
          cmakeVersions = [ "3.10.2" ];
          extraLicenses = [
            "android-googletv-license"
            "android-sdk-arm-dbt-license"
            "android-sdk-license"
            "android-sdk-preview-license"
            "google-gdk-license"
            "intel-android-extra-license"
            "intel-android-sysimage-license"
            "mips-android-sysimage-license"
          ];
        };
        # `nix develop`
        devShell = pkgs.mkShell {

          NIX_LD = "${pkgs.stdenv.cc.libc}/lib/ld-linux-x86-64.so.2";
          ANDROID_HOME = "${androidComposition.androidsdk}/libexec/android-sdk";
          NDK_HOME = "${androidComposition.androidsdk}/libexec/android-sdk/ndk/${builtins.head (pkgs.lib.lists.reverseList (builtins.split "-" "${androidComposition.ndk-bundle}"))}";
          ANDROID_SDK_ROOT = "${androidComposition.androidsdk}/libexec/android-sdk";
          ANDROID_NDK_ROOT = "${androidComposition.androidsdk}/libexec/android-sdk/ndk-bundle";


          nativeBuildInputs = with pkgs; [
            androidComposition.androidsdk
            androidComposition.ndk-bundle
            # cargo
            # rustc
            cargo-watch
            rustfmt
            rust-analyzer
            sqlite
            openssl.dev
            # aarch64-linux-android-pkgs.sqlite
            # aarch64-linux-android-pkgs.openssl.dev
            pkg-config
            elm2nix
            elmPackages.elm
            elmPackages.elm-analyse
            elmPackages.elm-doc-preview
            elmPackages.elm-format
            elmPackages.elm-live
            elmPackages.elm-test
            elmPackages.elm-upgrade
            elmPackages.elm-xref
            elmPackages.elm-language-server
            elmPackages.elm-verify-examples
            elmPackages.elmi-to-json
            elmPackages.elm-optimize-level-2
            # extra stuff for tauri
            my-tauri
            cargo-tauri
            libsoup
            cairo
            atk
            webkitgtk
            gst_all_1.gstreamer
            gst_all_1.gst-plugins-base
            gst_all_1.gst-plugins-good
            gst_all_1.gst-plugins-bad
            # for tauti-mobile
            librsvg
            webkitgtk_4_1
            # tauri-mobile
            my-cargo-mobile
            lldb
            nodejs
            # rustup # `cargo tauri android init` wants this, even though targets already installed.
            # should be fixed though, https://github.com/tauri-apps/tauri/issues/7044
            alsa-lib
            mobileTargets
            android-studio
            # they suggest using the jbr (jetbrains runtime?) from android-studio, but that is not accessible.
            jetbrains.jdk
          ];
        };
      }
    );
}
