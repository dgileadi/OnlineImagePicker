OnlineImagePicker
=================

An image picker for iOS that allows choosing images from online services like Dropbox, Facebook, Instagram and Flickr as well as from the local photo library.

Installing
---------------

The easiest way is to use [Cocoapods](http://cocoapods.org). Just add `pod 'OnlineImagePicker'` to your Podfile and then `pod update`.

If you don't want to use you can add the following frameworks to your project along with OnlineImagePicker:

* Dropbox-iOS-SDK
* Facebook-iOS-SDK
* FlickrKit
* InstagramKit
* SDWebImage
* M13ProgressSuite

Note that I haven't tested this so you're on your own.

Using the Picker
----------------

Using the picker could hardly be easier:

		..
		OnlineImagePickerController *picker = [[OnlineImagePickerController alloc] initWithDelegate:self];
		[self presentViewController:picker animated:YES completion:nil];
		// or you could push the picker onto a UINavigationController stack
	}

	// your class needs to implement the OnlineImagePickerDelegate protocol:
	#pragma mark - OnlineImagePickerDelegate

	-(void) imagePickedWithInfo:(id<OnlineImageInfo>)info andThumbnail:(UIImage *)thumbnail {
		[self dismissViewControllerAnimated:YES completion:nil];
		// maybe display the thumbnail image temporarily
		[info loadFullSizeWithProgress:^(double progress) {
			// show progress, or just pass nil for the progress block
		} completed:^(UIImage *)image, NSError *error) {
			// use the full-sized image
		}];
	}

	-(void) cancelledPicker {
		[self dismissViewControllerAnimated:YES completion:nil];
	}

