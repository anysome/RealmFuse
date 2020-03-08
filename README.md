# RealmFuse

[![CI Status](https://img.shields.io/travis/anysome/RealmFuse.svg?style=flat)](https://travis-ci.org/anysome/RealmFuse)
[![Version](https://img.shields.io/cocoapods/v/RealmFuse.svg?style=flat)](https://cocoapods.org/pods/RealmFuse)
[![License](https://img.shields.io/cocoapods/l/RealmFuse.svg?style=flat)](https://cocoapods.org/pods/RealmFuse)
[![Platform](https://img.shields.io/cocoapods/p/RealmFuse.svg?style=flat)](https://cocoapods.org/pods/RealmFuse)

Provide [Fuse](https://github.com/krisk/fuse-swift) search api in Realm

Define properities to search
```swift
extension PostModel: Fuseable {
    
    var fuseProperties: [FuseProperty] {
        return [
            FuseProperty(name: "title", weight: 0.34),
            FuseProperty(name: "content", weight: 0.66)
        ]
    }
}
```

Run query
```swift
var results = realm.objects(PostModel.self).fuseSearch(searchText)
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

RealmFuse is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'RealmFuse'
```

## Author

Layman, anysome@gmail.com

## License

RealmFuse is available under the MIT license. See the LICENSE file for more info.
