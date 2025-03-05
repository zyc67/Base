//
//  CollectionVC.swift
//  Base
//
//  Created by remy on 2018/8/14.
//

import UIKit

open class CollectionVC: BaseVC, UICollectionViewDelegateFlowLayout {
    
    public var collectionView: UICollectionView!
    public var collectionModel: CollectionModel!
    public var collectionAction: CollectionAction!
    
    open override func loadView() {
        super.loadView()
        collectionView = UICollectionView(frame: contentFrame, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        collectionModel = CollectionModel()
        collectionAction = CollectionAction()
        collectionAction.forwardDelegates.add(self)
        collectionView.dataSource = collectionModel
        collectionView.delegate = collectionAction
        view.addSubview(collectionView)
    }
}

public class CollectionManager {
    
    public let view: UICollectionView
    public let model: CollectionModel
    public let action: CollectionAction
    
    private init(_ view: UICollectionView,
                 _ model: CollectionModel,
                 _ action: CollectionAction) {
        self.view = view
        self.model = model
        self.action = action
    }
    
    public static func create(frame: CGRect,
                              layout: UICollectionViewLayout? = nil,
                              target: UIScrollViewDelegate? = nil,
                              closure: ((CollectionManager) -> Void)? = nil) -> CollectionManager {
        let collectionView = UICollectionView(frame: frame, collectionViewLayout: layout ?? UICollectionViewFlowLayout())
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        let collectionModel = CollectionModel()
        let collectionAction = CollectionAction()
        let manager = CollectionManager(collectionView, collectionModel, collectionAction)
        if let target = target {
            collectionAction.forwardDelegates.add(target)
        }
        closure?(manager)
        collectionView.dataSource = collectionModel
        collectionView.delegate = collectionAction
        return manager
    }
}
