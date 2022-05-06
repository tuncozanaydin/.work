FROM pytorch/pytorch:1.11.0-cuda11.3-cudnn8-runtime
     MAINTAINER Tunc Aydin <tuncozanaydin@gmail.com>

ARG uid=1000
ARG gid=985
ARG username=tunc

# WORKDIR /home/${username}/src
WORKDIR /install
RUN groupadd -g ${gid} ${username} 
RUN useradd -u ${uid} -g ${gid} ${username}
RUN usermod -aG sudo tunc
RUN yes 123 | passwd

# Install basic tools
RUN apt-get -y update --fix-missing
RUN apt-get -y install software-properties-common
RUN apt-get -y install git sudo nano curl
RUN git clone --single-branch --depth=1 https://github.com/emacs-mirror/emacs.git
RUN apt install -y autoconf make gcc texinfo libxpm-dev \
    libjpeg-dev libgif-dev libtiff-dev libpng-dev libgnutls28-dev \
    libncurses5-dev libjansson-dev libharfbuzz-dev
WORKDIR /install/emacs
RUN ./autogen.sh
RUN ./configure --with-json --with-modules --with-harfbuzz --with-compress-install \
            --with-threads --with-included-regex --with-zlib --with-cairo --without-rsvg\
            --without-sound --without-imagemagick  --without-toolkit-scroll-bars \
            --without-gpm --without-dbus --without-makeinfo --without-pop \
            --without-mailutils --without-gsettings --without-x-toolkit
RUN make -j$(nproc)
RUN make install-strip
RUN apt-get -y update
RUN rm -rf /install

# Install nodjs for pyright
RUN curl -sL https://deb.nodesource.com/setup_17.x | bash -
RUN apt-get install -y nodejs

WORKDIR /home/${username}/src
# Switch to user mode for various configurations
RUN chown -R tunc /home/tunc/
USER tunc

# Configure LSP
RUN pip install pyright
# RUN pip install -U setuptools
# RUN pip install pyls-flake8 pyls-mypy pyls-isort python-lsp-black pyls-memestra pylsp-rope
# RUN pip install 'python-lsp-server'

# Configure emacs
RUN git clone https://github.com/tuncozanaydin/.dotfiles.git /home/tunc/.dotfiles
RUN ln -s /home/tunc/.dotfiles/.emacs.d /home/tunc/
# RUN emacs --daemon -nw --kill

# Configure terminal
RUN tic -x -o /home/tunc/.terminfo /home/tunc/.dotfiles/.config/kitty/terminfo-24bit.src
ENV TERM=xterm-24bit
ENV PATH=$PATH:/home/tunc/.local/bin

# Setup tensorboard (remember to invoke container with -p 6006:6006)
RUN pip install tensorboard
RUN echo 'alias tensorboard="tensorboard --host 0.0.0.0"' >> ~/.bashrc

CMD /bin/bash
