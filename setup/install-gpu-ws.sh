# This script is designed to work with ubuntu 16.04 LTS

# ensure system is updated and has basic build tools
sudo apt-get update
sudo apt-get --assume-yes upgrade
sudo apt-get --assume-yes install tmux build-essential gcc g++ make binutils
sudo apt-get --assume-yes install software-properties-common
sudo apt-get --assume-yes install git


# download CUDA 8.0.61, Anaconda2-4.4.0, cuDNN v5.1 
# you can comment the 3 wget lines and mannually download these 3 file to downloads folder
mkdir downloads
cd downloads
wget "http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/cuda-repo-ubuntu1604_8.0.61-1_amd64.deb" -O "cuda-repo-ubuntu1604_8.0.61-1_amd64.deb"
wget "https://repo.continuum.io/archive/Anaconda2-4.4.0-Linux-x86_64.sh" -O "Anaconda2-4.4.0-Linux-x86_64.sh"
wget "http://files.fast.ai/files/cudnn-8.0-linux-x64-v5.1.tgz" -O "cudnn.tgz"


# install CUDA8.0.61 and cuBLAS Patch Update
sudo dpkg -i cuda-repo-ubuntu1604_8.0.61-1_amd64.deb
sudo apt-get update
sudo apt-get -y install cuda-8.0
sudo modprobe nvidia
nvidia-smi

echo "export PATH=\"/usr/local/cuda-8.0/bin:\$PATH\"" >> ~/.bashrc
echo "export LD_LIBRARY_PATH=\"/usr/local/cuda/include:/usr/local/cuda/lib:/usr/local/cuda/lib64:\$LD_LIBRARY_PATH\"" >> ~/.bashrc
export PATH="/usr/local/cuda-8.0/bin:$PATH"
export LD_LIBRARY_PATH="/usr/local/cuda/include:/usr/local/cuda/lib:/usr/local/cuda/lib64:$LD_LIBRARY_PATH"


# install Anaconda for current user
bash "Anaconda2-4.4.0-Linux-x86_64.sh" -b

echo "export PATH=\"$HOME/anaconda2/bin:\$PATH\"" >> ~/.bashrc
export PATH="$HOME/anaconda2/bin:$PATH"


# install cudnn libraries
tar -zxf cudnn.tgz
cd cuda
sudo cp lib64/* /usr/local/cuda/lib64/
sudo cp include/* /usr/local/cuda/include/


# install neccessary python packages
conda install -y pygpu==0.6.2 theano==0.9.0 keras==1.2.2 mkl-service==1.1.2 h5py==2.7.0
conda install -y matplotlib pandas
pip install sklearn
conda install -y bcolz
conda install -c menpo ffmpeg


# configure theano and keras
echo "[global]
device = cuda0
floatX = float32
dnn.enabled=False
gpuarray.preallocate=0.8

[cuda]
root = /usr/local/cuda-8.0/bin" > ~/.theanorc

mkdir ~/.keras
echo '{
    "image_dim_ordering": "th",
    "epsilon": 1e-07,
    "floatx": "float32",
    "backend": "theano"
}' > ~/.keras/keras.json


# configure jupyter and prompt for password
jupyter notebook --generate-config
jupass=`python -c "from notebook.auth import passwd; print(passwd())"`
echo "c.NotebookApp.password = u'"$jupass"'" >> $HOME/.jupyter/jupyter_notebook_config.py
echo "c.NotebookApp.ip = '*'
c.NotebookApp.open_browser = False" >> $HOME/.jupyter/jupyter_notebook_config.py


# clone the fast.ai course repo and prompt to start notebook
cd ~
git clone https://github.com/fastai/courses.git
echo "\"jupyter notebook\" will start Jupyter on port 8888"
echo "If you get an error instead, try restarting your session so your $PATH is updated"
