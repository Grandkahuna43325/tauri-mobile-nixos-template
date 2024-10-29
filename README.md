# A simple template for tauri android development for NixOS

## Setup
type `nix develop`

after installation run `android-studio` and connect your phone(you need to enable USB debugging).

DON'T INSTALL ANYTHING THROUGH android-studio INSTALL IT WITH flake.nix in androidComposition!!

you can find the list of aviable oppions [here](https://ryantm.github.io/nixpkgs/languages-frameworks/android/)

init project with `npm run tauri android init`

run your project in dev mode with `npm run tauri android dev`

before building follow instructions in ./docs/sign_app.md 

and run `npm run tauri android build`

done!!






# Troubleshooting!

### if the `npm run tauri android dev` hangs 
open android-studio

click the icon on top with the devices

connect phone

### No frontend and just black/white screen? or `couldn't connect to url for example 192.168.1.1`
You are probably not in the same network as your phone.

### App fails to install 
App is probably badly signed or the platformVersion is wrong

## tauri/cargo-mobile too old? 
Go to my-tauri.nix or my-cargo-moblie.nix and edit version

then you need to change the sha256

to do that you need to get the:
- repo owner in this case `tauri-apps`
- package name `cargo-mobile2` or `tauri`
- version which in this case is the tag `2.0.0-alpha.10`

then you run this command:
`nix-prefetch-url https://github.com/<owner>/<repo>/archive/<version>.tar.gz`



#TODO! finish readme, add examples and create documentation
