//
//  TableModel.swift
//  Andmix
//
//  Created by remy on 2018/3/22.
//

import UIKit

/// UITableView 的 dataSource 代理对象
public final class TableModel: NSObject {
    
    public var sectionItems: [TableSectionItem] = []
    /// section索引-值列表
    public var sectionIndexTitles: [String]?
    /// section索引-值列表对应的section
    public var sectionForSectionIndexTitle: [Int]?
    
    public func set(_ cellItem: TableCellItem) {
        set([cellItem])
    }
    
    public func set(_ cellItems: [TableCellItem]) {
        guard cellItems.count > 0 else { return }
        if sectionItems.count == 0 {
            sectionItems.append(TableSectionItem())
        }
        sectionItems.last!.rows = cellItems
    }
    
    public func set(_ sectionItem: TableSectionItem) {
        set([sectionItem])
    }
    
    public func set(_ sectionItems: [TableSectionItem]) {
        guard sectionItems.count > 0 else { return }
        self.sectionItems = sectionItems
    }
    
    public func add(_ cellItem: TableCellItem) {
        add([cellItem])
    }
    
    public func add(_ cellItems: [TableCellItem]) {
        guard cellItems.count > 0 else { return }
        if sectionItems.count == 0 {
            sectionItems.append(TableSectionItem())
        }
        sectionItems.last!.rows.append(contentsOf: cellItems)
    }
    
    public func add(_ sectionItem: TableSectionItem) {
        add([sectionItem])
    }
    
    public func add(_ sectionItems: [TableSectionItem]) {
        guard sectionItems.count > 0 else { return }
        self.sectionItems.append(contentsOf: sectionItems)
    }
    
    public func insert(_ cellItem: TableCellItem, at indexPath: IndexPath) {
        return insert([cellItem], at: indexPath)
    }
    
    public func insert(_ cellItems: [TableCellItem], at indexPath: IndexPath) {
        guard cellItems.count > 0 else { return }
        if sectionItems.count == 0 {
            sectionItems.append(TableSectionItem())
        }
        let section = indexPath.section
        let row = indexPath.row
        if let sectionItem = sectionItem(at: section) {
            if row <= sectionItem.rows.count {
                sectionItem.rows.insert(contentsOf: cellItems, at: row)
            }
        }
    }
    
    public func insert(_ sectionItem: TableSectionItem, at section: Int) {
        insert([sectionItem], at: section)
    }
    
    public func insert(_ sectionItems: [TableSectionItem], at section: Int) {
        guard sectionItems.count > 0 else { return }
        if section <= self.sectionItems.count {
            self.sectionItems.insert(contentsOf: sectionItems, at: section)
        }
    }
    
    @discardableResult
    public func remove(at section: Int) -> Bool {
        if section < sectionItems.count {
            sectionItems.remove(at: section)
            return true
        }
        return false
    }
    
    @discardableResult
    public func remove(at indexPath: IndexPath) -> Bool {
        let section = indexPath.section
        let row = indexPath.row
        if let sectionItem = sectionItem(at: section) {
            if row < sectionItem.rows.count {
                sectionItem.rows.remove(at: row)
                return true
            }
        }
        return false
    }
    
    public func removeAll() {
        sectionItems = []
    }
    
    public func sectionItem(at section: Int) -> TableSectionItem? {
        if section < sectionItems.count {
            return sectionItems[section]
        }
        return nil
    }
    
    public func cellItems(at section: Int) -> [TableCellItem] {
        return sectionItem(at: section)?.rows ?? []
    }
    
    public func allCellItems() -> [TableCellItem] {
        return sectionItems.reduce(into: [TableCellItem]()) {
            $0.append(contentsOf: $1.rows)
        }
    }
    
    public func cellItem(at indexPath: IndexPath) -> TableCellItem? {
        let section = indexPath.section
        let row = indexPath.row
        let rows = cellItems(at: section)
        if row < rows.count {
            return rows[row]
        }
        return nil
    }
}

extension TableModel {
    
    private func cellView(with cellClass: TableCell.Type, tableView: UITableView, cellItem: TableCellItem) -> UITableViewCell {
        let identifier = cellClass.metaTypeName + cellItem.cellReuseIDSuffix
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = (cellClass as UITableViewCell.Type).init(style: .default, reuseIdentifier: identifier)
        }
        (cell as! TableCell).updateBinding(cellItem: cellItem)
        return cell!
    }
}

extension TableModel: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sectionItems.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let item = sectionItem(at: section), item.showRows {
            return item.rows.count
        }
        return 0
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionItem(at: section)?.headerTitle
    }
    
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sectionItem(at: section)?.footerTitle
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let item = cellItem(at: indexPath) {
            if let cls = item.cellClass {
                item.indexPath = indexPath
                return cellView(with: cls, tableView: tableView, cellItem: item)
            }
        }
        fatalError()
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if let rowActions = cellItem(at: indexPath)?.rowActions {
            return rowActions.count > 0
        }
        return false
    }
    
    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionIndexTitles
    }
    
    public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if let index = sectionForSectionIndexTitle?.firstIndex(of: index) {
            return index
        }
        return -1
    }
}
