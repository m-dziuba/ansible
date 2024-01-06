FROM archlinux:latest
ARG TAGS
RUN useradd -ms /bin/bash mdziuba
RUN usermod -aG wheel mdziuba
RUN echo mdziuba:iski2kxx! | chpasswd
RUN echo root:iski2kxx! | chpasswd
RUN echo "mdziuba ALL=(ALL) NOPASSWD: ALL" | tee -a /etc/sudoers
RUN pacman -Sy && pacman -S --noconfirm git ansible curl which sudo && pacman -Syu --noconfirm 
USER mdziuba
WORKDIR /home/mdziuba
