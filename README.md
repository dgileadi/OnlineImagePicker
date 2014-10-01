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

Setting up Facebook
-------------------

Facebook has a [handy guide for getting started on iOS](https://developers.facebook.com/docs/ios/getting-started). Follow it, but skip step 2 (for installing the SDK) since it's handled by Cocoapods. For the same reason skip the part in step 4 that talks about adding the SDK to your Xcode project.

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

