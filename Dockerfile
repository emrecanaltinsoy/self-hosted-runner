# base image
FROM ubuntu:24.04

#input GitHub runner version argument
ARG RUNNER_VERSION
ENV DEBIAN_FRONTEND=noninteractive

LABEL Author="Emrecan Altinsoy"
LABEL Email="emrecanaltinsoy@gmail.com"
LABEL GitHub="https://github.com/emrecanaltinsoy"
LABEL BaseImage="ubuntu:20.04"
LABEL RunnerVersion=${RUNNER_VERSION}

# update the base packages + add a non-sudo user
RUN apt-get update -y && apt-get upgrade -y && useradd -m docker

# install the packages and dependencies along with jq so we can parse JSON (add additional packages as necessary)
RUN apt-get install -y --no-install-recommends \
    curl nodejs wget unzip vim git jq build-essential lsb-release libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip

# Symlink python to python3
RUN ln -s /usr/bin/python3 /usr/bin/python
# ln -s /usr/bin/pip3 /usr/bin/pip

# cd into the user directory, download and unzip the github actions runner
RUN cd /home/docker && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# install some additional dependencies
RUN chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh

# Install AWS cli
RUN cd /home/docker \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install

# add over the entrypoint.sh script
ADD scripts/entrypoint.sh entrypoint.sh

# make the script executable
RUN chmod 777 entrypoint.sh

# set the user to "docker" so all subsequent commands are run as the docker user
USER docker

# set the entrypoint to the entrypoint.sh script
ENTRYPOINT ["./entrypoint.sh"]
