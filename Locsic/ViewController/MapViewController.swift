//
//  MapViewController.swift
//  Locsic
//
//  Created by 砂賀開晴 on 2019/06/16.
//  Copyright © 2019 Kaisei Sunaga. All rights reserved.
//

import Foundation
import UIKit
import XLPagerTabStrip
import MapKit
import CoreLocation
import RxSwift
import RxCoreLocation
import RxCocoa
import AudioKit

class MapViewController: UIViewController, IndicatorInfoProvider, SoundGeneratable {
    @IBOutlet weak var mapView: MKMapView!
    
    private let disp = DisposeBag()
    private let locationMan = CLLocationManager()
    private var annotations: [MKPointAnnotation] = []
    private let onSetOutput = PublishSubject<AKNode>()
    
    var setOutput: Observable<AKNode> {
        return onSetOutput.asObservable()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.userTrackingMode = .followWithHeading
        
        locationMan.desiredAccuracy = kCLLocationAccuracyBest
        locationMan.requestWhenInUseAuthorization()
        
        locationMan.rx.didChangeAuthorization.subscribe({ [weak self] ev in
            guard let auth = ev.element else { return }
            
            if auth.status == .authorizedWhenInUse || auth.status == .authorizedAlways {
                self?.locationMan.startUpdatingLocation()
            }
        }).disposed(by: disp)
        
        locationMan.rx.didUpdateLocations.take(1).subscribe({ [weak self] ev in
            guard let this = self, let loc = ev.element?.locations.first else { return }
            let region = MKCoordinateRegion(center: loc.coordinate, latitudinalMeters: 700, longitudinalMeters: 700)
            this.mapView.setRegion(region, animated: true)
        }).disposed(by: disp)
        
        locationMan.rx.didUpdateLocations.debounce(3, scheduler: MainScheduler.instance).subscribe({ [weak self] ev in
            guard let this = self else { return }
            
            let req = MKLocalSearch.Request()
            req.region = this.mapView.region
            req.naturalLanguageQuery = "Shop"
            
            let search = MKLocalSearch(request: req)
            
            search.start(completionHandler: { [weak self] res, err in
                if let error = err {
                    print(error.localizedDescription)
                    return
                }
                guard let resp = res else { return }
                
                self?.mapView.removeAnnotations(self!.mapView.annotations)
                let mapFunc: (MKMapItem) -> MKPointAnnotation = { (item) in
                    let point = MKPointAnnotation()
                    point.coordinate = item.placemark.coordinate
                    point.title = item.name
                    return point
                }
                
                let annotations = resp.mapItems.map(mapFunc)
                self?.mapView.addAnnotations(annotations)
                
                let osc = AKOscillator()
                osc.frequency = annotations.count * 100
                osc.amplitude = 0.5
                
                self?.onSetOutput.onNext(osc)
            })
        }).disposed(by: disp)
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Map")
    }
}
