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

	NSArray *sources = [NSArray arrayWithObjects:[[FacebookUserImagesSource alloc] init], [[PhotoLibraryImageSource alloc] init], nil];
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

Key						| Value
----------------------- | ------
DropboxAppKey			| [The App Key that Dropbox gave you]
DropboxAppSecret		| [The App Secret that Dropbox gave you]

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

Setting up Instagram
--------------------

First [register a new application with Instagram](http://instagram.com/developer/clients/manage/). Make sure the Redirect URI you use is something like `appname://instagram_oauth_redirect` where `appname` is a prefix specific to your app.

And then add the following values to your app's Info.plist (or to InstagramKit.plist):

Key								| Value
------------------------------- | ------
InstagramKitAppClientId			| [The Client ID that Instagram gave you]
InstagramKitAppRedirectURL		| [The Redirect URI you gave Instagram, like `appname://instagram_oauth_redirect`]
InstagramKitBaseUrl				| `https://api.instagram.com/v1/`
InstagramKitAuthorizationUrl	| `https://api.instagram.com/oauth/authorize/`

