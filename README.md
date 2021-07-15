# WIP: Murcure

<!-- ABOUT THE PROJECT -->
## About The Project

Mumble server written in Crystal. Started for learning purposes.

<!-- GETTING STARTED -->
## Getting Started
### Prerequisites

* [Install Crystal](https://crystal-lang.org/install/)

### Installation

1. Clone the repo.
   ```sh
   git clone https://github.com/Odebe/murcure && cd murcure
   ```
2. Install dependencies.
    ```sh
    shards install
    ```
3. Build app.
    ```sh
    shards build --release --ignore-crystal-version
    ```
4. Place binary wherever you want to. (`run/` in our case).
    ```sh
    cp bin/murcure run/
    ```
5. Copy example config.
    ```sh
    cp run/config.example.yml run/config.yml
    ```

<!-- CONFIGURATION -->
## Configuration
Murcure expects config fine in one of these paths: 
1. `/etc/murcure/config.yml` (has highter priority)
2. `./config.yml`

Example config file is in `./run/config.example.yml`.

<!-- USAGE EXAMPLES -->
## Usage
Just run binary.
```
Usage: murcure
    -v, --version                    Show version
    -h, --help                       Show this help
```

<!-- CONTRIBUTING -->
## Contributing
I developing this project for learning purposes so at current time I dont want PRs.
**BUT** feel free to open issues if you want to share experience or discuss realization mistakes.

<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE` for more information.

<!-- CONTACT -->
## Contact

Mihail "Odebe" - [@telegram](https://t.me/Odebe)

Project Link: [https://github.com/Odebe/murcure](https://github.com/Odebe/murcure)
