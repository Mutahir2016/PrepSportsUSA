//
//  BottomBarViewController.swift
//  Plate101
//
//  Created by Syed Mutahir Pirzada on 10/26/17.
//  Copyright © 2017 Asad. All rights reserved.
//

import UIKit


protocol TabBarDelegate: NSObjectProtocol {
    func tabBar(_ tabbar: TabBar, selectedTab nSelectedTab: Int)
}


class TabBar: UIViewController {
    weak var delegate: TabBarDelegate?
    var nSelectedTab: Int = -1
    var selectedTab = UIConstants.selectedTab.none
        
    @IBOutlet weak var pFirstTabImg: UIImageView!
    @IBOutlet weak var pFirstTabTitleLbl: UILabel!
    
    @IBOutlet weak var pSecondTabImg: UIImageView!
    @IBOutlet weak var pSecondTabTitleLbl: UILabel!
    
//    @IBOutlet weak var pThirdTabTitleLbl: UILabel!
//    @IBOutlet weak var pThirdTabImg: UIImageView!
    
    @IBOutlet weak var pFourthTabTitleLbl: UILabel!
    @IBOutlet weak var pFourthTabImg: UIImageView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    /*****************************************************************************/
    //
    /*****************************************************************************/
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
    }

    /*****************************************************************************/
    //
    /*****************************************************************************/

    private func setupUI() {
        pFirstTabTitleLbl.textColor = UIColor.tabBarUnSelectedColor
        pSecondTabTitleLbl.textColor = UIColor.tabBarUnSelectedColor
//        pThirdTabTitleLbl.textColor = UIColor.tabBarUnSelectedColor
        pFourthTabTitleLbl.textColor = UIColor.tabBarUnSelectedColor
    }
    
    /*****************************************************************************/
    //
    /*****************************************************************************/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*****************************************************************************/
    //
    /*****************************************************************************/
    
    func setSelectedTab(_ nTab: Int) {
        nSelectedTab = nTab
        setTabbarUI()
    }
    
    /*****************************************************************************/
    //
    /*****************************************************************************/
    
    func getSelectedTab() -> Int {
        return nSelectedTab
    }
    
    /*****************************************************************************/
    //
    /*****************************************************************************/
    
    func setTabbarUI() {
        // setting UI for selected tab
        pFirstTabTitleLbl.font = UIFont.ibmRegular(size: 12.0)
        pSecondTabTitleLbl.font = UIFont.ibmRegular(size: 12.0)
//        pThirdTabTitleLbl.font = UIFont.ibmRegular(size: 12.0)
        pFourthTabTitleLbl.font = UIFont.ibmRegular(size: 12.0)
    }
    
    /*****************************************************************************/
    // Here we will set the Tab bar according to type. because there are two types
    // of tabs used in the app.
    /*****************************************************************************/
    
    func setTabBarFor(nTabType: Int) {
        setTabbarUI()
        pFirstTabTitleLbl.textColor = nTabType == 1 ? UIColor.tabBarSelectedColor : UIColor.tabBarUnSelectedColor
        pSecondTabTitleLbl.textColor = nTabType == 2 ? UIColor.tabBarSelectedColor : UIColor.tabBarUnSelectedColor
//        pThirdTabTitleLbl.textColor = nTabType == 3 ? UIColor.tabBarSelectedColor : UIColor.tabBarUnSelectedColor
        pFourthTabTitleLbl.textColor = nTabType == 4 ? UIColor.tabBarSelectedColor : UIColor.tabBarUnSelectedColor
        
        pFirstTabImg.image = nTabType == 1 ? UIImage(named: "Home_active") : UIImage(named: "Home_Inactive")
        pSecondTabImg.image = nTabType == 2 ? UIImage(named: "Monitor") : UIImage(named: "Monitor_unselected")
//        pThirdTabImg.image = nTabType == 3 ? UIImage(named: "GlobeSimple") : UIImage(named: "GlobeSimple")
        pFourthTabImg.image = nTabType == 4 ? UIImage(named: "DotsThreeCircle") : UIImage(named: "DotsThreeCircle")

        // Configure Monitor icon with template rendering
        if let monitorImage = UIImage(named: "Monitor") {
            let templateImage = monitorImage.withRenderingMode(.alwaysTemplate)
            pSecondTabImg.image = templateImage
            pSecondTabImg.tintColor = nTabType == 2 ? UIColor.tabBarSelectedColor : UIColor.tabBarUnSelectedColor
        }
        
        // Configure MagnifyingGlass icon with template rendering for color fill
        if let magnifyingGlassImage = UIImage(named: "MagnifyingGlass") {
            let templateImage = magnifyingGlassImage.withRenderingMode(.alwaysTemplate)
//            pThirdTabImg.image = templateImage
//            pThirdTabImg.tintColor = nTabType == 5 ? UIColor.tabBarSelectedColor : UIColor.tabBarUnSelectedColor
        }
        
        // Configure DotsThreeCircle icon with template rendering
        if let dotsImage = UIImage(named: "DotsThreeCircle") {
            let templateImage = dotsImage.withRenderingMode(.alwaysTemplate)
            pFourthTabImg.image = templateImage
            pFourthTabImg.tintColor = nTabType == 4 ? UIColor.tabBarSelectedColor : UIColor.tabBarUnSelectedColor
        }
    }
    
    /*****************************************************************************/
    //
    /*****************************************************************************/
    
    @IBAction func onHomeTapped(_ sender: Any)
    {
        setSelectedTab(1)
        delegate?.tabBar(self, selectedTab:1)
    }
    
    /*****************************************************************************/
    //
    /*****************************************************************************/
    
    @IBAction func onStoriesTapped(_ sender: Any)
    {
        setSelectedTab(2)
        delegate?.tabBar(self, selectedTab:2)
    }
    
    /*****************************************************************************/
    //
    /*****************************************************************************/
    
    @IBAction func onTrafficTapped(_ sender: Any)
    {
        setSelectedTab(3)
        delegate?.tabBar(self, selectedTab:3)
    }
    
    /*****************************************************************************/
    //
    /*****************************************************************************/
    
    @IBAction func onMoreTapped(_ sender: Any)
    {
        setSelectedTab(4)
        delegate?.tabBar(self, selectedTab:4)
    }
    
    /*****************************************************************************/
    //
    /*****************************************************************************/
    
    @IBAction func onSearchTapped(_ sender: Any)
    {
        setSelectedTab(3)
        delegate?.tabBar(self, selectedTab:3)
    }
}
