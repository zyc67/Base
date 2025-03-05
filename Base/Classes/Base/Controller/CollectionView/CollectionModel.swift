//
//  CollectionModel.swift
//  Andmix
//
//  Created by remy on 2018/8/8.
//

import UIKit

/// UICollectionView 的 dataSource 代理对象
public final class CollectionModel: NSObject {

    public var sectionItems: [CollectionSectionItem] = []
    /// section索引-值列表
    public var sectionIndexTitles: [String]?
    /// section索引-值列表对应的section
    public var sectionForSectionIndexTitle: [Int]?
    private var registerSet: Set<String> = []
    
    public func set(_ cellItem: CollectionCellItem) {
        set([cellItem])
    }
    
    public func set(_ cellItems: [CollectionCellItem]) {
        guard cellItems.count > 0 else { return }
        if sectionItems.count == 0 {
            sectionItems.append(CollectionSectionItem())
        }
        sectionItems.last!.rows = cellItems
    }
    
    public func set(_ sectionItem: CollectionSectionItem) {
        set([sectionItem])
    }
    
    public func set(_ sectionItems: [CollectionSectionItem]) {
        guard sectionItems.count > 0 else { return }
        self.sectionItems = sectionItems
    }

    public func add(_ cellItem: CollectionCellItem) {
        add([cellItem])
    }
    
    public func add(_ cellItems: [CollectionCellItem]) {
        guard cellItems.count > 0 else { return }
        if sectionItems.count == 0 {
            sectionItems.append(CollectionSectionItem())
        }
        sectionItems.last!.rows.append(contentsOf: cellItems)
    }
    
    public func add(_ sectionItem: CollectionSectionItem) {
        add([sectionItem])
    }
    
    public func add(_ sectionItems: [CollectionSectionItem]) {
        guard sectionItems.count > 0 else { return }
        self.sectionItems.append(contentsOf: sectionItems)
    }
    
    public func insert(_ cellItem: CollectionCellItem, at indexPath: IndexPath) {
        return insert([cellItem], at: indexPath)
    }
    
    public func insert(_ cellItems: [CollectionCellItem], at indexPath: IndexPath) {
        guard cellItems.count > 0 else { return }
        let section = indexPath.section
        let row = indexPath.row
        if let sectionItem = sectionItem(at: section) {
            if row <= sectionItem.rows.count {
                sectionItem.rows.insert(contentsOf: cellItems, at: row)
            }
        }
    }
    
    public func insert(_ sectionItem: CollectionSectionItem, at section: Int) {
        insert([sectionItem], at: section)
    }
    
    public func insert(_ sectionItems: [CollectionSectionItem], at section: Int) {
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
    
    public func sectionItem(at section: Int) -> CollectionSectionItem? {
        if section < sectionItems.count {
            return sectionItems[section]
        }
        return nil
    }
    
    public func cellItems(at section: Int) -> [CollectionCellItem] {
        return sectionItem(at: section)?.rows ?? []
    }
    
    public func allCellItems() -> [CollectionCellItem] {
        return sectionItems.reduce(into: [CollectionCellItem]()) {
            $0.append(contentsOf: $1.rows)
        }
    }
    
    public func cellItem(at indexPath: IndexPath) -> CollectionCellItem? {
        let section = indexPath.section
        let row = indexPath.row
        let rows = cellItems(at: section)
        if row < rows.count {
            return rows[row]
        }
        return nil
    }
}

extension CollectionModel {
    
    private func sectionView(collectionView: UICollectionView, indexPath: IndexPath, kind: String) -> UICollectionReusableView {
        let identifier = UICollectionReusableView.metaTypeName
        if !registerSet.contains(identifier) {
            registerSet.insert(identifier)
            collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
        }
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath)
    }
    
    private func sectionView(with sectionClass: CollectionSection.Type, collectionView: UICollectionView, sectionItem: CollectionSectionItem, kind: String, suffix: String) -> UICollectionReusableView {
        let identifier = sectionClass.metaTypeName + suffix
        if !registerSet.contains(identifier) {
            registerSet.insert(identifier)
            collectionView.register(sectionClass, forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
        }
        let section = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: sectionItem.indexPath!)
        (section as! CollectionSection).updateBinding(sectionItem: sectionItem)
        return section
    }
    
    private func cellView(with cellClass: CollectionCell.Type, collectionView: UICollectionView, cellItem: CollectionCellItem) -> UICollectionViewCell {
        let identifier = cellClass.metaTypeName + cellItem.cellReuseIDSuffix
        if !registerSet.contains(identifier) {
            registerSet.insert(identifier)
            collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: cellItem.indexPath!)
        (cell as! CollectionCell).updateBinding(cellItem: cellItem)
        return cell
    }
}

extension CollectionModel: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionItems.count
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let item = sectionItem(at: section), item.showRows {
            return item.rows.count
        }
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let item = cellItem(at: indexPath) {
            if let cls = item.cellClass {
                item.indexPath = indexPath
                return cellView(with: cls, collectionView: collectionView, cellItem: item)
            }
        }
        fatalError()
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            if let item = sectionItem(at: indexPath.section), let cls = item.headerClass {
                item.indexPath = indexPath
                return sectionView(with: cls, collectionView: collectionView, sectionItem: item, kind: kind, suffix: item.headerReuseIDSuffix)
            }
        } else {
            if let item = sectionItem(at: indexPath.section), let cls = item.footerClass {
                item.indexPath = indexPath
                return sectionView(with: cls, collectionView: collectionView, sectionItem: item, kind: kind, suffix: item.footerReuseIDSuffix)
            }
        }
        return sectionView(collectionView: collectionView, indexPath: indexPath, kind: kind)
    }
    
    public func indexTitles(for collectionView: UICollectionView) -> [String]? {
        return sectionIndexTitles
    }
    
    public func collectionView(_ collectionView: UICollectionView, indexPathForIndexTitle title: String, at index: Int) -> IndexPath {
        if let index = sectionForSectionIndexTitle?.firstIndex(of: index) {
            return IndexPath(row: 0, section: index)
        }
        return IndexPath(row: 0, section: -1)
    }
}
