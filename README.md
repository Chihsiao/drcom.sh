English | [简体中文](README-zh_CN.md)

# drcom.sh

drcom.sh is for handling status checks and login for captive portals.

## How it works

1. **Redirect Detection**: The script attempts to access a test endpoint and checks for any HTTP redirects.
2. **Portal Prediction**: It iterates through available portal scripts to predict the correct portal type.
3. **Auto Login**: After prediction, it executes the login routine defined in the portal script.

## Requirements

- **bash**: Used to execute the script.
- **curl**: Used to make network requests and handle responses.
- **grep、sed、awk**: Used to filter, transform, and extract specific information.

## Installation

1. **Clone the repository**:

   ```bash
   git clone https://github.com/Chihsiao/drcom.sh.git
   cd drcom.sh
   ```

2. **Create your credential configuration**:

   Create a configuration file with your login credentials:

   ```bash
   cat <<EOF > your_username.conf
   export DRCOM_USER="your_username"
   export DRCOM_PASS="your_password"
   EOF
   ```

3. **Create portal types**

  To support new portal types, create a new script in the `portals` directory and implement the `predict` and `login` cases.

  <details>
  <summary>Example</summary>

  ```bash
  case "$1" in
    "predict")
      # Check drcom.sh for more variables and functions
      @match "$redirect_url" -E '^http://example\.com/login\b'
    ;;
    "login")
      _request -X POST "http://example.com/login" \
          --url-encoded "username=$DRCOM_USER" \
          --url-encoded "password=$DRCOM_PASS" \
          -o /dev/null
    ;;
  esac
  ```
  </details>

## Usage

Run the script with the desired command:

- **Check Status**:

  ```bash
  ./drcom.sh your_username.conf status
  ```

- **Login**:

  ```bash
  ./drcom.sh your_username.conf try_to_login
  ```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
