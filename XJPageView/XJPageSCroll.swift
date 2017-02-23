//
//  XJPageSCroll.swift
//  XJPageView
//
//  Created by 任晓健 on 2017/2/22.
//  Copyright © 2017年 rxj. All rights reserved.
//

import UIKit

let navHeight: CGFloat = 64

enum ScrollSate: Int {
    case scrollToNomal = 0
    case scrollToUp
    case scrollToDown
}

class XJPageSCroll: UIScrollView {

    
    fileprivate var titles: [String]!
    fileprivate var views:[UIView]!
    fileprivate var topView: UIView!
    fileprivate lazy var optionView: XJOptionView = {
        let newOptionView: XJOptionView = XJOptionView(frame: CGRect(x: 0, y: 0, width: scr_width, height: 40), type: .line)
        newOptionView.normalColor = UIColor.gray
        newOptionView.selectedColor = UIColor.red
        newOptionView.optionViewDelegate = self
        
        let line = UILabel()
        line.backgroundColor = UIColor.groupTableViewBackground
        line.frame = CGRect(x: 0, y: 39.5, width: scr_width, height: 0.5)
        newOptionView.addSubview(line)
        
        return newOptionView
    }()
   fileprivate lazy var pageView: XJPageView = {
        let aPageView = XJPageView()
        aPageView.frame = CGRect(x: 0, y: 40, width: scr_width, height: scr_height - 40)
        aPageView.pageViewDelegate = self
        return aPageView
    }()
    
  fileprivate var scrollSate: ScrollSate = .scrollToNomal {
        didSet{
            if scrollSate != oldValue {
                sateChange()
            }
        }
    }
    
    convenience init(frame: CGRect,topView: UIView, titles: [String], views: [UIView]) {
        self.init(frame: frame)
        self.titles = titles
        self.views = views
        self.topView = topView;
        setupScroll()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   private func setupScroll() {
        delegate = self
        backgroundColor = UIColor.white
        alwaysBounceVertical = true
        setupSubView()
    }
    
   private func setupSubView() {
        
        addSubview(topView)
        let midView = mideView()
        addSubview(midView)
    
        let sepView = sepeView()
        let pageView = UIView(frame: CGRect(x: 0, y: midView.frame.maxY, width: scr_width, height: scr_height - 64 - 40))
        addSubview(pageView)
        
        pageView.addSubview(self.pageView)
        pageView.addSubview(optionView)
        pageView.addSubview(sepView)
        
        sepView.snp.makeConstraints { (make) in
            make.bottom.equalTo(optionView.snp.top)
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
        }
         contentSize = CGSize(width: scr_width, height: topView.frame.height + 40)
        
    }
    
   private func sepeView() -> UIView {
        let sepView = UIView()
        sepView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        let label = UILabel()
        label.text = "下拉返回顶部"
        label.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 12)
        sepView.addSubview(label)
        sepView.layer.masksToBounds = true
        label.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-20)
            make.centerX.equalToSuperview()
        }
        
        let imgView = UIImageView(image: #imageLiteral(resourceName: "slide"))
        sepView.addSubview(imgView)
        imgView.snp.makeConstraints { (make) in
            make.centerY.equalTo(label)
            make.right.equalTo(label.snp.left).offset(-8)
        }
        
        return sepView
    }
    
   private func mideView() -> UIView {
        let midView = UIView(frame: CGRect(x: 0, y: (topView.frame.maxY), width: scr_width, height: 40))
        midView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        let label = UILabel()
        label.text = "继续下拉进入详情页";
        label.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 12)
        midView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        let imgView = UIImageView(image: #imageLiteral(resourceName: "slide"))
        imgView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
        midView.addSubview(imgView)
        imgView.snp.makeConstraints { (make) in
            make.centerY.equalTo(label)
            make.right.equalTo(label.snp.left).offset(-8)
        }
        
        return midView
    }
    
   private func sateChange() {
        switch scrollSate {
        case .scrollToNomal:
            break
        case .scrollToDown:
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                self.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            }, completion: { (finsined) in
                self.contentSize = CGSize(width: scr_width, height: self.topView.frame.height + 40)
                self.isScrollEnabled = true
            })
           
        case .scrollToUp:
            
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut, animations: {
                self.setContentOffset(CGPoint(x: 0, y: self.topView.frame.height + 40), animated: false)
            }, completion: { (finsined) in
                self.contentSize = CGSize(width: scr_width, height: self.topView.frame.height + 40 + scr_height)
                self.isScrollEnabled = false
            })
            
        }
    }

}

