//
//  XJOptionView.swift
//  XJOptionView
//
//  Created by rxj on 16/9/28.
//  Copyright © 2016年 rxj. All rights reserved.
//

import UIKit

public typealias XJOptionViewCellPoint = AutoreleasingUnsafeMutablePointer<XJOptionViewCell>
@objc public protocol XJOptionViewDelegate: NSObjectProtocol {
    func numberOfItemsInOptionView(_ optionView: XJOptionView) ->Int
    func optionView(_ optionView: XJOptionView, itemSizeOfIndex index: Int) ->CGSize
    func optionView(_ optionView: XJOptionView, cellPointConfig cellConfig: XJOptionViewCellPoint)
    @objc optional func optionView(_ optionView: XJOptionView, didSelectedItemOfIndex index: Int)
}

enum Type: Int {
    case line
    case scale
    case arrow
}

var offset: CGFloat = 20
let lineHeight: CGFloat = 2
let timeInterval = 0.25

public class XJOptionView: UICollectionView {
   public weak var optionViewDelegate:XJOptionViewDelegate? {
        didSet{
            setOffset()
            setLineView()
        }
    }
    /// 偏移量
    public var floatIndex: Float = 0.0 {
        didSet{
            handeWithFloatIndex(floatIndex)
        }
    }
    public var normalColor: UIColor?
    public var selectedColor: UIColor? {
        didSet{
            lineView.backgroundColor = selectedColor
        }
    }
    
    var type: Type! = Type.line
    
    fileprivate lazy  var lineView: UIView! = {
        let aLineView = UIView()
        aLineView.backgroundColor = self.selectedColor != nil ? self.selectedColor: UIColor.red
        return aLineView
    }()
    fileprivate lazy var longLineView: UIView! = {
        let longLine = UIView()
        longLine.backgroundColor = UIColor.red
        longLine.frame = CGRect(x: 0, y: self.frame.maxY - self.frame.origin.y - 1, width: scr_width, height: 1)
        return longLine
    }()
    fileprivate lazy var arrowImgView: UIImageView! = {
        let imagView = UIImageView()
        imagView.image = #imageLiteral(resourceName: "arrow")
        return imagView
    }()
    
