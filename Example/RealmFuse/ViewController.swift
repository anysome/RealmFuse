//
//  ViewController.swift
//  RealmFuse
//
//  Created by anysome on 03/07/2020.
//  Copyright (c) 2020 anysome. All rights reserved.
//

import UIKit
import RealmSwift
import RealmFuse

class ViewController: UIViewController {

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchText = ""
    var results = [FuseSearchResult<PostModel>]()
    
    let perfectMatchAttrs: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.backgroundColor: UIColor.red
    ]
    let matchAttrs: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.foregroundColor: UIColor.red
    ]
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let sc = UISearchController()
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchResultsUpdater = self
        sc.searchBar.isTranslucent = false
        sc.hidesNavigationBarDuringPresentation = false
        navBar.items?.first?.searchController = sc
        
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Init test data
        initData()
    }
    
    private func initData() {
        let objects = realm.objects(PostModel.self)
        if objects.count == 0 {
            realm.beginWrite()
            [["title","content"],
             ["Search is a problem","I’m currently taking a big interest in. "],
             ["The legacy project","I maintain has an utterly abominable search facility"],
             ["one that I’m eager","to replace with something like Elasticsearch."],
             ["But smaller sites","that are too small for Elasticsearch to be worth the bother can still benefit from having a decent search implementation. "],
             ["Despite some recent improvements","relational databases aren’t generally that good a fit for search because they don’t really understand the concept of relevance - you can’t easily order something by how good a match it is, and your database may not deal with fuzzy matching well."],
             ["a small flat-file CMS","I’m currently working on a small flat-file CMS as a personal project"],
             ["In this case,","In the past I’ve used Lunr.js on my own site, and it works very well for this use case. "],
             ["Now we can load the JSON","via AJAX, and pass it to a new Fuse instance. You can search the index using the .search() method, as shown below:"],
             ["Fuse.js is that it can search","JSON content, making it extremely flexible. For a site with a MySQL"],
             ["cache it in Redis or Memcached indefinitely ","such time as the content changes again, and only regenerate it then, making for an extremely efficient client-side search"],
             ["As you can see","it’s pretty straightforward to use Fuse.js to create a working search field out of the box"],
             ["but the website","lists a number of options allowing you to customise the search for your particular use case"],
             ["I’d recommend","looking through these if you’re planning on using it on a project."],
             ["春节之后", "涛思数据团队全部居家远程办公"],
             ["因为疫情", "在涛我们每个人的情绪都被疫情左右了大半个月之后"],
             ["终于在新年伊始", "TDengine有了第一个好消息，按照计划，我们如期推出ARM 32位版"],
             ["为边缘计算", "嵌入式场景下时序数据的存储、查询、分析与计算提供一强大的工具"],
             ["并且100%开源", "以解决流行的SQLite在该场景下的诸多不足"],
             ["希望这个好消息", "能让你从低沉的情绪中短暂的抽离，和我们一样感到欣慰。​"],
             ["嵌入式系统中", "数据往往是各种传感器或设备采集的时序数据，这些数据具有如下鲜明的特点"],
             ["SQLite是关系型数据库", "没有利用上述数据特点，因此在存储、查询数据的性能上严重不足，而且不提供插值、不提供流式计算、不提供数据生命周期管理、无账号、无远程登录等功能，也难实现边云协同。"],
             ["TDengine还具有几大优势", "1：体量很小，安装包不到1.3M；2：占用的CPU、内存资源很少；3：数据压缩率高，占用的存储资源大幅减少。这几大优势让TDengine在资源紧张的嵌入式系统里如鱼得水。"],
             ["涛思数据团队不负众望，终于推出", "在2019年7月TDengine宣布开源后，获得全球开发者的高度关注(GitHub Star超过1万，Fork数超过2.9k)，很多开发者希望涛思数据提供ARM 32位版本，以代替他们现在使用的SQLite。"],
                ].forEach{ data in
                let model = PostModel()
                model.title = data[0]
                model.content = data[1]
                realm.add(model)
            }
            try! realm.commitWrite()
        }
    }
    
    @IBAction func reloadData(_ sender: Any) {
        try! realm.write {
            realm.deleteAll()
        }
        initData()
    }
    
    func doSearch(_ text: String? = nil) {
        if searchText == text {
            return
        }
        if let text = text {
            searchText = text
        }
        if searchText.isEmpty {
            results.removeAll()
        } else {
            results = realm.objects(PostModel.self).fuseSearch(searchText, location: 1, distance: 800, threshold: 0.3)
        }
        tableView.reloadData()
    }

}

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        doSearch(searchController.searchBar.text)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let result = results[indexPath.row]
        let attributedTitle = NSMutableAttributedString(string: result.element.title)
        let attributedContent = NSMutableAttributedString(string: result.element.content)
        for (key, _, matchedRanges) in result.results {
            if key == "title" {
                matchedRanges
                    .map(Range.init)
                    .map(NSRange.init)
                    .forEach {
                        if $0.length == self.searchText.count {
                            attributedTitle.addAttributes(perfectMatchAttrs, range: $0)
                        } else {
                            attributedTitle.addAttributes(matchAttrs, range: $0)
                        }
                }
            }
            if key == "content" {
                matchedRanges
                    .map(Range.init)
                    .map(NSRange.init)
                    .forEach {
                        if $0.length == self.searchText.count {
                            attributedContent.addAttributes(perfectMatchAttrs, range: $0)
                        } else {
                            attributedContent.addAttributes(matchAttrs, range: $0)
                        }
                }
            }
        }
        print(result.score)
        cell.textLabel?.attributedText = attributedTitle
        cell.detailTextLabel?.attributedText = attributedContent
        return cell
    }
    
}
