//
//  ViewController.swift
//  MyOkashi
//
//  Created by 米田 央 on 2017/06/17.
//  Copyright © 2017年 Swift-Yoneda. All rights reserved.
//

import UIKit
import SafariServices

class ViewController: UIViewController,UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,SFSafariViewControllerDelegate {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    searchText.delegate = self
    searchText.placeholder = "お菓子の名前を入力してください"
    
    tableView.dataSource = self
    
    tableView.delegate = self
    
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBOutlet weak var searchText: UISearchBar!
  
  @IBOutlet weak var tableView: UITableView!
  
  // タプル配列
  var okashiList : [(maker:String, name:String, link:String, image:String)] = []
  
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    
    view.endEditing(true)
    print(searchBar.text ?? "値がありません")
    
    if let searchWord = searchBar.text{
      searchOkashi(keyword: searchWord)
    }
  }
  
  func searchOkashi(keyword:String){
    
    let keyword_encode = keyword.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
    
    // Foundationはなくてもok
    let url = Foundation.URL(string: "http://www.sysbird.jp/toriko/api/?apikey=guest&format=json&keyword=\(keyword_encode!)&max=10&order=r")
    
    print(url ?? "urlなし")
    
    // リクエストオブジェクトの生成
    let req = URLRequest(url: url!)
    
    // セッションのタイムアウトのカスタマイズ
    let configuration = URLSessionConfiguration.default
    
    let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
    
    let task = session.dataTask(with: req, completionHandler: {
      (data, request, error) in
      
      do{
        let json = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
        
        // 「\」は文字列の中で、変数を展開する書き方
        // print("count = \(String(describing: json["count"]))")
        
        // お菓子リストの初期化
        self.okashiList.removeAll()
        
        if let items = json["item"] as? [[String:Any]]{
          
          for item in items{
            
            guard let maker = item["maker"] as? String else{
              continue
            }
            
            guard let name = item["name"] as? String else{
              continue
            }
            
            guard let link = item["url"] as? String else{
              continue
            }
            
            guard let image = item["image"] as? String else{
              continue
            }
            
            let okashi = (maker,name,link,image)
            
            self.okashiList.append(okashi)
            
          }
          
        }
        
        print("--------------------")
        print("okashiList[0] = \(String(describing: self.okashiList.first))")
        
        // tableViewの更新
        self.tableView.reloadData()
        
      }catch{
        print("エラーが出ました")
      }
    
    })
    
    // ダウンロード開始
    // ここで初めて、taskが動き出す
    task.resume()
  }
  
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return okashiList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "okashiCell", for: indexPath)
    
    cell.textLabel?.text = okashiList[indexPath.row].name
    
    let url = URL(string: okashiList[indexPath.row].image)
    
    
    // 「tyr?」は簡易エラーハンドリング
    if let image_data = try? Data(contentsOf: url!){
      
      cell.imageView?.image = UIImage(data: image_data)
    }
    
    return cell
  }
  
  

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    tableView.deselectRow(at: indexPath, animated: true)
    
    let urlToLink = URL(string: okashiList[indexPath.row].link)
    
    let safariViewController = SFSafariViewController(url: urlToLink!)
    
    safariViewController.delegate = self
    
    present(safariViewController, animated: true, completion: nil)
    
  }
  
  
  func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
    dismiss(animated: true, completion: nil)
  }
  


}

