# Why? well it won't run if you don't


# How to sign your app?
## Generate key
AND DON'T COMMIT IT!!!

You'll probably want to change the keystore.jks location from home dir to your android development dir
`keytool -genkey -v -keystore ~/keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`

## Configure the signing
Create file in `/src-tauri/gen/android/keystore.properties`

with contents:
```
password=<password from generating key>
keyAlias=upload
storeFile=<location of keystore.jks>
```

## Configure gradle to sign your key
TODO!
