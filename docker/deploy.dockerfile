# Use latest dart image
FROM alpine:latest AS build
ARG EXEC_DOWNLOAD_URL

WORKDIR /app
# Install dependencies.
RUN apk add --no-cache --update wget gzip tar ca-certificates curl bind-tools openssh-client gcompat

# Extract the executable archive.
COPY . .
RUN wget -O main.tar.gz $EXEC_DOWNLOAD_URL
RUN tar zxvf main.tar.gz

# Give execute permission to the executable.
RUN chmod +x bin/main

# https://github.com/gliderlabs/docker-alpine/issues/367#issuecomment-424546457
RUN [ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' > /etc/nsswitch.conf
# https://github.com/dart-lang/dart-docker/blob/e1ef8a01789e6e0b3dad6b471934199c2587a6ef/stable/bullseye/Dockerfile#L15
# Create a minimal runtime environment for executing AOT-compiled Dart code
# with the smallest possible image size.
# usage: COPY --from=dart:xxx /runtime/ /
# uses hard links here to save space
RUN set -eux; \
    case "$(apk --print-arch)" in \
        x86_64) \
            TRIPLET="x86_64-linux-gnu" ; \
            FILES="/lib64/ld-linux-x86-64.so.2" ;; \
        armhf) \
            TRIPLET="arm-linux-gnueabihf" ; \
            FILES="/lib/ld-linux-armhf.so.3 \
                /lib/arm-linux-gnueabihf/ld-linux-armhf.so.3";; \
        aarch64) \
            TRIPLET="aarch64-linux-gnu" ; \
            FILES="/lib/ld-linux-aarch64.so.1 \
                /lib/aarch64-linux-gnu/ld-linux-aarch64.so.1" ;; \
        *) \
            echo "Unsupported architecture" ; \
            exit 5;; \
    esac; \
    FILES="$FILES \
        /etc/nsswitch.conf \
        /etc/ssl/certs \
        /usr/share/ca-certificates \
        /lib/$TRIPLET/libc.so.6 \
        /lib/$TRIPLET/libdl.so.2 \
        /lib/$TRIPLET/libm.so.6 \
        /lib/$TRIPLET/libnss_dns.so.2 \
        /lib/$TRIPLET/libpthread.so.0 \
        /lib/$TRIPLET/libresolv.so.2 \
        /lib/$TRIPLET/librt.so.1"; \
    for f in $FILES; do \
        dir=$(dirname "$f"); \
        mkdir -p "/runtime$dir"; \
        cp --archive --link --dereference --no-target-directory "$f" "/runtime$f"; \
    done

# Copy the executable.
FROM scratch
COPY --from=build /runtime /
COPY --from=build /app/bin/main /app/bin/

# Start the program.
CMD ["/app/bin/main"]