extension XJPageSCroll: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y - (scrollView.contentSize.height - scrollView.frame.height)
        print(offsetY)
        if offsetY >= 80 {
            if !scrollView.isDragging {
                scrollSate = .scrollToUp
            }
            
        }
    }
}

//MARK: XJOptionViewDelegate
extension XJPageSCroll: XJOptionViewDelegate {
    func numberOfItemsInOptionView(_ optionView: XJOptionView) -> Int {
        return titles.count
    }
    func optionView(_ optionView: XJOptionView, itemSizeOfIndex index: Int) -> CGSize {
        let title = titles[index]
        let size = NSString(string: title).boundingRect(with: CGSize.zero, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: setSystemFontSize(14)], context: nil)
        return CGSize(width: size.width, height: 40)
    }
    func optionView(_ optionView: XJOptionView, cellPointConfig cellConfig: XJOptionViewCellPoint) {
        let cell = cellConfig.pointee
        cell.textLabel.text = titles[cell.index]
    }
    func optionView(_ optionView: XJOptionView, didSelectedItemOfIndex index: Int) {
        pageView.currentIndex = index
    }
}

//MARK: XJPageViewDelegate
extension XJPageSCroll: XJPageViewDelegate {
    func numbersOfItemsInPageView(_ pageView: XJPageView) -> Int {
        return titles.count
    }
    func pageView(_ pageView: XJPageView, cellForPageViewAtIndex index: Int) -> XJPageViewCell {
        let cell: XJPageViewCell = pageView.dequeueReusableCell(withReuseIdentifier: "XJPageViewCell", for: IndexPath(row: index, section: 0)) as! XJPageViewCell
        cell.index = index
        let view = views[index]
        if view is XJTableView {
            (view as! XJTableView).scrolldidChangeClosures(closures: { (scrollView, isStop) in
                let offsetY = scrollView.contentOffset.y
                print(offsetY)
                if offsetY <= 0 {
                    self.optionView.frame = CGRect(x: 0, y: -offsetY, width: scr_width, height: 40)
                    if offsetY <= -80 {
                        if !scrollView.isDragging {
                            self.scrollSate = .scrollToDown
                        }
                        
                    }
                }
                if isStop {
                   UIView.animate(withDuration: 0.2, animations: { 
                    self.optionView.frame = CGRect(x: 0, y: 0, width: scr_width, height: 40)
                   })
                }

            })
        } else {
            (view as! XJWebView).scrolldidChangeClosures(closures: { (scrollView, isStop) in
                let offsetY = scrollView.contentOffset.y
                print(offsetY)
                if offsetY <= 0 {
                    self.optionView.frame = CGRect(x: 0, y: -offsetY, width: scr_width, height: 40)
                    if offsetY <= -80 {
                        if !scrollView.isDragging {
                            self.scrollSate = .scrollToDown
                        }
                        
                    }
                }
                if isStop {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.optionView.frame = CGRect(x: 0, y: 0, width: scr_width, height: 40)
                    })
                }

            })
        }
        view.frame = CGRect(x: 0, y: 0, width: scr_width, height: scr_height - 40 - 64)
        cell.addSubview(view)
        return cell
    }
    func pageView(_ pageView: XJPageView, didScrollToFloatIndex floatIndex: Float) {
        guard floatIndex >= 0 && (floatIndex < Float(titles.count - 1)) else {
            return
        }
        optionView.floatIndex = floatIndex
    }
}

