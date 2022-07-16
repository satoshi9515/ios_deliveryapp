//
//  MapViewController.swift
//  GsTodo
//
//  Created by 鈴江元尚 on 2022/03/18.
//  Copyright © 2022 yamamototatsuya. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

/// 位置情報をマップ表示するビュー
class MapViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {
    ///マップ
    @IBOutlet weak var mapView: MKMapView!
    ///ロケーションマネージャー
    var locationManager:CLLocationManager!
    ///地図上のピン
    var pin = MKPointAnnotation()
    ///緯度
    var latitude:CLLocationDegrees? {
        didSet{
            ///latitudeの値が変わった時に走る処理
            print("latitude didSet")
            ///ピンを取り除く
            mapView.removeAnnotation(pin)
            ///latitudeとlongitudeから位置情報のインスタンスを作成
            let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude ?? 0.0, longitude: longitude ?? 0.0)
            ///ピンの位置情報を更新
            pin.coordinate = coordinate
            ///ピンを再び加える
            mapView.addAnnotation(pin)
        }
    }
    ///経度
    var longitude:CLLocationDegrees?{
        didSet{
            print("longitude didSet")
            mapView.removeAnnotation(pin)
            let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude ?? 0.0, longitude: longitude ?? 0.0)
            pin.title = "Staff"
            pin.coordinate = coordinate
            mapView.addAnnotation(pin)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch UserInfo.user.segment {
            ///カスタマーが開いた時のみ機能する形にする
        case .customer:
            ///マップビューのデリゲート先を指定
            self.mapView.delegate = self
            ///ユーザー自身の位置をトラッキング
            self.mapView.setUserTrackingMode(.followWithHeading, animated: true)
            ///ユーザー自身の位置を表示
            self.mapView.showsUserLocation = true
            ///ロケーションマネージャーをセット
            self.setUpLocationManager()
            ///ピンのタイトルを設定
            pin.title = "Staff"
        case .staff:
            print("staff")
        }

        // Do any additional setup after loading the view.
    }
    
    ///マップ表示のビューを消す
    @IBAction func tapDismissButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    ///ロケーションマネージャーを設定（customer側が自分自身の現在地を知るため）
    func setUpLocationManager(){
        locationManager = CLLocationManager()
        ///ロケーションマネージャーのデリゲート先を指定
        locationManager.delegate = self
        ///ロケーションマネージャーの利用許可をリクエスト
        locationManager.requestWhenInUseAuthorization()
        
        print("center:\(mapView.userLocation.coordinate)")
    }
    
    /// 位置情報の許可に応じた処理を行うためのdelegateメソッド
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            /// 許可されてない場合
        case .notDetermined:
            /// 許可を求める
            manager.requestWhenInUseAuthorization()
            /// 拒否されてる場合
        case .restricted, .denied:
            /// 何もしない
            break
            /// 許可されている場合
        case .authorizedAlways, .authorizedWhenInUse:
            /// 現在地の取得を開始
            manager.startUpdatingLocation()
            break
        default:
            break
        }
    }
    ///マップビューのデリゲートメソッド
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        switch UserInfo.user.segment {
        case .customer:
            ///地図のズーム表示。0に近づくほどズームされ、1に近づくほど拡大される
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            ///中心位置をユーザーの現在地に設定し、ズーム設定を反映
            let region = MKCoordinateRegion(center: userLocation.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        case .staff:
            print("staff")
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
