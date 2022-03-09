//
//  ContentView.swift
//  DragAndDropBugs
//
//  Created by Rostyslav Litvinov on 09.03.2022.
//

import SwiftUI

struct ContentView: View {
    @State private var onDragCount = 0

    @State private var items: [Int] = {
        (0..<5).map { $0 }
    }()

    @State private var currentItemOffset: Int? = nil

    var body: some View {
        VStack {
            Text("onDrag count: \(onDragCount)")
            ForEach(items, id: \.self) { item in
                HStack {
                    Spacer()
                    Text("Item \(item)")
                    Spacer()
                }
                .frame(height: 30)
                .border(Color.blue, width: 3)
                .background(Color.gray)
                .padding()
                .onDrag {
                    onDragCount += 1
                    currentItemOffset = items.firstIndex(of: item)!
                    return .init(object: "\(item)" as NSString)
                }
                .onDrop(of: [.text],
                        delegate: MyInsideDelegate(
                            offset: items.firstIndex(of: item)!,
                            currentItemOffset: $currentItemOffset,
                            onMove: onMove))
            }
        }
        .animation(.default, value: items)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onDrop(of: [.text],
                delegate: MyOutsideDelegate(currentItemOffset: $currentItemOffset))
    }

    private func onMove(fromOffset: Int, toOffset: Int) {
        items.move(fromOffsets: IndexSet(integer: fromOffset), toOffset: toOffset)
    }
}

struct MyInsideDelegate: DropDelegate {
    let offset: Int
    let currentItemOffset: Binding<Int?>
    let onMove: (Int, Int) -> Void

    func performDrop(info: DropInfo) -> Bool {
        currentItemOffset.wrappedValue = nil
        return true
    }

    func dropEntered(info: DropInfo) {
        guard let currentOffset = currentItemOffset.wrappedValue, currentOffset != offset else {
            return
        }
        
        let moveOffset = offset > currentOffset ? offset + 1 : offset
        onMove(currentOffset, moveOffset)
        currentItemOffset.wrappedValue = offset
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }

    func validateDrop(info: DropInfo) -> Bool {
        true
    }
}

struct MyOutsideDelegate: DropDelegate {
    let currentItemOffset: Binding<Int?>

    func performDrop(info: DropInfo) -> Bool {
        currentItemOffset.wrappedValue = nil
        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }

    func validateDrop(info: DropInfo) -> Bool {
        true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
