FROM sd-kvm

RUN apt-get update && apt-get install -y curl cpio && apt-get clean
COPY kvmbootstrap preseed.cfg /

ENV DOCKERTIPS3_PRESEED /preseed.cfg
