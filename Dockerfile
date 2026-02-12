FROM nixos/nix:2.33.2

RUN echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf && \
    nix-shell -p busybox --run "addgroup -g 1000 kang && adduser -u 1000 -G kang -D kang" && \
    chown -R kang:kang /nix && \
    mkdir -p /home/kang/nixEnvironment && \
    chown -R kang:kang /home/kang
USER kang
ENV HOME /home/kang
ENV USER kang
WORKDIR /home/kang/nixEnvironment
COPY --chown=kang:kang ./flake.lock ./
COPY --chown=kang:kang ./linux_desktop ./linux_desktop
COPY --chown=kang:kang ./standalone ./standalone
COPY --chown=kang:kang ./common ./common
COPY --chown=kang:kang ./flake.nix ./

RUN nix build .#kang-homemanager

WORKDIR /home/kang/

USER root
RUN mkdir /etc/dbus-1
COPY --chown=root:root ./session.conf /etc/dbus-1/session.conf
USER kang

RUN ./nixEnvironment/result/activate && env | grep -Eiv 'hostname|container|path|lang' > .env.000_default && mkdir -p /tmp/dbus-1-session
ENV PATH $PATH:/home/kang/.nix-profile/bin
ENV SHELL /home/kang/.nix-profile/bin/zsh
ENV XDG_RUNTIME_DIR /tmp/dbus-1-session
ENV LANG=en_US.UTF-8

CMD [ "sh", "-c", "./nixEnvironment/result/activate && dbus-run-session -- sh -c 'dbus-launch > .env.dbus && ./swayvnc.sh'" ]
