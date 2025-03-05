//
//  ANItemView.swift
//  Base
//
//  Created by remy on 2018/7/20.
//

open class ANItemView: UIView, ANLinable {
    
    public var data: [AnyHashable: Any]?
    
    public init(frame: CGRect = .zero,
                color: UIColor = .clear,
                type: ANLineType = .none) {
        super.init(frame: frame)
        self.backgroundColor = color
        self.anx.lineType = type
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
