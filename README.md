## Rivet for iOS

This is the iOS code for Rivet as it appeared the day we closed it down. To keep things simple, I'm not committing the full Git history.

A couple things I'd like to point out:

* This code is not well-documented, so it may be hard to follow
* The next things on my to-do list were to switch to dependency injection and refactor more UI code
* To make styles easier to apply across the app, in most cases I used auto layout code instead of the interface builder
* If you want to run the app you'll have to do the following:
	* Install CocoaPods and run `pod install` in the same directory as the Podfile
	* Hard-code responses for registration and location-related server calls if you want to get past the initial screen
	* Run the RivetDevelopment scheme