    fileprivate var selectedIndex: Int = 0
    
 
    init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        super.init(frame: frame, collectionViewLayout: layout)
        backgroundColor = UIColor.clear
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        isPagingEnabled = false
        dataSource = self
        delegate = self
        bounces = true
        register(XJOptionViewCell.self, forCellWithReuseIdentifier: "XJOptionViewCell")
        
    }
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    convenience init(frame: CGRect, type: Type) {
        self.init(frame: frame)
        self.type = type
        if type == .line {
             addSubview(lineView)
            
        } else if type == .arrow {
            addSubview(longLineView)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override public func layoutSubviews() {
        super.layoutSubviews()
    }
    
    
}

//MARK: private Method
extension XJOptionView {
    
   fileprivate func setLineView() {
        let size = optionViewDelegate!.optionView(self, itemSizeOfIndex: 0)
        let centerX = (size.width + offset) / 2
        let width = size.width
        lineView.center = CGPoint(x: centerX, y: size.height / 4 + (center.y - self.frame.origin.y))
        lineView.bounds = CGRect(x: 0, y: 0, width: width, height: lineHeight)
        
    }
    
    
   fileprivate func setOffset() {
        let count = optionViewDelegate!.numberOfItemsInOptionView(self)
        var sizes = [CGSize]()
        for i in 0..<count {
            let size = optionViewDelegate!.optionView(self, itemSizeOfIndex: i)
            sizes.append(size)
        }
        var allWidth: CGFloat = 0
        for size in sizes  {
            allWidth += (size.width + offset)
        }
        var sizesWidth: CGFloat = 0
        for size in sizes {
            sizesWidth += size.width
        }
        if allWidth < frame.width {
            offset = (frame.width - sizesWidth) / CGFloat(count)
        }
    }
    
   fileprivate func handeWithFloatIndex(_ floatIndex: Float) {
        if floatIndex - Float(Int(floatIndex)) == 0 {
            selectedIndex = Int(floatIndex)
            if type == .line {
                lineView.center.x = cellForOptionViewAtIndex(selectedIndex).center.x
                lineView.bounds.size = CGSize(width: cellForOptionViewAtIndex(selectedIndex).bounds.width - offset, height: lineHeight)
            }
            return
        }
        let handle = calculatepreAndNextAtFloatIndex(floatIndex)
        let preCell = cellForOptionViewAtIndex(handle.preIndex)
        let nextCell = cellForOptionViewAtIndex(handle.nextIndex)
        preCell.textLabel.textColor = handleColorOfDecimal(handle.decimal)
        nextCell.textLabel.textColor = handleColorOfDecimal(1.0 - handle.decimal)
        contentOffset = contentOffsetForCurrentIndex(floatIndex)
    if type == .line {
        let preWidth = floatIndex > Float(selectedIndex) ? preCell.bounds.width - offset: nextCell.bounds.width - offset
        let preCenterX = floatIndex > Float(selectedIndex) ? preCell.center.x : nextCell.center.x
        let centerX = preCenterX + (floatIndex > Float(selectedIndex) ? (nextCell.center.x - preCell.center.x) * CGFloat(handle.decimal): (preCell.center.x - nextCell.center.x) * CGFloat(1 - handle.decimal))
        lineView.center.x = centerX
        let offsetX = floatIndex > Float(selectedIndex) ? (nextCell.bounds.width - offset  - (preCell.bounds.width - offset)) * CGFloat(handle.decimal): (preCell.bounds.width - offset - (nextCell.bounds.width - offset)) * CGFloat(1 - handle.decimal)
        let width = preWidth + offsetX
        lineView.bounds.size = CGSize(width: width, height: lineHeight)
    } else if type == .scale {
        preCell.textLabel.transform = CGAffineTransform(scaleX: CGFloat(1.2 - handle.decimal * 0.2), y: CGFloat(1.2 - handle.decimal * 0.2))
        let scale = CGFloat(1 + handle.decimal * 0.2)
        nextCell.textLabel.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
    }
   fileprivate func contentOffsetForCurrentIndex(_ floatIndex: Float) ->CGPoint {
        let handle = calculatepreAndNextAtFloatIndex(floatIndex)
        let preCell = cellForOptionViewAtIndex(handle.preIndex)
        let nextCell = cellForOptionViewAtIndex(handle.nextIndex)
        var offsetX = preCell.center.x + (nextCell.center.x - preCell.center.x) * CGFloat(handle.decimal) - frame.width / 2
        offsetX = min(max(0, offsetX), contentSize.width - frame.width)
        return CGPoint(x: offsetX, y: 0)
    }
   private func handleColorOfDecimal(_ decimal: Float) -> UIColor {
    let startColor = selectedColor != nil ? selectedColor: UIColor.red
    let endColor = normalColor != nil ? normalColor: UIColor.black
        return XJColor(startColor: startColor!, endColor: endColor!, decimal: CGFloat(decimal))
    }
   private func calculatepreAndNextAtFloatIndex(_ floatIndex: Float) -> (preIndex: Int, nextIndex: Int, decimal: Float) {
        let preIndex = Int(floor(floatIndex))
        let nextIndex = Int(ceil(floatIndex))
        let decimal = floatIndex - Float(preIndex)
        return (preIndex, nextIndex, decimal)
    }
   private func cellForOptionViewAtIndex(_ index: Int) ->XJOptionViewCell {
        let cell = cellForItem(at: IndexPath(row: index, section: 0)) as! XJOptionViewCell
        return cell
    }
}

//MARK: UICollectionViewDataSource and UICollectionViewDelegate and UICollectionViewDelegateFlowLayout
extension XJOptionView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard optionViewDelegate != nil else {
            return 0
        }
        let number = optionViewDelegate?.numberOfItemsInOptionView(self)
        return number!
    }
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: XJOptionViewCell = dequeueReusableCell(withReuseIdentifier: "XJOptionViewCell", for: indexPath) as! XJOptionViewCell
        cell.index = indexPath.row
        cell.textLabel.textColor = selectedIndex == indexPath.row ? selectedColor != nil ? selectedColor: UIColor.red: normalColor != nil ? normalColor: UIColor.black
        if type != .line {
           cell.textLabel.transform = CGAffineTransform(scaleX: selectedIndex == indexPath.row ? 1.3: 1.0, y: selectedIndex == indexPath.row ? 1.3: 1.0)
        }
        if optionViewDelegate != nil {
            optionViewDelegate?.optionView(self, cellPointConfig: &cell)
        }
        return cell
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard optionViewDelegate != nil else {
            return CGSize(width: 100, height: 40)
        }
        let size = optionViewDelegate!.optionView(self, itemSizeOfIndex: indexPath.row)
        return CGSize(width: size.width + offset, height: size.height)
        
    }
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let preCell: XJOptionViewCell =  cellForItem(at: IndexPath(row: selectedIndex, section: 0)) as! XJOptionViewCell?  {
            if type == .line {
                UIView.transition(with: preCell.textLabel, duration: timeInterval, options: .transitionCrossDissolve, animations: {
                    preCell.textLabel.textColor = self.normalColor != nil ? self.normalColor: UIColor.black
                }, completion: nil)
            } else {
                UIView.animate(withDuration: timeInterval, animations: { 
                    preCell.textLabel.textColor = self.normalColor != nil ? self.normalColor: UIColor.black
                    preCell.textLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                })
            }
           
        }
        if let currentCell: XJOptionViewCell = cellForItem(at: indexPath) as! XJOptionViewCell? {
            if type == .line {
                UIView.transition(with: currentCell.textLabel, duration: timeInterval, options: .transitionCrossDissolve, animations: {
                    currentCell.textLabel.textColor = self.selectedColor != nil ? self.selectedColor: UIColor.red
                }, completion: nil)
            }
            UIView.animate(withDuration: timeInterval) {
                if self.type == .line {
                    self.lineView.center.x = currentCell.center.x
                    self.lineView.bounds.size = CGSize(width: currentCell.bounds.width - offset, height: lineHeight)
                } else if self.type == .scale {
                    currentCell.textLabel.textColor = self.selectedColor != nil ? self.selectedColor: UIColor.red
                    currentCell.textLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                }
                
            }
        }
        
        selectedIndex = indexPath.row
        setContentOffset(contentOffsetForCurrentIndex(Float(indexPath.row)), animated: true)
        guard optionViewDelegate != nil else {
            return
        }
        guard optionViewDelegate!.responds(to: #selector(XJOptionViewDelegate.optionView(_:didSelectedItemOfIndex:))) else {
            return
        }
        optionViewDelegate!.optionView!(self, didSelectedItemOfIndex: indexPath.row)
    }
    
}

public class XJOptionViewCell: UICollectionViewCell {
    var index: Int = 0
    var textLabel: UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupUI() {
        textLabel = UILabel()
        textLabel.textColor = UIColor.black
        textLabel.textAlignment = .center
        textLabel.font = setSystemFontSize(14)
        addSubview(textLabel)
    }
    override public func layoutSubviews() {
        super.layoutSubviews()
        textLabel.snp.makeConstraints { (make) in
            make.edges.equalTo(self).inset(UIEdgeInsets(top: 0, left: offset / 4, bottom: 0, right: offset / 4))
        }
    }
    
}
