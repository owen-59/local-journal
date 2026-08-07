{ pkgs, lib, config, inputs, ... }:

{
    android = {
        enable = true;
        flutter.enable = true;
        
        platforms.version = [ "34" "35" "36" ];
        buildTools.version = [ "34.0.0" "35.0.0" "36.0.0" ];
    };

    packages = with pkgs; [
        at-spi2-core
        clang
        cmake
        gdk-pixbuf
        glib
        gtk3
        harfbuzz
        libepoxy
        pango
        pkg-config
        unzip
        google-chrome
    ];

    env = {
        LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
            pkgs.stdenv.cc.cc.lib
            pkgs.llvmPackages.libcxx.out
        ];
    };

    enterShell = ''
        yes | sdkmanager --licenses > /dev/null 2>&1

        mkdir -p .devenv/lib
        ln -sf ${pkgs.llvmPackages.libcxx.out}/lib/libc++.so.1 .devenv/lib/libc++.so
        export LD_LIBRARY_PATH="$PWD/.devenv/lib:${pkgs.lib.makeLibraryPath [ pkgs.stdenv.cc.cc.lib ]}:$LD_LIBRARY_PATH"
    '';
}
