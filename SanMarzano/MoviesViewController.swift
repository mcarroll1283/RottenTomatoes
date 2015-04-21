//
//  MoviesViewController.swift
//  SanMarzano
//
//  Created by Matthew Carroll on 4/14/15.
//  Copyright (c) 2015 blarg. All rights reserved.
//

import UIKit
// TODO:
// subclass UITableViewDataSource (a protocol)
// add required methods cellForRowAtIndexPath, numberOfRowsInSection

// Created prototype cell in storyboard, named it (reuse identifier) MovieCell

// Setting zero lines in label means 'wrap text'

// Don't name outlet variable for an image view 'imageView', or bad things happen?

// Embed MoviesView in a Navigation Controller (Editor menu)


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
        // XXX: another exclamation mark cast needed here? There's one in the video
        var cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as MovieCell
        // XXX: According to the video, this is safe because if the above method returned nonzero, then we have
        // a movie. I don't quite follow.
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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let cell = sender as UITableViewCell
        // XXX: More weirdo stuff here. In the video, the above line is this:
        // let cell = sender as! UITableViewCell
        // Why do I need these exclamations? Why doesn't as! work for me?
        // Why can't I find stuff on google about this?
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
                // XXX: Dangerous - will crash if JSON object doesn't have movies key
                self.movies = json["movies"] as? [NSDictionary]
                self.tableView.reloadData()
            } else {
                println("JSON serialization failed")
            }
        }

    }

}
