FROM registry.access.redhat.com/ubi8 

# Install build dependencies
RUN dnf -y update && \
        dnf -y install \
	bash\
	rust\
	gcc gcc-c++\
	clang\
	go\
	docker\
	git\
	curl\
	wget\
	gdb\
	tar gzip xz\
	openssl-devel zlib-devel\
	ncurses-devel && \
    dnf clean all

#zoxide, bat, docker_compose, fd, fzf, htop ,tmux

# --- Install zsh 5.8 ---
RUN wget https://sourceforge.net/projects/zsh/files/zsh/5.8/zsh-5.8.tar.xz && \
    tar -xf zsh-5.8.tar.xz && \
    cd zsh-5.8 && \
    ./configure --prefix=/usr/local --without-tcsetpgrp && \
    make && make install && \
    cd .. && rm -rf zsh-5.8 zsh-5.8.tar.xz

# --- Install make 4.4.1 ---
RUN curl -LO https://ftp.gnu.org/gnu/make/make-4.4.1.tar.gz && \
    tar -xzf make-4.4.1.tar.gz && \
    cd make-4.4.1 && \
    ./configure --prefix=/usr/local && \
    make -j$(nproc) && \
    make install && \
    cd .. && rm -rf make-4.4.1 make-4.4.1.tar.gz && \
    make --version

# --- Install CMake 3.27.2 ---
ENV CMAKE_VERSION=3.27.2

RUN mkdir -p /opt/cmake
RUN wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-x86_64.sh && \
    chmod +x cmake-${CMAKE_VERSION}-linux-x86_64.sh && \
    ./cmake-${CMAKE_VERSION}-linux-x86_64.sh --skip-license --prefix=/opt/cmake && \
    ln -s /opt/cmake/bin/* /usr/local/bin/ && \
    rm cmake-${CMAKE_VERSION}-linux-x86_64.sh

# --- Install golangci_lint 1.64.5 ---
ENV GOLANGCI_LINT_VERSION=v1.64.5
RUN curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | \
    sh -s -- -b /usr/local/bin ${GOLANGCI_LINT_VERSION} && \
    ls -lh /usr/local/bin/golangci-lint && \
    golangci-lint --version

COPY . /app

WORKDIR /app

CMD ["/bin/bash"]
