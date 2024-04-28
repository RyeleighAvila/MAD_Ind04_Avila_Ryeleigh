//
//  ViewController.swift
//  MAD_Ind04_Avila_Ryeleighh
//
//  Created by Ryeleigh Avila on 4/27/24.
//

import UIKit

struct State: Codable {
    let Names: String
    let Nicknames: String
    
    // Define CodingKeys to handle snake_case to camelCase conversion, I saw this as an example through w3schools
    private enum CodingKeys: String, CodingKey {
        case Names = "Names"
        case Nicknames = "Nicknames"
    }
}

class ViewController: UITableViewController {
    @IBOutlet weak var customTableView: UITableView! // Renamed IBOutlet variable to customTableView
    
    private let spinner = UIActivityIndicatorView(style: .medium) // Spinner for indicating loading (requirement)
    
    var states: [State] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Add spinner to the table view
        setupSpinner()
        
        // Fetching data from my URL
        fetchDataFromURL()
    }

    func setupSpinner() {
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        // Registering if UITableViewCell if necessary
        customTableView?.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    func fetchDataFromURL() {
        // Starting the spinner!
        spinner.startAnimating()
        
        guard let url = URL(string: "https://cs.okstate.edu/~ryavila/index.php") else {
            print("Invalid URL")
            spinner.stopAnimating() // Stop the spinner in case of an error
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                print("Error fetching data:", error)
                DispatchQueue.main.async {
                    self.spinner.stopAnimating() // Stop the spinner in case of an error
                }
                return
            }

            guard let data = data else {
                print("No data received")
                DispatchQueue.main.async {
                    self.spinner.stopAnimating() // Stop the spinner when no data is being received
                }
                return
            }

            // Parse the fetched data
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase // Handles snake_case to camelCase conversion which I found example in w3schools
                self.states = try decoder.decode([State].self, from: data)
                
                // Print the parsed data to verify
                print("Parsed Data:", self.states)

                // Update UI on the main thread
                DispatchQueue.main.async {
                    self.spinner.stopAnimating() // Stop the spinner when data fetching is completed
                    self.customTableView?.reloadData() // Reload table view to reflect changes
                }
            } catch {
                print("Error decoding JSON:", error)
                DispatchQueue.main.async {
                    self.spinner.stopAnimating() // Stop the spinner in case of an error
                }
            }
        }

        task.resume()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return states.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let state = states[indexPath.row]
        cell.textLabel?.text = "\(state.Names) - \(state.Nicknames)"
        return cell
    }
}
