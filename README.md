Hello-Swift-Youtube
===================

**REQUIREMENTS**: You need XCode 6 Beta 6 to open the project. It is possible that the project will not compile on future versions of XCode 6 since XCode 6 and the Swift language are still in beta and in every release they may introduce non-backwards compatible changes.

The aim of this project is to test some of the features of the new Swift programming language. The project is very simple and consists of two View Controllers: 

- A Collection View of Youtube videos with a Search bar to search videos through the Youtube REST API.
- A Video view to play the selected video with the youtube-ios-player-helper lib (based on a WebView)

We use AFNetworking to make the Youtube REST API calls and JSONModel to serialize the JSON responses. To simplify the integration of these two libraries and write less error-control code we use our own tiny wrapper over some AFNetworking methods: the AFNetworking-JSONModel pod. See the YoutubeManager class.

We use a paginated Collection View to display the Youtube search results. When we scroll down we request the next page of results before they appear on the screen (pre-loading). To implement the pagination we use the placeholder view technique as described in this post http://www.iosnomad.com/blog/2014/4/21/fluent-pagination. The YoutubeSearchDataProvider and PagedArray are the classes that manage the pagination.

### TODO
Cache the Youtube API results using Realm http://realm.io/

### Some Swift features tested in this project:
- Interaction with Objective-C classes. We use the "Hello Swift Youtube-Bridging-Header.h" file to import Objective-C classes
- Closures (Objective-C blocks)
- Protocols
- Playgrounds
- Custom operators: We have defined the "=~" operator to match a String against a Regex

### Swift features to investigate:
- Definition of powerful macros as DLog. Can be defined in Swift? Can be defined in ObjC and called from Swift? Take a look at https://github.com/DaveWoodCom/XCGLogger
- Swift alternatives for JSON parsing
- Core Data in Swift
- Realm in Swift
- Targets and preprocessor macros: the only way I have seen to differenciate targets at compile time is to add Custom Flags (Swift Compiler), http://stackoverflow.com/a/24397402/933261

### Swift libraries catalog
http://www.swifttoolbox.io/
