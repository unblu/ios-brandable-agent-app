# iOS Brandable Agent App

A basic application you can adapt to your organization's branding to create a fully functional agent application that works with the Unblu Collaboration Server.

## Rename the app
To rename an application, follow these steps:
- Rename the project in the Xcode File Inspector
- Rename the scheme by clicking it and selecting "Manage Schemes..."
- Rename the project folder and <AppName>.xcworkspace
- Rename your target in the Podfile

## Replace the app icon
To replace the app's icons with your own, add them to the `AppIcon` set of the default asset catalog.
Add the icons in all the sizes currently present.

## Logo
Add the logo for the splash screen to the asset catalog, then add the name of the logo to the `splashLogoIconName` property of the Configuration class.

## Localization
Create a Localizable.strings file for each language you want your app to be available in and add them to the Localization section of the root project panel.
For more information, refer to [Apple's documentation on localization](https://developer.apple.com/documentation/xcode/localization).

## Authentication methods
To set the authentication method, adapt the properties of the `Configuration` class.
There are three ways to authenticate:

- Direct authentication.
Set the following properties:
	- `unbluServerUrl` - The HTTP address of your Unblu Collaboration Server
	- `unbluServerEntryPath` - The entry path
	- `authType = .direct`

- Authentication with a reverse proxy.
Set the following properties:
	- `unbluServerUrl` - The HTTP address of you proxy server
	- `unbluServerEntryPath` - The entry path
	- `authType = .oauthProxy`

- With an external identity provider and authorization header. 
Set the following properties:
  - `unbluServerUrl` - The HTTP address of you proxy server
  - `unbluServerEntryPath` - The entry path
  - `authType = .oauth`
  - `authProvider` - The information your identity provider requires.
    Here's an example:

    ```
    IdentityProvider(type: .Microsoft,webAuthServerAddress:  "https://login.microsoftonline.com",
	    webAuthBaseUrl: "/oauth2/v2.0",
	    webAuthClientId: "aae6ad6b-2230-414e-83f0-2b5933499b0b",
	    webAuthClientSecret: "VJ38Q~r0i77qACoCtdN~dig9XsYPFrT-5mZadaef",
	    webAuthCallbackURLScheme: "msauth.com.unblu.prototype.BrandableAgent",
	    webAuthGetTokenId: "/authorize?response_type=code",
	    webAuthGetToken: "/token",
	    webAuthLogout: "/logout",
	    webAuthTenant:"8005dd54-64b0-4f9d-bf46-e2582d0c2760")
    ```

    Refer to you identity provider's documentation for how to fill in these settings correctly.

## WKAppBoundDomains
If you use an external identity provider for authentication, uncomment the `WKAppBoundDomains` section in your Info.plist file and add the following information there:
- The domain of your server
- The domain of your identity provider's server

Once you've done that, your application will only work with these domains.
