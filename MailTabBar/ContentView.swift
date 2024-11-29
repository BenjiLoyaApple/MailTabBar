//
//  ContentView.swift
//  MailTabBar
//
//  Created by Benji Loya on 28.11.2024.
//

import SwiftUI

struct ContentView: View {
    //View Properties
    @State private var searchText: String = ""
    @State private var isSearchactive: Bool = false
    @State private var activeTab: TabModel = .primary
    ///Scroll Properties
    @State private var scrollOffset: CGFloat = 0
    @State private var  topInset: CGFloat = 0
    @State private var  startTopInset: CGFloat = 0
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    CustomTabBar(activeTab: $activeTab)
                        .frame(height: isSearchactive ? 0 : nil, alignment: .top)
                        .opacity(isSearchactive ? 0 : 1)
                        .padding(.bottom, isSearchactive ? 0 : 10)
                        .padding(.bottom, 10)
                        .background {
                            let progress = min(max((scrollOffset + startTopInset - 110) / 15, 0), 1)
                            
                            ZStack(alignment: .bottom) {
                                RoundedRectangle(cornerRadius: 0, style: .continuous)
                                    .fill(.ultraThinMaterial)
                                
                                /// Divider
                                RoundedRectangle(cornerRadius: 0, style: .continuous)
                                    .fill(.gray.opacity(0.3))
                                    .frame(height: 1)
                                
                            }
                            .padding(.top, -topInset)
                            .opacity(progress)
                        }
                        .offset(y: (scrollOffset + topInset) > 0 ? (scrollOffset + topInset) : 0)
                        .zIndex(1000)
                    
                    /// your other view here
                    LazyVStack(alignment: .leading) {
                        Text("Mails")
                            .font(.caption2)
                            .foregroundStyle(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(15)
                    .zIndex(0)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: isSearchactive)
            .onScrollGeometryChange(for: CGFloat.self, of: {
                $0.contentOffset.y
            }, action: { oldValue, newValue in
                scrollOffset = newValue
            })
            .onScrollGeometryChange(for: CGFloat.self, of: {
                $0.contentInsets.top
            }, action: { oldValue, newValue in
                if startTopInset == .zero {
                    startTopInset = newValue
                }
                topInset = newValue
            })
            
            .navigationTitle("All Inbox")
            .searchable(text: $searchText, isPresented: $isSearchactive, placement: .navigationBarDrawer(displayMode: .automatic))
            .background(.gray.opacity(0.1))
            .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
        }
    }
}

struct CustomTabBar: View {
    
    @Binding var activeTab: TabModel
    @Environment(\.colorScheme) private var scheme
    var body: some View {
        GeometryReader { _ in
            HStack(spacing: 8) {
                HStack(spacing: activeTab == .allMails ? -15 : 8) {
                    ForEach(TabModel.allCases.filter({ $0 != .allMails}), id: \.rawValue) { tab in
                        ResizableTabButton(tab)
                    }
                }
                
                if activeTab == .allMails {
                    ResizableTabButton(.allMails)
                        .transition(.offset(x: 200))
                }
            }
            .padding(.horizontal, 15)
        }
        .frame(height: 50)
    }
    
    @ViewBuilder
    func ResizableTabButton(_ tab: TabModel) -> some View {
        HStack(spacing: 8) {
            Image(systemName: tab.symbolImage)
                .opacity(activeTab != tab ? 1 : 0)
                .overlay {
                    Image(systemName: tab.symbolImage)
                        .symbolVariant(.fill)
                        .opacity(activeTab == tab ? 1 : 0)
                }
            
            if activeTab == tab {
                Text(tab.rawValue)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .lineLimit(1)
            }
        }
        .foregroundStyle(tab == .allMails ? schemeColor : activeTab == tab ? .white : .gray)
        .frame(maxHeight: .infinity)
        .frame(maxWidth: activeTab == tab ? .infinity : nil)
        .padding(.horizontal, activeTab == tab ? 10 : 20)
        .background {
            Rectangle()
                .fill(activeTab == tab ? tab.color : .gray.opacity(0.1))
        }
        .clipShape(.rect(cornerRadius: 20, style: .continuous))
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.background)
                .padding(activeTab == .allMails && tab != .allMails ? -3 : 3)
        }
        .contentShape(.rect)
        .onTapGesture {
            guard tab != .allMails else { return }
            withAnimation(.bouncy) {
                if activeTab == tab {
                    activeTab = .allMails
                } else {
                    activeTab = tab
                }
            }
        }
    }
    
    var schemeColor: Color {
        scheme == .dark ? .black : .white
    }
}




#Preview {
    ContentView()
}
