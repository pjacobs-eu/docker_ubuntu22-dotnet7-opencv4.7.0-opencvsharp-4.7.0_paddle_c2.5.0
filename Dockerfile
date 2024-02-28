FROM amd64/buildpack-deps:bullseye-curl AS installer

WORKDIR /

ENV OPENCV_VERSION="4.7.0"
RUN apt-get update && apt-get install -y cmake g++ git libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev unzip wget \
    && wget https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip -O opencv-${OPENCV_VERSION}.zip \
	&& wget https://github.com/opencv/opencv_contrib/archive/${OPENCV_VERSION}.zip -O opencv_contrib-${OPENCV_VERSION}.zip \
	&& unzip opencv-${OPENCV_VERSION}.zip \
	&& unzip opencv_contrib-${OPENCV_VERSION}.zip \
	&& mkdir /opencv-${OPENCV_VERSION}/build \
	&& cd /opencv-${OPENCV_VERSION}/build \
	&& cmake -DCMAKE_INSTALL_PREFIX=/usr/local \
	-DOPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-${OPENCV_VERSION}/modules \
	-DCMAKE_BUILD_TYPE=RELEASE .. \
	&& make \
	&& make install \
	&& ldconfig \
	&& rm /opencv-${OPENCV_VERSION}.zip \
	&& rm /opencv_contrib-${OPENCV_VERSION}.zip \
	&& rm -r /opencv-${OPENCV_VERSION} \
	&& rm -r /opencv_contrib-${OPENCV_VERSION} \
	&& apt-get remove -y cmake git unzip wget g++ && apt-get autoremove -y \
	&& rm -rf /var/lib/apt/lists/*

ENV OPENCVSHARP_VERSION="4.7.0.20230114"
RUN apt-get update && apt-get install -y wget unzip cmake g++ libgdiplus \
    && wget https://github.com/shimat/opencvsharp/archive/${OPENCVSHARP_VERSION}.zip -O opencvsharp.zip \
    && unzip opencvsharp.zip \
    && cd opencvsharp-${OPENCVSHARP_VERSION}/src \
    && cmake . \
    && make \
    && make install \
    && rm -r /opencvsharp-${OPENCVSHARP_VERSION} \
    && rm /opencvsharp.zip \
    && apt-get remove -y cmake wget unzip g++ && apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/*

RUN wget -q https://paddle-inference-lib.bj.bcebos.com/2.5.0/cxx_c/Linux/CPU/gcc8.2_avx_mkl/paddle_inference_c.tgz && \
    tar -xzf /paddle_inference_c.tgz && \
    find /paddle_inference_c -mindepth 2 -name *.so* -print0 | xargs -0 -I {} mv {} /usr/lib && \
    ls /usr/lib/*.so* && \
    rm -rf /paddle_inference_c && \
    rm paddle_inference_c.tgz

# .NET 7 Base
FROM mcr.microsoft.com/dotnet/runtime:7.0 AS final
COPY --from=builder /usr/lib /usr/lib