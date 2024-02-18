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
    @AppStorage("isReverseSort") private var isReverseSort: Bool = false
    
    @State private var selectedList: CustomList?
    
    var body: some View {
        NavigationSplitView {
            ListListView(sortOrder: sortOrder, isReverseSort: isReverseSort, selectedList: $selectedList)
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
                        Picker(selection: $sortOrder) {
                            Label("Alphabetically", systemImage: "textformat.abc")
                                .tag(ListSort.alphabetically)
                            Label("Newest", systemImage: "calendar")
                                .tag(ListSort.creationDate)
                            Label("Modified", systemImage: "eraser.line.dashed.fill")
                                .tag(ListSort.modified)
                        } label: {
                            Text("Sort")
                        }
                        
                        Toggle(isOn: $isReverseSort) {
                            Label("Reverse", systemImage: "arrow.up.arrow.down")
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
        } detail: {
            if let list = selectedList {
                ListView(list: list)
            } else {
                ContentUnavailableView("Add a new List", image: "plus")
            }
        }
    }
}
