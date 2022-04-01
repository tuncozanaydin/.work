FROM pytorch/pytorch:1.11.0-cuda11.3-cudnn8-runtime
     MAINTAINER Tunc Aydin <tuncozanaydin@gmail.com>

WORKDIR /home/tunc/app
# RUN groupadd -g $(id -g) staff
RUN useradd -u 501 -g 20 tunc
RUN usermod -aG sudo tunc
RUN yes 123 | passwd

RUN apt-get -y update
RUN apt-get -y install software-properties-common
RUN add-apt-repository ppa:kelleyk/emacs
RUN apt-get -y update
RUN apt-get -y install emacs27 git shellcheck sudo nano
RUN chown -R tunc /home/tunc/
USER tunc
RUN git clone https://github.com/tuncozanaydin/.dotfiles.git /home/tunc/.dotfiles
RUN ln -s /home/tunc/.dotfiles/.emacs.d /home/tunc/
RUN emacs --daemon
RUN tic -x -o /home/tunc/.terminfo /home/tunc/.dotfiles/.config/alacritty/terminfo-24bit.src
ENV TERM=xterm-24bit
RUN pip install 'python-lsp-server[all]'
RUN pip install -U setuptools
ENV PATH=$PATH:/home/tunc/.local/bin

