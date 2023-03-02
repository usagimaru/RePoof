# RePoof
An injection that displays the lost Poof effect of the Dock (experiment).

![](./poof-on-dock.gif)

## The Poof API

`NSAnimationEffect.poof` is used to display Poof. This is a perfectly legal API.

[https://developer.apple.com/documentation/appkit/nsanimationeffect](https://developer.apple.com/documentation/appkit/nsanimationeffect)


## Catching user events sent to the Dock

Tap events with CGEvent API. I have included my own [EventTapper](https://github.com/usagimaru/EventTapper) via Swift PM.


## Calculate the threshold point at which a Dock tile is removed by user dragging

A certain amount of mouse movement is required for a Dock tile to be removed by user dragging. I have analyzed the Dock's behaviors and found a way to calculate the threshold for that distance of movement.

The formula is simple.

> `threshold = largeTileSize * 2 + 38`

`largeTileSize` is the tile size of the Dock when magnified. This value is recorded in the Dock's preferences plist file and is a field keyed `largesize`.

`38` is the magic number that I calculated visually. I did not measure it precisely, so this value may be inaccurate.


## Cases not fully taken into consideration

- User events sent to the Dock may not be caught correctly
- If the Dock is placed on the left or right side
- Calculation of the Dock Height
- Drawing position of a Poof effect
- Processing when a user aborts a drag with the Escape key
- Branch processing when a user drags a tile that cannot be removed
- Coverage of tile types that can be registered in the Dock


## Is there a more accurate way to detect Dock tile drags than mouse event monitoring?

Mouse event monitoring is inaccurate for detecting tile dragging. To catch it accurately, we need to know that we are dragging a tile reliably.

I thought I could get that information from the NSPasteboard for dragging, but that failed shortly after. According to Yoink's development blog, the NSPasteboard for dragging in the Dock is built with a unique name (as private), so it cannot be viewed by outside processes.

I have tried it, but could not get any useful information from it.

[Yoink: the Dock’s Stacks and iTunes files [UPDATE]](https://blog.eternalstorms.at/2011/11/29/yoink-the-docks-stacks-and-itunes-files/)
