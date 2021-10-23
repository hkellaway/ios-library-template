# ios-library-template

Template for creating a new iOS library.

[![Swift](https://img.shields.io/badge/Swift-5.3-orange.svg)](https://swift.org/about/)
[![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![License](https://img.shields.io/badge/License-MIT-lightgray.svg)](https://raw.githubusercontent.com/hkellaway/ios-library-template/main/LICENSE)
[![Build](https://github.com/hkellaway/ios-library-template/actions/workflows/build.yml/badge.svg)](https://github.com/hkellaway/ios-library-template/actions/workflows/build.yml)

## Usage

### Create a New Library From Template

* Create a new repo from this template library
* Update the LICENSE file with your name or project's name
* Rename the Xcode project using ([stackoverflow/60984691/3777116](https://stackoverflow.com/a/60984691/3777116))
* Update references to LibraryTemplate
	* Re-configure CI
	* Update Swift Package Manager and CocoaPods specs
	* Update Demo project Swift Package source
	* Update README and CHANGELOG
* In Xcode settings, set:
	* iOS minimum
* In specs, set:
	* Cocoapods podspec details, including iOS min
	* Swift Package Manager spec iOS version `ios=` TODO
* Customize the file header by modifying LibraryTemplate.xcodeproj/xcshareddata/IDETemplateMacros.plist (e.g. add ___FULLUSERNAME___ to include name in headers)
* Fill out README and CHANGELOG

## Installation

### Swift Package Manager

Point to the [latest release](https://github.com/hkellaway/LibraryTemplate/releases) or to the `main` branch for the latest.

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

LibraryTemplate is available under the MIT license. See the [LICENSE](https://raw.githubusercontent.com/hkellaway/LibraryTemplate/main/LICENSE) file for more info.
