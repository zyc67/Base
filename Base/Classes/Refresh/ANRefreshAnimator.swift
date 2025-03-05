//
//  ANRefreshAnimator.swift
//  Base
//
//  Created by remy on 2018/5/17.
//

open class ANRefreshAnimator: UIView {
    public enum RefreshState {
        case idle
        case pulling
        case releaseToRefresh
        case refreshing
        case noMoreData
    }
    public var pullingText: String = "" { didSet { textDidChanged.toggle() } }
    public var releaseToRefreshText: String = "" { didSet { textDidChanged.toggle() } }
    public var refreshingText: String = "" { didSet { textDidChanged.toggle() } }
    public var loadMoreText: String = "" { didSet { textDidChanged.toggle() } }
    public var loadingText: String = "" { didSet { textDidChanged.toggle() } }
    public var noMoreDataText: String = "" { didSet { textDidChanged.toggle() } }
    private var _textDidChanged: Int = 0
    private var textDidChanged: Bool = false {
        didSet {
            if _textDidChanged == 0 {
                DispatchQueue.main.async {
                    [weak self] in
                    guard let sSelf = self else { return }
                    sSelf._textDidChanged = 0
                    sSelf.updateState(state: sSelf.state)
                }
            }
            _textDidChanged += 1
        }
    }
    /// 刷新视图高度
    open var viewHeight: CGFloat {
        return 0
    }
    /// 刷新视图高度
    open var triggerHeight: CGFloat {
        return 0
    }
    /// 位置
    open var isTop: Bool = true
    /// 当前状态
    var state: RefreshState = .idle {
        didSet {
            if oldValue == state { return }
            updateState(state: state)
            adjustView(size: self.size)
        }
    }
    /// 视图偏移比例
    public var offsetRatio: CGFloat = 0 {
        didSet {
            if oldValue == offsetRatio { return }
            updateOffsetRatio(ratio: offsetRatio)
        }
    }
    
    required public init(isTop: Bool = true) {
        super.init(frame: .zero)
        self.isTop = isTop
        if isTop {
            pullingText = ANRefreshComponent.defaultPullingText[safe: 0] ?? ""
            loadMoreText = ANRefreshComponent.defaultLoadMoreText[safe: 0] ?? ""
        } else {
            pullingText = ANRefreshComponent.defaultPullingText[safe: 1] ?? ""
            loadMoreText = ANRefreshComponent.defaultLoadMoreText[safe: 1] ?? ""
        }
        releaseToRefreshText = ANRefreshComponent.defaultReleaseToRefreshText
        refreshingText = ANRefreshComponent.defaultRefreshingText
        loadingText = ANRefreshComponent.defaultLoadingText
        noMoreDataText = ANRefreshComponent.defaultNoMoreDataText
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func updateState(state: RefreshState) {}
    open func updateOffsetRatio(ratio: CGFloat) {}
    open func adjustView(size: CGSize) {}
}

open class ANPullToRefreshAnimator: ANRefreshAnimator {
    override open var viewHeight: CGFloat {
        return 60
    }
    // https://stackoverflow.com/questions/43123862/cgaffinetransform-revert-the-rotating-direction/43124530
    private lazy var rotations1: [CGFloat] = [0, -0.999 * CGFloat.pi]
    private lazy var rotations2: [CGFloat] = [-0.999 * CGFloat.pi, 0]
    public private(set) lazy var titleLabel: UILabel = {
        let label = UILabel(textColor: UIColor(0x58646E), fontSize: 14)
        label.height = 20
        self.addSubview(label)
        return label
    }()
    public private(set) lazy var indicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .gray)
        self.addSubview(view)
        return view
    }()
    public private(set) lazy var arrow: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 12, height: 16), image: UIImage.resource(name: "arrow")!)
        self.addSubview(view)
        return view
    }()
    
    override open func updateState(state: RefreshState) {
        indicatorView.stopAnimating()
        indicatorView.isHidden = true
        arrow.isHidden = true
        let rotations = isTop ? self.rotations1 : self.rotations2
        switch state {
        case .idle:
            titleLabel.text = pullingText
        case .pulling:
            titleLabel.text = pullingText
            UIView.animate(withDuration: 0.25, animations: {
                self.arrow.transform = CGAffineTransform(rotationAngle: rotations[0])
            })
            arrow.isHidden = false
        case .releaseToRefresh:
            titleLabel.text = releaseToRefreshText
            UIView.animate(withDuration: 0.25, animations: {
                self.arrow.transform = CGAffineTransform(rotationAngle: rotations[1])
            })
            arrow.isHidden = false
        case .refreshing:
            titleLabel.text = refreshingText
            indicatorView.startAnimating()
            indicatorView.isHidden = false
            arrow.transform = CGAffineTransform(rotationAngle: rotations[0])
        default:
            break
        }
    }
    
    override open func adjustView(size: CGSize) {
        let w = size.width
        let h = size.height
        if let text = titleLabel.text {
            UIView.performWithoutAnimation {
                titleLabel.frame.size.width = text.width(font: titleLabel.font)
                titleLabel.center = CGPoint(x: w / 2, y: h / 2)
                indicatorView.center = CGPoint(x: titleLabel.frame.origin.x - 16, y: h / 2)
                arrow.center = CGPoint(x: titleLabel.frame.origin.x - 12, y: h / 2)
            }
        }
    }
}

open class ANAutoRefreshAnimator: ANRefreshAnimator {
    override open var viewHeight: CGFloat {
        return 40
    }
    override open var triggerHeight: CGFloat {
        return 24
    }
    public private(set) lazy var titleLabel: UILabel = {
        let label = UILabel(textColor: UIColor(0x58646E), fontSize: 14)
        label.height = 20
        self.addSubview(label)
        return label
    }()
    public private(set) lazy var indicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .gray)
        self.addSubview(view)
        return view
    }()
    
    override open func updateState(state: RefreshState) {
        indicatorView.stopAnimating()
        indicatorView.isHidden = true
        switch state {
        case .idle:
            titleLabel.text = loadMoreText
        case .pulling:
            titleLabel.text = loadMoreText
        case .refreshing:
            titleLabel.text = loadingText
            indicatorView.startAnimating()
            indicatorView.isHidden = false
        case .noMoreData:
            titleLabel.text = noMoreDataText
        default:
            break
        }
    }
    
    override open func adjustView(size: CGSize) {
        let w = size.width
        let h = size.height
        if let text = titleLabel.text {
            UIView.performWithoutAnimation {
                titleLabel.frame.size.width = text.width(font: titleLabel.font)
                titleLabel.center = CGPoint(x: w / 2, y: h / 2)
                indicatorView.center = CGPoint(x: titleLabel.frame.origin.x - 16, y: h / 2)
            }
        }
    }
}
