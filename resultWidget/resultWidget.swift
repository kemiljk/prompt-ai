//
//  resultWidget.swift
//  resultWidget
//
//  Created by Karl Koch on 22/01/2023.
//

import WidgetKit
import SwiftUI

struct SimpleEntry: TimelineEntry, Identifiable, Hashable {
    var id = UUID()
    public let date: Date
    public let text: String
}

struct Provider: TimelineProvider {
    @AppStorage("result", store: UserDefaults(suiteName: "group.com.kejk.promptai")) var result: String = "Access GPT-3, which performs a variety of natural language tasks, Codex, which translates natural language to code, and DALL·E, which creates and edits original images."
    
    var date: Date = Date()
    
    func placeholder(in context: Context) -> SimpleEntry {
        let text: String = "Access GPT-3, which performs a variety of natural language tasks, Codex, which translates natural language to code, and DALL·E, which creates and edits original images."
        return SimpleEntry(date: Date(), text: text)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), text: result)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let nextUpdateDate = Calendar.current.date(byAdding: .hour, value: 1, to: date)!
        let entry = SimpleEntry(date: nextUpdateDate, text: result)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
        completion(timeline)
    }
}

struct resultWidgetEntryView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: Provider.Entry
    
    static let DateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    var body: some View {
        VStack (alignment: .leading) {
            VStack (alignment: .leading) {
                HStack(alignment: .center) {
                    Text("LATEST GPT-3 RESPONSE")
                        .font(Font(UIFont.systemFont(ofSize: 11, weight: .bold, width: .expanded)))
                        .foregroundColor(.mint)
                        .minimumScaleFactor(0.8)
                    Spacer()
                    if family == .systemMedium || family == .systemLarge {
                        Text("\(entry.date, formatter: Self.DateFormat)")
                            .font(.caption).bold()
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                    }
                }
                .padding(.bottom, family == .accessoryRectangular ? 2 : 8)
                VStack (alignment: .leading) {
                    Text("\(entry.text)")
                        .font(family == .accessoryRectangular || family == .systemSmall ? .system(.footnote, design: .monospaced) : .system(.body, design: .monospaced))
                        .minimumScaleFactor(family != .systemLarge ? 0.8 : 0.9)
                        .allowsTightening(true)
                        .frame(height: .infinity)
                }
                Spacer()
            }
        }
        .padding(family == .accessoryRectangular ? 0 : 16)
        .frame(minWidth: 0, idealWidth: 100, maxWidth: .infinity, minHeight: 0, idealHeight: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(family != .accessoryRectangular ? Color("bg") : .clear)
    }
}

struct resultWidget: Widget {
    let kind: String = "resultWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            resultWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Latest GPT-3 response")
        .description("Your latest GPT-3 response from your most recent prompt")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .accessoryRectangular])
    }
}

struct resultWidget_Previews: PreviewProvider {
    static var previews: some View {
        resultWidgetEntryView(entry: SimpleEntry(date: Date(), text: "Access GPT-3, which performs a variety of natural language tasks, Codex, which translates natural language to code, and DALL·E, which creates and edits original images."))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
        
        resultWidgetEntryView(entry: SimpleEntry(date: Date(), text: "Access GPT-3, which performs a variety of natural language tasks, Codex, which translates natural language to code, and DALL·E, which creates and edits original images."))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        
        resultWidgetEntryView(entry: SimpleEntry(date: Date(), text: "Access GPT-3, which performs a variety of natural language tasks, Codex, which translates natural language to code, and DALL·E, which creates and edits original images."))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        
        resultWidgetEntryView(entry: SimpleEntry(date: Date(), text: "Access GPT-3, which performs a variety of natural language tasks, Codex, which translates natural language to code, and DALL·E, which creates and edits original images."))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
