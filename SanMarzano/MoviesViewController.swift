//
//  MoviesViewController.swift
//  SanMarzano
//
//  Created by Matthew Carroll on 4/14/15.
//  Copyright (c) 2015 blarg. All rights reserved.
//

import UIKit


class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var networkErrorView: UIView!
    
    var refreshControl: UIRefreshControl!
    
    var movies : [NSDictionary]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        loadMoviesDataIntoTableView()
        
        tableView.dataSource = self
        tableView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // The next two methods are required by the UITableViewDataSource protocol
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as MovieCell
        let movie = movies![indexPath.row]
        let url = NSURL(string: movie.valueForKeyPath("posters.thumbnail") as String)
        
        cell.titleLabel.text = movie["title"] as? String
        cell.synopsisLabel.text = movie["synopsis"] as? String
        cell.posterView.setImageWithURL(url)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)!
        let movie = movies![indexPath.row]
        let movieDetailsViewController = segue.destinationViewController as MovieDetailsViewController
        movieDetailsViewController.movie = movie
    }
    
    func onRefresh() {
        // TODO: Add a 'finished' closure callback argument to loadMoviesDataIntoTableView.
        // Use it to call self.refreshControl.endRefreshing() only after the request completes
        
        // TODO: Also, should I maybe empty the table view first? Is that even possible?
        loadMoviesDataIntoTableView()
        self.refreshControl.endRefreshing()
    }
    
    private func loadMoviesDataIntoTableView() {
        // TODO: Make it not take up space unless it's visible
        networkErrorView.hidden = true
        
        let url = NSURL(string: "http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=dagqdghwaq3e3mxyrp7kmmj5&limit=20&country=US")!
        let request = NSURLRequest(URL: url)
        SVProgressHUD.showWithMaskType(SVProgressHUDMaskType.Black)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error:  NSError!) -> Void in
            SVProgressHUD.dismiss()
            
            if error != nil {
                self.networkErrorView.hidden = false
                return
            }
            
            let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? NSDictionary
            if let json = json {
                self.movies = json["movies"] as? [NSDictionary]
                self.tableView.reloadData()
            } else {
                println("JSON serialization failed")
            }
        }

    }

}
