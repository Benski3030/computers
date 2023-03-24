# Fetch ubuntu
FROM ubuntu:latest

# Install python on image
RUN apt-get update && apt-get install -y python3

# create a directory for the tests
RUN mkdir /tests

# Copy in our python test e 
COPY test.py /tests/test.py

# command that will be involved when the container starts
ENTRYPOINT [ "python3", "tests/test.py" ]

# note the default is $/bin/sh -c
