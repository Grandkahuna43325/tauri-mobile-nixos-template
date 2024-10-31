# How to sign your app?
## Generate key
AND DON'T COMMIT IT!!! Your key is PRIVATE

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

## Configure gradle to use your key
Add this to the beginning of `./src-tauri/gen/android/app/build.gradle.kts`
```
import java.io.FileInputStream
```

Add this before buildTypes
```
signingConfigs {
    create("release") {
        val keystorePropertiesFile = rootProject.file("keystore.properties")
        val keystoreProperties = Properties()
        if (keystorePropertiesFile.exists()) {
            keystoreProperties.load(FileInputStream(keystorePropertiesFile))
        }

        keyAlias = keystoreProperties["keyAlias"] as String
        keyPassword = keystoreProperties["password"] as String
        storeFile = file(keystoreProperties["storeFile"] as String)
        storePassword = keystoreProperties["password"] as String
    }
}
```
And change buildTypes to look like this(the `...` mean the rest of the code not litteral dots):
```
    buildTypes {
        ...
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            ...
        }
    }

```
