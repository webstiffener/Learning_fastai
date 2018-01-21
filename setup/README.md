Tips on setting up your computer for Fast.ai courses on both Windows and Ubuntu
===================================================

**>> LAST UPDATED JANUARY, 2018 <<**

**I strictly followed the fast.ai wiki installation guide, but didn't get it work, then I spent a lot of time on solving all kinds of problems and finally got it done. So I decide to write down what I did different, hoping that it might help someone to get through this pain in the ass process.**

# Windows 10

The wiki recommended [this guide](https://github.com/philferriere/dlwin), which is great and thorough. However, in order to make it work for the fast.ai courses a few things has to be changed.

1. Unzip the VS2015 installation file before install it, or you might get a "missing package" error or something like that, although you can solve it by copying the `packages` folder from the .zip file to the missing directory.

2. Install Anaconda with python2.7 as Fast.ai recommended, however install a python3.6 version is not a problem, just remember to use `conda create --yes -n python ==2.7 dlwin27` when you create deep learning environment.

3. Do rememer to `activate dlwin27` before installing any python packages, or you will install it to the main conda environment instead of dlwin27.

4. I changed some packages' version, because the guide's version didn't work for me , you should install like this `conda -y pygpu==0.7.5 theano==1.0.1 keras==1.2.2`. Also you might want to install the following packages before starting lesson 1.
```Shell
pip install matplotlib
pip install pandas
conda install -y PIL
pip install sklearn
conda install -y bcolz
conda install -c menpo ffmpeg
conda install -y h5py
```
5. If your `keras.json` file has a line like `"image_data_format": "channels_last"`, it could be that you installed a higher version keras like 2.0.5. Uninstall it use `conda uninstall keras==2.0.5` and install version 1.2.2, then change `keras.json` like this.
```json
{
    "floatx": "float32",
    "epsilon": 1e-07,
    "backend": "theano",
    "image_dim_ordering": "th"
}
```
6. In order to use cuDNN acceleration, you will need a GPU with compute capability higher than 3.0, otherwise it will ignore the cuDNN flag and use GPU only. Check your GPU's compute capability [here](https://developer.nvidia.com/cuda-gpus). 

7. Installing TensorFlow or CNTK is not necessary for Fast.ai courses.

8. Do validate your installation using `cpu_gpu_test.py` as suggested in the guide.

# Ubuntu 16.04 LTS

1. I have changed the original [install-gpu.sh](https://github.com/fastai/courses/blob/master/setup/install-gpu.sh) file to [install-gpu-ws.py](https://github.com/webstiffener/Learning_fastai/blob/master/setup/install-gpu-ws.sh), because it didn't work for me.

2. For some reason, the original script always installs CUDA-9.1, so I used `sudo apt-get -y install cuda-8.0` instead. I also add more system variables, see line 27~30 in [install-gpu-ws.py](https://github.com/webstiffener/Learning_fastai/blob/master/setup/install-gpu-ws.sh).

3. You will have to install the following python packages before starting lesson 1, pay attention to the package version.
```Shell
conda install -y pygpu==0.6.2 theano==0.9.0 keras==1.2.2 mkl-service==1.1.2 h5py==2.7.0
conda install -y matplotlib pandas
pip install sklearn
conda install -y bcolz
conda install -c menpo ffmpeg
```

4. My `.theanorc` file is a little different from the original script, use `use device = cpu` when you want to use the CPU mode.
```
[global]
device = cuda0
floatX = float32
dnn.enabled=False
gpuarray.preallocate=0.8

[cuda]
root = /usr/local/cuda-8.0/bin
```

5. Remember to install git using `sudo apt-get --assume-yes install git`, because the last part of the script will use git to clone the course repository.

6. **THE MOST IMPORTANT THING**. Notice that line 25 in `install-gpu-ws.py`should output something like following, or it means your nvidia drive is not properly installed.

![nvidia-smi](https://github.com/webstiffener/Learning_fastai/raw/master/setup/nvidia-smi.png)

To solve this problem you have to manually install the Nvidia drive. 
Firstly, remove cuda and the nvidia drive installed previously.

```Shell
sudo apt-get remove nvidia*
sudo apt-get autoremove
```

Secondly, download the Nvidia drive .run file suitable for your GPU from [here](http://www.nvidia.cn/Download/index.aspx), and remember where you put it. And then use the following code to block and backup the ubuntu default drive file `/lib/modules/4.10.0-42-generic/kernel/drivers/gpu/drm/nouveau/nouveau.ko`, notice you might have more than one `x.xx.x-xx-generic` folder, block them all. 

```Shell
sudo mv /lib/modules/4.10.0-42-generic/kernel/drivers/gpu/drm/nouveau/nouveau.ko /lib/modules/4.10.0-42-generic/kernel/drivers/gpu/drm/nouveau/nouveau.ko.org
```

Reboot and execute `lsmod | grep nouveau`, the default drive is successfully blocked if there is no output. Use `sudo /etc/init.d/lightdm stop` to enter system command mode, press Ctrl + Alt +F1 to login the system. (I use "root" as my login name and sudo password as my login password, and **DO NOT USE THE NUMBER KEYBOARD TO ENTER YOUR PASSWORD.**)
`cd` to where you download the drive .run file and run it.

```Shell
sudo ./NVIDIA-Linux-x86_64-375.20.run
```
When asked about `opengl-files` or `X configuration` or `nouveau check`, **CHOOSE NO**. Reboot and execute `nvidia-smi`, you should expect something like the above image.
Then download and install [CUDA 8.0.61](https://developer.nvidia.com/cuda-80-ga2-download-archive), after running the .run file you will have to read a super long text, just press ENTER until it gets 100%.

![download CUDA-8.0.61](https://github.com/webstiffener/Learning_fastai/raw/master/setup/download%20cuda-8.0.61.png)

Choose like following and contitue the rest steps.
```
Description

This package includes over 100+ CUDA examples that demonstrate
various CUDA programming principles, and efficient CUDA
implementation of algorithms in specific application domains.
The NVIDIA CUDA Samples License Agreement is available in
Do you accept the previously read EULA?
accept/decline/quit: accept

Install NVIDIA Accelerated Graphics Driver for Linux-x86_64 367.48?
(y)es/(n)o/(q)uit: n

Install the CUDA 8.0 Toolkit?
(y)es/(n)o/(q)uit: y

Enter Toolkit Location
 [ default is /usr/local/cuda-8.0 ]:

Do you want to install a symbolic link at /usr/local/cuda?
(y)es/(n)o/(q)uit: y

Install the CUDA 8.0 Samples?
(y)es/(n)o/(q)uit: y

Enter CUDA Samples Location
 [ default is /home/c302 ]:

Installing the CUDA Toolkit in /usr/local/cuda-8.0 ...
Installing the CUDA Samples in /home/c302 ...
Copying samples to /home/c302/NVIDIA_CUDA-8.0_Samples now...
Finished copying samples.
```

Last advice, be patient. I am only a rookie coder and I made it, so will you, much serious challenges are waiting for us. The [Forum](http://forums.fast.ai/) and website like Stackoverflow are excellent places to look for help, and fixing problems is the best learning process.

Good luck.




