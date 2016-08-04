FROM sunside/trusty-libuv:1.9.1

ENV MONO_VERSION 4.4.1.0

RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF \
    && apt-get update && apt-get install -y apt-transport-https \
	&& echo "deb http://download.mono-project.com/repo/debian wheezy/snapshots/$MONO_VERSION main" > /etc/apt/sources.list.d/mono-wheezy.list \
    && echo "deb [arch=amd64] https://apt-mo.trafficmanager.net/repos/dotnet/ trusty main" > /etc/apt/sources.list.d/dotnetdev.list \
    && apt-key adv --keyserver apt-mo.trafficmanager.net --recv-keys 417A0893 \
	&& apt-get update \
	&& apt-get install -y \
        mono-devel \
        ca-certificates-mono \
        dotnet-dev-1.0.0-preview2-003121 \
        # fix for https://github.com/dotnet/core/issues/227
        dotnet-hostfxr-1.0.2

# fix for https://github.com/aspnet/KestrelHttpServer/issues/963, https://github.com/OmniSharp/omnisharp-roslyn/issues/600
RUN apt-get install -y \
        build-essential \
        g++ \
        git \
    && cd /tmp \
    && git clone https://github.com/borgdylan/corefx.git \
    && cd corefx/src/Native/System.Native/ \
    && git checkout sysnative_standalone2 \
    && make \
    && make install \
    && cd /tmp \
    && rm -rf corefx \
    && apt-get -y purge \
        build-essential \
        g++ \
        git \
        apt-transport-https
    && mozroots --import --sync

RUN apt-get -y autoremove \
	&& apt-get -y clean \
	&& rm -rf /var/lib/apt/lists/*

# Workaround for https://github.com/dotnet/cli/issues/1582, Bug only appears in Docker < 1.11.0
ENV LTTNG_UST_REGISTER_TIMEOUT -1

RUN cd /tmp \
    && mkdir warmup \
    && cd warmup \
    && dotnet new \
    && cd /tmp \
    && rm -rf warmup
