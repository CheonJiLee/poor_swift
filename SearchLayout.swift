//
//  SearchLayout.swift
//  roop
//
//  Created by 이천지 on 2016. 10. 24..
//  Copyright © 2016년 project. All rights reserved.
//

import UIKit

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

@objc public protocol SearchLayoutDelegate:UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize
    
    @objc optional func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, heightForHeaderInSection section: Int) -> Float
    
    @objc optional func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, heightForFooterInSection section: Int) -> Float
    
    @objc optional func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, insetForSection section: Int) -> UIEdgeInsets
    
    @objc optional func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, insetForHeaderInSection section: Int) -> UIEdgeInsets
    
    @objc optional func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, insetForFooterInSection section: Int) -> UIEdgeInsets
    
    @objc optional func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, minimumInteritemSpacingForSection section: Int) -> Float
    
}

open class SearchLayout: UICollectionViewLayout {
    
    //MARK: Private constants
    /// How many items to be union into a single rectangle
    fileprivate let unionSize = 20;
    var columnCount:Int = 2
    var minimumColumnSpacing:Float = 10.0
    var minimumInteritemSpacing:Float = 10.0
    var sectionInset:UIEdgeInsets = UIEdgeInsets.zero
    
    fileprivate weak var delegate: SearchLayoutDelegate?  {
        get {
            return collectionView?.delegate as? SearchLayoutDelegate
        }
    }
    fileprivate var columnHeights = [Float]()
    fileprivate var sectionItemAttributes = [[UICollectionViewLayoutAttributes]]()
    fileprivate var allItemAttributes = [UICollectionViewLayoutAttributes]()
    fileprivate var unionRects = [CGRect]()
    
    
    //MARK: UICollectionViewLayout Methods
    override open func prepare() {
        super.prepare()
        
        let numberOfSections = collectionView?.numberOfSections
        
        if numberOfSections == 0 {
            return;
        }
        
        unionRects.removeAll(keepingCapacity: false)
        columnHeights.removeAll(keepingCapacity: false)
        allItemAttributes.removeAll(keepingCapacity: false)
        sectionItemAttributes.removeAll(keepingCapacity: false)
        
        for _ in 0..<columnCount {
            self.columnHeights.append(0)
        }
        
        // Create attributes
        var attributes: UICollectionViewLayoutAttributes
        
        for section in 0..<numberOfSections! {
            /*
             * 1. Get section-specific metrics (minimumInteritemSpacing, sectionInset)
             */
            var minimumInteritemSpacing: Float
            if let height = delegate?.collectionView?(collectionView!, layout: self, minimumInteritemSpacingForSection: section) {
                minimumInteritemSpacing = height
            }
            else {
                minimumInteritemSpacing = self.minimumInteritemSpacing
            }
            
            var sectionInset: UIEdgeInsets
            if let inset = delegate?.collectionView?(collectionView!, layout: self, insetForSection: section) {
                sectionInset = inset
            }
            else {
                sectionInset = self.sectionInset
            }
            
            let width = Float(collectionView!.frame.size.width - sectionInset.left - sectionInset.right)
            let itemWidth = floorf((width - Float(columnCount - 1) * Float(minimumColumnSpacing)) / Float(columnCount))
            
            /*
             * 3. Section items
             */
            let itemCount = collectionView!.numberOfItems(inSection: section)
            var itemAttributes = [UICollectionViewLayoutAttributes]()
            
            // Item will be put into shortest column.
            for idx in 0..<itemCount {
                let indexPath = IndexPath(item: idx, section: section)
                let columnIndex = shortestColumnIndex()
                
                let xOffset = Float(sectionInset.left) + Float(itemWidth + minimumColumnSpacing) * Float(columnIndex)
                let yOffset = columnHeights[columnIndex]
                let itemSize = delegate?.collectionView(collectionView!, layout: self, sizeForItemAtIndexPath: indexPath)
                var itemHeight: Float = 0.0
                if itemSize?.height > 0 && itemSize?.width > 0 {
                    itemHeight = Float(itemSize!.height) * itemWidth / Float(itemSize!.width)
                }
                
                attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(x: CGFloat(xOffset), y: CGFloat(yOffset), width: CGFloat(itemWidth), height: CGFloat(itemHeight) + 100)
                itemAttributes.append(attributes)
                allItemAttributes.append(attributes)
                columnHeights[columnIndex] = Float(attributes.frame.maxY) + minimumInteritemSpacing
            }
            
            sectionItemAttributes.append(itemAttributes)
            
        }
        
        //  Build union rects
        var idx = 0
        let itemCounts = allItemAttributes.count
        
        while idx < itemCounts {
            let rect1 = allItemAttributes[idx].frame
            idx = min(idx + unionSize, itemCounts) - 1
            let rect2 = allItemAttributes[idx].frame
            unionRects.append(rect1.union(rect2))
            idx += 1
        }
    }
    
    override open var collectionViewContentSize : CGSize {
        let numberOfSections = collectionView?.numberOfSections
        if numberOfSections == 0 {
            return CGSize.zero
        }
        
        var contentSize = collectionView?.bounds.size
        contentSize?.height = CGFloat(columnHeights[0])
        
        return contentSize!
    }
    
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if (indexPath as NSIndexPath).section >= sectionItemAttributes.count {
            return nil
        }
        
        if (indexPath as NSIndexPath).item >= sectionItemAttributes[(indexPath as NSIndexPath).section].count {
            return nil
        }
        
        return sectionItemAttributes[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).item]
    }
    
    
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var begin:Int = 0
        var end: Int = unionRects.count
        var attrs = [UICollectionViewLayoutAttributes]()
        
        for i in 0..<unionRects.count {
            if rect.intersects(unionRects[i]) {
                begin = i * unionSize
                break
            }
        }
        for i in (0..<unionRects.count).reversed() {
            if rect.intersects(unionRects[i]) {
                end = min((i+1) * unionSize, allItemAttributes.count)
                break
            }
        }
        for i in begin ..< end {
            let attr = allItemAttributes[i]
            if rect.intersects(attr.frame) {
                attrs.append(attr)
            }
        }
        
        return Array(attrs)
    }
    
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        let oldBounds = collectionView?.bounds
        if newBounds.width != oldBounds!.width {
            return true
        }
        
        return false
    }
    
    //MARK: Private Methods
    fileprivate func shortestColumnIndex() -> Int {
        var index: Int = 0
        var shortestHeight = MAXFLOAT
        
        for (idx, height) in columnHeights.enumerated() {
            if height < shortestHeight {
                shortestHeight = height
                index = idx
            }
        }
        
        return index
    }
    
    fileprivate func longestColumnIndex() -> Int {
        var index: Int = 0
        var longestHeight:Float = 0
        
        for (idx, height) in columnHeights.enumerated() {
            if height > longestHeight {
                longestHeight = height
                index = idx
            }
        }
        
        return index
    }
}
