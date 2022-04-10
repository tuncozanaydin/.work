FROM pytorch/pytorch:1.11.0-cuda11.3-cudnn8-runtime
     MAINTAINER Tunc Aydin <tuncozanaydin@gmail.com>

ARG uid=1000
ARG gid=985
ARG username=tunc

WORKDIR /home/${username}/src
RUN groupadd -g ${gid} ${username} 
RUN useradd -u ${uid} -g ${gid} ${username}
RUN usermod -aG sudo tunc
RUN yes 123 | passwd

# Install basic tools
RUN apt-get -y update
RUN apt-get -y install software-properties-common
RUN add-apt-repository ppa:kelleyk/emacs
RUN apt-get -y update
RUN apt-get -y install emacs27 git shellcheck sudo nano 

# Switch to user mode for various configurations
RUN chown -R tunc /home/tunc/
USER tunc

# Configure emacs
RUN git clone https://github.com/tuncozanaydin/.dotfiles.git /home/tunc/.dotfiles
RUN ln -s /home/tunc/.dotfiles/.emacs.d /home/tunc/
RUN emacs --daemon

# Configure LSP
RUN pip install -U setuptools
RUN pip install pyls-flake8 pyls-mypy pyls-isort python-lsp-black pyls-memestra pylsp-rope
RUN pip install 'python-lsp-server[all]'

# Configure terminal
RUN tic -x -o /home/tunc/.terminfo /home/tunc/.dotfiles/.config/alacritty/terminfo-24bit.src
ENV TERM=xterm-24bit
ENV PATH=$PATH:/home/tunc/.local/bin

# Setup tensorboard (remember to invoke container with -p 6006:6006)
RUN pip install tensorboard
RUN echo 'alias tensorboard="tensorboard --host 0.0.0.0"' >> ~/.bashrc
