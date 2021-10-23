# Original Setup

How this repo was initially created.

## Steps

* Create new Xcode project ``LibraryTemplate` (using Xcode 13.0 at time of writing)
	* Select **Framework** for project type
	* Select **Swift** for language
	* Check **Include Tests** and de-select **Include Docs**
* Update library Xcode settings
	* Select iOS Minimum (set to 14.0 at time of writing)
	* Remove Team
* Move Xcode files to root of repo and re-add files back to Xcode
* Create custom file header under LibraryTemplate.xcodeproj/xcshareddata/IDETemplateMacros.plist
* Create Swift Package Manager spec
* Create CocoaPods spec
* Create Demo project and validate both specs integrate
* Setup CI
