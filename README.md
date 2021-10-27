# ios-library-template

Template for creating a new iOS library.

[![Swift](https://img.shields.io/badge/Swift-5.5-orange.svg)](https://swift.org/about/)
[![Swift Package Manager compatible](https://img.shields.io/badge/SPM-compatible-orange.svg)](https://swift.org/package-manager/)
[![CocoaPods compatible](https://img.shields.io/badge/pod-compatible-blue.svg)](https://cocoapods.org/about) 
[![License](https://img.shields.io/badge/License-MIT-lightgray.svg)](https://raw.githubusercontent.com/hkellaway/ios-library-template/main/LICENSE)
[![Build](https://github.com/hkellaway/ios-library-template/actions/workflows/build.yml/badge.svg)](https://github.com/hkellaway/ios-library-template/actions/workflows/build.yml)

## Usage

### Create a New Library From Template

* Create a new repo from this template library
* Customize GitHub repo settings
* Rename the Xcode project using ([stackoverflow/60984691/3777116](https://stackoverflow.com/a/60984691/3777116))
	* Rename folders under the *Sources/* directory
	* Re-configure Xcode project with new filepaths
	* Confirm project is compiling and tests are green :white_check_mark:
		* Compilation error gotchas: Ensure *Tests* files are in the *Test* target; ensure *.h* file is *Public* under *Build Phases > Headers*
* Update Xcode settings, updating:
	* iOS minimum
	* Bundle identifier
* Rename CocoaPods *.podpsec* file
* Update references to `LibraryTemplate` in the following configs:
	* CI (`.github/workflows/build.yml`)
	* Swift Package Manager manifest (*Package.swift* file)
	* CocoaPods podspec
* Review spec details closely and replace all details, including but not limited to:
	* iOS minimum
	* Git source
* Update Demo project
	* Rename Xcode project
	* Update Swift package source
	* Update Podfile
	* Test that SPM integration and CocoaPods integration work
* Update documentation
	* Set CODEOWNERS (*.github/CODEOWNERS*)
	* Customize the file header by modifying *X.xcodeproj/xcshareddata/IDETemplateMacros.plist* (e.g. add `___FULLUSERNAME___` to include name in headers)
	* Update the LICENSE file with your name and the current year
	* Fill out README
		* Update title, description, and badge links
			* To determine Swift version, run `/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift --version`
		* Remove instructions
		* Customize *Usage*, *Installation*, *Credits*, *License*
	* Fill out CHANGELOG
	* Update GitHub repo details
* Ensure CI is green :white_check_mark:

Now you're all set to develop your library, tests and demo project!

### How This Repo Was Originally Created

In case you'd rather create your setup from scratch:

* Create new Xcode project `LibraryTemplate` (using Xcode 13.0 at time of writing)
	* Select *Framework for project type
	* Select *Swift* for language
	* Check *Include Tests* and de-select **Include Docs**
* Update library Xcode settings
	* Select iOS Minimum (set to 14.0 at time of writing)
	* Remove Team
* Move Xcode files to root of repo and re-add files back to Xcode
* Create custom file header under *X.xcodeproj/xcshareddata/IDETemplateMacros.plist*
* Create Swift Package Manager manifest
* Create CocoaPods podspec
* Create Demo project and validate both specs integrate
* Setup CI

## Installation

### Swift Package Manager

Point to the [most recent release](https://github.com/hkellaway/ios-library-template/releases) or to the `main` branch for the very latest.

### CocoaPods

```ruby
pod 'LibraryTemplate', :git => 'https://github.com/hkellaway/LibraryTemplate.git', :tag => 'x.x.x'
```

```ruby
pod 'LibraryTemplate', :git => 'https://github.com/hkellaway/LibraryTemplate.git', :branch => 'main'
```

## Credits

LibraryTemplate was created by [Harlan Kellaway](http://github.com/hkellaway).

## License

LibraryTemplate is available under the MIT license. See the [LICENSE](https://raw.githubusercontent.com/hkellaway/ios-library-template/main/LICENSE) file for more info.
