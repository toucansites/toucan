---
title: Tesla's Vision for Wireless Energy
description: Nikola Tesla's ambitious vision for a world powered by wireless energy.
image: ./teslas-vision-for-wireless-energy/cover.jpg
publication: 1919-09-10 12:01:01
tags: 
    - energy
    - engineering
authors: 
    - nikola-tesla
---



# An h1 header

Paragraphs are separated by a blank line.

2nd paragraph. *Italic*, **bold**, and `monospace`. Itemized lists look like:

  * this one
  * that one
  * the other one

Note that --- not considering the asterisk --- the actual text content starts at 4-columns in.

> Block quotes are
> written like so.
>
> They can span multiple paragraphs,
> if you like.

Use 3 dashes for an em-dash. Use 2 dashes for ranges (ex., "it's all in chapters 12--14"). Three dots ... will be converted to an ellipsis. Unicode is supported. ☺

```swift
actor AppState {
    enum DownloadState {
        case notDownloaded
        case downloading
        case downloaded
    }

    var downloadState = DownloadState.notDownloaded
    let stream: AsyncStream<UIEvent>

    init(stream: AsyncStream<UIEvent>) {
        self.stream = stream
    }

    func handleEvents() async {
        for await event in stream {
            switch event {
            case .startDownloadTapped:
                switch downloadState {
                case .notDownloaded:
                    downloadState = .downloading
                    do {
                        try await startDownload()
                        downloadState = .downloaded
                    } catch {
                        downloadState = .notDownloaded
                    }
                case .downloading, .downloaded:
                    // Don't respond to user input
                    continue
                }
            }
        }
    }
}
```

Use 3 dashes for an em-dash. Use 2 dashes for ranges (ex., "it's all in chapters 12--14"). Three dots ... will be converted to an ellipsis. Unicode is supported. ☺
