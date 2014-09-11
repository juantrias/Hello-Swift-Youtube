Hello-Swift-Youtube
===================

**REQUIREMENTS**: You need XCode 6 Beta 6 to open the project. It is possible that the project will not compile on future versions of XCode 6 since XCode 6 and the Swift language are still in beta and in every release they may introduce non-backwards compatible changes.

The aim of this project is to test some of the features of the new Swift programming language. The project is very simple and consists of two View Controllers: 

- A Collection View of Youtube videos with a Search bar to search videos through the Youtube REST API.
- A Video view to play the selected video with the youtube-ios-player-helper lib (based on a WebView)

We use AFNetworking to make the Youtube REST API calls and JSONModel to serialize the JSON responses. To simplify the integration of these two libraries and write less error-control code we use our own tiny AFNetworking extension: the AFNetworking-JSONModel pod. See the YoutubeApiClient class.

We store the results fetched from the Youtube REST API in a Realm (http://realm.io/) database. So if we relaunch the app we display the cached results instead of making a new REST API call.

We use a paginated Collection View to display the Youtube search results. When we scroll down we request the next page of results before they appear on the screen (pre-loading). To implement the pagination we use the placeholder view technique as described in this post (http://www.iosnomad.com/blog/2014/4/21/fluent-pagination), but replacing the placeholder AWPagedArray by a RLMRealm array to cache the API results. The YoutubeManager and PagedScrollHelper are the classes that manage the pagination.

### TODO
- Improve the ViewController-Manager-ApiClient architecture: 
  - Single responsibilities
  - Well defined flow for callbacks (blocks or delegates to update the UI)
  - Reusability with future services
- Limit the memory consumption (number of results in memory) with very large datasets
- Cancel a request for a page of results if the rows are not in the screen
- Animate the transition when a cell is reused to display other result: we see a little abrupt transition when changing the thumbnail of a row 
- Do not copy a Dictionary to store it on NSUserDefaults: NSUserDefaults+SwiftExtensions 

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

### Architecture review
We are looking for a robust architecture to implement the typical stack in a native app, from the View Controller down to the REST API call, including a local storage to cache the results and enable offline access. If the API makes it possible, we want to integrate also paginated scroll support when dealing with large datasets. This is only a draft tested partially on real projects. This are the layers:

- View
- ViewController
- Manager
  - Decide if we fetch the results from the Local Storage or from the REST API (cache expiration, local data synchronization and so on...)
  - Save the results returned by the ApiClient in the Local Storage
  - Perform the business logic (ie validating an object before POSTing it to the REST API)
  - Return meaningful errors to the ViewControllers (do not change drectly the UI of course)
- Local Storage: Realm, CoreData (backed by SQLite or other storage engine), raw SQLite...
- ApiClient
  - Translate API objects (serialized & validated JSON objects) to DTOs (the data objects we use in the UI). In our case JSONModel objects to Realm objects. We can also define the serialized objects and the DTOs as the same thing or use some kind of automatic mapping.
  - Validate API responses (NOTE: for automatic required-fields validation we can rely on a parsing library like JSONModel)
  - Handle Api Errors
  - Manage results pagination if needed
  - Append user credentials to the request if needed (ie OAuth Access Token)
- Networking & Parsing libraries: In our case AFNetworking for the HTTP stuff & JSONModel for parsing and automatic required fields validation. In every service we pass to AFNetworking and JSONModel the JSONModel class we expect to receive as the API response. Any other response is automatically redirected to the same error callback we use for networking errors, so we move away the JSON structure error control code from every ApiClient service, making it generic. We have implemented this logic in our own tiny AFNetworking extension: the AFNetworking-JSONModel pod. See the YoutubeApiClient class
