//
//  ViewController.swift
//  Project7
//
//  Created by Enrique Casas on 9/20/21.
//

import UIKit

class ViewController: UITableViewController {
    
    var petitions = [Petition]()
    var filteredPetitions = [Petition]()
    var newFilter = [Petition]()
    var tempArray = [Petition]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(submitFilter))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(showCredits))
        
        let urlString: String
        if navigationController?.tabBarItem.tag == 0 {
           // urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
           urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
           // urlString = "https://api.whitehouse.gov/v1/petition.json?signatureCountFloor=10000&limit=100"
           urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
        
        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                parse(json: data)
                return
            }
        }
        showError()
    }
    
    func parse (json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            newFilter = petitions
            //print(petitions[0].title)
            //print(petitions.count)
            //print(jsonPetitions.results)
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newFilter.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:
       "Cell", for: indexPath)
        let petition = newFilter[indexPath.row]
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = newFilter[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showError() {
        let ac = UIAlertController(title: "Loading Error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present(ac, animated: true)
    }
    
    @objc func showCredits() {
        let vc = UIAlertController(title: "Credits", message: "Data comes from White House petitions", preferredStyle: .actionSheet)
        vc.addAction(UIAlertAction(title: "Close", style: .cancel))
        present(vc, animated: true)
    }
    
    //This serves more as a function that submits the user's input for filtering
    @objc func submitFilter() {
        let ac = UIAlertController(title: "Search", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] action in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
            }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
        }
    
    func submit(_ answer: String) {
        
        let urlString: String
        if navigationController?.tabBarItem.tag == 0 {
           // urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
           urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
           // urlString = "https://api.whitehouse.gov/v1/petition.json?signatureCountFloor=10000&limit=100"
           urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
        
        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                filterParse(json: data, search: answer)
            } else {
                showError()
            }
        } else {
            showError()
        }
        
        
    }
    
    //this function decodes the JSON and then does the actual filtering of the list by comparing the user-submitted string with the different petitions
    func filterParse (json: Data, search: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            let decoder = JSONDecoder()
            
            if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
                self.filteredPetitions = jsonPetitions.results
                //print(petitions.count)
                let lowerSearch = search.lowercased()
                
                for i in 0...99 {
                    if self.filteredPetitions[i].body.lowercased().contains(lowerSearch) {
                        self.tempArray.append(self.filteredPetitions[i])
                        //print(filteredPetitions[i])
                    } else {
    //                    filteredPetitions.remove(at: i)
                    }
                }
                self.newFilter = self.tempArray
                print(self.newFilter.count)
            }
        }
//        let decoder = JSONDecoder()
//
//        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
//            filteredPetitions = jsonPetitions.results
//            //print(petitions.count)
//            let lowerSearch = search.lowercased()
//
//            for i in 0...99 {
//                if filteredPetitions[i].body.lowercased().contains(lowerSearch) {
//                    tempArray.append(filteredPetitions[i])
//                    //print(filteredPetitions[i])
//                } else {
////                    filteredPetitions.remove(at: i)
//                }
//            }
//            newFilter = tempArray
//            print(newFilter.count)
            tableView.reloadData()
    }
}