But (and I hope you like big buts 'cause this is a big one), since this library is for choosing images from users' online accounts, you'll need to do some more setup in order to access those accounts. Otherwise the above code will simply crash your app, complaining that it couldn't find various plist properties.

You might ask, "can't OnlineImagePicker do this setup itself and save me the bother?" No, no it can't because each online account wants to know about your particular app, so they ask you to register with them. You then need to provide the registration info to the libraries that OnlineImagePicker uses.

However, if you'd rather not bother with a particular kind of account then you can specify the list of image sources to OnlineImagePickerController when you initialize it:

	NSArray *sources = @[[[FacebookUserImagesSource alloc] init], [[PhotoLibraryImageSource alloc] init]];
	OnlineImagePickerController *picker = [[OnlineImagePickerController alloc] initWithDelegate:self andImageSources:sources];

For each source you don't include you can skip the setup section below. Probably. Not tested. In any case the above initializer also lets you use other image sources that aren't included in the defaults, like `InstagramPopularImagesSource`.

So, here are guides for setting up the various online accounts:

Setting up Dropbox
------------------

First [register your application with Dropbox](https://www.dropbox.com/developers/apps/create), choosing the "Dropbox API App" type. Make sure the settings you choose allow your app to find the photos you want to make available.

You'll need to set up your app to handle redirects from Dropbox. You do this by first adding or editing the `URL types` key in your app's Info.plist. Under it add or edit the `URL Schemes` key. Within the `URL Schemes` array add an item named `db-APP_KEY`, replacing `APP_KEY` with the App Key that Dropbox gave you when you registered your app.

You'll also need to make your AppDelegate handle redirects from Dropbox, something like:

	#import <DropboxSDK/DropboxSDK.h>
	..
	-(BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
	{
		BOOL wasHandled = [[DBSession sharedSession] handleOpenURL:url];
		if (!wasHandled) {
			// maybe try other handlers
		}
		return wasHandled;
	}

Finally you'll need to make your Dropbox app key and secret available to OnlineImagePicker. An easy way to do that is to add the following values to your app's Info.plist:

Key					| Value
------------------- | ------
DropboxAppKey		| [The App Key that Dropbox gave you]
DropboxAppSecret	| [The App Secret that Dropbox gave you]

If you'd rather not store them in your Info.plist then you can instead put the following in your AppDelegate's `application:didFinishLaunchingWithOptions:` method:

	DBSession *dbSession = [[DBSession alloc]
	      initWithAppKey:@"INSERT_APP_KEY"
	      appSecret:@"INSERT_APP_SECRET"
	      root:kDBRootDropbox];
	[DBSession setSharedSession:dbSession];

Setting up Facebook
-------------------

Facebook has a [handy guide for getting started on iOS](https://developers.facebook.com/docs/ios/getting-started). Follow it, but skip step 2 (for installing the SDK) since it's handled by Cocoapods. For the same reason skip the part in step 4 that talks about adding the SDK to your Xcode project.

This library requires the `user_photos` permission. This is not one of the basic permissions that Facebook automatically grants, so you'll need to request it when registering your app with Facebook and they'll need to review your app and approve the request.

You'll also need to make your AppDelegate handle redirects from Facebook for login, something like:

	#import <FacebookSDK/FacebookSDK.h>
	..
	-(BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
	{
		BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
		if (!wasHandled) {
			// maybe try other handlers
		}
		return wasHandled;
	}

Also in your AppDelegate add the following code to your `applicationDidBecomeActive:` method:

	[FBAppCall handleDidBecomeActive];

This handles the situation where the app moved to the background in the middle of logging in.

Setting up Flickr
-----------------

First [register a new application with Flickr](https://www.flickr.com/services/apps/create/).

You'll need to make the API key and secret they'll give you available to OnlineImagePicker. An easy way to do that is to add the following values to your app's Info.plist:

Key				| Value
--------------- | ------
FlickrAPIKey	| [The API Key that Flickr gave you]
FlickrSecret	| [The Shared Secret that Flickr gave you]

If you'd rather not store them in your Info.plist then you can instead put the following in your AppDelegate's `application:didFinishLaunchingWithOptions:` method:

	[[FlickrKit sharedFlickrKit] initializeWithAPIKey:@"INSERT_API_KEY"
	                                     sharedSecret:@"INSERT_SECRET"];

If you plan to load user images then it can speed up image loading if you log the user into Flickr when your app launches. To do this you can add code like the following to your AppDelegate's `application:didFinishLaunchingWIthOptions:` method:

	[[FlickrKit sharedFlickrKit] checkAuthorizationOnCompletion:^(NSString *userName, NSString *userId, NSString *fullName, NSError *error) {
        // maybe handle the error somehow, if there is one
    }];

Be sure that before the call to `checkAuthorizationOnCompletion:` you either call the above code to `initializeWithAPIKey:sharedSecret:` or else call the following to use the Flickr values from your Info.plist:

	[[FlickrAccount sharedInstance] registerWithFlickrKit];

Setting up Instagram
--------------------

First [register a new application with Instagram](http://instagram.com/developer/clients/manage/). Make sure the Redirect URI you use is something like `appname://instagram_oauth_redirect` where `appname` is a prefix specific to your app.

Then add the following values to your app's Info.plist (or to InstagramKit.plist):

Key								| Value
------------------------------- | ------
InstagramKitAppClientId			| [The Client ID that Instagram gave you]
InstagramKitAppRedirectURL		| [The Redirect URI you gave Instagram, like `appname://instagram_oauth_redirect`]
InstagramKitBaseUrl				| `https://api.instagram.com/v1/`
InstagramKitAuthorizationUrl	| `https://api.instagram.com/oauth/authorize/`

Building Your Own Picker
------------------------

You may decide that you'd prefer a custom UI instead of using `OnlineImagePickerController`. That's fine; you're welcome to do so. Under the hood `OnlineImagePickerController` uses an instance of `OnlineImageManager` to provide its images. You're welcome to do the same for your custom UI.

Creating Your Own Image Source
------------------------------

Suppose you aren't satisfied with Dropbox, Facebook, Flickr, Instagram and the device's Photo Library and want to support an additional source of images. To do so you'll need to create the following classes:

1. A class that implements the `OnlineImageSource` protocol. This class will be responsible for loading metadata about images. The protocol's header file is well-documented, and you can examine one of the existing classes like `InstagramUserFeedImageSource` for an example.
2. A class that implements the `OnlineImageInfo` protocol. This class will be responsible for holding metadata about a single image, and for being able to load a thumnail and full-size image. Your implementation of `OnlineImageSource` will create and return instances of this class. In most cases you can do like `InstagramImageInfo` and just extend `SDWebImageInfo` to get the loading for free, provided you supply the appropriate URLs.
3. If your source of images requires authentication then you'll also need a class that implements the `OnlineImageAccount` protocol, and have your OnlineImageSource return an instance of it from its `account` method.

To use your new source of images you can pass it to `OnlineImagePickerController` or to `OnlineImageManager`, depending on which you use.