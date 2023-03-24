# Docker Training

## Table of Contents
- [Docker Training](#docker-training)
  - [Table of Contents](#table-of-contents)
  - [Part One: Docker Basics](#part-one-docker-basics)
    - [1.1 What is Docker?](#11-what-is-docker)
    - [1.2 CI/CD](#12-cicd)
    - [1.3 How to Build a Simple Test Suite with Docker](#13-how-to-build-a-simple-test-suite-with-docker)
    - [1.4 Running Unit Tests with Docker](#14-running-unit-tests-with-docker)

## Part One: Docker Basics

### 1.1 What is Docker?

Before we look at running Docker, let’s examine why you might want to use it over a more traditional approach: virtual machines (VMs). The following diagram outlines the different software architectures of VMs versus Docker.

A virtual machine is a full OS that runs inside of a host operating system. To accomplish this, you must run a special program on your computer known as a “hypervisor.” The hypervisor is in charge of providing the necessary emulation to run a full OS inside of an application, including all of the necessary emulated hardware. This hardware emulation is often accomplished by connecting directly to your computer’s hardware. Resources, like memory, can be split into separate environments for the virtualized computer.

The guest OSes must provide their own set of hardware drivers that talk to the hypervisor’s virtualized hardware. From there, you can develop applications using any of the OS’s binaries and libraries as needed.

Docker, on the other hand, is extremely lightweight. It removes the need for a hypervisor program. Instead, it relies on the Docker Engine to provide the necessary virtualized drivers that connect to your host OS’s hardware. In most circumstances, containers will behave like full operating systems while relying on your host’s hardware drivers. However, you can run some standalone applications, such as Node, in a Docker container.

Without the full underlying OS and drivers, Docker containers are lightweight; they can boot quickly and run with little overhead. As a result, hundreds or thousands of Docker containers can be created and run efficiently on a single computer (e.g. a server). This is nearly impossible with virtual machines due to the required driver and resource overhead.

However, containers do not offer the same isolation (read: security) as virtual machines. Applications in Docker containers can access host OS resources, which can allow malicious attackers to more easily take control of the host OS (and other containers) on a system. It is up to you to implement good security practices on your containers and applications, as relying on the isolation of a virtualized OS will not help here.

### 1.2 CI/CD

Continuous integration and continuous delivery (CI/CD) is the process of automating the testing and deployment of a software project. While CI/CD practices might differ from organization to organization, here is what one basic workflow might look like.

In a workflow without CI/CD, you might write code, test it locally, push changes to a shared repository, go through quality assurance steps (i.e. building and running the full project), and deploy the changes to users.

CI/CD (sometimes you’ll see CT for “continuous testing” included in there) helps to automate this process. It’s often found in larger projects with multiple contributors. If you’re contributing code to this hypothetical project, you might perform some local testing and then push your changes (e.g. a GitHub pull request). This is where the CI/CD framework takes over.

This framework must be created in addition to the software you’re creating for your project. If you are using GitHub, this could be a GitHub Action that runs each time a new push or pull request is created.

The Action might fully build the project with your changes and then perform any tests, such as running the program with dummy inputs or performing unit tests on individual program components. This is considered the CI portion of the workflow: we have automated the integration and testing of new changes to the project.

Sometimes, you might want to push incremental changes to the application. This is often the case for cloud-based services or websites. For end-user software, you might push patches in chunks at scheduled intervals or for emergencies only. With incremental changes, you can automate the process of doing quality assurance (QA) checks and deploying the updated software to your target system. This is known as “continuous delivery” (CD) or sometimes “continuous deployment.”

Automating these processes helps software teams reduce testing and integration time, allowing them to focus on writing good software. It also encourages writing code in smaller, incremental steps rather than large, sweeping changes. This process helps identify bugs (especially bugs that only appear during integration testing) early and often, which means less time finding nasty, hidden bugs down the road.

While CI/CD is most often found in large-scale software projects, it still has its place in smaller or even embedded projects, where testing without real hardware can be difficult. However, even simply compiling your code can be a quick way to spot some bugs. We’ll walk through an example of creating a Docker image that compiles and runs a very simple C program to test its functionality.

### 1.3 How to Build a Simple Test Suite with Docker

You will need to install the Docker Desktop for this tutorial.

To start, we need to make a Dockerfile. This is a simple recipe that tells Docker how to build our image. Create a new directory somewhere on your computer. I’ll call mine “hello-docker.” In that folder, create a file named “Dockerfile” (note the capitalization and lack of extension). When we run the Docker build system, it will look for a Dockerfile in the given directory with that exact spelling.

Open that Dockerfile in a text editor of your choice. Enter the following:

```
# Fetch ubuntu image
FROM ubuntu:22.04

# Install Python on image
RUN \
    apt-get update && \
    apt-get install -y python3 && \
    apt-get install -y build-essential
    
# Create a directory for our tests
RUN mkdir /tests

# Copy in our Python script
COPY test.py /tests/test.py

# Copy in our program under test
COPY main.c /tests/main.c

# Command that will be invoked when container starts
ENTRYPOINT ["python3", "tests/test.py"]
```

This recipe tells Docker that we want to start with the official Ubuntu 22.04 image that can be downloaded from Docker Hub. From there, we’ll make a few modifications to that image, as can be seen in the RUN and COPY commands. Specifically, we want to update the aptitude package manager to the latest version, install Python 3, and install the build-essential package, which, among other things, includes gcc so we can compile our C program. Then, we create a directory in root (/tests) before copying our test.py and main.c code files into that directory. Finally, the entrypoint tells the image to run our test.py script as soon as it boots.

Next, we are going to create our test script that will compile and run our C program. This script can be written in any language you wish (so long as it runs on our Docker image). I will choose Python, as it’s what I’m familiar with, and I find it relatively easy to read. In the same directory as your Dockerfile, create a new file named “test.py.” In that file, enter the following:

```
import os, subprocess

# Settings
TEST_DIR = "/tests"         # Directory with our program
CODE_FILE = "main.c"        # Our C code
COMPILER_TIMEOUT = 10.0     # Compiler timeout (seconds)
RUN_TIMEOUT = 10.0          # Run timeout (seconds)

# Create absolute paths
code_path = os.path.join(TEST_DIR, CODE_FILE)
app_path = os.path.join(TEST_DIR, "app")

# Compile the program
print("Building...")
try:
        ret = subprocess.run(["gcc", code_path, "-o", app_path],
                                stdout=subprocess.PIPE,
                                stderr=subprocess.PIPE,
                                timeout=COMPILER_TIMEOUT)
except Exception as e:
    print("ERROR: Compilation failed.", str(e))
    exit(1)
    
# Parse output
output = ret.stdout.decode('utf-8')
print(output)- [Docker Training](#docker-training)
    - [Table of Contents](#table-of-contents)
  - [Part One: Docker Basics](#part-one-docker-basics)
    - [1.1 What is Docker?](#11-what-is-docker)
    - [1.2 CI/CD](#12-cicd)
    - [1.3 How to Build a Simple Test Suite with Docker](#13-how-to-build-a-simple-test-suite-with-docker)
    - [1.4 Running Unit Tests with Docker](#14-running-unit-tests-with-docker)

output = ret.stderr.decode('utf-8')
print(output)

# Check to see if the program compiled successfully
if ret.returncode != 0:
    print("Compilation failed.")
    exit(1)
    
# Run the compiled program
print("Running...")
try:
    ret = subprocess.run([app_path],
                            stdout=subprocess.PIPE,
                            timeout=RUN_TIMEOUT)
except Exception as e:
    print("ERROR: Runtime failed.", str(e))
    exit(1)
    
# Parse output
output = ret.stdout.decode('utf-8')
print("Output:", output)

# All tests passed! Exit gracefully
print("All tests passed!")
exit(0)
```

This script uses the “subprocess” package to run commands in the Linux OS. We call gcc to first compile our C program, then we run the program. Both times, we look at the OS return code and capture any output text printed to the console. If any step produces a failure (or exception), we immediately print the error to the console and exit (note the exit(1) for error and exit(0) for OK). 

Finally, we need to write our C program. This would be your program under test, such as a unit test for a part of your project or the whole project itself. We’re going to keep this very simple: the ubiquitous “hello, world” program. Create a new file named “main.c” in the same directory as the other two files. In that file, enter the following:

```
#include <stdio.h>

int main()
{
    printf("Hello from C!")
    
    return 0;
}
```
At this point, your directory should look like the following:

```
…/hello-docker
    |-- Dockerfile
    |-- main.c
    |-- test.p
```

### 1.4 Running Unit Tests with Docker

Open a new terminal on your host OS and navigate to your project directory. Enter the following to build the image:

```
cd <some-location>/hello-docker
docker build -t my-image .
```

The -t parameter allows us to tag (or name) the image. Also, note the ‘.’ at the end of the docker command: it tells Docker where to find the Dockerfile (the current directory in this case). You can read more about the docker build subcommand here.

You can think of an image as a factory that produces actual runtime environments (e.g. simple Ubuntu OS instances in our example). These instances are known as “containers.” Images don’t actually run; they just help create containers, which do the actual work. You can view the available images with:

`docker images`

 Now, we need to create a container from our image:

`docker create -i -t  --entrypoint="/bin/bash" --name my-container my-image`

 Here are what the parameters mean:

* i means “interactive mode,” which keeps the container running to allow for interactions.
* -t means “tty” to add a pseudo terminal for command line interactions with the container.
* --entrypoint overrides the entrypoint in the Dockerfile. We do this for this example so you can see how to log in to a container without running the test.py script.
* --name gives a name to the container. If you don’t specify a name, Docker will randomly assign a name by default.
* The only required parameter is the image name that we wish to create a container from (my-image in this case)

Learn more about the docker create subcommand here.

You can list all of the containers you have made with this command:

`docker container ls -a`

If you wish to copy a file from your host OS to a container, you can do that with the docker cp command.

Now, we start our container with the following:

`docker start -i my-container`

You should be presented with root access to your container. Feel free to explore your container. Take a look inside the /tests directory to make sure your test files were copied in.

When you are done, you can type the “exit” command to leave the container (which will also shut it down).

We can combine the “create” and “start” subcommands in the “run” subcommand. Let’s do that here:

`docker run --rm my-image`

Note the `--rm` flag that tells Docker to automatically delete the container when it’s done. Since we specified the entrypoint in our Dockerfile, this container will automatically run our test script, print any output to the console, and exit the container. We did not specify the `-i` or `-t` flags for an interactive console, as we do not care to interact with the container; we just want it to run our script and be done.

Hopefully, you saw the “All tests passed!” message.

Because we use `exit(0)` and `exit(1)` in our Python script, the Docker container will also return with the same exit code when it’s done. If you are on a Linux or macOS host, you can check this with the “echo $?” command to view the previous command’s return status. A ‘0’ means “OK” and anything else (e.g. ‘1’) means “error.” You can learn more about standard Linux exit codes here.

To remove a container (e.g. one named "my-container"), enter the following:

`docker rm my-container`

Once all of the containers associated with an image have been removed, you can remove the image with:

`docker rmi my-image`

Due to the modular and portable nature of our Docker image, we can deploy our test suite to nearly any computer. Some cloud services, like GitHub Actions, look at the return code from the Docker container to determine if the tests passed or failed. This simple example forms the basis for creating complex automated test suites for your CI/CD framework! 

Recommended Reading

Here is some good reading and watching material if you would like to learn more about Docker:

    Docker reference guide
    Official Docker getting started guide
    Official Docker getting started video
**