//
//
//  PinballMapWidget.swift
//  LibraryTemplateDemo
//
// Copyright (c) 2021 Harlan Kellaway
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
//

import WidgetKit
import SwiftUI
import Intents

//@main
//struct CommitCheckerWidget: Widget {
//    private let kind: String = "CommitCheckerWidget"
//
//    public var body: some WidgetConfiguration {
//        StaticConfiguration(kind: kind, provider: CommitTimeline(), placeholder: PlaceholderView()) { entry in
//            CommitCheckerWidgetView(entry: entry)
//        }
//        .configurationDisplayName("Swift's Latest Commit")
//        .description("Shows the last commit at the Swift repo.")
//    }
//}

//private let kWidgetKind = "PinballMapWidget"
//
//@main
//struct PinballMapWidget: Widget {
//    public var body: some WidgetConfiguration {
//        StaticConfiguration(kind: kWidgetKind, provider: PinballActivityTimeline(), placeholder: PlaceholderView()) content: { entry in
//            PinballMapWidgetView(entry: entry)
//        }
//        .configurationDisplayName("Latest Activity")
//        .description("Show's the latset activity in your region")
//    }
//}

struct Commit {
    let message: String
    let author: String
    let date: String
}

struct LastCommitEntry: TimelineEntry {
    public let date: Date
    public let commit: Commit
}



struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

struct PinballMapWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        Text(entry.date, style: .time)
    }
}

@main
struct PinballMapWidget: Widget {
    let kind: String = "PinballMapWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            PinballMapWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct PinballMapWidget_Previews: PreviewProvider {
    static var previews: some View {
        PinballMapWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
