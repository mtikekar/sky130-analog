FROM archlinux:base-devel

RUN pacman -Syu --needed --noprogressbar --noconfirm git tigervnc xfce4
RUN echo "securitytypes=none,tlsnone" >> /etc/tigervnc/vncserver-config-defaults
# python3 is optionally needed to build magic but it is not included in PKGBUILD
# glu seems to be needed if magic is using opengl (not needed for cairo)
# For now, we're enabling both cairo and opengl.
# I have not properly checked if python3 and glu are really needed. In principle,
# both are optional dependencies, but magic does not run if one or both are missing.
RUN pacman -S --needed --noprogressbar --noconfirm python3 glu

ARG GUI_USER=analog
ARG GUI_PASSWD=analog
RUN useradd $GUI_USER --create-home --home-dir /home/$GUI_USER \
 && echo ${GUI_USER}:${GUI_PASSWD} | chpasswd \
 && echo "$GUI_USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER $GUI_USER
WORKDIR /home/$GUI_USER

RUN git clone https://aur.archlinux.org/yay-bin.git \
 && cd yay-bin \
 && makepkg -sirc --needed --noprogressbar --noconfirm

RUN yay -S --needed --noprogressbar --noconfirm magic-git ngspice xschem netgen-lvs-git

# docker build -t analog:latest .
# docker run -p 5901:5901 --rm -it --security-opt seccomp=unconfined analog:latest
# (in container) vncserver :1
# (in host) vncviewer :5901
