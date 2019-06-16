//
//  TabViewController.swift
//  Locsic
//
//  Created by 砂賀開晴 on 2019/06/16.
//  Copyright © 2019 Kaisei Sunaga. All rights reserved.
//

import Foundation
import XLPagerTabStrip
import RxSwift
import AudioKit

protocol SoundGeneratable {
    var setOutput: Observable<AKNode>
}

class TabViewController: TwitterPagerTabStripViewController {
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        return [MapViewController()]
    }
}

class NavigationTabViewController: UINavigationController {
    public init() {
        super.init(rootViewController: TabViewController())
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
