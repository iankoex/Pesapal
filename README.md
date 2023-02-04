# Pesapal
This is my submission to [The Pesapal Developer Challenge.](https://pesapal.freshteam.com/jobs/2OU7qEKgG4DR/junior-developer-23)

I have attempted to solve Problem 3 and Problem 4.

# Installation
The solutions are in the form of an app that runs on macOS and iOS.

A binarry that is signed for development can be found in the releases tab.

The app was created on `Xcode 14.2 (14C18)` but should be compatible with previous versions of Xcode.

First clone the project to your mac. Open `Pesapal.xcodeproj`. On Xcode's sidebar go to Pesapal then Targets > Pesapal > Signing & Capabilities. 
On Signing & Capabilities create your signing certificate and run the project.

![Signing & Capabilities](https://user-images.githubusercontent.com/30172987/216751079-54adf32b-6cfe-49a7-940a-54adb13e9de3.png)

# Problem 3 A distributed system.
Once the app is running, it will start a server on port `8080`. Confirm that the server is running by clicking `Test on Browser` on the app or by visiting [Port 8080](http://localhost:8080). If for some reason the server is not running click `Start Server` button.

Once the app connects to the server, it will connect to the socket automatically. The different clients are represented by windows of the app. Create a new window by pressing `CMD + N`. The new window should also connect to the socket and will be allocated the next available rank.

A side note for `iOS`: Since we can't create multiple windows of the same app on iPhone, the solution can only be tested on `Mac` or `iPad`. The iOS app will still start a server and connect to the socket.

To send commands press the `Send Command` button. Clients with a lower rank will exceute the command by showing: 
> **Running Commmand from participant x with rank x**

Once a client disconnects (Click on the red `Disconnect` button) the socket promotes the clients accordingly.

The following is a demo with Four particpants: 

[Problem 3 Screen Recording](https://user-images.githubusercontent.com/30172987/216752425-8bdf2c05-a183-4bcd-8bab-5d884012ffe2.mp4)

# Problem Four: A Boolean logic interpreter
On the side bar click on the problem four tab.

The view on problem four consists of a textfield and a submit button.

## The Synatx
The syntax uses the Swift standard syantax for Boolens and Logical operators.

1. `true` for true
2. `false` for false
3. `&&` for AND
4. `\\` for OR
5. `!` for NOT

## Usage
On the text field type the expession you want to evaluate such as `true && true`.

The text field supports initialisation of variables using the syatax `let x = true` or `let y = !true`.

After initialising a variable you can evaluate expressions such as `true || x`, `x && y`, `!y && true`

If you try to evaluate an expression with variable that has never been initialised such as `k && true`, you will get an error.

The following is a demo of the same:

[Problem 4 Demo Screen Recording](https://user-images.githubusercontent.com/30172987/216753258-78eb3985-8a0c-40d9-b62e-cdcf0ce2ebd1.mp4)



