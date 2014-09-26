OnlineImagePicker
=================

An image picker for iOS that allows choosing images from online services like Facebook, Instagram and Flickr as well as from the local photo library.


Setting up Instagram
--------------------

First [register a new application with Instagram](http://instagram.com/developer/clients/manage/). Make sure the Redirect URI you use is something like `appname://instagram_oauth_redirect` where `appname` is a prefix specific to your app.

You'll also need to set up your app to handle this prefix. You do this by first adding or editing the `URL types` key in your app's Info.plist. Under it add or edit the `URL Schemes` key. Within the `URL Schemes` array add an item for whatever value you used for `appname`.

Also add the following two values to your app’s Info.plist (or to InstagramKit.plist):

Key							| Value
--------------------------- | ------
InstagramKitAppClientId		| [The Client ID that Instagram gave you]
InstagramKitAppRedirectURL	| [The Redirect URI you gave Instagram, like `appname://instagram_oauth_redirect`]

And finally make your AppDelegate forward to InstagramEngine, something like:

	#import <InstagramKit/InstagramKit.h>
	..
	-(BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
	{
		BOOL wasHandled = [[InstagramEngine sharedEngine] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
		if (!wasHandled) {
			// try other handlers, such as for Facebook, Flickr, etc.
		}
		return wasHandled;
	}

