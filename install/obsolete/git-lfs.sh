
### SOME GIT LFS COMMANDS, INCOMPLETE
sudo apt-get update
sudo apt-get install -y python-software-properties
sudo apt-get install -y software-properties-common
sudo add-apt-repository ppa:git-core/ppa

sudo curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash 				# For linux: https://packagecloud.io/install/repositories/github/git-lfs/script.rpm.sh
sudo apt-get install -y git-lfs
sudo git lfs install

sudo wget https://github.com/Microsoft/Git-Credential-Manager-for-Mac-and-Linux/releases/download/git-credential-manager-2.0.0/git-credential-manager-2.0.0-1.noarch.rpm
sudo wget https://java.visualstudio.com/Content/RPM-GPG-KEY-olivida.txt
sudo apt-get install -y rpm
sudo rpm --import RPM-GPG-KEY-olivida.txt
sudo rpm --checksig --verbose git-credential-manager-2.0.0-1.noarch.rpm 
# sudo apt-get install alien
# sudo alien --install git-credential-manager-2.0.0-1.noarch.rpm
sudo rpm --install git-credential-manager-2.0.0-1.noarch.rpm --nodeps
sudo ln -s /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java /bin/java 	# Make sure the installer can find the java bin
sudo git-credential-manager install

# Add this to a passwd file: https://cvast:<personal access token>@cvastdevelopment.visualstudio.com/DefaultCollection/CVAST/_git/CVAST-Potree
PASSWD_FILE=<file path>
sudo git config --global credential.helper "store --file=${PASSWD_FILE}"

# Download the actual data
sudo git lfs pull