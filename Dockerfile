FROM python:3.9

ENV PROJECT_HOME=/app \
    CRON_1='project-1' \
    CRON_2='project-2'

# Install dependencies:
RUN apt-get update && \
    apt-get -y install cron vim && \
    apt-get clean
# Copy cron file to the cron.d directory:
COPY crontab /etc/cron.d/crontab
# Give execution rights on the cron job:
RUN chmod 0644 /etc/cron.d/crontab
# Apply cron job:
RUN /usr/bin/crontab /etc/cron.d/crontab

WORKDIR ${PROJECT_HOME}

# TODO: Add here all the requirements.txt:
COPY /schedulers/${CRON_1}/requirements.txt ${PROJECT_HOME}/${CRON_1}/requirements.txt
COPY /schedulers/${CRON_2}/requirements.txt ${PROJECT_HOME}/${CRON_2}/requirements.txt

# Prepare Python Environment:
COPY ./build/* /build/
RUN chmod 750 -R /build
# Add alias to enable / disable cron-jobs:
# NOTE: Run 'cron-control enable/disable'
RUN cp /build/cron-control /usr/bin/cron-control

# Install virtual environment per scheduler. Use seperate RUN commnands to catch errors per scheduler:
RUN /build/environment.sh -d ${PROJECT_HOME}/${CRON_1}
RUN /build/environment.sh -d ${PROJECT_HOME}/${CRON_2}

# Copy Schedulers code:
COPY /schedulers ${PROJECT_HOME}/

# Expose to the World:
# EXPOSE XXXX

# Ensure Persistence of Data:
# VOLUME ["/app/project-1/data", "/app/project-1/data"]

# Run the application:
CMD ["cron", "-f"]
