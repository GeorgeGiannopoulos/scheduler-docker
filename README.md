# Scheduler with Python and cron Dockerfile

A docker image has been designed to run scheduled jobs using cron utility.

**ASSUMPTION:** All the scheduled jobs are python based, so the docker image selected for this job is a `python` official image


## How it Works

- An `python` image is used

- An environmental variable named `PROJECT_HOME` is used to keep the path where all the projects will be reside inside the image

- Environmental variables named `CRON_XX` are used to keep the name of the directory of each scheduler inside the project home directory

- The `cron` utility is installed

- Also the `vim` utility is installed in case the cronjob configuration requires on-the-fly changes without the need of re-creating the image

- The `crontab` file with the schedule is copied to **cron.d** directory and is enabled

- Change working directory to where all the project will be reside

- Each project's python dependencies are copied to each project home directory

- Script that manage the schedule are copied to the image

- A script with alias that control the schedulers is added to the image

- A python virtual environmental is created for each project by the `environment.sh` script. This script creates a virtual environment inside each project's directory, and creates a parent script for each project that sources the project's virtual environment at each execution. The latter contains a lock mechanism to enable/disable the scheduler

- Each project's source code is copied inside the corresponding directory

- Placeholder for exporting ports exists in the `Dockerfile`

- Placeholder for mounting volumes exists in the `Dockerfile`

- `cron -f` is ran as the main process

## How to Configure

1. Select a `python` image version that matches the one used to develop the projects (replace `latest`)

2. Add each project to seperate directory and update `ENV` in `Dockerfile`

2. Add a text file named `requirements.txt` with all the project's python dependencies for one of them

## How to Use

Build Image

```shell
docker build -t scheduler:latest .
```

Run container
```shell
docker run -idt --name scheduler scheduler:latest
```

**NOTES:**

- An official python image is used. Use an `-alpine` version to reduce the size of the image, if needed

- Add to **.dockerignore** any directory/file that needs to be excluded from docker image to keep the image size as small as possible

## To add a new scheduler:

1. Create a new directory (e.g `project-3`) or clone a submodule there
2. The scheduler must have a main script that will be called from cron
3. The scheduler must have a `requirement.txt` file will all the dependencies, if any
4. Modify the `crontab` file by adding crontab lines there (see [crontab.guru](https://crontab.guru/))
5. Update dockerfile by:

- Adding a new environmental variable with the scheduler's parent directory `CRON_XXX='project-XXX'`
- Adding a COPY command to copy the `requirement.txt` of the project
- Adding a RUN command to run the `environment.sh` script in order to create a venv for the scheduler

6. Ignore any unnecessary files by adding them to .dockerignore to minimize docker image

## Control Crontab jobs

A docker alias has been created to `enable` or `disable` a scheduled cronjob

Lets assume that the crontab file contains the following lines:

```shell
0 * * * * /app/project-1/python /app/project-1/run.py -a argument.01 -b argument.02
0 * * * * /app/project-1/python /app/project-1/run.py -a argument.03 -b argument.04
```

This line is executed `at minute 0` of each hour, every day. Every line on the crontab file, contains a `task` which resides on a `directory`, like **project-1** that executes a script, like `run.py` which has some arguments, like `argument.01`

To `disable` this scheduled job, run:

```shell
docker exec -it scheduler cron-control disable -s project-1 -p run.py
```

To `enable` this scheduled job, run:

```shell
docker exec -it scheduler cron-control enable -s project-1 -p run.py
```

, where `-s` its scheduler's name (directory) and `-p` a pattern that corresponds to the script filename or one of the arguments

**NOTES:**

1. This script creates a .lock file in the parent directory of the project with the pattern as a name, for example **/app/project-1/run.py.lock** and the wrapper script that executes the cronjob exits if an argument matches the filename.

2. There could be more than one .lock file. For example the argument `-s project` is used that disables all the projects (current ones) along side the aforementioned one. So if one of the .lock files is deleted the other will continue to block the execution of the task.

3. In case the same script is been executed more than once, then use one of its argument, for example `argument.01` to enable/disable it
