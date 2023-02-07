# use light base image for the python application
FROM python:3.7-slim

# create a new directory for the python application
WORKDIR /app

# We copy just the requirements.txt first to leverage Docker cache
COPY ./requirements.txt /app/requirements.txt

# install the requirements.txt
RUN pip install -r requirements.txt

# copy application code
COPY . /app

# move to application directory to be able to run the application
WORKDIR /app/src

# run the application
CMD ["flask" , "--app" , "hello.py" ,  "run" , "--host","0.0.0.0" ]