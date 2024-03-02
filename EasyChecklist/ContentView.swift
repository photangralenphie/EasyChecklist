//
//  ContentView.swift
//  EasyChecklist
//
//  Created by Jonas Helmer on 16.02.24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var showSettings: Bool = false
    @State private var newCustomList: Bool = false
    
    @AppStorage("sortOrder") private var sortOrder: ListSort = ListSort.modified
    @AppStorage("isAcendingSort") private var isAscendingSort: Bool = false
    
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
    
    @State private var selectedList: CustomList?
    
    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            ListListView(sortOrder: sortOrder, isAscendingSort: isAscendingSort, selectedList: $selectedList)
            .toolbar{
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button { 
                        showSettings.toggle()
                    } label: {
                        Label("Settings", systemImage: "gear")
                    }
                }
                
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Menu {
                        Picker(selection: $sortOrder.animation()) {
                            Label("Alphabetically", systemImage: "textformat.abc")
                                .tag(ListSort.alphabetically)
                            Label("Newest", systemImage: "calendar")
                                .tag(ListSort.creationDate)
                            Label("Modified", systemImage: "eraser.line.dashed.fill")
                                .tag(ListSort.modified)
                        } label: {
                            Text("Sort")
                        }
                        
                        ControlGroup("Order") {
                            Button {
                                withAnimation { isAscendingSort = true }
                            } label: {
                                Label(
                                    title: { Text("Ascending") },
                                    icon: { Image(isAscendingSort ? "arrow.up.badge.checkmark" : "arrow.up") }
                                )
                            }
                            
                            Button {
                                withAnimation { isAscendingSort = false }
                            } label: {
                                Label(
                                    title: { Text("Descending") },
                                    icon: { Image(isAscendingSort ? "arrow.down" : "arrow.down.badge.checkmark") }
                                )
                            }
                        }
                    } label: {
                        Label("Sort by", systemImage: "arrow.up.arrow.down")
                    }

                    Button {
                        newCustomList.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $newCustomList) { AddListView() }
            .sheet(isPresented: $showSettings) { SettingsView() }
            .navigationTitle("Checklists")
            .navigationSplitViewStyle(.balanced)
        } detail: {
            if let list = selectedList {
                ListView(list: list)
            } else {
                ContentUnavailableView("No Checklists", image: "plus", description: Text("Get Started by adding a new Checklist with the plus button"))
                //ContentUnavailableView("No Checklists", systemImage: "plus")
            }
        }
    }
}
