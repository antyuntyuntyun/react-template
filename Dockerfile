ARG NODE_VERSION=16
FROM node:${NODE_VERSION}

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Tokyo
RUN echo $TZ > /etc/timezone

# workdir
ARG WORKDIR=/frontend
RUN mkdir -p ${WORKDIR}
# Give owner rights to the current user
RUN chown -Rh $USERNAME:$USERNAME ${WORKDIR}
WORKDIR ${WORKDIR}

# Or your actual UID, GID on Linux if not the default 1000
ARG USERNAME=developer
ARG USER_UID=1001
ARG USER_GID=$USER_UID
ENV HOME /home/$USERNAME

# change default shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN chsh -s /bin/bash

# Increase timeout for apt-get to 300 seconds
RUN /bin/echo -e "\n\
    Acquire::http::Timeout \"300\";\n\
    Acquire::ftp::Timeout \"300\";" >> /etc/apt/apt.conf.d/99timeout

# Configure apt and install packages
RUN rm -rf /var/lib/apt/lists/* \
    && apt-get update \
    && apt-get -y --no-install-recommends install sudo vim tzdata less graphviz 

# install gh
RUN wget https://github.com/cli/cli/releases/download/v1.0.0/gh_1.0.0_linux_amd64.deb
RUN dpkg -i gh_*_linux_amd64.deb
RUN chmod g+rwx -R /usr/local/bin/
RUN gh --version

# Create a non-root user to use if preferred - see https://aka.ms/vscode-remote/containers/non-root-user.
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    # Add sudo support for non-root user
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# terminal setting
RUN wget --progress=dot:giga https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -O /home/$USERNAME/.git-completion.bash \
    && wget --progress=dot:giga https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh -O /home/$USERNAME/.git-prompt.sh \
    && chmod a+x /home/$USERNAME/.git-completion.bash \
    && chmod a+x /home/$USERNAME/.git-prompt.sh \
    && echo -e "\n\
    source ~/.git-completion.bash\n\
    source ~/.git-prompt.sh\n\
    export PS1='\\[\\e]0;\\u@\\h: \\w\\a\\]\${debian_chroot:+(\$debian_chroot)}\\[\\033[01;32m\\]\\u\\[\\033[00m\\]:\\[\\033[01;34m\\]\\w\\[\\033[00m\\]\\[\\033[1;30m\\]\$(__git_ps1)\\[\\033[0m\\] \\$ '\n\
    export EDITOR=vim\n\
    " >>  /home/$USERNAME/.bashrc

# Remove outdated yarn from /opt and install via package
# so it can be easily updated via apt-get upgrade yarn
RUN rm -rf /opt/yarn-* /usr/local/bin/{yarn,yarnpkg} \
    && apt-get install -y curl apt-transport-https lsb-release \
    && curl -sS https://dl.yarnpkg.com/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/pubkey.gpg | apt-key add - 2>/dev/null \
    && echo "deb https://dl.yarnpkg.com/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update \
    && apt-get -y install --no-install-recommends yarn

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
ENV DEBIAN_FRONTEND=dialog

# node package install setup
RUN mkdir -p ${WORKDIR}/node_modules
RUN chown -Rh $USERNAME:$USERNAME ${WORKDIR}/node_modules

# Set the default user / npm package install
USER $USERNAME
COPY package.json ${WORKDIR}
COPY yarn.lock ${WORKDIR}
RUN yarn install